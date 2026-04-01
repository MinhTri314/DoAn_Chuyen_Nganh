import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tri_go/constants.dart'; 
import 'package:firebase_auth/firebase_auth.dart'; // Thêm Firebase
import '../home_screen.dart'; 

class OtpScreen extends StatefulWidget {
  final String email; 
  
  const OtpScreen({super.key, required this.email});

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  bool _isLoading = false;

  // --- HÀM KIỂM TRA XEM USER ĐÃ BẤM LINK TRONG EMAIL CHƯA ---
  Future<void> _checkEmailVerified() async {
    setState(() => _isLoading = true);

    try {
      User? user = FirebaseAuth.instance.currentUser;
      
      // BẮT BUỘC PHẢI RELOAD ĐỂ CẬP NHẬT TRẠNG THÁI MỚI NHẤT TỪ FIREBASE
      await user?.reload(); 
      user = FirebaseAuth.instance.currentUser;

      if (user != null && user.emailVerified) {
        // Nếu đã xác thực -> Bay vào Home
        if (mounted) {
          Navigator.pushAndRemoveUntil(
            context, 
            MaterialPageRoute(builder: (context) => const HomeScreen()), 
            (route) => false
          );
        }
      } else {
        // Nếu chưa bấm link mà lanh chanh bấm nút
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Tài khoản chưa được xác thực. Vui lòng kiểm tra email và bấm vào link!'),
              backgroundColor: Colors.red,
            )
          );
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Có lỗi xảy ra, vui lòng thử lại!'), backgroundColor: Colors.red)
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // --- HÀM GỬI LẠI EMAIL NẾU USER KHÔNG TÌM THẤY ---
  Future<void> _resendEmail() async {
    try {
      await FirebaseAuth.instance.currentUser?.sendEmailVerification();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Đã gửi lại email xác thực!'), backgroundColor: Colors.green)
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Gửi lại email thất bại. Vui lòng đợi một lát!'), backgroundColor: Colors.red)
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent, elevation: 0,
        leading: const BackButton(color: AppColors.textDark),
        title: Text('Xác nhận Email', style: GoogleFonts.plusJakartaSans(color: AppColors.textDark, fontWeight: FontWeight.bold, fontSize: 18)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          children: [
            const SizedBox(height: 40),
            // Đổi icon cho phù hợp ngữ cảnh
            Container(
              width: 100, height: 100,
              decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.1), shape: BoxShape.circle),
              child: const Icon(Icons.mark_email_read_outlined, size: 50, color: AppColors.primary),
            ),
            const SizedBox(height: 32),
            
            Text('Kiểm tra hòm thư', style: GoogleFonts.plusJakartaSans(fontSize: 28, fontWeight: FontWeight.bold, color: AppColors.textDark)),
            const SizedBox(height: 12),
            RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                style: GoogleFonts.plusJakartaSans(fontSize: 15, color: AppColors.textGrey, height: 1.5),
                children: [
                  const TextSpan(text: 'Chúng tôi vừa gửi một đường link xác thực tài khoản tới email:\n'),
                  TextSpan(text: widget.email, style: const TextStyle(color: AppColors.textDark, fontWeight: FontWeight.bold)),
                  const TextSpan(text: '\n\nVui lòng nhấn vào link trong email để kích hoạt tài khoản của bạn.'),
                ],
              ),
            ),
            
            const SizedBox(height: 40),
            
            // Nút Xác nhận đã bấm link
            SizedBox(
              width: double.infinity, height: 56,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _checkEmailVerified,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary, 
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 4,
                  shadowColor: AppColors.primary.withOpacity(0.3),
                ),
                child: _isLoading 
                    ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : Text('Tôi đã bấm link xác thực', style: GoogleFonts.plusJakartaSans(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
              ),
            ),

            const SizedBox(height: 24),
            
            // Nút Gửi lại
            TextButton(
              onPressed: _resendEmail,
              child: Text('Chưa nhận được? Gửi lại email', style: GoogleFonts.plusJakartaSans(color: AppColors.primary, fontWeight: FontWeight.w600, fontSize: 14)),
            ),
          ],
        ),
      ),
    );
  }
}