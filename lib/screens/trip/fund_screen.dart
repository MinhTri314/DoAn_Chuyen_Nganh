import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:tri_go/constants.dart';
import 'dart:io';
import 'dart:async'; // BẮT BUỘC PHẢI CÓ ĐỂ FIX LỖI ĐƠ MÁY

class FundScreen extends StatefulWidget {
  final String tripId; 
  const FundScreen({super.key, required this.tripId});

  @override
  State<FundScreen> createState() => _FundScreenState();
}

class _FundScreenState extends State<FundScreen> {
  double _totalFund = 0;
  double _totalExpense = 0;
  List<Map<dynamic, dynamic>> _mergedTransactions = []; 
  bool _isPickingImage = false; 

  // BIẾN LƯU TRỮ LUỒNG LẮNG NGHE FIREBASE (ĐỂ HỦY KHI THOÁT)
  StreamSubscription<DatabaseEvent>? _fundSubscription;

  @override
  void initState() {
    super.initState();
    _listenToTripData();
  }

  // BƯỚC QUAN TRỌNG NHẤT FIX LỖI ĐƠ MÁY: HỦY LẮNG NGHE KHI THOÁT
  @override
  void dispose() {
    _fundSubscription?.cancel();
    super.dispose();
  }

  // --- LẤY DATA (QUỸ + CHI TIÊU + NẠP TIỀN) ---
  void _listenToTripData() {
    _fundSubscription = FirebaseDatabase.instance.ref('trips/${widget.tripId}').onValue.listen((event) {
      if (event.snapshot.value != null && mounted) {
        final data = event.snapshot.value as Map<dynamic, dynamic>;
        
        double currentFund = double.parse((data['currentFund'] ?? 0).toString());
        double totalExp = double.parse((data['totalExpense'] ?? 0).toString());
        List<Map<dynamic, dynamic>> tempList = [];

        if (data['contributions'] != null) {
          (data['contributions'] as Map).forEach((key, value) {
            tempList.add({
              'id': key, 'isExpense': false, 'title': '${value['contributorName']} đóng quỹ',
              'amount': value['amount'], 'timestamp': value['timestamp'] ?? 0,
            });
          });
        }

        if (data['expenses'] != null) {
          (data['expenses'] as Map).forEach((key, value) {
            tempList.add({
              'id': key, 'isExpense': true, 'title': value['shopName'] ?? 'Dịch vụ',
              'payerName': value['payerName'] ?? 'Thành viên', 'note': value['note'] ?? '',
              'billImage': value['billImage'] ?? '', 'amount': value['amount'], 'timestamp': value['timestamp'] ?? 0,
              'items': value['items'] ?? [], // Lấy danh sách món ăn nếu có
            });
          });
        }

        tempList.sort((a, b) => (b['timestamp'] ?? 0).compareTo(a['timestamp'] ?? 0));

        setState(() {
          _totalFund = currentFund;
          _totalExpense = totalExp;
          _mergedTransactions = tempList;
        });
      }
    });
  }

