import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:intl/intl.dart';

import 'package:tri_go/constants.dart';
import 'package:tri_go/widgets/trip_card.dart';
import 'package:tri_go/widgets/destination_card.dart'; 
import 'package:tri_go/models/trip.dart';

import 'package:tri_go/screens/create_trip/create_trip_screen.dart';
import 'package:tri_go/screens/profile/profile_screen.dart'; 
import 'package:tri_go/screens/trip/TripDetailScreen.dart';
import 'package:tri_go/screens/explore/explore_screen.dart'; 
import 'package:tri_go/screens/trip/AllTripsScreen.dart'; 

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final User? currentUser = FirebaseAuth.instance.currentUser;
  String _displayName = "Người dùng";
  String _avatarPath = "";

  @override
  void initState() {
    super.initState();
    _listenToUserData();
  }

  void _listenToUserData() {
    if (currentUser != null) {
      DatabaseReference userRef = FirebaseDatabase.instance.ref('users/${currentUser!.uid}');
      userRef.onValue.listen((event) {
        if (event.snapshot.value != null && mounted) {
          final data = event.snapshot.value as Map<dynamic, dynamic>;
          setState(() {
            _displayName = data['displayName'] ?? currentUser?.email?.split('@')[0] ?? "Người dùng";
            _avatarPath = data['avatar'] ?? "";
          });
        }
      });
    }
  }

  // --- HÀM MỚI: HIỂN THỊ DIALOG CHẤP NHẬN LỜI MỜI ---
  void _showAcceptDialog(String tripId, String tripTitle) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Lời mời tham gia', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold, color: AppColors.primary)),
        content: Text('Bạn được mời tham gia chuyến đi "$tripTitle". Bạn có muốn tham gia chia sẻ hành trình này không?', style: GoogleFonts.plusJakartaSans()),
        actions: [
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await FirebaseDatabase.instance.ref('trips/$tripId/pendingMembers/${currentUser!.uid}').remove();
            }, 
            child: const Text('Từ chối', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold))
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
            onPressed: () async {
              Navigator.pop(context);
              await FirebaseDatabase.instance.ref('trips/$tripId/pendingMembers/${currentUser!.uid}').remove();
              await FirebaseDatabase.instance.ref('trips/$tripId/members/${currentUser!.uid}').set(true);
              if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Đã tham gia chuyến đi!'), backgroundColor: Colors.green));
            }, 
            child: const Text('Chấp nhận', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))
          )
        ]
      )
    );
  }

  String _formatCurrency(double amount) => NumberFormat.currency(locale: 'vi_VN', symbol: 'đ').format(amount);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const CreateTripScreen())),
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add, color: Colors.white, size: 28),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 80), 
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Chào buổi sáng,', style: GoogleFonts.plusJakartaSans(fontSize: 14, color: Colors.grey)),
                        Text(_displayName, style: GoogleFonts.plusJakartaSans(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.textDark)),
                      ],
                    ),
                    GestureDetector(
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const ProfileScreen())),
                      child: Container(
                        padding: const EdgeInsets.all(3),
                        decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: AppColors.primary.withValues(alpha: 77), width: 2)),
                        child: CircleAvatar(
                          radius: 22, backgroundColor: Colors.blue.shade50,
                          backgroundImage: _avatarPath.isNotEmpty ? FileImage(File(_avatarPath)) : null,
                          child: _avatarPath.isEmpty ? Text(_displayName[0].toUpperCase(), style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blue)) : null,
                        ),
                      ),
                    )
                  ],
                ),
              ),

              _buildSectionHeader('Địa điểm nổi bật', 'Khám phá', onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const ExploreScreen()))),
              
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const CreateTripScreen(initialDestination: 'Vịnh Hạ Long'))),
                      child: const DestinationCard(title: 'Vịnh Hạ Long', location: 'Quảng Ninh', description: 'Kỳ quan thiên nhiên thế giới.', imageUrl: 'https://picsum.photos/id/1015/800/600'),
                    ),
                    GestureDetector(
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const CreateTripScreen(initialDestination: 'Đà Lạt'))),
                      child: const DestinationCard(title: 'Đà Lạt', location: 'Lâm Đồng', description: 'Thành phố ngàn hoa.', imageUrl: 'assets/images/da_lat.webp'),
                    ),
                    GestureDetector(
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const CreateTripScreen(initialDestination: 'Phú Quốc'))),
                      child: const DestinationCard(title: 'Phú Quốc', location: 'Kiên Giang', description: 'Thiên đường nghỉ dưỡng.', imageUrl: 'assets/images/phu_quoc.webp'),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 10),

              _buildSectionHeader('Chuyến đi của bạn', 'Xem tất cả', onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const AllTripsScreen()))),
              
              SizedBox(
                height: 280, 
                child: StreamBuilder(
                  stream: FirebaseDatabase.instance.ref('trips').onValue,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
                    if (!snapshot.hasData || snapshot.data!.snapshot.value == null) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.flight_takeoff, size: 50, color: Colors.grey.shade300),
                            const SizedBox(height: 10),
                            Text('Chưa có chuyến đi nào.\nHãy tạo hoặc chờ được mời nhé!', textAlign: TextAlign.center, style: GoogleFonts.plusJakartaSans(color: Colors.grey)),
                          ],
                        ),
                      );
                    }
                    
                    final data = snapshot.data!.snapshot.value as Map<dynamic, dynamic>;
                    List<Map<dynamic, dynamic>> rawTrips = [];
                    
                    data.forEach((key, value) {
                      final tripData = value as Map<dynamic, dynamic>;
                      
                      bool isCreator = tripData['createdBy'] == currentUser?.uid;
                      bool isMember = tripData['members'] != null && tripData['members'][currentUser!.uid] != null;
                      bool isPending = tripData['pendingMembers'] != null && tripData['pendingMembers'][currentUser!.uid] != null;
                      
                      // Hiển thị nếu là chủ, là thành viên, hoặc đang trong danh sách chờ
                      if (isCreator || isMember || isPending) {
                        DateTime? endDate = DateTime.tryParse(tripData['endDate'] ?? '');
                        
                        bool isFinished = endDate != null && DateTime.now().isAfter(endDate.add(const Duration(days: 1)));
                        bool isReviewed = false;
                        
                        if (currentUser != null && tripData['reviewedBy'] != null && tripData['reviewedBy'][currentUser!.uid] == true) {
                          isReviewed = true;
                        }
                        
                        if (!(isFinished && isReviewed)) {
                          rawTrips.add({'key': key, ...tripData});
                        }
                      }
                    });

                    if (rawTrips.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.check_circle_outline, size: 50, color: Colors.green),
                            const SizedBox(height: 10),
                            Text('Chưa có chuyến đi nào đang diễn ra!', textAlign: TextAlign.center, style: GoogleFonts.plusJakartaSans(color: Colors.grey)),
                          ],
                        ),
                      );
                    }

                    rawTrips.sort((a, b) => (b['createdAt'] ?? 0).compareTo(a['createdAt'] ?? 0));

                    return ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: rawTrips.length,
                      itemBuilder: (context, index) {
                        final tData = rawTrips[index];
                        
                        final trip = Trip(
                          id: tData['id'] ?? tData['key'],
                          title: tData['title'] ?? 'Chuyến đi mới',
                          destinationName: tData['destinationName'] ?? 'Chưa rõ',
                          imageUrl: tData['imageUrl'] ?? 'https://picsum.photos/800/600',
                          startDate: DateTime.tryParse(tData['startDate'] ?? '') ?? DateTime.now(),
                          endDate: DateTime.tryParse(tData['endDate'] ?? '') ?? DateTime.now().add(const Duration(days: 1)),
                          budgetLimit: (tData['budgetLimit'] ?? 0).toDouble(),
                        );

                        bool isThisCardPending = tData['pendingMembers'] != null && tData['pendingMembers'][currentUser!.uid] != null;

                        return GestureDetector(
                          onTap: () {
                            if (isThisCardPending) {
                              _showAcceptDialog(trip.id, trip.title);
                            } else {
                              Navigator.push(context, MaterialPageRoute(builder: (context) => TripDetailScreen(trip: trip)));
                            }
                          },
                          child: Stack(
                            children: [
                              Container(width: 320, margin: const EdgeInsets.only(right: 16), child: TripCard(trip: trip)),
                              
                              if (isThisCardPending)
                                Positioned(
                                  top: 10, right: 26, 
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                    decoration: BoxDecoration(color: Colors.orange, borderRadius: BorderRadius.circular(20), boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 4)]),
                                    child: const Text('Có lời mời!', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12))
                                  )
                                )
                            ]
                          )
                        );
                      },
                    );
                  },
                ),
              ),

              const SizedBox(height: 10),

              Padding(
                padding: const EdgeInsets.fromLTRB(16, 20, 16, 12),
                child: Text('Giao dịch gần đây', style: GoogleFonts.plusJakartaSans(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textDark)),
              ),
              
              if (currentUser != null)
                StreamBuilder(
                  stream: FirebaseDatabase.instance.ref('users/${currentUser!.uid}/transactions').orderByChild('timestamp').limitToLast(5).onValue,
                  builder: (context, snapshot) {
                    if (!snapshot.hasData || snapshot.data!.snapshot.value == null) {
                      return Padding(padding: const EdgeInsets.all(20), child: Center(child: Text('Chưa có giao dịch nào.', style: GoogleFonts.plusJakartaSans(color: Colors.grey))));
                    }
                    final data = snapshot.data!.snapshot.value as Map<dynamic, dynamic>;
                    List<Map<dynamic, dynamic>> txList = [];
                    data.forEach((key, value) => txList.add(value));
                    txList.sort((a, b) => (b['timestamp'] ?? 0).compareTo(a['timestamp'] ?? 0));

                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Column(
                        children: txList.map((tx) {
                          final bool isPositive = tx['isPositive'] ?? true;
                          return Container(
                            margin: const EdgeInsets.only(bottom: 12), padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 8, offset: const Offset(0, 4))]),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(color: isPositive ? Colors.green.shade50 : Colors.red.shade50, borderRadius: BorderRadius.circular(12)),
                                  child: Icon(isPositive ? Icons.account_balance_wallet : Icons.payment, color: isPositive ? Colors.green : Colors.red),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(tx['title'] ?? 'Giao dịch', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold, fontSize: 15, color: AppColors.textDark)),
                                      const SizedBox(height: 4),
                                      Text(DateFormat('dd/MM/yyyy - HH:mm').format(DateTime.fromMillisecondsSinceEpoch(tx['timestamp'])), style: GoogleFonts.plusJakartaSans(fontSize: 12, color: AppColors.textGrey)),
                                    ],
                                  ),
                                ),
                                Text('${isPositive ? "+" : "-"}${_formatCurrency((tx['amount'] ?? 0).toDouble())}', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold, fontSize: 16, color: isPositive ? Colors.green : Colors.red)),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                    );
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, String actionText, {VoidCallback? onTap}) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: GoogleFonts.plusJakartaSans(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textDark)),
          InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(4),
            child: Padding(padding: const EdgeInsets.all(4.0), child: Text(actionText, style: GoogleFonts.plusJakartaSans(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.primary))),
          ),
        ],
      ),
    );
  }
}