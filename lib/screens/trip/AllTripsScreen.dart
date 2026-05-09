import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

import 'package:tri_go/constants.dart';
import 'package:tri_go/models/trip.dart';
import 'package:tri_go/widgets/trip_card.dart';
import 'package:tri_go/screens/trip/TripDetailScreen.dart';

class AllTripsScreen extends StatefulWidget {
  const AllTripsScreen({super.key});

  @override
  State<AllTripsScreen> createState() => _AllTripsScreenState();
}

class _AllTripsScreenState extends State<AllTripsScreen> {
  final User? currentUser = FirebaseAuth.instance.currentUser;

  // HÀM XÓA CHUYẾN ĐI KHI NHẤN GIỮ[cite: 6]
  void _showDeleteDialog(String tripId, String tripTitle) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            const Icon(Icons.delete_forever, color: Colors.red),
            const SizedBox(width: 8),
            Text('Xóa lịch sử?', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold, fontSize: 18)),
          ],
        ),
        content: Text('Bạn có chắc muốn xóa "$tripTitle" khỏi lịch sử chuyến đi không?\n\nLưu ý: Hành động này không thể hoàn tác.', style: GoogleFonts.plusJakartaSans(fontSize: 14, color: Colors.grey.shade700)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context), 
            child: Text('Hủy', style: GoogleFonts.plusJakartaSans(color: Colors.grey, fontWeight: FontWeight.bold))
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context); // Đóng hộp thoại[cite: 6]
              try {
                await FirebaseDatabase.instance.ref('trips/$tripId').remove();
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Đã xóa khỏi lịch sử.'), backgroundColor: Colors.green));
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Lỗi: $e'), backgroundColor: Colors.red));
                }
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
            child: Text('Xóa', style: GoogleFonts.plusJakartaSans(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  // --- HÀM TẠO NHÃN TRẠNG THÁI (MỚI) ---
  Widget _buildStatusBadge(bool isFinished, bool isReviewed) {
    String text;
    Color color;
    IconData icon;

    if (isReviewed) {
      text = 'Đã đánh giá';
      color = Colors.green;
      icon = Icons.check_circle;
    } else if (isFinished) {
      text = 'Chưa đánh giá';
      color = Colors.orange;
      icon = Icons.star_half;
    } else {
      text = 'Đang diễn ra';
      color = Colors.blue;
      icon = Icons.flight_takeoff;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.95),
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 4, offset: Offset(0, 2))],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 14),
          const SizedBox(width: 4),
          Text(text, style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('Tất cả chuyến đi', style: GoogleFonts.plusJakartaSans(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black)),
        centerTitle: true,
      ),
      body: currentUser == null 
        ? const Center(child: Text("Vui lòng đăng nhập"))
        : StreamBuilder(
            // LOAD TOÀN BỘ KHÔNG LỌC STATUS[cite: 6]
            stream: FirebaseDatabase.instance.ref('trips').orderByChild('createdBy').equalTo(currentUser?.uid).onValue,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (!snapshot.hasData || snapshot.data!.snapshot.value == null) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.history, size: 60, color: Colors.grey.shade300),
                      const SizedBox(height: 16),
                      Text('Lịch sử trống.', style: GoogleFonts.plusJakartaSans(fontSize: 16, color: Colors.grey)),
                    ],
                  ),
                );
              }
              
              final data = snapshot.data!.snapshot.value as Map<dynamic, dynamic>;
              List<Map<dynamic, dynamic>> rawTrips = [];
              data.forEach((key, value) => rawTrips.add({'key': key, ...value as Map<dynamic, dynamic>}));
              
              // Sắp xếp chuyến nào mới tạo nằm trên cùng[cite: 6]
              rawTrips.sort((a, b) => (b['createdAt'] ?? 0).compareTo(a['createdAt'] ?? 0));

              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: rawTrips.length,
                itemBuilder: (context, index) {
                  final tData = rawTrips[index];
                  
                  // LOGIC XÁC ĐỊNH TRẠNG THÁI CHUYẾN ĐI
                  DateTime? endDate = DateTime.tryParse(tData['endDate'] ?? '');
                  bool isFinished = endDate != null && DateTime.now().isAfter(endDate.add(const Duration(days: 1)));
                  bool isReviewed = currentUser != null && tData['reviewedBy'] != null && tData['reviewedBy'][currentUser!.uid] == true;
                  
                  final trip = Trip(
                    id: tData['id'] ?? tData['key'],
                    title: tData['title'] ?? 'Chuyến đi mới',
                    destinationName: tData['destinationName'] ?? 'Chưa rõ',
                    imageUrl: tData['imageUrl'] ?? 'https://picsum.photos/800/600',
                    startDate: DateTime.tryParse(tData['startDate'] ?? '') ?? DateTime.now(),
                    endDate: endDate ?? DateTime.now().add(const Duration(days: 1)),
                    budgetLimit: (tData['budgetLimit'] ?? 0).toDouble(),
                  );

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16.0),
                    child: GestureDetector(
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => TripDetailScreen(trip: trip))),
                      // NHẤN GIỮ ĐỂ XÓA NHƯ SẾP YÊU CẦU[cite: 6]
                      onLongPress: () => _showDeleteDialog(trip.id, trip.title),
                      child: Stack(
                        children: [
                          TripCard(trip: trip),
                          
                          // --- THÊM NHÃN TRẠNG THÁI GÓC TRÁI ---
                          Positioned(
                            top: 12,
                            left: 12,
                            child: _buildStatusBadge(isFinished, isReviewed),
                          ),

                          // Nút xóa nhỏ góc phải cho user dễ biết có thể thao tác[cite: 6]
                          Positioned(
                            top: 12,
                            right: 12,
                            child: CircleAvatar(
                              backgroundColor: const Color.fromRGBO(255, 255, 255, 0.9),
                              radius: 16,
                              child: IconButton(
                                padding: EdgeInsets.zero,
                                icon: const Icon(Icons.more_vert, size: 18, color: Colors.black54),
                                onPressed: () => _showDeleteDialog(trip.id, trip.title),
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          ),
    );
  }
}