  // --- HÀM THÊM ẢNH HÓA ĐƠN ---
  Future<void> _attachBillImage(String expenseId) async {
    if (_isPickingImage) return;
    setState(() => _isPickingImage = true);

    try {
      final picker = ImagePicker();
      final image = await picker.pickImage(source: ImageSource.gallery);
      
      if (image != null) {
        await FirebaseDatabase.instance.ref('trips/${widget.tripId}/expenses/$expenseId/billImage').set(image.path);
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Đã đính kèm ảnh hóa đơn!'), backgroundColor: Colors.green));
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Lỗi tải ảnh: $e')));
    } finally {
      setState(() => _isPickingImage = false);
    }
  }

  void _showImageDialog(String imagePath) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(16),
        child: Stack(
          alignment: Alignment.topRight,
          children: [
            InteractiveViewer(
              child: ClipRRect(borderRadius: BorderRadius.circular(16), child: Image.file(File(imagePath), fit: BoxFit.contain)),
            ),
            IconButton(
              icon: const Icon(Icons.cancel, color: Colors.white, size: 30),
              onPressed: () => Navigator.pop(context),
            )
          ],
        ),
      ),
    );
  }

  String _formatCurrency(double amount) => NumberFormat.currency(locale: 'vi_VN', symbol: 'đ').format(amount);
  String _formatDateTime(int timestamp) => DateFormat('dd/MM/yyyy - HH:mm').format(DateTime.fromMillisecondsSinceEpoch(timestamp));

  @override
  Widget build(BuildContext context) {
    double remaining = _totalFund - _totalExpense;

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        backgroundColor: Colors.white, elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black54), onPressed: () => Navigator.pop(context)),
        title: Text('Sao kê & Hóa đơn', style: GoogleFonts.plusJakartaSans(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 18)),
        centerTitle: true,
      ),

      body: Column(
        children: [
          // THẺ TỔNG QUAN QUỸ (GIỮ NGUYÊN GIAO DIỆN ĐẸP)
          Container(
            width: double.infinity, margin: const EdgeInsets.all(16), padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [Color(0xFF1999B3), Color(0xFF106E82)], begin: Alignment.topLeft, end: Alignment.bottomRight),
              borderRadius: BorderRadius.circular(24), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 10, offset: const Offset(0, 5))],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('TỔNG QUỸ ĐÃ NẠP', style: GoogleFonts.plusJakartaSans(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Text(_formatCurrency(_totalFund), style: GoogleFonts.plusJakartaSans(color: Colors.white, fontSize: 32, fontWeight: FontWeight.w800)),
                const Padding(padding: EdgeInsets.symmetric(vertical: 16), child: Divider(color: Colors.white24, height: 1)),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Đã chi', style: GoogleFonts.plusJakartaSans(color: Colors.white70, fontSize: 12)),
                        Text(_formatCurrency(_totalExpense), style: GoogleFonts.plusJakartaSans(color: Colors.redAccent.shade100, fontSize: 16, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text('Còn lại', style: GoogleFonts.plusJakartaSans(color: Colors.white70, fontSize: 12)),
                        Text(_formatCurrency(remaining), style: GoogleFonts.plusJakartaSans(color: Colors.greenAccent.shade400, fontSize: 16, fontWeight: FontWeight.bold)),
                      ],
                    )
                  ],
                )
              ],
            ),
          ),
          
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Row(
              children: [
                Text('Lịch sử Dòng tiền', style: GoogleFonts.plusJakartaSans(fontSize: 18, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          
          // DANH SÁCH SAO KÊ DÙNG EXPANSION TILE ĐỂ XỔ XUỐNG
          Expanded(
            child: _mergedTransactions.isEmpty
              ? Center(child: Text('Chưa có phát sinh dòng tiền nào.', style: GoogleFonts.plusJakartaSans(color: Colors.grey)))
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8).copyWith(bottom: 40), 
                  itemCount: _mergedTransactions.length,
                  itemBuilder: (context, index) {
                    final item = _mergedTransactions[index];
                    final bool isExpense = item['isExpense']; 
                    final double amount = double.tryParse(item['amount'].toString()) ?? 0.0;

                    return Card(
                      elevation: 0,
                      margin: const EdgeInsets.only(bottom: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                        side: BorderSide(color: Colors.grey.shade200),
                      ),
                      child: ExpansionTile(
                        tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        shape: const Border(), // Xóa dòng kẻ viền đen khi xổ xuống
                        leading: Container(
                          width: 48, height: 48, 
                          decoration: BoxDecoration(color: isExpense ? Colors.red.shade50 : Colors.green.shade50, borderRadius: BorderRadius.circular(12)),
                          child: Icon(isExpense ? Icons.receipt_long : Icons.arrow_downward, color: isExpense ? Colors.red.shade400 : Colors.green.shade600),
                        ),
                        title: Text(item['title'], style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold, fontSize: 15), maxLines: 1, overflow: TextOverflow.ellipsis),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (isExpense) Text('Người trả: ${item['payerName']}', style: GoogleFonts.plusJakartaSans(color: AppColors.primary, fontSize: 12, fontWeight: FontWeight.bold)),
                            Text(_formatDateTime(item['timestamp']), style: GoogleFonts.plusJakartaSans(color: Colors.grey.shade500, fontSize: 11)),
                          ],
                        ),
                        trailing: Text('${isExpense ? "-" : "+"}${_formatCurrency(amount)}', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold, fontSize: 15, color: isExpense ? Colors.red.shade700 : Colors.green.shade700)),
                        children: [
                          if (isExpense) ...[
                            const Divider(height: 1, indent: 16, endIndent: 16),
                            Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Hiển thị ghi chú
                                  if (item['note'].toString().isNotEmpty) ...[
                                    Text('Ghi chú:', style: GoogleFonts.plusJakartaSans(fontSize: 12, color: Colors.grey)),
                                    const SizedBox(height: 4),
                                    Text('"${item['note']}"', style: GoogleFonts.plusJakartaSans(fontSize: 14, fontStyle: FontStyle.italic, color: Colors.black87)),
                                    const SizedBox(height: 16),
                                  ],
                                  
                                  // Hiển thị danh sách các món ăn (Nếu có trong Firebase)
                                  if (item['items'] != null && (item['items'] as List).isNotEmpty) ...[
                                    Text('Chi tiết hóa đơn:', style: GoogleFonts.plusJakartaSans(fontSize: 12, color: Colors.grey)),
                                    const SizedBox(height: 8),
                                    ...(item['items'] as List).map((monAn) => Padding(
                                      padding: const EdgeInsets.only(bottom: 8),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Expanded(child: Text(monAn['name'] ?? 'Món', style: GoogleFonts.plusJakartaSans(fontSize: 14, color: Colors.black87))),
                                          Text(_formatCurrency(double.tryParse(monAn['price'].toString()) ?? 0), style: GoogleFonts.plusJakartaSans(fontSize: 14, fontWeight: FontWeight.bold)),
                                        ],
                                      ),
                                    )),
                                    const SizedBox(height: 16),
                                  ],

                                  // Hiển thị ảnh Bill có thể bấm vào xem Full
                                  Text('Ảnh hóa đơn đính kèm:', style: GoogleFonts.plusJakartaSans(fontSize: 12, color: Colors.grey)),
                                  const SizedBox(height: 8),
                                  if (item['billImage'] != null && item['billImage'].toString().isNotEmpty)
                                    GestureDetector(
                                      onTap: () => _showImageDialog(item['billImage']),
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(12),
                                        child: Stack(
                                          alignment: Alignment.center,
                                          children: [
                                            Image.file(File(item['billImage']), width: double.infinity, height: 200, fit: BoxFit.cover),
                                            Container(
                                              padding: const EdgeInsets.all(12),
                                              decoration: BoxDecoration(color: Colors.black.withOpacity(0.6), shape: BoxShape.circle),
                                              child: const Icon(Icons.zoom_in, color: Colors.white, size: 28),
                                            )
                                          ],
                                        ),
                                      ),
                                    )
                                  else
                                    // Giao diện Nút thêm Bill khi bị thiếu
                                    GestureDetector(
                                      onTap: () => _attachBillImage(item['id']),
                                      child: Container(
                                        width: double.infinity, height: 100,
                                        decoration: BoxDecoration(
                                          color: Colors.orange.shade50, borderRadius: BorderRadius.circular(12), 
                                          border: Border.all(color: Colors.orange.shade200, style: BorderStyle.solid)
                                        ),
                                        child: Column(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            const Icon(Icons.add_a_photo, color: Colors.orange, size: 28),
                                            const SizedBox(height: 8),
                                            Text('Bấm để bổ sung ảnh Bill', style: GoogleFonts.plusJakartaSans(color: Colors.orange, fontWeight: FontWeight.bold)),
                                          ],
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            )
                          ]
                        ],
                      ),
                    );
                  },
                ),
          ),
        ],
      ),
    );
  }
}