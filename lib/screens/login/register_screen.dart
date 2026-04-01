import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tri_go/constants.dart'; 
import 'package:firebase_auth/firebase_auth.dart'; 
import 'otp_screen.dart'; 

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false; 

  // --- HÀM XỬ LÝ ĐĂNG KÝ VÀ GỬI EMAIL XÁC THỰC ---
  Future<void> _handleRegister() async {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng nhập đủ Email và Mật khẩu'))
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // 1. Gọi Firebase tạo tài khoản
      UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
      
      // 2. Gửi link xác thực tới Email vừa nhập
      await userCredential.user?.sendEmailVerification();
      
      // 3. Thông báo thành công và chuyển sang màn hình OTP
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Tài khoản đã tạo thành công! Vui lòng kiểm tra hộp thư Email để bấm link xác thực.'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 5), // Hiện 5 giây để user kịp đọc
          )
        );

        Navigator.push(
          context, 
          MaterialPageRoute(builder: (context) => OtpScreen(email: _emailController.text.trim()))
        );
      }
    } on FirebaseAuthException catch (e) {
      // BẮT LỖI CHI TIẾT BẰNG TIẾNG VIỆT
      String message = e.message ?? 'Đã có lỗi xảy ra'; 
      if (e.code == 'weak-password') {
        message = 'Mật khẩu quá yếu (cần ít nhất 6 ký tự)';
      } else if (e.code == 'email-already-in-use') {
        message = 'Email này đã được đăng ký, vui lòng dùng email khác';
      } else if (e.code == 'operation-not-allowed') {
        message = 'Bạn chưa bật phương thức Email/Password trên Firebase Console!';
      } else if (e.code == 'invalid-email') {
        message = 'Định dạng Email không hợp lệ';
      }
      
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(message), 
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 4),
      ));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
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
                  Text('Vui lòng nhập email và mật khẩu của bạn để tạo tài khoản mới.', style: GoogleFonts.plusJakartaSans(fontSize: 15, color: AppColors.textGrey, height: 1.5)),
                  
                  const SizedBox(height: 32),
                  
                  // Ô nhập Email
                  Text('Email', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600, fontSize: 14, color: AppColors.textDark)),
                  const SizedBox(height: 8),
                  Container(
                    height: 56,
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.borderColor)),
                    child: TextField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(border: InputBorder.none, hintText: 'name@example.com', hintStyle: GoogleFonts.plusJakartaSans(color: AppColors.textGrey), prefixIcon: const Icon(Icons.mail_outline, color: AppColors.textGrey)),
                    ),
                  ),
                  
                  const SizedBox(height: 20),

                  // Ô nhập Mật khẩu
                  Text('Mật khẩu', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600, fontSize: 14, color: AppColors.textDark)),
                  const SizedBox(height: 8),
                  Container(
                    height: 56,
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.borderColor)),
                    child: TextField(
                      controller: _passwordController,
                      obscureText: true, 
                      decoration: InputDecoration(border: InputBorder.none, hintText: 'Mật khẩu (ít nhất 6 ký tự)', hintStyle: GoogleFonts.plusJakartaSans(color: AppColors.textGrey), prefixIcon: const Icon(Icons.lock_outline, color: AppColors.textGrey)),
                    ),
                  ),
                  
                  const SizedBox(height: 32),
                  
                  // Nút Đăng ký
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _handleRegister,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        elevation: 8,
                      ),
                      child: _isLoading 
                        ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text('Đăng ký', style: GoogleFonts.plusJakartaSans(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                              const SizedBox(width: 8),
                              const Icon(Icons.arrow_forward, color: Colors.white, size: 20),
                            ],
                          ),
                    ),
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