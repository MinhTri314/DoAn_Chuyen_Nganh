import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tri_go/constants.dart'; 
import 'package:firebase_auth/firebase_auth.dart'; 
import 'package:firebase_database/firebase_database.dart'; // THÊM THƯ VIỆN NÀY
import 'otp_screen.dart'; 

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController(); // THÊM CONTROLLER SĐT
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false; 

  Future<void> _handleRegister() async {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty || _phoneController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Vui lòng nhập đủ Email, SĐT và Mật khẩu')));
      return;
    }

    setState(() => _isLoading = true);

    try {
      // 1. Gọi Firebase tạo tài khoản Auth
      UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
      
      // 2. LƯU THÔNG TIN (GỒM SĐT) LÊN REALTIME DATABASE ĐỂ TÌM KIẾM
      await FirebaseDatabase.instance.ref('users/${userCredential.user!.uid}').set({
        'email': _emailController.text.trim(),
        'phone': _phoneController.text.trim(),
        'displayName': _emailController.text.trim().split('@')[0], // Lấy chữ cái đầu email làm tên tạm
        'avatar': '',
        'balance': 0,
        'createdAt': ServerValue.timestamp,
      });

      // 3. Gửi link xác thực
      await userCredential.user?.sendEmailVerification();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Tài khoản đã tạo thành công!'), backgroundColor: Colors.green));
        Navigator.push(context, MaterialPageRoute(builder: (context) => OtpScreen(email: _emailController.text.trim())));
      }
    } on FirebaseAuthException catch (e) {
      String message = e.message ?? 'Đã có lỗi xảy ra'; 
      if (e.code == 'email-already-in-use') message = 'Email này đã được đăng ký!';
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message), backgroundColor: Colors.red));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),
              IconButton(icon: const Icon(Icons.chevron_left, size: 32, color: AppColors.primary), onPressed: () => Navigator.pop(context), padding: EdgeInsets.zero, alignment: Alignment.centerLeft),
              const SizedBox(height: 20),
              
              Text('Đăng ký tài khoản', style: GoogleFonts.plusJakartaSans(fontSize: 32, fontWeight: FontWeight.w800, color: AppColors.textDark)),
              const SizedBox(height: 12),
              Text('Vui lòng nhập thông tin để tạo tài khoản mới.', style: GoogleFonts.plusJakartaSans(fontSize: 15, color: AppColors.textGrey, height: 1.5)),
              
              const SizedBox(height: 32),
              
              Text('Email', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600, fontSize: 14)),
              const SizedBox(height: 8),
              _buildInput(_emailController, 'name@example.com', Icons.mail_outline, TextInputType.emailAddress),
              const SizedBox(height: 20),

              // --- Ô NHẬP SỐ ĐIỆN THOẠI ---
              Text('Số điện thoại', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600, fontSize: 14)),
              const SizedBox(height: 8),
              _buildInput(_phoneController, 'Ví dụ: 0912345678', Icons.phone_android, TextInputType.phone),
              const SizedBox(height: 20),

              Text('Mật khẩu', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600, fontSize: 14)),
              const SizedBox(height: 8),
              Container(
                height: 56, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.borderColor)),
                child: TextField(controller: _passwordController, obscureText: true, decoration: InputDecoration(border: InputBorder.none, hintText: 'Ít nhất 6 ký tự', prefixIcon: const Icon(Icons.lock_outline, color: AppColors.textGrey))),
              ),
              const SizedBox(height: 32),
              
              SizedBox(
                width: double.infinity, height: 56,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _handleRegister,
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
                  child: _isLoading ? const CircularProgressIndicator(color: Colors.white) : const Text('Đăng ký', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInput(TextEditingController controller, String hint, IconData icon, TextInputType type) {
    return Container(
      height: 56, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.borderColor)),
      child: TextField(controller: controller, keyboardType: type, decoration: InputDecoration(border: InputBorder.none, hintText: hint, prefixIcon: Icon(icon, color: AppColors.textGrey))),
    );
  }
}