import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
// IMPORT THƯ VIỆN ML KIT MỚI
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:firebase_database/firebase_database.dart';

class PaymentScreen extends StatefulWidget {
  const PaymentScreen({super.key});

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  String _amount = "0";
  final TextEditingController _noteController = TextEditingController(text: "Thanh toán hóa đơn");
  
  File? _selectedImage;
  bool _isScanning = false;
  String _scanStatus = "Đang khởi động Camera...";
  bool _isSavingToFirebase = false; 
  
  List<dynamic> _scannedItems = [];

  // --- HÀM QUÉT ẢNH BẰNG GOOGLE ML KIT (BẢN NÂNG CẤP ĐỌC CHI TIẾT MÓN) ---
  Future<void> _scanBillReal() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      setState(() {
        _selectedImage = File(image.path);
        _isScanning = true;
        _scanStatus = "Đang quét và bóc tách từng món...";
      });

      try {
        final inputImage = InputImage.fromFilePath(image.path);
        final textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);
        final RecognizedText recognizedText = await textRecognizer.processImage(inputImage);

        double maxAmount = 0;
        List<dynamic> extractedItems = [];
        String shopName = "Hóa đơn (ML Kit)";

        // 1. Gom tất cả các dòng chữ lại
        List<TextLine> allLines = [];
        for (TextBlock block in recognizedText.blocks) {
          allLines.addAll(block.lines);
        }

        // 2. Sắp xếp các dòng từ trên xuống dưới theo tọa độ Y
        allLines.sort((a, b) => a.boundingBox.top.compareTo(b.boundingBox.top));

        // 3. Thuật toán ghép đôi thông minh (Tên món ăn + Giá tiền)
        String lastSeenText = ""; // Biến nhớ tên món ăn ở dòng trên
        RegExp extractPriceRegex = RegExp(r'\b\d{1,3}(?:[.,]\d{3})+\b|\b\d{4,}\b'); // Tìm số >= 1000

        for (TextLine line in allLines) {
          String text = line.text.trim();

          Iterable<RegExpMatch> matches = extractPriceRegex.allMatches(text);
          if (matches.isNotEmpty) {
            // Tìm thấy một mức giá
            String priceStr = matches.last.group(0)!.replaceAll(RegExp(r'[.,]'), '');
            double price = double.tryParse(priceStr) ?? 0;

            if (price > 1000) {
              if (price > maxAmount) maxAmount = price;

              // Tách chữ nằm cùng dòng với số tiền (nếu có)
              String remainingText = text.replaceAll(extractPriceRegex, '').replaceAll(RegExp(r'[^a-zA-ZÀ-ỹ\s]'), '').trim();
              String itemName = "";

              if (remainingText.length > 2 && !remainingText.toLowerCase().contains("tổng")) {
                itemName = remainingText; // Món ăn và giá nằm trên cùng 1 dòng
              } else if (lastSeenText.length > 2 && !lastSeenText.toLowerCase().contains("tổng")) {
                itemName = lastSeenText; // Món ăn nằm ở dòng ngay bên trên giá
                lastSeenText = ""; // Dùng xong thì xóa trí nhớ
              }

              // Lọc bỏ các từ rác không phải món ăn
              String lowerItem = itemName.toLowerCase();
              if (itemName.isNotEmpty && !lowerItem.contains('thanh toán') && !lowerItem.contains('tiền') && !lowerItem.contains('vnd') && !lowerItem.contains('total') && !lowerItem.contains('cash')) {
                extractedItems.add({
                  "name": itemName,
                  "qty": 1,
                  "price": price
                });
              }
            }
          } else {
            // Nếu dòng này không có số tiền, lưu nó lại làm "ứng cử viên" cho tên món ăn
            if (text.length > 2 && !text.toLowerCase().contains("tổng") && !text.toLowerCase().contains("hóa đơn") && !text.toLowerCase().contains("hđ")) {
              lastSeenText = text;
            }
          }
        }

        textRecognizer.close();
        setState(() => _isScanning = false);

