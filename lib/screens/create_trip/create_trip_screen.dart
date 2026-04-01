import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:tri_go/constants.dart';
import 'package:tri_go/models/trip.dart';
import 'package:tri_go/data/mock_data.dart';

class CreateTripScreen extends StatefulWidget {
  // THÊM BIẾN ĐỂ NHẬN DỮ LIỆU TỪ TRANG KHÁM PHÁ TRUYỀN SANG
  final String? initialDestination; 
  
  const CreateTripScreen({super.key, this.initialDestination});

  @override
  State<CreateTripScreen> createState() => _CreateTripScreenState();
}

class _CreateTripScreenState extends State<CreateTripScreen> {
  final TextEditingController _titleController = TextEditingController();
  late TextEditingController _destinationController; // Dùng 'late' vì sẽ gán giá trị ở initState
  final TextEditingController _budgetController = TextEditingController();

  DateTime? _startDate;
  DateTime? _endDate;

  @override
  void initState() {
    super.initState();
    // TỰ ĐỘNG ĐIỀN TÊN ĐỊA ĐIỂM NẾU CÓ
    _destinationController = TextEditingController(text: widget.initialDestination ?? '');
  }

  Future<void> _selectDateRange(BuildContext context) async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime.now(),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: Colors.white,
              onSurface: AppColors.textDark,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _startDate = picked.start;
        _endDate = picked.end;
      });
    }
  }

  void _submitTrip() {
    if (_titleController.text.isEmpty || 
        _destinationController.text.isEmpty || 
        _budgetController.text.isEmpty || 
        _startDate == null || 
        _endDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng điền đầy đủ thông tin!')),
      );
      return;
    }

    final newTrip = Trip(
      id: 'T_${DateTime.now().millisecondsSinceEpoch}',
      title: _titleController.text,
      destinationName: _destinationController.text,
      imageUrl: 'https://picsum.photos/id/1015/800/600', 
      startDate: _startDate!,
      endDate: _endDate!,
      budgetLimit: double.tryParse(_budgetController.text) ?? 0,
    );

    mockTrips.insert(0, newTrip);
    Navigator.pop(context, true); 
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: AppColors.textDark),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('Tạo chuyến đi mới', 
          style: GoogleFonts.plusJakartaSans(color: AppColors.textDark, fontWeight: FontWeight.bold, fontSize: 18)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildLabel('Tên chuyến đi'),
            _buildTextField(controller: _titleController, hintText: 'VD: Mùa hè rực rỡ tại Đà Nẵng', icon: Icons.explore_outlined),
            const SizedBox(height: 24),

            _buildLabel('Điểm đến'),
            _buildTextField(controller: _destinationController, hintText: 'VD: Đà Nẵng', icon: Icons.location_on_outlined),
            const SizedBox(height: 24),

            _buildLabel('Thời gian (Ngày đi - Ngày về)'),
            GestureDetector(
              onTap: () => _selectDateRange(context),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(color: Colors.grey.shade50, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.grey.shade200)),
                child: Row(
                  children: [
                    Icon(Icons.calendar_today_outlined, color: Colors.grey.shade500),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        _startDate == null ? 'Chọn ngày đi và ngày về' : '${DateFormat('dd/MM/yyyy').format(_startDate!)} - ${DateFormat('dd/MM/yyyy').format(_endDate!)}',
                        style: GoogleFonts.plusJakartaSans(color: _startDate == null ? Colors.grey.shade500 : AppColors.textDark, fontSize: 15),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            _buildLabel('Ngân sách dự kiến (VNĐ)'),
            _buildTextField(controller: _budgetController, hintText: 'VD: 5000000', icon: Icons.account_balance_wallet_outlined, keyboardType: TextInputType.number),
            const SizedBox(height: 40),

            SizedBox(
              width: double.infinity, height: 56,
              child: ElevatedButton(
                onPressed: _submitTrip,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: Text('Khởi tạo hành trình', style: GoogleFonts.plusJakartaSans(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildLabel(String text) => Padding(padding: const EdgeInsets.only(bottom: 8, left: 4), child: Text(text, style: GoogleFonts.plusJakartaSans(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.grey.shade700)));

  Widget _buildTextField({required TextEditingController controller, required String hintText, required IconData icon, TextInputType keyboardType = TextInputType.text}) {
    return Container(
      decoration: BoxDecoration(color: Colors.grey.shade50, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.grey.shade200)),
      child: TextField(
        controller: controller, keyboardType: keyboardType,
        decoration: InputDecoration(hintText: hintText, hintStyle: GoogleFonts.plusJakartaSans(color: Colors.grey.shade400, fontSize: 15), border: InputBorder.none, contentPadding: const EdgeInsets.symmetric(vertical: 20), prefixIcon: Icon(icon, color: Colors.grey.shade500)),
      ),
    );
  }
}