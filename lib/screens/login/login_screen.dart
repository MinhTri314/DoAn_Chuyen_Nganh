import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tri_go/constants.dart'; // <-- Cách này gọi là "gọi thẳng tên", không sợ sai
import 'register_screen.dart'; // Để chuyển trang
import '../home_screen.dart';    // Để đăng nhập thành công

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: AppColors.textDark),
          onPressed: () {}, // Tạm thời chưa back đi đâu
        ),
        title: Text('Đăng nhập', style: GoogleFonts.plusJakartaSans(color: AppColors.textDark, fontWeight: FontWeight.bold, fontSize: 18)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            Text('Đăng nhập tài khoản', style: GoogleFonts.plusJakartaSans(fontSize: 32, fontWeight: FontWeight.bold, color: AppColors.textDark, height: 1.2)),
            const SizedBox(height: 12),
            Text('Lên kế hoạch và quản lý chi tiêu nhóm dễ dàng cùng bạn bè.', style: GoogleFonts.plusJakartaSans(fontSize: 16, color: AppColors.textGrey, height: 1.5)),
            
            const SizedBox(height: 32),
            
            // Ô Email
            _buildLabel('Email'),
            _buildInput(hint: 'Email của bạn', icon: null),
            
            const SizedBox(height: 20),
            
            // Ô Mật khẩu
            _buildLabel('Mật khẩu'),
            _buildInput(hint: 'Mật khẩu', icon: Icons.visibility_outlined, isPassword: true),
            
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () {},
                child: Text('Quên mật khẩu?', style: GoogleFonts.plusJakartaSans(color: AppColors.primary, fontWeight: FontWeight.w600)),
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Nút Đăng nhập
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: () {
                   // Giả lập đăng nhập -> Vào Home
                   Navigator.push(context, MaterialPageRoute(builder: (context) => const HomeScreen()));
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 4,
                  shadowColor: AppColors.primary.withOpacity(0.4),
                ),
                child: Text('Đăng nhập', style: GoogleFonts.plusJakartaSans(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
              ),
            ),
            
            const SizedBox(height: 30),
            _buildDivider(),
            const SizedBox(height: 30),
            
            // Nút Google
            _buildGoogleButton(),
            
            const SizedBox(height: 40),
            Center(
              child: GestureDetector(
                onTap: () {
                   Navigator.push(context, MaterialPageRoute(builder: (context) => const RegisterScreen()));
                },
                child: RichText(
                  text: TextSpan(
                    text: 'Bạn chưa có tài khoản? ',
                    style: GoogleFonts.plusJakartaSans(color: AppColors.textGrey),
                    children: [
                      TextSpan(text: 'Đăng ký ngay', style: GoogleFonts.plusJakartaSans(color: AppColors.primary, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, left: 4),
      child: Text(text, style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600, fontSize: 14, color: AppColors.textDark)),
    );
  }

  Widget _buildInput({required String hint, IconData? icon, bool isPassword = false}) {
    return Container(
      height: 56,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderColor),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      alignment: Alignment.centerLeft,
      child: TextField(
        obscureText: isPassword,
        style: GoogleFonts.plusJakartaSans(color: AppColors.textDark),
        decoration: InputDecoration(
          border: InputBorder.none,
          hintText: hint,
          hintStyle: GoogleFonts.plusJakartaSans(color: AppColors.textGrey),
          suffixIcon: icon != null ? Icon(icon, color: AppColors.textGrey) : null,
        ),
      ),
    );
  }
  
  Widget _buildDivider() {
    return Row(children: [
      const Expanded(child: Divider(color: AppColors.borderColor)),
      Padding(padding: const EdgeInsets.symmetric(horizontal: 16), child: Text('Hoặc tiếp tục với', style: GoogleFonts.plusJakartaSans(fontSize: 12, color: AppColors.textGrey, fontWeight: FontWeight.w600))),
      const Expanded(child: Divider(color: AppColors.borderColor)),
    ]);
  }

  Widget _buildGoogleButton() {
    return Container(
      height: 56,
      width: double.infinity,
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.borderColor),
        borderRadius: BorderRadius.circular(16),
        color: Colors.white,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Logo Google giả lập bằng Icon nếu chưa có ảnh
          const Icon(Icons.g_mobiledata, size: 32, color: Colors.blue), 
          const SizedBox(width: 8),
          Text('Tiếp tục với Google', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold, color: AppColors.textDark)),
        ],
      ),
    );
  }
}