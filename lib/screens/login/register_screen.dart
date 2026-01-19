import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tri_go/constants.dart'; // <-- Cách này gọi là "gọi thẳng tên", không sợ sai
import 'otp_screen.dart'; // Chuyển sang nhập mã OTP

class RegisterScreen extends StatelessWidget {
  const RegisterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Background mờ ảo (Decorative)
          Positioned(top: -100, left: -100, child: Container(width: 200, height: 200, decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.05), shape: BoxShape.circle))),
          Positioned(bottom: -50, right: -50, child: Container(width: 200, height: 200, decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.05), shape: BoxShape.circle))),

          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 10),
                  IconButton(
                    icon: const Icon(Icons.chevron_left, size: 32, color: AppColors.primary),
                    onPressed: () => Navigator.pop(context),
                    padding: EdgeInsets.zero,
                    alignment: Alignment.centerLeft,
                  ),
                  const SizedBox(height: 20),
                  
                  Text('Đăng ký tài khoản', style: GoogleFonts.plusJakartaSans(fontSize: 32, fontWeight: FontWeight.w800, color: AppColors.textDark)),
                  const SizedBox(height: 12),
                  Text('Vui lòng nhập email của bạn. Chúng tôi sẽ gửi một mã xác nhận gồm 6 chữ số để kích hoạt tài khoản.', style: GoogleFonts.plusJakartaSans(fontSize: 15, color: AppColors.textGrey, height: 1.5)),
                  
                  const SizedBox(height: 32),
                  
                  // Label & Input
                  Text('Email', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600, fontSize: 14, color: AppColors.textDark)),
                  const SizedBox(height: 8),
                  Container(
                    height: 56,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.borderColor),
                    ),
                    child: Row(
                      children: [
                        const Padding(padding: EdgeInsets.only(left: 16, right: 12), child: Icon(Icons.mail_outline, color: AppColors.textGrey)),
                        Expanded(
                          child: TextField(
                            decoration: InputDecoration(
                              border: InputBorder.none,
                              hintText: 'name@example.com',
                              hintStyle: GoogleFonts.plusJakartaSans(color: AppColors.textGrey),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 32),
                  
                  // Button
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: () {
                        // Chuyển sang màn hình nhập OTP
                        Navigator.push(context, MaterialPageRoute(builder: (context) => const OtpScreen()));
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        elevation: 8,
                        shadowColor: AppColors.primary.withOpacity(0.3),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('Gửi mã xác nhận', style: GoogleFonts.plusJakartaSans(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                          const SizedBox(width: 8),
                          const Icon(Icons.arrow_forward, color: Colors.white, size: 20),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 30),
                  const Center(child: Text('HOẶC', style: TextStyle(color: AppColors.textGrey, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1.2))),
                  const SizedBox(height: 30),

                  // Nút Google (tái sử dụng style)
                  Container(
                    height: 56,
                    decoration: BoxDecoration(border: Border.all(color: AppColors.borderColor), borderRadius: BorderRadius.circular(16)),
                    child: Center(child: Text('Tiếp tục với Google', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold, color: AppColors.textDark))),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}