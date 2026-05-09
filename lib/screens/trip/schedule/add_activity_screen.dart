import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_map/flutter_map.dart'; 
import 'package:latlong2/latlong.dart'; 
import 'dart:convert'; 
import 'dart:io'; 

class AddActivityScreen extends StatefulWidget {
  final String tripId; 
  const AddActivityScreen({super.key, required this.tripId});

  @override
  State<AddActivityScreen> createState() => _AddActivityScreenState();
}

class _AddActivityScreenState extends State<AddActivityScreen> {
  static const Color primaryColor = Color(0xFF1999B3);
  static const Color textDark = Color(0xFF111617);
  
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _timeController = TextEditingController(text: '08:00');
  final TextEditingController _locationController = TextEditingController();

  double? _selectedLat; // Lưu vĩ độ
  double? _selectedLng; // Lưu kinh độ

  int _selectedIndex = 0;
  bool _isSaving = false;
  String _destinationName = 'Đà Lạt'; 
  
  final List<Map<String, dynamic>> _categories = [
    {'iconCode': Icons.restaurant.codePoint, 'label': 'Ăn uống', 'color': 0xFF1999B3},
    {'iconCode': Icons.camera_alt.codePoint, 'label': 'Chụp ảnh', 'color': 0xFFF79A7F},
    {'iconCode': Icons.local_cafe.codePoint, 'label': 'Cà phê', 'color': 0xFF8B5CF6},
    {'iconCode': Icons.hotel.codePoint, 'label': 'Nghỉ ngơi', 'color': 0xFF2196F3},
    {'iconCode': Icons.directions_car.codePoint, 'label': 'Di chuyển', 'color': 0xFFFF9800},
    {'iconCode': Icons.more_horiz.codePoint, 'label': 'Khác', 'color': 0xFF9E9E9E},
  ];

  @override
  void initState() {
    super.initState();
    _fetchDestinationName(); 
  }

  Future<void> _fetchDestinationName() async {
    final snap = await FirebaseDatabase.instance.ref('trips/${widget.tripId}/destinationName').get();
    if (snap.exists && mounted) {
      setState(() {
        _destinationName = snap.value.toString();
      });
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context, initialTime: TimeOfDay.now(),
      builder: (context, child) => Theme(data: Theme.of(context).copyWith(colorScheme: const ColorScheme.light(primary: primaryColor)), child: child!),
    );

    if (picked != null) {
      setState(() {
        _timeController.text = '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
      });
    }
  }

