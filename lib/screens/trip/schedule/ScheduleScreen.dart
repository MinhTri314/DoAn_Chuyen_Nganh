import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tri_go/models/activity.dart'; // Import Model
import 'add_activity_screen.dart';

class ScheduleScreen extends StatefulWidget {
  const ScheduleScreen({super.key});

  @override
  State<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends State<ScheduleScreen> {
  static const Color primaryColor = Color(0xFF1999B3);
  static const Color coralColor = Color(0xFFF79A7F);

  // Tạo một danh sách lịch trình giả định ban đầu
  List<Activity> scheduleList = [
    Activity(title: 'Ăn sáng tại Bánh mì Xíu mại', time: '08:00', location: '26 Hoàng Diệu, Đà Lạt', icon: Icons.restaurant, color: primaryColor),
    Activity(title: 'Check-in Quảng trường Lâm Viên', time: '09:30', location: 'Phường 10, Đà Lạt', icon: Icons.camera_alt, color: coralColor),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black), onPressed: () => Navigator.pop(context)),
        title: Text('Lịch trình Chuyến đi', style: GoogleFonts.plusJakartaSans(color: Colors.black, fontWeight: FontWeight.w800)),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // 1. Day Tabs (Giữ nguyên giao diện)
          Container(
            height: 60, padding: const EdgeInsets.symmetric(vertical: 8),
            child: ListView(
              scrollDirection: Axis.horizontal, padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                _buildDayTab('Ngày 1', true), _buildDayTab('Ngày 2', false),
              ],
            ),
          ),
          
          // 2. Timeline List (Tự động load từ danh sách scheduleList)
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(24),
              itemCount: scheduleList.length + 1, // Cộng 1 để chừa chỗ cho Nút "Thêm hoạt động" ở cuối cùng
              itemBuilder: (context, index) {
                
                // Nếu là phần tử cuối cùng thì in ra Nút Thêm
                if (index == scheduleList.length) {
                  return Column(
                    children: [
                      const SizedBox(height: 16),
                      InkWell(
                        onTap: () async {
                          // Bấm nút thêm -> Chờ kết quả trả về từ trang AddActivity
                          final Activity? newAct = await Navigator.push(
                            context, 
                            MaterialPageRoute(builder: (context) => const AddActivityScreen())
                          );

                          // Nếu có dữ liệu trả về -> Thêm vào List và báo UI vẽ lại
                          if (newAct != null) {
                            setState(() {
                              scheduleList.add(newAct);
                              // Tùy chọn: Bạn có thể viết hàm sort() ở đây để sắp xếp lại theo giờ
                            });
                          }
                        },
                        child: Container(
                          height: 56,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade50, borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.grey.shade300, style: BorderStyle.solid),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.add_circle, color: Colors.grey),
                              const SizedBox(width: 8),
                              Text('Thêm hoạt động', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold, color: Colors.grey)),
                            ],
                          ),
                        ),
                      )
                    ],
                  );
                }

                // Nếu không phải phần tử cuối thì in ra UI của Timeline
                final act = scheduleList[index];
                return _buildTimelineItem(
                  time: act.time,
                  title: act.title,
                  location: act.location,
                  icon: act.icon,
                  color: act.color,
                  isFirst: index == 0,
                  isLast: index == scheduleList.length - 1, // Đường kẻ dọc
                );
              },
            ),
          )
        ],
      ),
    );
  }

  // --- Các hàm UI phụ trợ giữ nguyên ---
  Widget _buildDayTab(String text, bool isSelected) {
    return Container(
      margin: const EdgeInsets.only(right: 12), padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8), alignment: Alignment.center,
      decoration: BoxDecoration(
        color: isSelected ? primaryColor : Colors.white, borderRadius: BorderRadius.circular(20),
        border: Border.all(color: isSelected ? primaryColor : Colors.grey.shade200),
      ),
      child: Text(text, style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold, color: isSelected ? Colors.white : Colors.grey.shade500)),
    );
  }

  Widget _buildTimelineItem({required String time, required String title, required String location, required IconData icon, required Color color, bool isFirst = false, bool isLast = false}) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 50,
            child: Column(
              children: [
                Container(
                  width: 40, height: 40,
                  decoration: BoxDecoration(color: color.withOpacity(0.1), shape: BoxShape.circle, border: Border.all(color: Colors.white, width: 4)),
                  child: Icon(icon, color: color, size: 20),
                ),
                // Đường nối dọc giữa các mốc thời gian
                Expanded(child: Container(width: 2, color: Colors.grey.shade200))
              ],
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(time, style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold, color: color)),
                      if (isFirst) ...[
                        const Spacer(),
                        Text('ĐÃ LÊN LỊCH', style: GoogleFonts.plusJakartaSans(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey.shade400)),
                      ]
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(title, style: GoogleFonts.plusJakartaSans(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black)),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.location_on, size: 14, color: Colors.grey.shade400),
                      const SizedBox(width: 4),
                      Text(location, style: GoogleFonts.plusJakartaSans(fontSize: 13, color: Colors.grey.shade500)),
                    ],
                  )
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}