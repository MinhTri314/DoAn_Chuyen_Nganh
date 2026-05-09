import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:tri_go/constants.dart';

class PaymentScreen extends StatefulWidget {
  final String tripId; 
  const PaymentScreen({super.key, required this.tripId});

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  final User? currentUser = FirebaseAuth.instance.currentUser;
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();
  
  Map<String, dynamic>? _selectedShop;
  File? _billImage;
  bool _isProcessingImage = false;
  
  // BIẾN LƯU DANH SÁCH MÓN ĂN BÓC TÁCH ĐƯỢC
  List<Map<String, dynamic>> _scannedItems = [];

  final List<Map<String, dynamic>> _fakeShops = [
    {'account': '0123456789', 'name': 'Nhà hàng Hải Sản Cô Ba', 'bank': 'Vietcombank', 'owner': 'NGUYEN VAN A', 'logo': 'VCB', 'color': Colors.green},
    {'account': '9876543210', 'name': 'Cà phê Mây Lang Thang', 'bank': 'TPBank', 'owner': 'TRAN THI B', 'logo': 'TPB', 'color': Colors.purple},
    {'account': '1122334455', 'name': 'Siêu thị Tiện Lợi 24/7', 'bank': 'MoMo', 'owner': 'PHAM THI D', 'logo': 'MoMo', 'color': Colors.pink},
    {'account': '5678901234', 'name': 'Vé tham quan Cáp Treo', 'bank': 'BIDV', 'owner': 'LE VAN C', 'logo': 'BIDV', 'color': Colors.blue.shade800},
  ];

