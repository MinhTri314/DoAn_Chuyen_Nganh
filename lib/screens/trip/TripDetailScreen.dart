import 'dart:nativewrappers/_internal/vm/lib/async_patch.dart';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'schedule/ScheduleScreen.dart';

class TripDetailScreen extends StatelessWidget {
  const TripDetailScreen({super.key});

  // Định nghĩa màu sắc theo thiết kế HTML
  static const Color primaryColor = Color(0xFF1999B3);
  static const Color coralColor = Color(0xFFF79A7F);
  static const Color purpleColor = Color(0xFF8B5CF6);
  static const Color textDark = Color(0xFF111617);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 100), // Chừa chỗ cho FAB
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Header Image & Navigation
            Stack(
              children: [
                Container(
                  height: 300,
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    image: DecorationImage(
                      image: NetworkImage('https://images.unsplash.com/photo-1506744038136-46273834b3fb?w=800&q=80'), // Ảnh rừng thông
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                // Gradient Overlay
                Container(
                  height: 300,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Colors.black.withOpacity(0.3), Colors.transparent, Colors.white],
                      stops: const [0.0, 0.5, 1.0],
                    ),
                  ),
                ),
                // AppBar Icons
                Positioned(
                  top: 50,
                  left: 16,
                  right: 16,
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
                // Title
                Positioned(
                  bottom: 20,
                  left: 16,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Chuyến đi Đà Lạt',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 28,
                          fontWeight: FontWeight.w800,
                          color: textDark,
                        ),
                      ),
                      Text(
                        '15 Th05 - 18 Th05 • 4 ngày 3 đêm',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: textDark.withOpacity(0.7),
                        ),
                      ),
                    ],
                  ),
                )
              ],
            ),

            // 2. Thành viên
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Thành viên (5)', style: GoogleFonts.plusJakartaSans(fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      SizedBox(
                        width: 140,
                        height: 40,
                        child: Stack(
                          children: [
                            _buildAvatar('https://i.pravatar.cc/150?img=1', 0),
                            _buildAvatar('https://i.pravatar.cc/150?img=2', 30),
                            _buildAvatar('https://i.pravatar.cc/150?img=3', 60),
                            _buildAvatar('https://i.pravatar.cc/150?img=4', 90),
                          ],
                        ),
                      ),
                      Container(
                        width: 40, height: 40,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: primaryColor, style: BorderStyle.solid),
                          color: primaryColor.withOpacity(0.05),
                        ),
                        child: const Icon(Icons.person_add, color: primaryColor, size: 20),
                      )
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // 3. Tổng chi tiêu Card
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey.shade200),
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
                            Text('TỔNG CHI TIÊU', style: GoogleFonts.plusJakartaSans(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey)),
                            const SizedBox(height: 4),
                            Text('12.450.000đ', style: GoogleFonts.plusJakartaSans(fontSize: 24, fontWeight: FontWeight.w800, color: textDark)),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(color: primaryColor.withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
                          child: Text('Dưới ngân sách', style: GoogleFonts.plusJakartaSans(fontSize: 10, fontWeight: FontWeight.bold, color: primaryColor)),
                        )
                      ],
                    ),
                    const SizedBox(height: 12),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: const LinearProgressIndicator(
                        value: 0.65,
                        backgroundColor: Color(0xFFF3F4F6),
                        valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
                        minHeight: 8,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Đã dùng 65%', style: GoogleFonts.plusJakartaSans(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.grey)),
                        Text('Ngân sách: 20.000.000đ', style: GoogleFonts.plusJakartaSans(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.grey)),
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
                  // Lịch trình (Full width)
                  _buildBentoCard(
                    color: coralColor,
                    icon: Icons.calendar_today,
                    title: 'Lịch trình',
                    subtitle: 'Xem chi tiết 4 ngày',
                    isHorizontal: true,
                    onTap: () {
                        Navigator.push(context, 
                        MaterialPageRoute(builder: (context) => const AddActivityScreen()));
                    },
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _buildBentoCard(
                          color: primaryColor,  
                          icon: Icons.account_balance_wallet,
                          title: 'Quỹ nhóm',
                          subtitle: '3 KHOẢN CHƯA CHIA',
                          isHorizontal: false,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildBentoCard(
                          color: purpleColor,
                          icon: Icons.qr_code_2,
                          title: 'Thanh toán QR',
                          subtitle: 'QUÉT & NHẬN TIỀN',
                          isHorizontal: false,
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),

            const SizedBox(height: 24),

            // 5. Dịch vụ QR
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text('Dịch vụ QR', style: GoogleFonts.plusJakartaSans(fontSize: 16, fontWeight: FontWeight.bold)),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(color: purpleColor.withOpacity(0.1), borderRadius: BorderRadius.circular(4)),
                        child: Text('TIỆN ÍCH', style: GoogleFonts.plusJakartaSans(fontSize: 8, fontWeight: FontWeight.bold, color: purpleColor)),
                      )
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(child: _buildServiceButton(Icons.qr_code_scanner, 'Quét mã QR', 'Thanh toán chi phí', purpleColor)),
                      const SizedBox(width: 16),
                      Expanded(child: _buildServiceButton(Icons.qr_code, 'Mã QR của tôi', 'Đóng góp vào quỹ', primaryColor)),
                    ],
                  )
                ],
              ),
            )
          ],
        ),
      ),
      
      // Floating Action Button
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        backgroundColor: primaryColor,
        shape: const CircleBorder(),
        child: const Icon(Icons.add, color: Colors.white, size: 30),
      ),
    );
  }

  // --- Widgets con ---

  Widget _buildGlassButton(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.2),
          shape: BoxShape.circle,
          backgroundBlendMode: BlendMode.overlay,
        ),
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
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white, width: 3),
          image: DecorationImage(image: NetworkImage(url), fit: BoxFit.cover),
        ),
      ),
    );
  }

  Widget _buildBentoCard({required Color color, required IconData icon, required String title, required String subtitle, required bool isHorizontal, VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        height: isHorizontal ? null : 140,
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: isHorizontal
            ? Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(10)),
                        child: Icon(icon, color: Colors.white, size: 20),
                      ),
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
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(8)),
                    child: Icon(icon, color: Colors.white, size: 20),
                  ),
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

  Widget _buildServiceButton(IconData icon, String title, String subtitle, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade100),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 4)],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: color.withOpacity(0.1), shape: BoxShape.circle),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: 8),
          Text(title, style: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.bold)),
          Text(subtitle, style: GoogleFonts.plusJakartaSans(fontSize: 10, color: Colors.grey)),
        ],
      ),
    );
  }
}