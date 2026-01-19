import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tri_go/constants.dart';

class TripCard extends StatelessWidget {
  final String title;
  final String date;
  final String membersCount;
  final String imageUrl;
  final String status;
  final int plusMember;

  const TripCard({
    super.key,
    required this.title,
    required this.date,
    required this.membersCount,
    required this.imageUrl,
    required this.status,
    required this.plusMember,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Phần Ảnh + Gradient + Badge + Title
          Stack(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                child: AspectRatio(
                  aspectRatio: 16 / 9, // Tỉ lệ ảnh chuẩn màn hình rộng
                  child: Image(
                    image: imageUrl.startsWith('http') 
                        ? NetworkImage(imageUrl) 
                        : AssetImage(imageUrl) as ImageProvider,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              // Gradient đen mờ
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                    gradient: LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      colors: [Colors.black.withOpacity(0.6), Colors.transparent],
                    ),
                  ),
                ),
              ),
              // Badge trạng thái (Góc trên phải)
              Positioned(
                top: 12, right: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.accentCoral,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(status.toUpperCase(),
                      style: GoogleFonts.plusJakartaSans(
                          color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1)),
                ),
              ),
              // Tiêu đề (Góc dưới trái)
              Positioned(
                bottom: 12, left: 16,
                child: Text(title,
                    style: GoogleFonts.plusJakartaSans(
                        color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          
          // Phần thông tin bên dưới (nền trắng)
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildInfoRow(Icons.calendar_today, date),
                    const SizedBox(height: 6),
                    _buildInfoRow(Icons.group_outlined, membersCount),
                  ],
                ),
                // Avatar Stack
                SizedBox(
                  width: 80, height: 32,
                  child: Stack(
                    children: [
                      _buildAvatar(0, 'https://i.pravatar.cc/150?img=6'),
                      _buildAvatar(20, 'https://i.pravatar.cc/150?img=7'),
                      _buildAvatar(40, 'https://i.pravatar.cc/150?img=8'),
                      Positioned(
                        left: 60,
                        child: Container(
                          width: 32, height: 32,
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.1),
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2),
                          ),
                          child: Center(
                            child: Text('+$plusMember',
                                style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.primary)),
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAvatar(double left, String url) {
    return Positioned(
      left: left,
      child: Container(
        width: 32, height: 32,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white, width: 2),
          image: DecorationImage(image: NetworkImage(url)),
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, color: AppColors.textGrey, size: 16),
        const SizedBox(width: 6),
        Text(text, style: GoogleFonts.plusJakartaSans(color: AppColors.textGrey, fontSize: 13, fontWeight: FontWeight.w500)),
      ],
    );
  }
}