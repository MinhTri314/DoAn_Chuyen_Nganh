import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// Import các file cần thiết (Dùng Absolute Import cho chuẩn)
import 'package:tri_go/constants.dart';
import 'package:tri_go/widgets/top_bar.dart';
import 'package:tri_go/widgets/destination_card.dart';
import 'package:tri_go/widgets/trip_card.dart';
import 'package:tri_go/widgets/expense_item.dart';
// Import màn hình Khám phá
import 'package:tri_go/screens/explore/explore_screen.dart'; // Đảm bảo đường dẫn này đúng với nơi bạn lưu file explore_screen.dart

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const TopBar(),

              // SECTION 1: Địa điểm nổi bật
              // Sửa: Thêm sự kiện onTap để chuyển trang
              _buildSectionHeader(
                'Địa điểm nổi bật', 
                'Khám phá', 
                onTap: () {
                  Navigator.push(
                    context, 
                    MaterialPageRoute(builder: (context) => const ExploreScreen())
                  );
                }
              ),
              
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: const [
                    // Card 1: Vịnh Hạ Long
                    DestinationCard(
                      title: 'Vịnh Hạ Long',
                      location: 'Quảng Ninh',
                      description: 'Kỳ quan thiên nhiên thế giới với hàng ngàn đảo đá vôi kỳ vĩ.',
                      imageUrl: 'https://picsum.photos/id/1015/800/600', // Dùng link mạng cho đẹp
                    ),
                    // Card 2: Đà Lạt
                    DestinationCard(
                      title: 'Đà Lạt',
                      location: 'Lâm Đồng',
                      description: 'Thành phố ngàn hoa với khí hậu ôn đới quanh năm.',
                      imageUrl: 'assets/images/da_lat.webp', // Đã sửa lỗi chính tả ssets -> assets
                    ),
                    // Card 3: Phú Quốc
                    DestinationCard(
                      title: 'Phú Quốc',
                      location: 'Kiên Giang',
                      description: 'Thiên đường nghỉ dưỡng với những bãi cát trắng.',
                      imageUrl: 'assets/images/phu_quoc.webp',
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 10),

              // SECTION 2: Chuyến đi sắp tới
              _buildSectionHeader('Chuyến đi sắp tới', 'Xem tất cả', onTap: () {}), // Tạm thời chưa làm gì
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: TripCard(
                  title: 'Phú Quốc - 3 ngày',
                  date: '15 Th09 - 18 Th09',
                  membersCount: '4 thành viên',
                  imageUrl: 'assets/images/phu_quoc.webp',
                  status: 'Đang đặt chỗ',
                  plusMember: 1,
                ),
              ),

              // SECTION 3: Chi tiêu
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                child: Text('Chi tiêu gần đây',
                    style: GoogleFonts.plusJakartaSans(
                        fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textDark)),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children: [
                    ExpenseItem(
                      title: 'Bữa tối hải sản',
                      subtitle: 'Phú Quốc • Hôm qua',
                      amount: '-1.200k',
                      icon: Icons.restaurant,
                      iconColor: Colors.deepOrange,
                      iconBgColor: Color(0xFFFFE0B2),
                    ),
                    ExpenseItem(
                      title: 'Vé máy bay khứ hồi',
                      subtitle: 'Hệ thống • 2 ngày trước',
                      amount: '-4.500k',
                      icon: Icons.flight,
                      iconColor: Colors.blue,
                      iconBgColor: Color(0xFFE3F2FD),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Hàm tạo tiêu đề Section (Đã nâng cấp để nhận sự kiện bấm)
  Widget _buildSectionHeader(String title, String actionText, {VoidCallback? onTap}) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title,
              style: GoogleFonts.plusJakartaSans(
                  fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textDark)),
          
          // Bọc nút bấm vào InkWell
          InkWell(
            onTap: onTap, 
            child: Padding( // Thêm padding để vùng bấm rộng hơn chút
              padding: const EdgeInsets.all(4.0),
              child: Text(actionText,
                  style: GoogleFonts.plusJakartaSans(
                      fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.primary)),
            ),
          ),
        ],
      ),
    );
  }
}