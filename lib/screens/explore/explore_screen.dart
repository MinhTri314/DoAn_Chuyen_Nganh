import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// Import constants cho màu sắc
import 'package:tri_go/constants.dart';

// Import màn hình Tạo chuyến đi
import 'package:tri_go/screens/create_trip/create_trip_screen.dart';

class ExploreScreen extends StatelessWidget {
  const ExploreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background.withOpacity(0.9),
        elevation: 0,
        automaticallyImplyLeading: false, 
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Khám phá',
                style: GoogleFonts.epilogue(
                    fontSize: 24, fontWeight: FontWeight.w800, color: AppColors.textDark)),
            Container(
              width: 40, height: 40,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: const Icon(Icons.notifications_outlined, color: Colors.black54),
            )
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 100),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Search Bar
            Padding(
              padding: const EdgeInsets.all(16),
              child: Container(
                height: 56,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4))
                  ],
                ),
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Tìm kiếm điểm đến, hành trình...',
                    hintStyle: GoogleFonts.epilogue(color: Colors.grey.shade400, fontSize: 14),
                    prefixIcon: const Icon(Icons.search, color: Colors.grey),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(vertical: 18),
                  ),
                ),
              ),
            ),

            // 2. Filter Chips
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  _buildChip('Tất cả', isActive: true),
                  _buildChip('Biển'),
                  _buildChip('Núi'),
                  _buildChip('Thành phố'),
                  _buildChip('Văn hóa'),
                ],
              ),
            ),
            
            const SizedBox(height: 24),

            // 3. Featured Hero Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                height: 220,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  image: const DecorationImage(
                    // FIX ẢNH 1: Đổi sang picsum
                    image: NetworkImage('https://picsum.photos/id/1016/800/600'),
                    fit: BoxFit.cover,
                  ),
                ),
                child: Stack(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(24),
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [Colors.transparent, Colors.black.withOpacity(0.8)],
                          stops: const [0.4, 1.0],
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 20, left: 20, right: 20,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(color: AppColors.orange, borderRadius: BorderRadius.circular(6)),
                            child: Text('XU HƯỚNG MÙA HÈ', style: GoogleFonts.epilogue(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: 1)),
                          ),
                          const SizedBox(height: 8),
                          Text('Hành trình di sản tại Vịnh Hạ Long', style: GoogleFonts.epilogue(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white, height: 1.2)),
                          const SizedBox(height: 12),
                          ElevatedButton(
                            onPressed: () {
                              Navigator.push(
                                context, 
                                MaterialPageRoute(builder: (context) => const CreateTripScreen(initialDestination: 'Vịnh Hạ Long')) // Truyền tên đi
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: Colors.black,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
                            ),
                            child: const Text('Xem chi tiết', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                          )
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // 4. Section Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Điểm đến tiêu biểu', style: GoogleFonts.epilogue(fontSize: 20, fontWeight: FontWeight.w800, color: AppColors.textDark)),
                  Text('Xem tất cả', style: GoogleFonts.epilogue(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.orange)),
                ],
              ),
            ),
            
            const SizedBox(height: 16),

            // 5. Destination List
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  // Card 1
                  _buildDestinationCard(
                    context, 
                    title: 'Nha Trang',
                    location: 'Khánh Hòa, Việt Nam',
                    price: '2.5M VNĐ',
                    rating: '4.9',
                    imageUrl: 'https://picsum.photos/id/1043/800/600', // FIX ẢNH 2
                    tags: ['Lặn biển', 'Nhảy đảo', '+2 khác'],
                  ),
                  const SizedBox(height: 20),
                  // Card 2
                  _buildDestinationCard(
                    context, 
                    title: 'Sapa',
                    location: 'Lào Cai, Việt Nam',
                    price: '1.8M VNĐ',
                    rating: '4.7',
                    imageUrl: 'https://picsum.photos/id/1018/800/600', // FIX ẢNH 3
                    tags: ['Trekking', 'Chợ phiên', 'Homestay'],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            // 6. Editorial Insights
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text('Kinh nghiệm du lịch', style: GoogleFonts.epilogue(fontSize: 20, fontWeight: FontWeight.w800, color: AppColors.textDark)),
            ),
            const SizedBox(height: 16),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  _buildInsightCard(
                    category: 'Mẹo du lịch',
                    title: 'Làm sao để tối ưu hóa ngân sách khi đi theo nhóm?',
                    imageUrl: 'https://picsum.photos/id/1019/400/300', // FIX ẢNH 4
                  ),
                  const SizedBox(width: 16),
                  _buildInsightCard(
                    category: 'Ẩm thực',
                    title: 'Top 5 món ăn đường phố phải thử tại Hà Nội',
                    imageUrl: 'https://picsum.photos/id/1020/400/300', // FIX ẢNH 5
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- WIDGET CON ---

  Widget _buildChip(String label, {bool isActive = false}) {
    return Container(
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        color: isActive ? AppColors.orange : Colors.white,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: isActive ? AppColors.orange : Colors.grey.shade200),
        boxShadow: isActive ? [BoxShadow(color: AppColors.orange.withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 4))] : [],
      ),
      child: Text(label, style: GoogleFonts.epilogue(fontSize: 13, fontWeight: FontWeight.w600, color: isActive ? Colors.white : Colors.grey.shade600)),
    );
  }

  Widget _buildDestinationCard(BuildContext context, {required String title, required String location, required String price, required String rating, required String imageUrl, required List<String> tags}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 15, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Ảnh & Rating
          Stack(
            children: [
              Container(
                height: 200,
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                  // HỖ TRỢ LOAD CẢ ẢNH MẠNG VÀ ẢNH ASSET NHƯ TRANG CHỦ
                  image: DecorationImage(
                    image: imageUrl.startsWith('http')
                        ? NetworkImage(imageUrl)
                        : AssetImage(imageUrl) as ImageProvider,
                    fit: BoxFit.cover
                  ),
                ),
              ),
              Positioned(
                top: 12, right: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(color: Colors.white.withOpacity(0.9), borderRadius: BorderRadius.circular(20)),
                  child: Row(children: [
                    const Icon(Icons.star, color: Colors.amber, size: 14),
                    const SizedBox(width: 4),
                    Text(rating, style: GoogleFonts.epilogue(fontWeight: FontWeight.bold, fontSize: 12))
                  ]),
                ),
              )
            ],
          ),
          // Thông tin
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(title, style: GoogleFonts.epilogue(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textDark)),
                        const SizedBox(height: 4),
                        Row(children: [
                          Icon(Icons.location_on, size: 14, color: Colors.grey.shade400),
                          const SizedBox(width: 4),
                          Text(location, style: GoogleFonts.epilogue(fontSize: 12, color: Colors.grey.shade500)),
                        ]),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text('CHI PHÍ TB', style: GoogleFonts.epilogue(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey.shade400)),
                        Text(price, style: GoogleFonts.epilogue(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.orange)),
                      ],
                    )
                  ],
                ),
                const SizedBox(height: 16),
                // Tags
                Row(children: tags.map((tag) => Container(
                  margin: const EdgeInsets.only(right: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(color: AppColors.background, borderRadius: BorderRadius.circular(8)),
                  child: Text(tag, style: GoogleFonts.epilogue(fontSize: 10, fontWeight: FontWeight.w600, color: Colors.grey.shade600)),
                )).toList()),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      // TRUYỀN TÊN ĐỊA ĐIỂM SANG TRANG TẠO CHUYẾN ĐI
                      Navigator.push(
                        context, 
                        MaterialPageRoute(builder: (context) => CreateTripScreen(initialDestination: title))
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.orange.withOpacity(0.1),
                      foregroundColor: AppColors.orange,
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: const Text('Lên kế hoạch ngay', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                )
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildInsightCard({required String category, required String title, required String imageUrl}) {
    return Container(
      width: 240,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 140,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              image: DecorationImage(
                image: imageUrl.startsWith('http')
                        ? NetworkImage(imageUrl)
                        : AssetImage(imageUrl) as ImageProvider,
                fit: BoxFit.cover
              ),
            ),
          ),
          const SizedBox(height: 10),
          Text(category.toUpperCase(), style: GoogleFonts.epilogue(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.orange)),
          const SizedBox(height: 4),
          Text(title, style: GoogleFonts.epilogue(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textDark, height: 1.4), maxLines: 2, overflow: TextOverflow.ellipsis),
        ],
      ),
    );
  }
}