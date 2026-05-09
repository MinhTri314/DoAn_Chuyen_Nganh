import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tri_go/constants.dart'; 
import 'package:firebase_auth/firebase_auth.dart'; 
import 'package:shared_preferences/shared_preferences.dart'; 
import 'package:google_sign_in/google_sign_in.dart'; // THÊM THƯ VIỆN GOOGLE
import 'package:firebase_database/firebase_database.dart'; // THÊM THƯ VIỆN DATABASE

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
    _loadSavedCredentials(); 
  }

  // --- HÀM 1: TẢI THÔNG TIN ĐÃ LƯU ---
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

  // --- HÀM 2: LƯU THÔNG TIN ĐĂNG NHẬP ---
  Future<void> _handleRememberMe() async {
    final prefs = await SharedPreferences.getInstance();
    if (_rememberMe) {
      await prefs.setString('saved_email', _emailController.text.trim());
      await prefs.setString('saved_password', _passwordController.text.trim());
      await prefs.setBool('remember_me', true);
    } else {
      await prefs.remove('saved_email');
      await prefs.remove('saved_password');
      await prefs.setBool('remember_me', false);
    }
  }

  // --- HÀM 3: ĐĂNG NHẬP BẰNG EMAIL & MẬT KHẨU ---
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

  // --- HÀM 4: ĐĂNG NHẬP BẰNG GOOGLE ---
  Future<void> _handleGoogleSignIn() async {
    setState(() => _isLoading = true);
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn(serverClientId: '479630668260-39ede8kushe78iljln70j4b1dvtclell.apps.googleusercontent.com',).signIn();
      if (googleUser == null) {
        setState(() => _isLoading = false);
        return; 
      }

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      UserCredential userCredential = await FirebaseAuth.instance.signInWithCredential(credential);
      User? user = userCredential.user;

      if (user != null) {
        // Kiểm tra xem user này đã có trên Realtime DB chưa
        final userRef = FirebaseDatabase.instance.ref('users/${user.uid}');
        final snapshot = await userRef.get();

        // Nếu chưa có (đăng nhập Google lần đầu) -> Tạo profile mới
        if (!snapshot.exists) {
          await userRef.set({
            'email': user.email,
            'phone': user.phoneNumber ?? '',
            'displayName': user.displayName ?? user.email!.split('@')[0],
            'avatar': user.photoURL ?? '',
            'balance': 0,
            'createdAt': ServerValue.timestamp,
          });
        }

        if (mounted) {
          Navigator.pushAndRemoveUntil(
            context, 
            MaterialPageRoute(builder: (context) => const HomeScreen()),
            (route) => false 
          );
        }
      }
    } on FirebaseAuthException catch (e) {
      String message = 'Đăng nhập Google thất bại';
      // Bắt lỗi trùng email với tài khoản đã đăng ký thủ công
      if (e.code == 'account-exists-with-different-credential') {
        message = 'Email này đã được đăng ký bằng mật khẩu. Vui lòng đăng nhập bình thường.';
      }
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message), backgroundColor: Colors.red));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // --- HÀM 5: DIALOG QUÊN MẬT KHẨU ---
  void _showForgotPasswordDialog() {
    final TextEditingController resetEmailController = TextEditingController(text: _emailController.text.trim());
    bool isResetting = false;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            title: Text('Quên mật khẩu?', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold)),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Nhập email của bạn để nhận liên kết đặt lại mật khẩu.', style: GoogleFonts.plusJakartaSans(fontSize: 13, color: Colors.grey)),
                const SizedBox(height: 16),
                TextField(
                  controller: resetEmailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    labelText: 'Email đã đăng ký',
                    prefixIcon: const Icon(Icons.mail_outline, color: AppColors.primary),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.primary, width: 2)),
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: isResetting ? null : () => Navigator.pop(dialogContext),
                child: const Text('Hủy', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold))
              ),
              ElevatedButton(
                onPressed: isResetting ? null : () async {
                  String email = resetEmailController.text.trim();
                  if (email.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Vui lòng nhập email!'), backgroundColor: Colors.red));
                    return;
                  }

                  FocusManager.instance.primaryFocus?.unfocus();
                  setDialogState(() => isResetting = true);

                  try {
                    await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
                    
                    if (dialogContext.mounted) {
                      Navigator.pop(dialogContext);
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                        content: Text('Đã gửi link đặt lại mật khẩu. Vui lòng kiểm tra hộp thư email!'), 
                        backgroundColor: Colors.green,
                        duration: Duration(seconds: 4),
                      ));
                    }
                  } on FirebaseAuthException catch (e) {
                    setDialogState(() => isResetting = false);
                    String msg = 'Có lỗi xảy ra, vui lòng thử lại sau!';
                    if (e.code == 'user-not-found') {
                      msg = 'Không tìm thấy tài khoản với email này.';
                    } else if (e.code == 'invalid-email') {
                      msg = 'Định dạng email không hợp lệ.';
                    }
                    if (dialogContext.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg), backgroundColor: Colors.red));
                    }
                  }
                },
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                child: isResetting 
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : const Text('Gửi link', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              )
            ],
          );
        }
      ),
    );
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
                  onPressed: _showForgotPasswordDialog, 
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

            // NÚT ĐĂNG NHẬP GOOGLE
            SizedBox(
              width: double.infinity, height: 56,
              child: OutlinedButton.icon(
                onPressed: _isLoading ? null : _handleGoogleSignIn,
                icon: const Icon(Icons.g_mobiledata, color: AppColors.primary, size: 32),
                label: Text('Tiếp tục với Google', style: GoogleFonts.plusJakartaSans(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textDark)),
                style: OutlinedButton.styleFrom(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  side: const BorderSide(color: AppColors.borderColor),
                ),
              ),
            ),
            
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