  void _showShopSelector() {
    showModalBottomSheet(
      context: context, backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
        child: Column(
          mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Chọn đơn vị thụ hưởng', style: GoogleFonts.plusJakartaSans(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            ..._fakeShops.map((shop) => ListTile(
              onTap: () { setState(() => _selectedShop = shop); Navigator.pop(context); },
              contentPadding: EdgeInsets.zero,
              leading: Container(width: 48, height: 48, decoration: BoxDecoration(color: shop['color'].withOpacity(0.1), borderRadius: BorderRadius.circular(12)), child: Center(child: Text(shop['logo'], style: TextStyle(color: shop['color'], fontWeight: FontWeight.bold)))),
              title: Text(shop['name'], style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold)),
              subtitle: Text('${shop['bank']} - ${shop['account']}'),
            ))
          ],
        ),
      ),
    );
  }

  // --- AI QUÉT BILL VÀ BÓC TÁCH MÓN ĂN (SIÊU CHUẨN) ---
  Future<void> _scanBill() async {
    final image = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (image == null) return;

    setState(() { 
      _billImage = File(image.path); 
      _isProcessingImage = true; 
      _scannedItems.clear(); // Xóa list cũ
    });

    try {
      final inputImage = InputImage.fromFilePath(image.path);
      final textRecognizer = TextRecognizer();
      final recognizedText = await textRecognizer.processImage(inputImage);
      
      List<Map<String, dynamic>> tempItems = [];
      // Regex lấy số tiền có format chuẩn (VD: 25,000 hoặc 50.000)
      RegExp currencyRegex = RegExp(r'\b(\d{1,3}(?:[.,]\d{3})+)\b');

      for (TextBlock block in recognizedText.blocks) {
        for (TextLine line in block.lines) {
          String text = line.text;
          String textLower = text.toLowerCase();

          // 1. NÉ RÁC: Bỏ qua ngày tháng, sđt, giờ
          if (textLower.contains('ngày') || textLower.contains('date') || textLower.contains('giờ') || 
              textLower.contains('đt') || textLower.contains('hotline') || textLower.contains('hđ') || 
              text.contains(':') || text.contains('/')) {
            continue; 
          }

          // 2. TÌM GIÁ TIỀN & TÊN MÓN TƯƠNG ỨNG TRÊN CÙNG 1 DÒNG
          Iterable<RegExpMatch> matches = currencyRegex.allMatches(text);
          if (matches.isNotEmpty) {
            List<double> linePrices = [];
            String nameStr = text;

            // Rút toàn bộ số tiền ra khỏi chuỗi (VD: rút "25,000" và "50,000")
            for (var m in matches) {
              String priceStr = m.group(1)!.replaceAll(RegExp(r'[.,]'), '');
              double price = double.parse(priceStr);
              linePrices.add(price);
              nameStr = nameStr.replaceAll(m.group(0)!, ''); // Xóa số tiền khỏi chuỗi
            }

            // Lọc tên món: Xóa Số lượng, Số thứ tự (VD: "1) ", "2"), và dấu câu
            nameStr = nameStr.replaceAll(RegExp(r'\d+'), ''); // Xóa mọi chữ số (SL, STT)
            nameStr = nameStr.replaceAll(RegExp(r'[.,)\]\[}:;\-]'), ''); // Xóa dấu câu
            nameStr = nameStr.trim();

            // Nếu tên món sau khi lọc còn ý nghĩa, và không phải là chữ Tổng Cộng
            if (nameStr.length > 1 && !nameStr.toLowerCase().contains('cộng') && !nameStr.toLowerCase().contains('tổng') && !nameStr.toLowerCase().contains('tiền')) {
              // Nếu 1 dòng có 2 mức giá (VD: Đơn giá và Tổng giá), ta lấy mức cao nhất làm tổng giá của món đó
              double itemPrice = linePrices.reduce((a, b) => a > b ? a : b);
              
              if (itemPrice < 100000000) { // Né mã vạch
                tempItems.add({'name': nameStr, 'price': itemPrice});
              }
            }
          }
        }
      }

      // 3. TÌM RA TỔNG CỘNG CỦA HÓA ĐƠN
      double maxAmount = 0;
      if (tempItems.isNotEmpty) {
        maxAmount = tempItems.map((e) => e['price'] as double).reduce((a, b) => a > b ? a : b);
        
        // Loại bỏ dòng Tổng tiền ra khỏi danh sách món ăn (để list bên dưới chỉ toàn món thật)
        tempItems.removeWhere((item) => item['price'] == maxAmount);

        setState(() {
          _amountController.text = maxAmount.toInt().toString();
          _scannedItems = tempItems;
        });
      } else {
        // Fallback: Tìm con số lớn nhất nếu format bill không có tên món cùng dòng
        for (TextBlock block in recognizedText.blocks) {
          for (TextLine line in block.lines) {
            Iterable<RegExpMatch> matches = currencyRegex.allMatches(line.text);
            for (var m in matches) {
              double val = double.parse(m.group(1)!.replaceAll(RegExp(r'[.,]'), ''));
              if (val > maxAmount && val < 100000000) maxAmount = val;
            }
          }
        }
        if (maxAmount > 0) {
          setState(() => _amountController.text = maxAmount.toInt().toString());
        } else {
          if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Không bóc tách được món ăn! Vui lòng nhập thủ công.')));
        }
      }
      textRecognizer.close();
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Lỗi quét: $e')));
    } finally {
      if (mounted) setState(() => _isProcessingImage = false);
    }
  }

  Future<void> _executePayment() async {
    if (_selectedShop == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Vui lòng chọn người nhận!'), backgroundColor: Colors.orange));
      return;
    }
    double? amount = double.tryParse(_amountController.text);
    if (amount == null || amount <= 0) return;

    showDialog(context: context, barrierDismissible: false, builder: (context) => const Center(child: CircularProgressIndicator()));

    try {
      final String uid = currentUser!.uid;
      final userSnap = await FirebaseDatabase.instance.ref('users/$uid').get();
      String payerName = userSnap.exists ? (userSnap.value as Map)['displayName'] ?? 'Thành viên' : 'Thành viên';

      final tripRef = FirebaseDatabase.instance.ref('trips/${widget.tripId}');
      final tripSnap = await tripRef.get();
      
      if (tripSnap.exists) {
        final tripData = tripSnap.value as Map<dynamic, dynamic>;
        double currentFund = double.parse((tripData['currentFund'] ?? 0).toString());
        double totalExpense = double.parse((tripData['totalExpense'] ?? 0).toString());
        
        if (amount > (currentFund - totalExpense)) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Quỹ nhóm không đủ tiền! Hãy nạp thêm.'), backgroundColor: Colors.red));
          return;
        }

        await tripRef.child('totalExpense').set(totalExpense + amount);
        
        // ĐẨY LUÔN DANH SÁCH MÓN ĂN VÀO KHOẢN CHI NÀY
        await tripRef.child('expenses').push().set({
          'shopName': _selectedShop!['name'],
          'bankName': _selectedShop!['bank'],
          'amount': amount,
          'note': _noteController.text.isEmpty ? 'Thanh toán dịch vụ' : _noteController.text,
          'billImage': _billImage?.path ?? '', 
          'payerName': payerName,
          'items': _scannedItems, // LƯU CHI TIẾT MÓN LÊN FIREBASE ĐỂ TRANG QUỸ XỔ RA
          'timestamp': ServerValue.timestamp,
        });

        if (mounted) {
          Navigator.pop(context); 
          Navigator.pop(context); 
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Thanh toán thành công!'), backgroundColor: Colors.green));
        }
      }
    } catch (e) {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        backgroundColor: Colors.white, elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios_new, color: AppColors.textDark), onPressed: () => Navigator.pop(context)),
        title: Text('Thanh toán Dịch vụ', style: GoogleFonts.plusJakartaSans(color: AppColors.textDark, fontWeight: FontWeight.bold, fontSize: 18)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Đang mở Camera quét QR...'))),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      decoration: BoxDecoration(color: Colors.blue.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.blue.shade200)),
                      child: Column(children: [const Icon(Icons.qr_code_scanner, color: Colors.blue, size: 32), const SizedBox(height: 8), Text('Quét mã QR', style: GoogleFonts.plusJakartaSans(color: Colors.blue, fontWeight: FontWeight.bold, fontSize: 12))]),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: InkWell(
                    onTap: _scanBill,
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.primary.withValues(alpha: 0.3))),
                      child: Column(
                        children: [
                          _isProcessingImage 
                            ? const SizedBox(height: 32, width: 32, child: CircularProgressIndicator(strokeWidth: 2)) 
                            : const Icon(Icons.document_scanner, color: AppColors.primary, size: 32), 
                          const SizedBox(height: 8), 
                          // BỎ CHỮ AI NHƯ SẾP YÊU CẦU
                          Text('Quét Hóa Đơn', style: GoogleFonts.plusJakartaSans(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 12))
                        ]
                      ),
                    ),
                  ),
                ),
              ],
            ),
            
            if (_billImage != null)
              Padding(
                padding: const EdgeInsets.only(top: 16),
                child: Row(
                  children: [
                    ClipRRect(borderRadius: BorderRadius.circular(8), child: Image.file(_billImage!, height: 50, width: 50, fit: BoxFit.cover)),
                    const SizedBox(width: 12),
                    const Text('Đã đính kèm ảnh hóa đơn ✅', style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 12))
                  ],
                ),
              ),

            // HIỂN THỊ CÁC MÓN ĂN VỪA BÓC TÁCH ĐƯỢC
            if (_scannedItems.isNotEmpty)
              Container(
                margin: const EdgeInsets.only(top: 16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: Colors.orange.shade50, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.orange.shade200)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Đã bóc tách ${_scannedItems.length} món:', style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.orange.shade800)),
                    const SizedBox(height: 12),
                    ..._scannedItems.map((item) => Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(child: Text(item['name'], style: const TextStyle(fontSize: 13, color: Colors.black87), maxLines: 1, overflow: TextOverflow.ellipsis)),
                          Text('${item['price'].toInt()}đ', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    )),
                  ],
                ),
              ),

            const SizedBox(height: 24),
            Text('THÔNG TIN NGƯỜI NHẬN', style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey)),
            const SizedBox(height: 12),
            InkWell(
              onTap: _showShopSelector,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.grey.shade200)),
                child: _selectedShop == null 
                  ? Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text('Bấm để chọn Tài khoản nhận', style: GoogleFonts.plusJakartaSans(color: AppColors.primary, fontWeight: FontWeight.bold)), const Icon(Icons.contacts, color: AppColors.primary)])
                  : Row(
                      children: [
                        Container(width: 48, height: 48, decoration: BoxDecoration(color: _selectedShop!['color'].withOpacity(0.1), borderRadius: BorderRadius.circular(12)), child: Center(child: Text(_selectedShop!['logo'], style: TextStyle(color: _selectedShop!['color'], fontWeight: FontWeight.bold)))),
                        const SizedBox(width: 16),
                        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Text(_selectedShop!['name'], style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.textDark)),
                          Text('${_selectedShop!['bank']} - ${_selectedShop!['account']}', style: GoogleFonts.plusJakartaSans(fontSize: 12, color: Colors.grey.shade600)),
                        ])),
                        const Icon(Icons.edit, color: Colors.grey, size: 20)
                      ],
                    ),
              ),
            ),
            
            const SizedBox(height: 24),
            Text('CHI TIẾT GIAO DỊCH', style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey)),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.grey.shade200)),
              child: Column(
                children: [
                  TextField(
                    controller: _amountController, keyboardType: TextInputType.number,
                    style: GoogleFonts.plusJakartaSans(fontSize: 28, fontWeight: FontWeight.bold, color: AppColors.primary),
                    decoration: const InputDecoration(labelText: 'Số tiền (VNĐ)', border: InputBorder.none, prefixIcon: Icon(Icons.monetization_on, color: AppColors.primary)),
                  ),
                  const Divider(height: 20),
                  TextField(
                    controller: _noteController,
                    decoration: const InputDecoration(labelText: 'Nội dung (Tùy chọn)', border: InputBorder.none, prefixIcon: Icon(Icons.edit_note, color: Colors.grey)),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity, height: 56,
              child: ElevatedButton(
                onPressed: _executePayment,
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
                child: const Text('Xác nhận & Trừ Quỹ', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
              ),
            )
          ],
        ),
      ),
    );
  }
}