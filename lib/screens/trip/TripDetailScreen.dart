import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

import 'package:tri_go/models/trip.dart'; 
import 'payment_screen.dart'; 
import 'schedule/ScheduleScreen.dart'; 
import 'fund_screen.dart'; 

class TripDetailScreen extends StatefulWidget {
  final Trip trip; 
  const TripDetailScreen({super.key, required this.trip});

  @override
  State<TripDetailScreen> createState() => _TripDetailScreenState();
}

class _TripDetailScreenState extends State<TripDetailScreen> {
  static const Color primaryColor = Color(0xFF1999B3);
  static const Color coralColor = Color(0xFFF79A7F);
  static const Color purpleColor = Color(0xFF8B5CF6);
  static const Color textDark = Color(0xFF111617);

  final User? currentUser = FirebaseAuth.instance.currentUser;
  List<Map<dynamic, dynamic>> _realMembers = [];
  List<String> _myFriends = []; 
  double _currentTotalExpense = 0; 
  double _currentFund = 0; 

  @override
  void initState() {
    super.initState();
    _listenToTripData();
    _fetchMyFriends(); 
  }

  void _fetchMyFriends() {
    if (currentUser == null) return;
    FirebaseDatabase.instance.ref('users/${currentUser!.uid}/friends').onValue.listen((event) {
      if (event.snapshot.value != null) {
        Map<dynamic, dynamic> friendsMap = event.snapshot.value as Map<dynamic, dynamic>;
        if (mounted) setState(() => _myFriends = friendsMap.keys.cast<String>().toList());
      }
    });
  }

  void _listenToTripData() {
    DatabaseReference tripRef = FirebaseDatabase.instance.ref('trips/${widget.trip.id}');
    tripRef.onValue.listen((event) async {
      if (event.snapshot.value != null) {
        final data = event.snapshot.value as Map<dynamic, dynamic>;
        
        if (mounted) {
          setState(() {
             _currentTotalExpense = double.parse((data['totalExpense'] ?? 0).toString());
             _currentFund = double.parse((data['currentFund'] ?? 0).toString());
          });
        }

        if (data['members'] != null) {
          Map<dynamic, dynamic> membersMap = data['members'];
          List<Map<dynamic, dynamic>> tempMembers = [];
          for (String uid in membersMap.keys) {
            final userSnap = await FirebaseDatabase.instance.ref('users/$uid').get();
            if (userSnap.exists) {
              tempMembers.add({'uid': uid, ...userSnap.value as Map<dynamic, dynamic>});
            }
          }
          if (mounted) setState(() => _realMembers = tempMembers);
        }
      }
    });
  }

