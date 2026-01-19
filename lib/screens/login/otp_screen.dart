import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tri_go/constants.dart'; // <-- Cách này gọi là "gọi thẳng tên", không sợ sai
import '../home_screen.dart'; // Xác thực xong thì vào Home

class OtpScreen extends StatelessWidget {
  const OtpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Hoặc Color(0xFFF6F8F8)
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
            Text('Nhập mã xác thực', style: GoogleFonts.plusJakartaSans(fontSize: 32, fontWeight: FontWeight.bold, color: AppColors.textDark)),
            const SizedBox(height: 12),
            RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                style: GoogleFonts.plusJakartaSans(fontSize: 16, color: AppColors.textGrey, height: 1.5),
                children: const [
                  TextSpan(text: 'Vui lòng nhập mã xác thực gồm 6 chữ số đã được gửi đến email:\n'),
                  TextSpan(text: 'trip-planner@example.com', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
            
            const SizedBox(height: 40),
            
            // 6 ô nhập mã
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(6, (index) => _buildOtpDigit()),
            ),
            
            const SizedBox(height: 40),
            
            const Text('Bạn chưa nhận được mã?', style: TextStyle(color: AppColors.textGrey)),
            const SizedBox(height: 16),
            
            // Timer
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildTimerBox('00', 'PHÚT'),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
                  child: Text(':', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.primary)),
                ),
                _buildTimerBox('59', 'GIÂY'),
              ],
            ),
            
            const SizedBox(height: 20),
            TextButton(
              onPressed: () {},
              child: Text('Gửi lại mã ngay', style: GoogleFonts.plusJakartaSans(color: AppColors.primary, fontWeight: FontWeight.w600)),
            ),

            const SizedBox(height: 40),
            
            // Button Xác nhận
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: () {
                   // Vào Home
                   Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => const HomeScreen()), (route) => false);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 6,
                  shadowColor: AppColors.primary.withOpacity(0.4),
                ),
                child: Text('Xác nhận', style: GoogleFonts.plusJakartaSans(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOtpDigit() {
    return Container(
      width: 45, height: 56,
      decoration: BoxDecoration(
        color: const Color(0xFFF6F8F8), // Màu nền ô nhập
        borderRadius: BorderRadius.circular(12),
        // border: Border.all(color: Colors.transparent), // Khi focus sẽ đổi màu border
      ),
      child: Center(
        child: TextField(
          textAlign: TextAlign.center,
          style: GoogleFonts.plusJakartaSans(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.textDark),
          decoration: const InputDecoration(border: InputBorder.none, counterText: ''),
          keyboardType: TextInputType.number,
          maxLength: 1,
        ),
      ),
    );
  }

  Widget _buildTimerBox(String value, String label) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.primary.withOpacity(0.2)),
          ),
          child: Text(value, style: GoogleFonts.plusJakartaSans(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.primary)),
        ),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(fontSize: 10, color: AppColors.textGrey, fontWeight: FontWeight.bold)),
      ],
    );
  }
}