import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tri_go/constants.dart';
// Import màn hình Thêm thành viên
import 'package:tri_go/screens/create_trip/add_member_screen.dart'; 

class CreateTripScreen extends StatelessWidget {
  const CreateTripScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC), // Màu nền hơi xanh nhẹ theo thiết kế
      appBar: AppBar(
        backgroundColor: Colors.white.withOpacity(0.8),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black54, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('Tạo Lịch trình Mới',
            style: GoogleFonts.epilogue(
                color: Colors.black, fontWeight: FontWeight.bold, fontSize: 18)),
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: Colors.grey.shade200, height: 1),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Tên chuyến đi
            _buildLabel('Tên chuyến đi'),
            Container(
              height: 56,
              decoration: _inputDecoration(),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              alignment: Alignment.centerLeft,
              child: TextField(
                style: GoogleFonts.epilogue(color: AppColors.textDark),
                decoration: InputDecoration(
                  border: InputBorder.none,
                  hintText: 'VD: Mùa hè rực rỡ tại Phú Quốc',
                  hintStyle: GoogleFonts.epilogue(color: Colors.grey.shade400),
                ),
              ),
            ),

            const SizedBox(height: 24),

            // 2. Thời gian chuyến đi
            _buildLabel('Thời gian chuyến đi'),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade200),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10)],
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      // Ngày đi
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('NGÀY ĐI', style: GoogleFonts.epilogue(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey.shade400)),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                const Icon(Icons.calendar_today, color: AppColors.blue, size: 20),
                                const SizedBox(width: 8),
                                Text('15/07/2024', style: GoogleFonts.epilogue(fontWeight: FontWeight.bold, color: AppColors.textDark)),
                              ],
                            )
                          ],
                        ),
                      ),
                      Container(width: 1, height: 40, color: Colors.grey.shade200),
                      const SizedBox(width: 16),
                      // Ngày về
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('NGÀY VỀ', style: GoogleFonts.epilogue(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey.shade400)),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                const Icon(Icons.calendar_month, color: AppColors.blue, size: 20),
                                const SizedBox(width: 8),
                                Text('20/07/2024', style: GoogleFonts.epilogue(fontWeight: FontWeight.bold, color: AppColors.textDark)),
                              ],
                            )
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Divider(height: 1),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Số ngày đi:', style: GoogleFonts.epilogue(color: Colors.grey.shade500, fontSize: 13)),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(color: AppColors.blue.withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
                        child: Text('5 Ngày 4 Đêm', style: GoogleFonts.epilogue(color: AppColors.blue, fontWeight: FontWeight.bold, fontSize: 12)),
                      )
                    ],
                  )
                ],
              ),
            ),

            const SizedBox(height: 24),

            // 3. Thành viên
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildLabel('Thành viên', marginBottom: 0),
                Text('Đã thêm 01', style: GoogleFonts.epilogue(fontSize: 12, color: Colors.grey.shade400)),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                // --- NÚT THÊM THÀNH VIÊN (ĐÃ SỬA) ---
                InkWell(
                  onTap: () {
                    Navigator.push(
                      context, 
                      MaterialPageRoute(builder: (context) => const AddMemberScreen())
                    );
                  },
                  child: Container(
                    width: 60, height: 60,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.grey.shade300, style: BorderStyle.solid), 
                    ),
                    child: const Icon(Icons.add, color: Colors.grey),
                  ),
                ),
                // ------------------------------------
                
                const SizedBox(width: 12),
                
                // Avatar người dùng
                Column(
                  children: [
                    Stack(
                      children: [
                        Container(
                          width: 60, height: 60,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: AppColors.blue, width: 2),
                            image: const DecorationImage(
                              image: NetworkImage('https://i.pravatar.cc/150?img=12'),
                              fit: BoxFit.cover
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: 0, right: 0,
                          child: Container(
                            padding: const EdgeInsets.all(2),
                            decoration: const BoxDecoration(color: AppColors.blue, borderRadius: BorderRadius.only(topLeft: Radius.circular(8))),
                            child: const Icon(Icons.star, color: Colors.white, size: 10),
                          ),
                        )
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text('Bạn', style: GoogleFonts.epilogue(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey.shade500))
                  ],
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Chưa mời ai tham gia? Nhấn dấu (+) để thêm bạn bè.',
                    style: GoogleFonts.epilogue(fontSize: 12, color: Colors.grey.shade400, fontStyle: FontStyle.italic),
                  ),
                )
              ],
            ),

            const SizedBox(height: 24),

            // 4. Mô tả
            Row(
              children: [
                _buildLabel('Mô tả chuyến đi', marginBottom: 0),
                const SizedBox(width: 4),
                Text('(Tùy chọn)', style: GoogleFonts.epilogue(fontSize: 12, color: Colors.grey.shade400)),
              ],
            ),
            const SizedBox(height: 8),
            Container(
              height: 120,
              decoration: _inputDecoration(),
              padding: const EdgeInsets.all(16),
              child: TextField(
                maxLines: 5,
                style: GoogleFonts.epilogue(color: AppColors.textDark),
                decoration: InputDecoration(
                  border: InputBorder.none,
                  hintText: 'Ghi chú về sở thích, lưu ý về sức khỏe hoặc ngân sách dự kiến...',
                  hintStyle: GoogleFonts.epilogue(color: Colors.grey.shade400),
                ),
              ),
            ),

            const SizedBox(height: 32),

            // 5. Nút Tạo
            SizedBox(
              width: double.infinity,
              height: 60,
              child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.blue,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 8,
                  shadowColor: AppColors.blue.withOpacity(0.3),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Tạo hành trình ngay', style: GoogleFonts.epilogue(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                    const SizedBox(width: 8),
                    const Icon(Icons.arrow_forward, color: Colors.white),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                'Bằng cách tạo lịch trình, bạn có thể bắt đầu thêm các điểm đến và quản lý chi phí nhóm.',
                textAlign: TextAlign.center,
                style: GoogleFonts.epilogue(fontSize: 11, color: Colors.grey.shade400, height: 1.5),
              ),
            ),
            
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildLabel(String text, {double marginBottom = 8}) {
    return Padding(
      padding: EdgeInsets.only(bottom: marginBottom, left: 4),
      child: Text(text, style: GoogleFonts.epilogue(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.textDark)),
    );
  }

  BoxDecoration _inputDecoration() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 4)],
    );
  }
}