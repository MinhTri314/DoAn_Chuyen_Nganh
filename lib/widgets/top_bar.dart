import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tri_go/constants.dart';
import '../screens//profile/profile_screen.dart'; // <--- Import trang Profile mới tạo

class TopBar extends StatelessWidget {
  const TopBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
      color: AppColors.background.withOpacity(0.9),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // BẮT SỰ KIỆN BẤM VÀO ĐÂY
          GestureDetector(
            onTap: () {
              // Chuyển sang trang Profile
              Navigator.push(
                context, 
                MaterialPageRoute(builder: (context) => const ProfileScreen())
              );
            },
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.primary.withValues(alpha: 0.2),
                  ),
                  child: const CircleAvatar(
                    radius: 20,
                    backgroundImage: NetworkImage('https://i.pravatar.cc/150?img=3'),
                  ),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Chào buổi sáng,',
                        style: GoogleFonts.plusJakartaSans(
                            fontSize: 12, 
                            color: AppColors.textGrey, 
                            fontWeight: FontWeight.w500)),
                    Text('Minh Nguyễn 👋',
                        style: GoogleFonts.plusJakartaSans(
                            fontSize: 18, 
                            color: AppColors.textDark, 
                            fontWeight: FontWeight.bold)),
                  ],
                ),
              ],
            ),
          ),
          
          // Nút thông báo (Giữ nguyên)
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05), 
                  blurRadius: 4, 
                  offset: const Offset(0, 2)
                )
              ],
            ),
            child: const Icon(Icons.notifications_outlined, color: AppColors.textDark),
          )
        ],
      ),
    );
  }
}