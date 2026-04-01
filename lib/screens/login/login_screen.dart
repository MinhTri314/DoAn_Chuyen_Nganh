import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tri_go/constants.dart'; 
import 'package:firebase_auth/firebase_auth.dart'; 
import 'package:shared_preferences/shared_preferences.dart'; // IMPORT THƯ VIỆN MỚI
import 'register_screen.dart'; 
import '../home_screen.dart';    

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  
  bool _isLoading = false;
  bool _rememberMe = true; 

  @override
  void initState() {
    super.initState();
    _loadSavedCredentials(); // GỌI HÀM TỰ ĐỘNG ĐIỀN KHI VỪA MỞ TRANG
  }

  // --- HÀM ĐỌC DỮ LIỆU ĐÃ LƯU ---
  Future<void> _loadSavedCredentials() async {
    final prefs = await SharedPreferences.getInstance();
    final savedEmail = prefs.getString('saved_email');
    final savedPassword = prefs.getString('saved_password');
    final isRemembered = prefs.getBool('remember_me') ?? true;

    if (savedEmail != null && savedPassword != null) {
      setState(() {
        _emailController.text = savedEmail;
        _passwordController.text = savedPassword;
        _rememberMe = isRemembered;
      });
    }
  }

  // --- HÀM LƯU HOẶC XÓA DỮ LIỆU ---
  Future<void> _handleRememberMe() async {
    final prefs = await SharedPreferences.getInstance();
    if (_rememberMe) {
      // Nếu tick -> Lưu lại
      await prefs.setString('saved_email', _emailController.text.trim());
      await prefs.setString('saved_password', _passwordController.text.trim());
      await prefs.setBool('remember_me', true);
    } else {
      // Nếu bỏ tick -> Xóa đi
      await prefs.remove('saved_email');
      await prefs.remove('saved_password');
      await prefs.setBool('remember_me', false);
    }
  }

  Future<void> _handleLogin() async {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Vui lòng nhập đủ Email và Mật khẩu')));
      return;
    }

    setState(() => _isLoading = true);

    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
      
      // GỌI HÀM LƯU DỮ LIỆU KHI ĐĂNG NHẬP THÀNH CÔNG
      await _handleRememberMe();
      
      if (mounted) {
        Navigator.pushAndRemoveUntil(
          context, 
          MaterialPageRoute(builder: (context) => const HomeScreen()),
          (route) => false 
        );
      }
    } on FirebaseAuthException catch (e) {
      String message = 'Đăng nhập thất bại';
      if (e.code == 'user-not-found' || e.code == 'invalid-credential') {
        message = 'Tài khoản không tồn tại hoặc sai thông tin';
      } else if (e.code == 'wrong-password') {
        message = 'Sai mật khẩu';
      }
      
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message), backgroundColor: Colors.red));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent, elevation: 0,
        automaticallyImplyLeading: false,
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
            
            Text('Email', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600, fontSize: 14, color: AppColors.textDark)),
            const SizedBox(height: 8),
            _buildInput(controller: _emailController, hint: 'Email của bạn'),
            
            const SizedBox(height: 20),
            
            Text('Mật khẩu', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600, fontSize: 14, color: AppColors.textDark)),
            const SizedBox(height: 8),
            _buildInput(controller: _passwordController, hint: 'Mật khẩu', icon: Icons.visibility_outlined, isPassword: true),
            
            const SizedBox(height: 16),
            
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    SizedBox(
                      width: 24, height: 24,
                      child: Checkbox(
                        value: _rememberMe,
                        onChanged: (value) {
                          setState(() {
                            _rememberMe = value ?? true;
                          });
                        },
                        activeColor: AppColors.primary,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                        side: const BorderSide(color: AppColors.borderColor),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text('Ghi nhớ tài khoản', style: GoogleFonts.plusJakartaSans(color: AppColors.textDark, fontWeight: FontWeight.w500, fontSize: 14)),
                  ],
                ),
                TextButton(
                  onPressed: () {}, 
                  style: TextButton.styleFrom(padding: EdgeInsets.zero, minimumSize: const Size(50, 30), tapTargetSize: MaterialTapTargetSize.shrinkWrap),
                  child: Text('Quên mật khẩu?', style: GoogleFonts.plusJakartaSans(color: AppColors.primary, fontWeight: FontWeight.w600, fontSize: 14))
                ),
              ],
            ),
            
            const SizedBox(height: 24),
            
            SizedBox(
              width: double.infinity, height: 56,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _handleLogin,
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
                child: _isLoading 
                    ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : Text('Đăng nhập', style: GoogleFonts.plusJakartaSans(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
              ),
            ),
            
            const SizedBox(height: 30),
            _buildDivider(),
            const SizedBox(height: 30),
            
            Center(
              child: GestureDetector(
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const RegisterScreen())),
                child: RichText(
                  text: TextSpan(
                    text: 'Bạn chưa có tài khoản? ', style: GoogleFonts.plusJakartaSans(color: AppColors.textGrey),
                    children: [TextSpan(text: 'Đăng ký ngay', style: GoogleFonts.plusJakartaSans(color: AppColors.primary, fontWeight: FontWeight.bold))],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInput({required TextEditingController controller, required String hint, IconData? icon, bool isPassword = false}) {
    return Container(
      height: 56,
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.borderColor)),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: TextField(
        controller: controller, obscureText: isPassword,
        decoration: InputDecoration(border: InputBorder.none, hintText: hint, suffixIcon: icon != null ? Icon(icon, color: AppColors.textGrey) : null),
      ),
    );
  }
  
  Widget _buildDivider() {
    return Row(children: [
      const Expanded(child: Divider(color: AppColors.borderColor)),
      Padding(padding: const EdgeInsets.symmetric(horizontal: 16), child: Text('Hoặc', style: GoogleFonts.plusJakartaSans(fontSize: 12, color: AppColors.textGrey, fontWeight: FontWeight.w600))),
      const Expanded(child: Divider(color: AppColors.borderColor)),
    ]);
  }
}