  Future<void> _openMapSelector() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => MapSelectionScreen(destination: _destinationName)),
    );
    
    // Nhận cả Tên địa chỉ VÀ Tọa độ từ Map trả về
    if (result != null && result is Map) {
      setState(() {
        _locationController.text = result['name'];
        _selectedLat = result['lat'];
        _selectedLng = result['lng'];
      });
    }
  }

  Future<void> _saveActivity() async {
    if (_titleController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Vui lòng nhập tên hoạt động!')));
      return;
    }

    setState(() => _isSaving = true);
    try {
      // ĐẨY LUÔN TỌA ĐỘ LÊN FIREBASE ĐỂ GOOGLE MAPS DẪN ĐƯỜNG
      await FirebaseDatabase.instance.ref('trips/${widget.tripId}/activities').push().set({
        'title': _titleController.text.trim(),
        'time': _timeController.text,
        'location': _locationController.text.isEmpty ? 'Chưa xác định' : _locationController.text,
        'lat': _selectedLat,
        'lng': _selectedLng,
        'iconCode': _categories[_selectedIndex]['iconCode'],
        'colorCode': _categories[_selectedIndex]['color'],
        'timestamp': ServerValue.timestamp,
      });

      if (mounted) {
        Navigator.pop(context); 
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Thêm lịch trình thành công!'), backgroundColor: Colors.green));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Lỗi: $e')));
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white, elevation: 0,
        leading: IconButton(icon: const Icon(Icons.close, color: textDark), onPressed: () => Navigator.pop(context)),
        title: Text('Thêm hoạt động', style: GoogleFonts.plusJakartaSans(color: textDark, fontWeight: FontWeight.w800, fontSize: 18)), centerTitle: true,
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
                  
                  _buildLabel('Thời gian'),
                  GestureDetector(
                    onTap: () => _selectTime(context),
                    child: AbsorbPointer(child: _buildTextField(controller: _timeController, hintText: '08:00', icon: Icons.access_time)),
                  ),
                  const SizedBox(height: 24),
                  
                  _buildLabel('Địa điểm'),
                  GestureDetector(
                    onTap: _openMapSelector, 
                    child: AbsorbPointer(
                      child: _buildTextField(controller: _locationController, hintText: 'Bấm để mở Bản Đồ...', icon: Icons.map, iconColor: primaryColor),
                    ),
                  ),
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
                                    color: isSelected ? Color(_categories[index]['color']) : Colors.white,
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(color: isSelected ? Color(_categories[index]['color']) : Colors.grey.shade200),
                                  ),
                                  child: Icon(
                                    IconData(_categories[index]['iconCode'], fontFamily: 'MaterialIcons'), 
                                    color: isSelected ? Colors.white : Colors.grey.shade400, size: 28
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  _categories[index]['label'],
                                  style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.bold, color: isSelected ? Color(_categories[index]['color']) : Colors.grey.shade400),
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
          
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(color: Colors.white, border: Border(top: BorderSide(color: Colors.grey.shade100))),
            child: SafeArea(
              child: SizedBox(
                width: double.infinity, height: 56,
                child: ElevatedButton(
                  onPressed: _isSaving ? null : _saveActivity,
                  style: ElevatedButton.styleFrom(backgroundColor: primaryColor, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
                  child: _isSaving ? const CircularProgressIndicator(color: Colors.white) : Text('Lưu vào lịch trình', style: GoogleFonts.plusJakartaSans(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
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

// =======================================================================
// MÀN HÌNH BẢN ĐỒ: DỊCH NGƯỢC TỌA ĐỘ RA ĐỊA CHỈ THỰC TẾ
// =======================================================================
class MapSelectionScreen extends StatefulWidget {
  final String destination; 
  const MapSelectionScreen({super.key, required this.destination});

  @override
  State<MapSelectionScreen> createState() => _MapSelectionScreenState();
}

class _MapSelectionScreenState extends State<MapSelectionScreen> {
  final MapController _mapController = MapController();
  final TextEditingController _searchController = TextEditingController();
  
  LatLng _center = const LatLng(11.940419, 108.458313); 
  bool _isLoadingMap = true; 
  bool _isSearching = false;
  bool _isConvertingAddress = false; // Biến xoay loading lúc bấm ghim

  @override
  void initState() {
    super.initState();
    _searchController.text = widget.destination;
    _findCoordinates(widget.destination, isInitial: true);
  }

  Future<void> _findCoordinates(String query, {bool isInitial = false}) async {
    if (query.isEmpty) return;
    
    if (!isInitial) {
      FocusManager.instance.primaryFocus?.unfocus(); 
      setState(() => _isSearching = true);
    }

    try {
      final url = Uri.parse('https://nominatim.openstreetmap.org/search?q=${Uri.encodeComponent(query)}&format=json&limit=1');
      final request = await HttpClient().getUrl(url);
      request.headers.set('User-Agent', 'tri_go_app_student_project'); 
      
      final response = await request.close();
      if (response.statusCode == 200) {
        final stringData = await response.transform(utf8.decoder).join();
        final data = json.decode(stringData);
        
        if (data.isNotEmpty) {
          double lat = double.parse(data[0]['lat'].toString());
          double lon = double.parse(data[0]['lon'].toString());
          LatLng newCenter = LatLng(lat, lon);
          
          if (mounted) {
            setState(() => _center = newCenter);
            if (!isInitial) _mapController.move(newCenter, 15.0);
          }
        } else {
          if (mounted && !isInitial) {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Không tìm thấy địa điểm này!')));
          }
        }
      }
    } catch (e) {
      debugPrint("Lỗi: $e");
    } finally {
      if (mounted) setState(() { _isLoadingMap = false; _isSearching = false; });
    }
  }

  // --- HÀM MỚI: TỪ TỌA ĐỘ QUÉT RA ĐỊA CHỈ CHỮ ---
  Future<void> _confirmAndGetAddress() async {
    setState(() => _isConvertingAddress = true);
    final LatLng center = _mapController.camera.center;
    String finalLocationName = _searchController.text.trim();

    // Nếu người dùng chỉ kéo map mà không nhập chữ, AI sẽ tự quét địa chỉ
    if (finalLocationName.isEmpty) {
      try {
        final url = Uri.parse('https://nominatim.openstreetmap.org/reverse?format=json&lat=${center.latitude}&lon=${center.longitude}&zoom=18&addressdetails=1');
        final request = await HttpClient().getUrl(url);
        request.headers.set('User-Agent', 'tri_go_app_student_project');
        
        final response = await request.close();
        if (response.statusCode == 200) {
          final stringData = await response.transform(utf8.decoder).join();
          final data = json.decode(stringData);
          // Lấy địa chỉ dễ đọc nhất
          finalLocationName = data['display_name'] ?? "Vị trí đã ghim";
        } else {
          finalLocationName = "Vị trí (${center.latitude.toStringAsFixed(4)}, ${center.longitude.toStringAsFixed(4)})";
        }
      } catch (e) {
        finalLocationName = "Vị trí (${center.latitude.toStringAsFixed(4)}, ${center.longitude.toStringAsFixed(4)})";
      }
    }

    if (mounted) {
      setState(() => _isConvertingAddress = false);
      // GỬI TRẢ VỀ CẢ TÊN LẪN TỌA ĐỘ
      Navigator.pop(context, {
        'name': finalLocationName,
        'lat': center.latitude,
        'lng': center.longitude
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chọn vị trí', style: GoogleFonts.plusJakartaSans(color: Colors.black, fontSize: 16, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white, elevation: 0, leading: const BackButton(color: Colors.black),
      ),
      body: _isLoadingMap 
        ? const Center(child: CircularProgressIndicator(color: Color(0xFF1999B3))) 
        : Stack(
            children: [
              FlutterMap(
                mapController: _mapController,
                options: MapOptions(initialCenter: _center, initialZoom: 14.0),
                children: [
                  TileLayer(urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png', userAgentPackageName: 'com.example.tri_go'),
                ],
              ),
              
              const Center(
                child: Padding(
                  padding: EdgeInsets.only(bottom: 40),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [Icon(Icons.location_pin, color: Colors.red, size: 50)],
                  ),
                ),
              ),

              Positioned(
                top: 16, left: 16, right: 16,
                child: Container(
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 4))]),
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Nhập địa điểm (Để trống sẽ tự quét địa chỉ)',
                      hintStyle: GoogleFonts.plusJakartaSans(fontSize: 14, color: Colors.grey),
                      border: InputBorder.none, contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                      suffixIcon: _isSearching
                          ? const Padding(padding: EdgeInsets.all(12.0), child: CircularProgressIndicator(strokeWidth: 2))
                          : IconButton(icon: const Icon(Icons.search, color: Color(0xFF1999B3)), onPressed: () => _findCoordinates(_searchController.text)),
                    ),
                    onSubmitted: (value) => _findCoordinates(value),
                  ),
                ),
              ),
              
              Positioned(
                bottom: 30, left: 20, right: 20,
                child: ElevatedButton(
                  onPressed: _isConvertingAddress ? null : _confirmAndGetAddress,
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1999B3), padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)), elevation: 8),
                  child: _isConvertingAddress 
                    ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : Text('Ghim & Dùng vị trí này', style: GoogleFonts.plusJakartaSans(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                ),
              ),
            ],
          ),
    );
  }
}