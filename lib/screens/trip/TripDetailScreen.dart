import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tri_go/models/trip.dart'; 
import 'package:tri_go/models/user.dart'; 
import 'package:intl/intl.dart'; 
import 'payment_screen.dart'; 
import 'schedule/ScheduleScreen.dart'; 
// IMPORT MÀN HÌNH QUỸ NHÓM VÀO ĐÂY
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

  // Mặc định tổng chi tiêu ban đầu (Demo)
  double _currentTotalExpense = 12450000; 

  final List<User> _tripMembers = [
    User(id: 'u1', name: 'Tôi (Trí)', email: 'tri@gmail.com', avatarUrl: 'https://i.pravatar.cc/150?img=11'),
    User(id: 'u2', name: 'Anh Thư', email: 'thu@gmail.com', avatarUrl: 'https://i.pravatar.cc/150?img=5'),
  ];

  final List<User> _mockFriends = [
    User(id: 'u3', name: 'Thiên Kim', email: 'kim@gmail.com', avatarUrl: 'https://i.pravatar.cc/150?img=9'),
    User(id: 'u4', name: 'Minh Nguyễn', email: 'minh@gmail.com', avatarUrl: 'https://i.pravatar.cc/150?img=15'),
    User(id: 'u5', name: 'Hoàng Trần', email: 'hoang@gmail.com', avatarUrl: 'https://i.pravatar.cc/150?img=33'),
    User(id: 'u6', name: 'Bảo Bảo', email: 'bao@gmail.com', avatarUrl: 'https://i.pravatar.cc/150?img=12'),
  ];

  void _showInviteBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true, 
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            return Container(
              height: MediaQuery.of(context).size.height * 0.7, 
              padding: const EdgeInsets.all(24),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Mời bạn bè', style: GoogleFonts.plusJakartaSans(fontSize: 20, fontWeight: FontWeight.bold, color: textDark)),
                      IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context)),
                    ],
                  ),
                  const SizedBox(height: 16),
                  
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(12)),
                    child: Row(
                      children: [
                        Icon(Icons.search, color: Colors.grey.shade500),
                        const SizedBox(width: 8),
                        Text('Tìm theo tên hoặc email...', style: TextStyle(color: Colors.grey.shade500)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text('Gợi ý từ các chuyến đi trước', style: GoogleFonts.plusJakartaSans(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.grey.shade600)),
                  const SizedBox(height: 12),

                  Expanded(
                    child: ListView.builder(
                      itemCount: _mockFriends.length,
                      itemBuilder: (context, index) {
                        final friend = _mockFriends[index];
                        bool isAlreadyMember = _tripMembers.any((member) => member.id == friend.id);

                        return ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: CircleAvatar(
                            radius: 24,
                            backgroundImage: NetworkImage(friend.avatarUrl),
                          ),
                          title: Text(friend.name, style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold)),
                          subtitle: Text(friend.email, style: GoogleFonts.plusJakartaSans(fontSize: 12, color: Colors.grey)),
                          trailing: isAlreadyMember
                              ? Text('Đã tham gia', style: GoogleFonts.plusJakartaSans(color: Colors.grey, fontWeight: FontWeight.bold))
                              : ElevatedButton(
                                  onPressed: () {
                                    setState(() {
                                      _tripMembers.add(friend);
                                    });
                                    setModalState(() {});
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: primaryColor.withOpacity(0.1),
                                    elevation: 0,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                                  ),
                                  child: Text('Mời', style: GoogleFonts.plusJakartaSans(color: primaryColor, fontWeight: FontWeight.bold)),
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

  String _formatDate(DateTime start, DateTime end) {
    String startMonth = start.month.toString().padLeft(2, '0');
    String endMonth = end.month.toString().padLeft(2, '0');
    int days = end.difference(start).inDays + 1;
    int nights = days - 1;
    return '${start.day} Th$startMonth - ${end.day} Th$endMonth • $days ngày $nights đêm';
  }

  String _formatCurrency(double amount) {
    final formatCurrency = NumberFormat.currency(locale: 'vi_VN', symbol: 'đ');
    return formatCurrency.format(amount);
  }

  @override
  Widget build(BuildContext context) {
    double budget = widget.trip.budgetLimit;
    double remaining = budget - _currentTotalExpense;
    bool isOverBudget = _currentTotalExpense > budget;
    
    double percentRemaining = budget > 0 ? (remaining / budget) : 0.0;
    if (percentRemaining < 0) percentRemaining = 0.0; 

    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 100),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Header Image
            Stack(
              children: [
                Container(
                  height: 300, width: double.infinity,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: widget.trip.imageUrl.startsWith('http')
                          ? NetworkImage(widget.trip.imageUrl)
                          : AssetImage(widget.trip.imageUrl) as ImageProvider,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                Container(
                  height: 300,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter, end: Alignment.bottomCenter,
                      colors: [Colors.black.withOpacity(0.3), Colors.transparent, Colors.white],
                      stops: const [0.0, 0.5, 1.0],
                    ),
                  ),
                ),
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
                          _buildGlassButton(Icons.more_horiz, () {}),
                        ],
                      ),
                    ],
                  ),
                ),
                Positioned(
                  bottom: 20, left: 16,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.trip.title,
                        style: GoogleFonts.plusJakartaSans(fontSize: 28, fontWeight: FontWeight.w800, color: textDark),
                      ),
                      Text(
                        _formatDate(widget.trip.startDate, widget.trip.endDate),
                        style: GoogleFonts.plusJakartaSans(fontSize: 14, fontWeight: FontWeight.w500, color: textDark.withOpacity(0.7)),
                      ),
                    ],
                  ),
                )
              ],
            ),

            // 2. THÀNH VIÊN 
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Thành viên (${_tripMembers.length})', style: GoogleFonts.plusJakartaSans(fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      SizedBox(
                        width: _tripMembers.length * 30.0 + 10,
                        height: 40,
                        child: Stack(
                          children: List.generate(_tripMembers.length, (index) {
                            return _buildAvatar(_tripMembers[index].avatarUrl, index * 30.0);
                          }),
                        ),
                      ),
                      const SizedBox(width: 8),
                      GestureDetector(
                        onTap: _showInviteBottomSheet, 
                        child: Container(
                          width: 40, height: 40,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: primaryColor, style: BorderStyle.solid),
                            color: primaryColor.withOpacity(0.05),
                          ),
                          child: const Icon(Icons.person_add, color: primaryColor, size: 20),
                        ),
                      )
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // 3. THẺ NGÂN SÁCH ĐÃ ĐƯỢC ĐẢO NGƯỢC LOGIC
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white, borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: isOverBudget ? Colors.red.withOpacity(0.3) : Colors.grey.shade200),
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
                            Text('SỐ DƯ NGÂN SÁCH', style: GoogleFonts.plusJakartaSans(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey)),
                            const SizedBox(height: 4),
                            Text(
                              _formatCurrency(remaining > 0 ? remaining : 0), 
                              style: GoogleFonts.plusJakartaSans(fontSize: 24, fontWeight: FontWeight.w800, color: isOverBudget ? Colors.red : textDark)
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: isOverBudget ? Colors.red.withOpacity(0.1) : primaryColor.withOpacity(0.1), 
                            borderRadius: BorderRadius.circular(20)
                          ),
                          child: Text(isOverBudget ? 'Vượt ngân sách' : 'Trong ngân sách', 
                            style: GoogleFonts.plusJakartaSans(fontSize: 10, fontWeight: FontWeight.bold, color: isOverBudget ? Colors.red : primaryColor)),
                        )
                      ],
                    ),
                    const SizedBox(height: 12),
                    
                    // Thanh màu xanh giảm dần
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: LinearProgressIndicator(
                        value: percentRemaining, 
                        backgroundColor: isOverBudget ? Colors.red.shade100 : const Color(0xFFF3F4F6),
                        valueColor: const AlwaysStoppedAnimation<Color>(primaryColor),
                        minHeight: 8,
                      ),
                    ),
                    const SizedBox(height: 8),
                    
                    // Chữ nhỏ bên dưới
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          isOverBudget ? 'Đã hết ngân sách!' : 'Còn lại ${(percentRemaining * 100).toStringAsFixed(1)}%', 
                          style: GoogleFonts.plusJakartaSans(fontSize: 11, fontWeight: FontWeight.w600, color: isOverBudget ? Colors.red : Colors.grey)
                        ),
                        Text(
                          'Tổng chi tiêu: ${_formatCurrency(_currentTotalExpense)}', 
                          style: GoogleFonts.plusJakartaSans(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.grey)
                        ),
                      ],
                    )
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // 4. Bento Grid (Lịch trình, Quỹ, QR)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  _buildBentoCard(
                    color: coralColor, icon: Icons.calendar_today, title: 'Lịch trình', subtitle: 'Xem chi tiết', isHorizontal: true,
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => const ScheduleScreen()));
                    },
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      // --- NÚT QUỸ NHÓM MỚI ---
                      Expanded(
                        child: _buildBentoCard(
                          color: primaryColor, 
                          icon: Icons.account_balance_wallet, 
                          title: 'Quỹ nhóm', 
                          subtitle: 'XEM LỊCH SỬ', 
                          isHorizontal: false,
                          onTap: () {
                            // Chuyển sang màn hình Quỹ (FundScreen) khi nhấn
                            Navigator.push(context, MaterialPageRoute(builder: (context) => const FundScreen()));
                          }
                        )
                      ),
                      const SizedBox(width: 16),
                      // --- NÚT THANH TOÁN (PAYMENT SCREEN) ---
                      Expanded(
                        child: _buildBentoCard(
                          color: purpleColor, 
                          icon: Icons.qr_code_2, 
                          title: 'Thanh toán QR', 
                          subtitle: 'QUÉT & NHẬN TIỀN', 
                          isHorizontal: false,
                          onTap: () async {
                            final double? addedExpense = await Navigator.push(
                              context, 
                              MaterialPageRoute(builder: (context) => const PaymentScreen())
                            );

                            if (addedExpense != null) {
                              setState(() {
                                _currentTotalExpense += addedExpense;
                              });
                            }
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
      
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        backgroundColor: primaryColor,
        shape: const CircleBorder(),
        child: const Icon(Icons.add, color: Colors.white, size: 30),
      ),
    );
  }

  Widget _buildGlassButton(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(color: Colors.black.withOpacity(0.3), shape: BoxShape.circle),
        child: Icon(icon, color: Colors.white, size: 20),
      ),
    );
  }

  Widget _buildAvatar(String url, double leftMargin) {
    return Positioned(
      left: leftMargin,
      child: Container(
        width: 40, height: 40,
        decoration: BoxDecoration(
          shape: BoxShape.circle, border: Border.all(color: Colors.white, width: 3),
          image: DecorationImage(image: NetworkImage(url), fit: BoxFit.cover),
        ),
      ),
    );
  }

  Widget _buildBentoCard({required Color color, required IconData icon, required String title, required String subtitle, required bool isHorizontal, VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20), height: isHorizontal ? null : 140,
        decoration: BoxDecoration(
          color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(16), border: Border.all(color: color.withOpacity(0.2)),
        ),
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