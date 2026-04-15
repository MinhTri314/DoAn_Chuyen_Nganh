import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tri_go/constants.dart';
import 'package:tri_go/models/trip.dart'; 
import 'package:firebase_database/firebase_database.dart'; // THÊM FIREBASE VÀO ĐÂY

class TripCard extends StatelessWidget {
  final Trip trip;

  const TripCard({
    super.key,
    required this.trip,
  });

  String _formatDate(DateTime start, DateTime end) {
    String startMonth = start.month.toString().padLeft(2, '0');
    String endMonth = end.month.toString().padLeft(2, '0');
    return '${start.day} Th$startMonth - ${end.day} Th$endMonth';
  }

  @override
  Widget build(BuildContext context) {
    // TÍNH TOÁN TRẠNG THÁI CHUYẾN ĐI DỰA TRÊN THỜI GIAN THỰC TẾ
    String status = 'Sắp diễn ra';
    Color statusColor = AppColors.accentCoral;
    final now = DateTime.now();

    if (now.isAfter(trip.endDate.add(const Duration(days: 1)))) {
      status = 'Đã kết thúc';
      statusColor = Colors.grey.shade600;
    } else if (now.isAfter(trip.startDate) || now.isAtSameMomentAs(trip.startDate)) {
      status = 'Đang diễn ra';
      statusColor = Colors.green;
    }

    return Container(
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
                  aspectRatio: 16 / 9, 
                  child: Image(
                    image: trip.imageUrl.startsWith('http')
                        ? NetworkImage(trip.imageUrl)
                        : AssetImage(trip.imageUrl) as ImageProvider,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                    gradient: LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      colors: [Colors.black.withOpacity(0.7), Colors.transparent],
                    ),
                  ),
                ),
              ),
              // Badge trạng thái Động
              Positioned(
                top: 12, right: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(status.toUpperCase(),
                      style: GoogleFonts.plusJakartaSans(
                          color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1)),
                ),
              ),
              // Tiêu đề chuyến đi
              Positioned(
                bottom: 12, left: 16, right: 16,
                child: Text(trip.title, 
                    maxLines: 1, overflow: TextOverflow.ellipsis,
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
                    _buildInfoRow(Icons.calendar_today, _formatDate(trip.startDate, trip.endDate)), 
                    const SizedBox(height: 6),
                    
                    // DÙNG STREAMBUILDER ĐỂ ĐẾM SỐ THÀNH VIÊN THẬT TỪ FIREBASE
                    StreamBuilder(
                      stream: FirebaseDatabase.instance.ref('trips/${trip.id}/members').onValue,
                      builder: (context, snapshot) {
                        int memberCount = 1; // Mặc định lúc tạo là 1 (chính mình)
                        if (snapshot.hasData && snapshot.data!.snapshot.value != null) {
                          final membersMap = snapshot.data!.snapshot.value as Map<dynamic, dynamic>;
                          memberCount = membersMap.length;
                        }
                        return _buildInfoRow(Icons.group_outlined, '$memberCount thành viên');
                      }
                    ),
                  ],
                ),
                
                // Thay đống avatar giả bằng nút mũi tên xịn xò
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.arrow_forward, color: AppColors.primary, size: 20),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, color: AppColors.textGrey, size: 16),
        const SizedBox(width: 6),
        Text(text, style: GoogleFonts.plusJakartaSans(color: AppColors.textGrey, fontSize: 13, fontWeight: FontWeight.w600)),
      ],
    );
  }
}