  // --- HÀM NẠP QUỸ (BẢN TỐI ƯU SIÊU NHẸ CHỐNG ĐƠ MÁY) ---
  void _showTopUpFundDialog() {
    final TextEditingController amountController = TextEditingController();
    bool isSubmitting = false; // Biến trạng thái để xoay loading trên nút

    showDialog(
      context: context,
      barrierDismissible: false, // Bắt buộc phải bấm Hủy hoặc Xác nhận
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            title: Text('Đóng quỹ chuyến đi', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold)),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Số tiền sẽ được trừ từ Ví Cá Nhân cộng vào Quỹ Nhóm.', style: GoogleFonts.plusJakartaSans(fontSize: 13, color: Colors.grey)),
                const SizedBox(height: 16),
                TextField(
                  controller: amountController, keyboardType: TextInputType.number,
                  decoration: InputDecoration(labelText: 'Số tiền đóng (VNĐ)', border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: isSubmitting ? null : () => Navigator.pop(dialogContext), 
                child: const Text('Hủy', style: TextStyle(color: Colors.grey))
              ),
              ElevatedButton(
                onPressed: isSubmitting ? null : () async {
                  double? amount = double.tryParse(amountController.text);
                  if (amount == null || amount <= 0 || currentUser == null) return;

                  // 1. TỰ ĐỘNG CỤP BÀN PHÍM XUỐNG ĐỂ TRÁNH LAG TRÀN RAM
                  FocusManager.instance.primaryFocus?.unfocus();
                  
                  // 2. Đổi trạng thái thành đang load
                  setDialogState(() => isSubmitting = true);

                  final userRef = FirebaseDatabase.instance.ref('users/${currentUser!.uid}');
                  final userSnap = await userRef.get();
                  
                  if (userSnap.exists) {
                    final userData = userSnap.value as Map<dynamic, dynamic>;
                    double personalBalance = double.parse((userData['balance'] ?? 0).toString());
                    String myName = userData['displayName'] ?? 'Thành viên';

                    // KIỂM TRA SỐ DƯ VÍ
                    if (amount > personalBalance) {
                      setDialogState(() => isSubmitting = false); // Tắt loading
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Ví không đủ tiền! Hãy nạp ví trước.'), backgroundColor: Colors.red));
                      return;
                    }

                    try {
                      // Trừ tiền ví cá nhân & Ghi lịch sử cá nhân
                      await userRef.child('balance').set(personalBalance - amount);
                      await userRef.child('transactions').push().set({
                        'type': 'FUND_CONTRIBUTION', 'title': 'Đóng quỹ', 'amount': amount, 'timestamp': ServerValue.timestamp, 'isPositive': false
                      });
                      
                      // Cộng tiền vào Quỹ Nhóm & Ghi lịch sử nhóm
                      final tripRef = FirebaseDatabase.instance.ref('trips/${widget.trip.id}');
                      await tripRef.child('currentFund').set(_currentFund + amount);
                      await tripRef.child('contributions').push().set({
                        'contributorName': myName, 'amount': amount, 'timestamp': ServerValue.timestamp
                      });

                      if (dialogContext.mounted) {
                        Navigator.pop(dialogContext); // Chỉ cần tắt cái dialog này đi là xong
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Đóng quỹ thành công!'), backgroundColor: Colors.green));
                      }
                    } catch (e) {
                      setDialogState(() => isSubmitting = false);
                      if (dialogContext.mounted) {
                         ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Lỗi: $e'), backgroundColor: Colors.red));
                      }
                    }
                  } else {
                     setDialogState(() => isSubmitting = false);
                  }
                },
                style: ElevatedButton.styleFrom(backgroundColor: primaryColor),
                // Hiển thị vòng xoay bên trong cái nút luôn
                child: isSubmitting 
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : const Text('Xác nhận Đóng', style: TextStyle(color: Colors.white)),
              )
            ],
          );
        }
      ),
    );
  }

  void _showInviteBottomSheet() {
    List<Map<dynamic, dynamic>> searchResults = [];
    bool isSearching = false;
    List<String> sentRequests = []; 

    showModalBottomSheet(
      context: context,
      isScrollControlled: true, 
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            return Container(
              height: MediaQuery.of(context).size.height * 0.85, 
              padding: EdgeInsets.only(top: 24, left: 24, right: 24, bottom: MediaQuery.of(context).viewInsets.bottom + 24),
              decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Thêm người', style: GoogleFonts.plusJakartaSans(fontSize: 20, fontWeight: FontWeight.bold, color: textDark)),
                      IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context)),
                    ],
                  ),
                  const SizedBox(height: 16),
                  
                  TextField(
                    onChanged: (query) async {
                      if (query.isEmpty) {
                        setModalState(() => searchResults = []);
                        return;
                      }
                      setModalState(() => isSearching = true);
                      
                      final snap = await FirebaseDatabase.instance.ref('users').get();
                      if (snap.exists) {
                        Map<dynamic, dynamic> allUsers = snap.value as Map<dynamic, dynamic>;
                        List<Map<dynamic, dynamic>> results = [];
                        allUsers.forEach((key, value) {
                          String email = value['email']?.toString().toLowerCase() ?? '';
                          String phone = value['phone']?.toString() ?? ''; 
                          
                          if (key != currentUser?.uid && (email.contains(query.toLowerCase()) || phone.contains(query))) {
                            results.add({'uid': key, ...value});
                          }
                        });
                        setModalState(() {
                          searchResults = results;
                          isSearching = false;
                        });
                      }
                    },
                    decoration: InputDecoration(
                      hintText: 'Nhập SĐT hoặc Email...',
                      prefixIcon: Icon(Icons.search, color: Colors.grey.shade500),
                      filled: true, fillColor: Colors.grey.shade100,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                    ),
                  ),
                  const SizedBox(height: 20),
                  
                  if (isSearching) const Center(child: CircularProgressIndicator())
                  else if (searchResults.isEmpty) Center(child: Text('Nhập thông tin để tìm kiếm người dùng.', style: TextStyle(color: Colors.grey.shade500)))
                  else Expanded(
                    child: ListView.builder(
                      itemCount: searchResults.length,
                      itemBuilder: (context, index) {
                        final user = searchResults[index];
                        String uid = user['uid'];
                        
                        bool isAlreadyInTrip = _realMembers.any((member) => member['uid'] == uid);
                        bool isFriend = _myFriends.contains(uid);
                        bool isRequestSent = sentRequests.contains(uid);

                        String avatarPath = user['avatar'] ?? '';
                        String name = user['displayName'] ?? user['email'] ?? 'User';

                        return ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: CircleAvatar(
                            radius: 24, backgroundColor: Colors.blue.shade50,
                            backgroundImage: avatarPath.isNotEmpty ? FileImage(File(avatarPath)) : null,
                            child: avatarPath.isEmpty ? Text(name[0].toUpperCase(), style: const TextStyle(fontWeight: FontWeight.bold)) : null,
                          ),
                          title: Text(name, style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold)),
                          subtitle: Text('${user['phone'] ?? 'Chưa có SĐT'} \n${user['email']}', style: GoogleFonts.plusJakartaSans(fontSize: 11, color: Colors.grey)),
                          
                          trailing: isAlreadyInTrip
                            ? Text('Đã tham gia', style: GoogleFonts.plusJakartaSans(color: Colors.grey, fontWeight: FontWeight.bold))
                            : isFriend 
                              ? ElevatedButton( 
                                  onPressed: () async {
                                    await FirebaseDatabase.instance.ref('trips/${widget.trip.id}/members/$uid').set(true);
                                    setModalState(() {}); 
                                  },
                                  style: ElevatedButton.styleFrom(backgroundColor: Colors.green.withOpacity(0.1), elevation: 0, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20))),
                                  child: Text('Mời nhóm', style: GoogleFonts.plusJakartaSans(color: Colors.green, fontWeight: FontWeight.bold)),
                                )
                              : isRequestSent
                                ? Text('Đã gửi KB', style: GoogleFonts.plusJakartaSans(color: Colors.orange, fontWeight: FontWeight.bold))
                                : ElevatedButton( 
                                    onPressed: () async {
                                      await FirebaseDatabase.instance.ref('users/$uid/friendRequests/${currentUser!.uid}').set(true);
                                      setModalState(() => sentRequests.add(uid)); 
                                    },
                                    style: ElevatedButton.styleFrom(backgroundColor: primaryColor, elevation: 0, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20))),
                                    child: Text('Kết bạn', style: GoogleFonts.plusJakartaSans(color: Colors.white, fontWeight: FontWeight.bold)),
                                  ),
                        );
                      },
                    ),
                  )
                ],
              ),
            );
          }
        );
      }
    );
  }

  void _showMoreOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Tùy chọn chuyến đi', style: GoogleFonts.plusJakartaSans(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            ListTile(
              leading: Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: Colors.red.withOpacity(0.1), shape: BoxShape.circle), child: const Icon(Icons.delete, color: Colors.red)),
              title: Text('Xóa & Hoàn tiền', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold, color: Colors.red)),
              subtitle: Text('Hủy chuyến đi và chia lại quỹ', style: GoogleFonts.plusJakartaSans(fontSize: 12, color: Colors.grey)),
              onTap: () {
                Navigator.pop(context); 
                _confirmDeleteTrip(); 
              },
            ),
          ],
        ),
      ),
    );
  }

  // --- HÀM XÓA CHUYẾN ĐI & HOÀN TIỀN TỰ ĐỘNG ---
  Future<void> _confirmDeleteTrip() async {
    bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            const Icon(Icons.warning_amber_rounded, color: Colors.red, size: 28),
            const SizedBox(width: 8),
            Text('Xóa & Hoàn tiền', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold, color: Colors.red)),
          ],
        ),
        content: Text('Bạn có muốn xóa chuyến đi này?\n\nNếu Quỹ Nhóm còn dư tiền, hệ thống sẽ tự động chia đều và hoàn trả về Ví Cá Nhân của từng thành viên.', style: GoogleFonts.plusJakartaSans(height: 1.5)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: Text('Hủy', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold, color: Colors.grey))),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
            child: Text('Đồng ý', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold, color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      showDialog(context: context, barrierDismissible: false, builder: (context) => const Center(child: CircularProgressIndicator()));
      try {
        // 1. TÍNH TOÁN TIỀN HOÀN TRẢ
        double remainingFund = _currentFund - _currentTotalExpense;
        
        if (remainingFund > 0 && _realMembers.isNotEmpty) {
          // Chia đều số tiền dư cho các thành viên
          double refundPerPerson = remainingFund / _realMembers.length;

          // Chạy vòng lặp cộng tiền cho từng người
          for (var member in _realMembers) {
            String uid = member['uid'];
            DatabaseReference userRef = FirebaseDatabase.instance.ref('users/$uid');
            
            // Lấy số dư hiện tại của người đó
            final userSnap = await userRef.child('balance').get();
            double currentBalance = 0;
            if (userSnap.exists) {
              currentBalance = double.parse(userSnap.value.toString());
            }

            // Cộng tiền trả lại ví
            await userRef.child('balance').set(currentBalance + refundPerPerson);
            
            // Ghi lịch sử giao dịch: Hoàn tiền
            await userRef.child('transactions').push().set({
              'type': 'REFUND',
              'title': 'Hoàn tiền hủy chuyến đi',
              'amount': refundPerPerson,
              'timestamp': ServerValue.timestamp,
              'isPositive': true, // Dấu cộng màu xanh
            });
          }
        }

        // 2. XÓA SẠCH DATA CHUYẾN ĐI
        await FirebaseDatabase.instance.ref('trips/${widget.trip.id}').remove();
        
        if (mounted) {
          Navigator.pop(context); // Tắt loading
          Navigator.pop(context); // Trở về trang Home
          
          // Thông báo tùy theo việc có hoàn tiền hay không
          String message = remainingFund > 0 
            ? 'Đã xóa chuyến đi và hoàn lại ${_formatCurrency(remainingFund)} cho các thành viên!' 
            : 'Đã xóa chuyến đi thành công!';
            
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message), backgroundColor: Colors.green));
        }
      } catch (e) {
        if (mounted) {
          Navigator.pop(context); 
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Lỗi khi xóa: $e'), backgroundColor: Colors.red));
        }
      }
    }
  }

  String _formatDate(DateTime start, DateTime end) {
    String startMonth = start.month.toString().padLeft(2, '0');
    String endMonth = end.month.toString().padLeft(2, '0');
    int days = end.difference(start).inDays + 1;
    return '${start.day}/$startMonth - ${end.day}/$endMonth • $days ngày';
  }

  String _formatCurrency(double amount) {
    final number = amount.toInt();
    return '${number.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}đ';
  }

  @override
  Widget build(BuildContext context) {
    double remainingFund = _currentFund - _currentTotalExpense;
    bool isFundEmpty = remainingFund < 0;
    double percentSpent = _currentFund > 0 ? (_currentTotalExpense / _currentFund) : 0.0;
    if (percentSpent > 1) percentSpent = 1.0; 

    return Scaffold(
      backgroundColor: Colors.white,
      
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showTopUpFundDialog,
        backgroundColor: coralColor, 
        icon: const Icon(Icons.add_card, color: Colors.white),
        label: const Text('ĐÓNG QUỸ', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 100),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                Container(
                  height: 300, width: double.infinity,
                  decoration: BoxDecoration(image: DecorationImage(image: widget.trip.imageUrl.startsWith('http') ? NetworkImage(widget.trip.imageUrl) : AssetImage(widget.trip.imageUrl) as ImageProvider, fit: BoxFit.cover)),
                ),
                Container(height: 300, decoration: BoxDecoration(gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Colors.black.withOpacity(0.3), Colors.transparent, Colors.white], stops: const [0.0, 0.5, 1.0]))),
                Positioned(
                  top: 50, left: 16, right: 16,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildGlassButton(Icons.arrow_back_ios_new, () => Navigator.pop(context)),
                      Row(
                        children: [
                          _buildGlassButton(Icons.share, () {}), 
                          const SizedBox(width: 8), 
                          _buildGlassButton(Icons.more_horiz, _showMoreOptions)
                        ]
                      ),
                    ],
                  ),
                ),
                Positioned(
                  bottom: 20, left: 16, right: 16,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(widget.trip.title, style: GoogleFonts.plusJakartaSans(fontSize: 28, fontWeight: FontWeight.w800, color: textDark), maxLines: 2, overflow: TextOverflow.ellipsis),
                      Text(_formatDate(widget.trip.startDate, widget.trip.endDate), style: GoogleFonts.plusJakartaSans(fontSize: 14, fontWeight: FontWeight.w500, color: textDark.withOpacity(0.7))),
                    ],
                  ),
                )
              ],
            ),

            // THÀNH VIÊN
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Thành viên (${_realMembers.length})', style: GoogleFonts.plusJakartaSans(fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      if (_realMembers.isNotEmpty)
                        SizedBox(
                          width: _realMembers.length * 30.0 + 10,
                          height: 40,
                          child: Stack(
                            children: List.generate(_realMembers.length, (index) {
                              String avatarPath = _realMembers[index]['avatar'] ?? '';
                              String name = _realMembers[index]['displayName'] ?? 'U';
                              return Positioned(
                                left: index * 30.0,
                                child: Container(
                                  width: 40, height: 40,
                                  decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: Colors.white, width: 3)),
                                  child: CircleAvatar(
                                    backgroundColor: Colors.blue.shade100,
                                    backgroundImage: avatarPath.isNotEmpty ? FileImage(File(avatarPath)) : null,
                                    child: avatarPath.isEmpty ? Text(name[0].toUpperCase(), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)) : null,
                                  ),
                                ),
                              );
                            }),
                          ),
                        ),
                      const SizedBox(width: 8),
                      GestureDetector(
                        onTap: _showInviteBottomSheet, 
                        child: Container(
                          width: 40, height: 40,
                          decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: primaryColor, style: BorderStyle.solid), color: primaryColor.withOpacity(0.05)),
                          child: const Icon(Icons.person_add, color: primaryColor, size: 20),
                        ),
                      )
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // QUỸ NHÓM
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white, borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: isFundEmpty ? Colors.red.withOpacity(0.3) : Colors.grey.shade200),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('SỐ DƯ QUỸ NHÓM', style: GoogleFonts.plusJakartaSans(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey)),
                            const SizedBox(height: 4),
                            Text(
                              _formatCurrency(remainingFund > 0 ? remainingFund : 0), 
                              style: GoogleFonts.plusJakartaSans(fontSize: 24, fontWeight: FontWeight.w800, color: isFundEmpty ? Colors.red : textDark)
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(color: isFundEmpty ? Colors.red.withOpacity(0.1) : primaryColor.withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
                          child: Text(isFundEmpty ? 'Hết quỹ' : 'An toàn', style: GoogleFonts.plusJakartaSans(fontSize: 10, fontWeight: FontWeight.bold, color: isFundEmpty ? Colors.red : primaryColor)),
                        )
                      ],
                    ),
                    const SizedBox(height: 12),
                    
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: LinearProgressIndicator(value: percentSpent, backgroundColor: const Color(0xFFF3F4F6), valueColor: AlwaysStoppedAnimation<Color>(isFundEmpty ? Colors.red : coralColor), minHeight: 8),
                    ),
                    const SizedBox(height: 8),
                    
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Tổng quỹ: ${_formatCurrency(_currentFund)}', style: GoogleFonts.plusJakartaSans(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.grey)),
                        Text('Đã chi: ${_formatCurrency(_currentTotalExpense)}', style: GoogleFonts.plusJakartaSans(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.red.shade300)),
                      ],
                    )
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // BENTO GRID
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  _buildBentoCard(
                    color: coralColor, icon: Icons.calendar_today, title: 'Lịch trình', subtitle: 'Xem chi tiết', isHorizontal: true,
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const ScheduleScreen())),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _buildBentoCard(
                          color: primaryColor, icon: Icons.account_balance_wallet, title: 'Quản lý quỹ', subtitle: 'XEM SAO KÊ', isHorizontal: false,
                          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => FundScreen(tripId: widget.trip.id)))
                        )
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildBentoCard(
                          color: purpleColor, icon: Icons.qr_code_2, title: 'Thanh toán QR', subtitle: 'TRỪ QUỸ TRỰC TIẾP', isHorizontal: false,
                          onTap: () async {
                            await Navigator.push(context, MaterialPageRoute(builder: (context) => PaymentScreen(tripId: widget.trip.id)));
                          }
                        )
                      ),
                    ],
                  )
                ],
              ),
            ),
            const SizedBox(height: 80), 
          ],
        ),
      ),
    );
  }

  Widget _buildGlassButton(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: Colors.black.withOpacity(0.3), shape: BoxShape.circle),
        child: Icon(icon, color: Colors.white, size: 20),
      ),
    );
  }

  Widget _buildBentoCard({required Color color, required IconData icon, required String title, required String subtitle, required bool isHorizontal, VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20), height: isHorizontal ? null : 140,
        decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(16), border: Border.all(color: color.withOpacity(0.2))),
        child: isHorizontal
            ? Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(10)), child: Icon(icon, color: Colors.white, size: 20)),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(title, style: GoogleFonts.plusJakartaSans(fontSize: 16, fontWeight: FontWeight.bold, color: textDark)),
                          Text(subtitle, style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.w500, color: textDark.withOpacity(0.6))),
                        ],
                      )
                    ],
                  ),
                  Icon(Icons.chevron_right, color: color)
                ],
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(8)), child: Icon(icon, color: Colors.white, size: 20)),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, style: GoogleFonts.plusJakartaSans(fontSize: 15, fontWeight: FontWeight.bold, color: textDark)),
                      Text(subtitle, style: GoogleFonts.plusJakartaSans(fontSize: 10, fontWeight: FontWeight.bold, color: color)),
                    ],
                  )
                ],
              ),
      ),
    );
  }
}