        if (mounted) {
          if (maxAmount == 0) {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Không tìm thấy số tiền nào trên ảnh!'), backgroundColor: Colors.orange));
          } else {
            // Gửi dữ liệu ra giao diện hiển thị
            _showExtractedBillDialog({
              "shopName": shopName,
              "category": "Chi tiêu",
              "totalAmount": maxAmount,
              "items": extractedItems
            });
          }
        }
      } catch (e) {
        setState(() => _isScanning = false);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Lỗi ML Kit: $e'), backgroundColor: Colors.red));
        }
      }
    }
  }

  void _showExtractedBillDialog(Map<String, dynamic> billData) {
    final String shopName = billData['shopName'] ?? "Không rõ tên quán";
    final double totalScannedAmount = (double.tryParse(billData['totalAmount'].toString()) ?? 0);
    final List<dynamic> scannedItems = billData['items'] ?? [];

    showModalBottomSheet(
      context: context, isScrollControlled: true, backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.85,
        decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Chi tiết Hóa đơn', style: GoogleFonts.plusJakartaSans(fontSize: 20, fontWeight: FontWeight.bold)),
                IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context)),
              ],
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(color: Colors.purple.shade50, borderRadius: BorderRadius.circular(8)),
              child: Text('Đọc bằng ML Kit (Siêu tốc)', style: GoogleFonts.plusJakartaSans(fontSize: 12, color: Colors.purple.shade700, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 24),
            Text('Nhận diện từ ảnh:', style: GoogleFonts.plusJakartaSans(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.grey.shade600)),
            const Divider(height: 24),
            Expanded(
              child: scannedItems.isEmpty 
              ? const Center(child: Text('Chỉ nhận diện được tổng tiền, không thấy món ăn rõ ràng.', textAlign: TextAlign.center))
              : ListView.builder(
                itemCount: scannedItems.length,
                itemBuilder: (context, index) {
                  final item = scannedItems[index];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(child: Text('${item['name']}', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600), maxLines: 2)),
                        Text('${_formatNumber(item['price'].toString())}đ', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold)),
                      ],
                    ),
                  );
                },
              ),
            ),
            const Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('TỔNG CỘNG', style: GoogleFonts.plusJakartaSans(fontSize: 16, fontWeight: FontWeight.bold)),
                Text('${_formatNumber(totalScannedAmount.toInt().toString())}đ', style: GoogleFonts.plusJakartaSans(fontSize: 24, fontWeight: FontWeight.w800, color: const Color(0xFF1999B3))),
              ],
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity, height: 56,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  setState(() {
                    _amount = totalScannedAmount.toInt().toString();
                    _noteController.text = "Thanh toán bill quét ảnh";
                    _scannedItems = scannedItems;
                  });
                  _showSuccessDialog(context);
                },
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF111617), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
                child: Text('Đồng ý & Chuẩn bị Lưu', style: GoogleFonts.plusJakartaSans(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
              ),
            )
          ],
        ),
      ),
    );
  }

  void _onNumPress(String val) {
    setState(() {
      if (val == "DEL") {
        if (_amount.length > 1) {
          _amount = _amount.substring(0, _amount.length - 1);
        } else {
          _amount = "0";
        }
      } else if (val == "000") {
        if (_amount != "0") _amount += "000";
      } else {
        if (_amount == "0") {
          _amount = val;
        } else if (_amount.length < 9) _amount += val;
      }
    });
  }

  String _formatNumber(String s) {
    if (s == "0") return "0";
    final number = double.tryParse(s)?.toInt() ?? 0;
    return number.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.');
  }

  Future<void> _showSuccessDialog(BuildContext parentContext) async {
    final bool? isSuccess = await showDialog<bool>(
      context: parentContext, barrierDismissible: false,
      builder: (dialogContext) => StatefulBuilder(
        builder: (BuildContext stfContext, StateSetter setStateDialog) {
          return AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)), contentPadding: const EdgeInsets.all(24),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(width: 80, height: 80, decoration: BoxDecoration(color: Colors.green.shade100, shape: BoxShape.circle), child: const Icon(Icons.check, color: Colors.green, size: 40)),
                const SizedBox(height: 16),
                Text('Xác nhận lưu trữ', style: GoogleFonts.plusJakartaSans(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 24),
                Container(
                  padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: Colors.grey.shade50, borderRadius: BorderRadius.circular(16)),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Tổng cộng', style: GoogleFonts.plusJakartaSans(fontSize: 12, color: Colors.grey)),
                          Text('${_formatNumber(_amount)}đ', style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.green)),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Nội dung', style: GoogleFonts.plusJakartaSans(fontSize: 12, color: Colors.grey)),
                          Expanded(child: Text(_noteController.text, textAlign: TextAlign.right, maxLines: 1, overflow: TextOverflow.ellipsis, style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.w600))),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity, height: 48,
                  child: ElevatedButton(
                    onPressed: _isSavingToFirebase ? null : () async {
                      setStateDialog(() => _isSavingToFirebase = true);
                      try {
                        DatabaseReference ref = FirebaseDatabase.instance.ref("expenses").push();
                        await ref.set({
                          'amount': double.parse(_amount),
                          'note': _noteController.text,
                          'items': _scannedItems, 
                          'timestamp': ServerValue.timestamp, 
                          'createdAt': DateTime.now().toIso8601String(),
                        });
                        if (dialogContext.mounted) Navigator.pop(dialogContext, true); 
                      } catch (e) {
                        setStateDialog(() => _isSavingToFirebase = false);
                        if (dialogContext.mounted) ScaffoldMessenger.of(dialogContext).showSnackBar(SnackBar(content: Text('Lỗi: $e'), backgroundColor: Colors.red));
                      }
                    },
                    style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF111617), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                    child: _isSavingToFirebase ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) : Text('Đẩy lên Đám Mây', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold, color: Colors.white)),
                  ),
                )
              ],
            ),
          );
        }
      ),
    );

    if (isSuccess == true && parentContext.mounted) {
      ScaffoldMessenger.of(parentContext).showSnackBar(const SnackBar(content: Text('Đã lưu dữ liệu!'), backgroundColor: Colors.green));
      Navigator.pop(parentContext, double.parse(_amount));
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isScanning) {
      return Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(color: Colors.purple),
              const SizedBox(height: 24),
              Text('ML Kit đang quét chữ...', style: GoogleFonts.plusJakartaSans(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.purple.shade700)),
              Text(_scanStatus, style: GoogleFonts.plusJakartaSans(fontSize: 14, color: Colors.grey)),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white, elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black54), onPressed: () => Navigator.pop(context)),
        title: Text('Nhập khoản chi', style: GoogleFonts.plusJakartaSans(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 16)),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: InkWell(
              onTap: _scanBillReal,
              borderRadius: BorderRadius.circular(16),
              child: Container(
                width: double.infinity, padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: Colors.purple.shade50, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.purple.shade300, style: BorderStyle.solid)),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.document_scanner, color: Colors.purple.shade700),
                    const SizedBox(width: 8),
                    Text('Quét Hóa Đơn (Bằng ML Kit)', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold, color: Colors.purple.shade700)),
                  ],
                ),
              ),
            ),
          ),
          
          Row(
            children: [
              Expanded(child: Container(height: 1, color: Colors.grey.shade200)),
              Padding(padding: const EdgeInsets.symmetric(horizontal: 16), child: Text('Hoặc nhập thủ công', style: GoogleFonts.plusJakartaSans(fontSize: 12, color: Colors.grey))),
              Expanded(child: Container(height: 1, color: Colors.grey.shade200)),
            ],
          ),

          const SizedBox(height: 20),
          Text('SỐ TIỀN CHI TIÊU', style: GoogleFonts.plusJakartaSans(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey.shade400, letterSpacing: 2)),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(_formatNumber(_amount), style: GoogleFonts.plusJakartaSans(fontSize: 48, fontWeight: FontWeight.bold, color: Colors.black, height: 1)),
              const SizedBox(width: 4),
              Text('đ', style: GoogleFonts.plusJakartaSans(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black)),
            ],
          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('NỘI DUNG', style: GoogleFonts.plusJakartaSans(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey.shade400)),
                TextField(
                  controller: _noteController,
                  style: GoogleFonts.plusJakartaSans(fontSize: 14, fontWeight: FontWeight.w500),
                  decoration: InputDecoration(
                    border: UnderlineInputBorder(borderSide: BorderSide(color: Colors.grey.shade200)),
                    focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Colors.purple)),
                  ),
                ),
              ],
            ),
          ),

          const Spacer(),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: GridView.count(
              shrinkWrap: true, crossAxisCount: 3, childAspectRatio: 2, mainAxisSpacing: 10, crossAxisSpacing: 10, physics: const NeverScrollableScrollPhysics(),
              children: ['1', '2', '3', '4', '5', '6', '7', '8', '9', '000', '0', 'DEL'].map((key) {
                return InkWell(
                  onTap: () => _onNumPress(key),
                  borderRadius: BorderRadius.circular(12),
                  child: Center(
                    child: key == 'DEL' ? const Icon(Icons.backspace_outlined, color: Colors.grey) : Text(key, style: GoogleFonts.plusJakartaSans(fontSize: 24, fontWeight: FontWeight.w500)),
                  ),
                );
              }).toList(),
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(24),
            child: SizedBox(
              width: double.infinity, height: 56,
              child: ElevatedButton(
                onPressed: () {
                  if (_amount == "0") return;
                  if (_amount != "0" && _scannedItems.isNotEmpty && _noteController.text == "Thanh toán hóa đơn") {
                    _scannedItems = []; 
                  }
                  _showSuccessDialog(context);
                },
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF111617), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
                child: Text('Cập nhật', style: GoogleFonts.plusJakartaSans(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
              ),
            ),
          )
        ],
      ),
    );
  }
}