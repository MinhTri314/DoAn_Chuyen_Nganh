import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tri_go/constants.dart'; // <-- Cách này gọi là "gọi thẳng tên", không sợ sai
import '../login/login_screen.dart'; // Để dùng cho nút Đăng xuất

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFA), // Màu nền xám rất nhạt giống thiết kế
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: AppColors.textDark, size: 20),
          onPressed: () => Navigator.pop(context), // Quay lại trang trước
        ),
        title: Text('Hồ sơ Cá nhân',
            style: GoogleFonts.plusJakartaSans(
                color: AppColors.textDark,
                fontWeight: FontWeight.bold,
                fontSize: 18)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Column(
          children: [
            const SizedBox(height: 20),
            
            // 1. Avatar & Info Section
            Center(
              child: Column(
                children: [
                  Stack(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: AppColors.primary.withOpacity(0.2), width: 4),
                        ),
                        child: const CircleAvatar(
                          radius: 50, // Avatar to (100x100)
                          backgroundImage: NetworkImage('https://i.pravatar.cc/150?img=3'), 
                        ),
                      ),
                      // Nút máy ảnh nhỏ
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: const BoxDecoration(
                            color: AppColors.primary,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(color: Colors.white, blurRadius: 0, spreadRadius: 2) // Viền trắng
                            ] 
                          ),
                          child: const Icon(Icons.camera_alt, color: Colors.white, size: 18),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text('Minh Nguyễn',
                      style: GoogleFonts.plusJakartaSans(
                          fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.textDark)),
                  Text('minh.nguyen@example.com',
                      style: GoogleFonts.plusJakartaSans(
                          fontSize: 14, color: AppColors.textGrey, fontWeight: FontWeight.w500)),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // 2. Nhóm chức năng: Thông tin & Lịch sử
            Container(
              decoration: _boxDecoration(),
              child: Column(
                children: [
                  _buildListTile(Icons.person_outline, 'Chỉnh sửa thông tin', Colors.blue),
                  _buildDivider(),
                  _buildListTile(Icons.history, 'Lịch sử chuyến đi', Colors.blue),
                  _buildDivider(),
                  _buildListTile(Icons.analytics_outlined, 'Thống kê chi tiêu cá nhân', Colors.blue),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // 3. Nhóm chức năng: Bảo mật
            Container(
              decoration: _boxDecoration(),
              child: _buildListTile(Icons.lock_reset, 'Đổi mật khẩu', Colors.blue),
            ),

            const SizedBox(height: 20),

            // 4. Nhóm chức năng: Đăng xuất (Màu đỏ)
            Container(
              decoration: _boxDecoration(),
              child: ListTile(
                onTap: () {
                   // Xóa hết các màn hình cũ và quay về trang Login
                   Navigator.pushAndRemoveUntil(
                     context, 
                     MaterialPageRoute(builder: (context) => const LoginScreen()), 
                     (route) => false
                   );
                },
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.logout, color: Colors.red),
                ),
                title: Text('Đăng xuất',
                    style: GoogleFonts.plusJakartaSans(
                        fontSize: 15, fontWeight: FontWeight.w600, color: Colors.red)),
              ),
            ),

            const SizedBox(height: 40),
            
            // Version Info
            Text('TRAVEL PLANNER v2.4.0',
                style: GoogleFonts.plusJakartaSans(
                    fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textGrey, letterSpacing: 1.5)),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // Style cho cái khung trắng bo góc
  BoxDecoration _boxDecoration() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      boxShadow: [
        BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4)),
      ],
    );
  }

  // Widget tạo từng dòng chức năng
  Widget _buildListTile(IconData icon, String title, Color color) {
    return ListTile(
      onTap: () {}, // Sau này code chức năng ở đây
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: AppColors.primary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: AppColors.primary),
      ),
      title: Text(title,
          style: GoogleFonts.plusJakartaSans(
              fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.textDark)),
      trailing: const Icon(Icons.chevron_right, color: AppColors.textGrey),
    );
  }

  // Đường kẻ mờ phân cách
  Widget _buildDivider() {
    return const Divider(height: 1, thickness: 0.5, color: Color(0xFFF0F2F5), indent: 64, endIndent: 16);
  }
}