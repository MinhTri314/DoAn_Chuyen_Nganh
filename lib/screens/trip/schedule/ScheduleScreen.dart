import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AddActivityScreen extends StatefulWidget {
  const AddActivityScreen({super.key});

  @override
  State<AddActivityScreen> createState() => _AddActivityScreenState();
}

class _AddActivityScreenState extends State<AddActivityScreen> {
  // Màu sắc chủ đạo
  static const Color primaryColor = Color(0xFF1999B3);
  static const Color textDark = Color(0xFF111617);
  
  // State quản lý loại hoạt động đang chọn
  int _selectedIndex = 0;
  
  final List<Map<String, dynamic>> _categories = [
    {'icon': Icons.restaurant, 'label': 'Ăn uống'},
    {'icon': Icons.camera_alt, 'label': 'Chụp ảnh'},
    {'icon': Icons.local_cafe, 'label': 'Cà phê'},
    {'icon': Icons.hotel, 'label': 'Nghỉ ngơi'},
    {'icon': Icons.directions_car, 'label': 'Di chuyển'},
    {'icon': Icons.more_horiz, 'label': 'Khác'},
  ];

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
                  // 1. Tên hoạt động
                  _buildLabel('Tên hoạt động'),
                  _buildTextField(hintText: 'Ví dụ: Ăn trưa tại chợ Đà Lạt'),
                  
                  const SizedBox(height: 24),
                  
                  // 2. Thời gian
                  _buildLabel('Thời gian'),
                  _buildTextField(hintText: '08:00 AM', icon: Icons.access_time, isReadOnly: true),
                  
                  const SizedBox(height: 24),
                  
                  // 3. Địa điểm
                  _buildLabel('Địa điểm'),
                  _buildTextField(hintText: 'Tìm kiếm địa điểm...', icon: Icons.location_on, iconColor: primaryColor),
                  
                  const SizedBox(height: 24),
                  
                  // 4. Loại hoạt động
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
                                    color: isSelected ? primaryColor : Colors.white,
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(color: isSelected ? primaryColor : Colors.grey.shade200),
                                    boxShadow: isSelected 
                                      ? [BoxShadow(color: primaryColor.withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 4))] 
                                      : [],
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
                                    fontSize: 12, 
                                    fontWeight: FontWeight.bold,
                                    color: isSelected ? primaryColor : Colors.grey.shade400
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
          
          // Button Lưu
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(top: BorderSide(color: Colors.grey.shade100)),
            ),
            child: SafeArea(
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context), // Giả lập lưu xong thì đóng
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    elevation: 5,
                    shadowColor: primaryColor.withOpacity(0.4),
                  ),
                  child: Text('Lưu vào lịch trình', 
                    style: GoogleFonts.plusJakartaSans(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, left: 4),
      child: Text(text, 
        style: GoogleFonts.plusJakartaSans(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.grey.shade500)),
    );
  }

  Widget _buildTextField({required String hintText, IconData? icon, Color? iconColor, bool isReadOnly = false}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: TextField(
        readOnly: isReadOnly,
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: GoogleFonts.plusJakartaSans(color: Colors.grey.shade400),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.all(20),
          prefixIcon: icon != null ? Icon(icon, color: iconColor ?? Colors.grey.shade400) : null,
          suffixIcon: isReadOnly ? const Icon(Icons.keyboard_arrow_down, color: Colors.grey) : null,
        ),
      ),
    );
  }
}