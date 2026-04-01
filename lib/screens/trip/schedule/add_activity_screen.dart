import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tri_go/models/activity.dart'; // Đảm bảo đã có file này

class AddActivityScreen extends StatefulWidget {
  const AddActivityScreen({super.key});

  @override
  State<AddActivityScreen> createState() => _AddActivityScreenState();
}

class _AddActivityScreenState extends State<AddActivityScreen> {
  static const Color primaryColor = Color(0xFF1999B3);
  static const Color textDark = Color(0xFF111617);
  
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _timeController = TextEditingController(text: '08:00');
  final TextEditingController _locationController = TextEditingController();

  int _selectedIndex = 0;
  
  final List<Map<String, dynamic>> _categories = [
    {'icon': Icons.restaurant, 'label': 'Ăn uống', 'color': const Color(0xFF1999B3)},
    {'icon': Icons.camera_alt, 'label': 'Chụp ảnh', 'color': const Color(0xFFF79A7F)},
    {'icon': Icons.local_cafe, 'label': 'Cà phê', 'color': const Color(0xFF8B5CF6)},
    {'icon': Icons.hotel, 'label': 'Nghỉ ngơi', 'color': Colors.blue},
    {'icon': Icons.directions_car, 'label': 'Di chuyển', 'color': Colors.orange},
    {'icon': Icons.more_horiz, 'label': 'Khác', 'color': Colors.grey},
  ];

  // --- HÀM MỚI: HIỆN BẢNG CHỌN GIỜ (TIME PICKER) ---
  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: primaryColor, // Màu của đồng hồ
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        // Format giờ:phút cho đẹp (VD: 08:05 thay vì 8:5)
        final String hour = picked.hour.toString().padLeft(2, '0');
        final String minute = picked.minute.toString().padLeft(2, '0');
        _timeController.text = '$hour:$minute';
      });
    }
  }

  // --- HÀM LƯU DỮ LIỆU VÀ ĐÓNG TRANG ---
  void _saveActivity() {
    if (_titleController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng nhập tên hoạt động!')),
      );
      return;
    }

    final newActivity = Activity(
      title: _titleController.text,
      time: _timeController.text,
      location: _locationController.text.isEmpty ? 'Chưa xác định' : _locationController.text,
      icon: _categories[_selectedIndex]['icon'],
      color: _categories[_selectedIndex]['color'],
    );

    // Gửi data newActivity về cho màn hình trước đó
    Navigator.pop(context, newActivity);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: textDark),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('Thêm hoạt động mới', 
          style: GoogleFonts.plusJakartaSans(color: textDark, fontWeight: FontWeight.w800, fontSize: 18)),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildLabel('Tên hoạt động'),
                  _buildTextField(controller: _titleController, hintText: 'Ví dụ: Ăn trưa tại chợ Đà Lạt'),
                  const SizedBox(height: 24),
                  
                  // --- Ô CHỌN THỜI GIAN ĐÃ ĐƯỢC NÂNG CẤP ---
                  _buildLabel('Thời gian'),
                  GestureDetector(
                    onTap: () => _selectTime(context), // Bấm vào để mở bảng chọn giờ
                    child: AbsorbPointer( // Chặn bàn phím hiện lên
                      child: _buildTextField(
                        controller: _timeController, 
                        hintText: '08:00', 
                        icon: Icons.access_time,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  _buildLabel('Địa điểm'),
                  _buildTextField(controller: _locationController, hintText: 'Tìm kiếm địa điểm...', icon: Icons.location_on, iconColor: primaryColor),
                  const SizedBox(height: 24),
                  
                  _buildLabel('Loại hoạt động'),
                  const SizedBox(height: 12),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: List.generate(_categories.length, (index) {
                        final isSelected = _selectedIndex == index;
                        return GestureDetector(
                          onTap: () => setState(() => _selectedIndex = index),
                          child: Container(
                            margin: const EdgeInsets.only(right: 16),
                            child: Column(
                              children: [
                                Container(
                                  width: 60, height: 60,
                                  decoration: BoxDecoration(
                                    color: isSelected ? _categories[index]['color'] : Colors.white,
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(color: isSelected ? _categories[index]['color'] : Colors.grey.shade200),
                                  ),
                                  child: Icon(
                                    _categories[index]['icon'], 
                                    color: isSelected ? Colors.white : Colors.grey.shade400,
                                    size: 28
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  _categories[index]['label'],
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 12, fontWeight: FontWeight.bold,
                                    color: isSelected ? _categories[index]['color'] : Colors.grey.shade400
                                  ),
                                )
                              ],
                            ),
                          ),
                        );
                      }),
                    ),
                  )
                ],
              ),
            ),
          ),
          
          // --- NÚT LƯU ---
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(color: Colors.white, border: Border(top: BorderSide(color: Colors.grey.shade100))),
            child: SafeArea(
              child: SizedBox(
                width: double.infinity, height: 56,
                child: ElevatedButton(
                  onPressed: _saveActivity, // Gắn sự kiện Lưu vào đây
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: Text('Lưu vào lịch trình', style: GoogleFonts.plusJakartaSans(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildLabel(String text) => Padding(padding: const EdgeInsets.only(bottom: 12, left: 4), child: Text(text, style: GoogleFonts.plusJakartaSans(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.grey.shade500)));

  Widget _buildTextField({required TextEditingController controller, required String hintText, IconData? icon, Color? iconColor}) {
    return Container(
      decoration: BoxDecoration(color: Colors.grey.shade50, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.grey.shade100)),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          hintText: hintText, border: InputBorder.none, contentPadding: const EdgeInsets.all(20),
          prefixIcon: icon != null ? Icon(icon, color: iconColor ?? Colors.grey.shade400) : null,
        ),
      ),
    );
  }
}