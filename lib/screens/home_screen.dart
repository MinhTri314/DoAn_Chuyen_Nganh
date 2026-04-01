import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// Import các file cần thiết
import 'package:tri_go/constants.dart';
import 'package:tri_go/widgets/top_bar.dart';
import 'package:tri_go/widgets/destination_card.dart';
import 'package:tri_go/widgets/trip_card.dart';
import 'package:tri_go/widgets/expense_item.dart';

// Import Data Mock và Models
import 'package:tri_go/models/trip.dart';
import 'package:tri_go/data/mock_data.dart'; 

// Import các màn hình
import 'package:tri_go/screens/explore/explore_screen.dart';
import 'package:tri_go/screens/trip/TripDetailScreen.dart';
import 'package:tri_go/screens/create_trip/create_trip_screen.dart'; // <--- IMPORT TRANG TẠO CHUYẾN ĐI VÀO ĐÂY

// --- CHUYỂN THÀNH STATEFUL WIDGET ĐỂ UPDATE UI KHI CÓ DATA MỚI ---
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      
      // --- THÊM NÚT DẤU + ĐỂ TẠO CHUYẾN ĐI Ở ĐÂY ---
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          // Điều hướng sang trang tạo chuyến đi và chờ kết quả trả về
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const CreateTripScreen()),
          );
          
          // Nếu trang tạo chuyến đi trả về true (tạo thành công), thì load lại giao diện
          if (result == true) {
            setState(() {
              // Giao diện sẽ tự động vẽ lại list mockTrips mới
            });
          }
        },
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add, color: Colors.white, size: 28),
      ),
      // ----------------------------------------------

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 80), // Tăng bottom padding để không bị nút + che mất nội dung
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const TopBar(),

              // SECTION 1: Địa điểm nổi bật
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
                    DestinationCard(
                      title: 'Vịnh Hạ Long',
                      location: 'Quảng Ninh',
                      description: 'Kỳ quan thiên nhiên thế giới với hàng ngàn đảo đá vôi kỳ vĩ.',
                      imageUrl: 'https://picsum.photos/id/1015/800/600',
                    ),
                    DestinationCard(
                      title: 'Đà Lạt',
                      location: 'Lâm Đồng',
                      description: 'Thành phố ngàn hoa với khí hậu ôn đới quanh năm.',
                      imageUrl: 'assets/images/da_lat.webp',
                    ),
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
              _buildSectionHeader(
                'Chuyến đi sắp tới', 
                'Xem tất cả', 
                onTap: () {
                  // Nút xem tất cả
                }
              ),
              
              // DÙNG LISTVIEW.BUILDER ĐỂ DUYỆT DATA MOCK
              SizedBox(
                height: 280, 
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: mockTrips.length, 
                  itemBuilder: (context, index) {
                    final Trip trip = mockTrips[index]; 

                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => TripDetailScreen(trip: trip),
                          ),
                        );
                      },
                      child: Container(
                        width: 320, 
                        margin: const EdgeInsets.only(right: 16),
                        child: TripCard(trip: trip), 
                      ),
                    );
                  },
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

  // Hàm tạo tiêu đề Section
  Widget _buildSectionHeader(String title, String actionText, {VoidCallback? onTap}) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title,
              style: GoogleFonts.plusJakartaSans(
                  fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textDark)),
          
          InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(4),
            child: Padding(
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