import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tri_go/constants.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart'; 
import 'dart:io'; 
import 'dart:async'; 
import '../login/login_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final User? currentUser = FirebaseAuth.instance.currentUser;
  double _balance = 0;
  String _displayName = "Người dùng";
  String _avatarPath = ""; 

  StreamSubscription<DatabaseEvent>? _userSubscription;

  @override
  void initState() {
    super.initState();
    _listenToUserData();
  }

  @override
  void dispose() {
    _userSubscription?.cancel();
    super.dispose();
  }

  // --- LẤY ẢNH ĐẠI DIỆN THÔNG MINH ---
  ImageProvider? _getAvatarProvider(String path) {
    if (path.isEmpty) return null;
    if (path.startsWith('http') || path.startsWith('https')) {
      return NetworkImage(path);
    }
    return FileImage(File(path));
  }

  // --- LẮNG NGHE DỮ LIỆU TỪ FIREBASE ---
  void _listenToUserData() {
    if (currentUser != null) {
      DatabaseReference userRef = FirebaseDatabase.instance.ref('users/${currentUser!.uid}');
      _userSubscription = userRef.onValue.listen((event) {
        if (!mounted) return; 
        
        if (event.snapshot.value != null) {
          final data = event.snapshot.value as Map<dynamic, dynamic>;
          setState(() {
            _balance = double.tryParse((data['balance'] ?? 0).toString()) ?? 0;
            _displayName = data['displayName'] ?? currentUser?.email?.split('@')[0] ?? "Người dùng";
            _avatarPath = data['avatar'] ?? ""; 
          });
        }
      });
    }
  }

  // --- 1. CẬP NHẬT THÔNG TIN ---
  void _showUpdateProfileDialog() {
    final TextEditingController nameController = TextEditingController(text: _displayName);
    String tempAvatarPath = _avatarPath; 

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
            title: Text('Cập nhật hồ sơ', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold), textAlign: TextAlign.center),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                GestureDetector(
                  onTap: () async {
                    final ImagePicker picker = ImagePicker();
                    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
                    if (image != null) {
                      setDialogState(() => tempAvatarPath = image.path);
                    }
                  },
                  child: Stack(
                    alignment: Alignment.bottomRight,
                    children: [
                      CircleAvatar(
                        radius: 45,
                        backgroundColor: Colors.blue.shade50,
                        backgroundImage: _getAvatarProvider(tempAvatarPath),
                        child: tempAvatarPath.isEmpty 
                            ? Text(_displayName[0].toUpperCase(), style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.blue))
                            : null,
                      ),
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(color: AppColors.primary, shape: BoxShape.circle, border: Border.all(color: Colors.white, width: 2)),
                        child: const Icon(Icons.camera_alt, color: Colors.white, size: 14),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                TextField(
                  controller: nameController,
                  decoration: InputDecoration(
                    labelText: 'Tên hiển thị',
                    prefixIcon: const Icon(Icons.person_outline, color: AppColors.primary),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: AppColors.primary, width: 2)),
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context), child: const Text('Hủy', style: TextStyle(color: Colors.grey))),
              ElevatedButton(
                onPressed: () async {
                  FocusManager.instance.primaryFocus?.unfocus(); 
                  if (nameController.text.isNotEmpty) {
                    await FirebaseDatabase.instance.ref('users/${currentUser!.uid}').update({
                      'displayName': nameController.text.trim(),
                      'avatar': tempAvatarPath, 
                    });
                    if (mounted) {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Đã cập nhật hồ sơ!'), backgroundColor: Colors.green));
                    }
                  }
                },
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                child: const Text('Lưu thông tin', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              )
            ],
          );
        }
      ),
    );
  }

  // --- 2. LỊCH SỬ GIAO DỊCH ---
  void _showTransactionHistory() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.85,
        decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Container(width: 40, height: 5, decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(10))),
            const SizedBox(height: 16),
            Text('Lịch sử giao dịch', style: GoogleFonts.plusJakartaSans(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            Expanded(
              child: StreamBuilder(
                stream: FirebaseDatabase.instance.ref('users/${currentUser!.uid}/transactions').orderByChild('timestamp').onValue,
                builder: (context, snapshot) {
                  if (!snapshot.hasData || snapshot.data!.snapshot.value == null) {
                    return const Center(child: Text('Chưa có phát sinh giao dịch nào.'));
                  }
                  final data = snapshot.data!.snapshot.value as Map<dynamic, dynamic>;
                  List<Map<dynamic, dynamic>> txList = [];
                  data.forEach((key, value) => txList.add(value));
                  txList.sort((a, b) => (b['timestamp'] ?? 0).compareTo(a['timestamp'] ?? 0));

                  return ListView.separated(
                    itemCount: txList.length,
                    separatorBuilder: (_, __) => const Divider(height: 1, indent: 60),
                    itemBuilder: (context, index) {
                      final tx = txList[index];
                      final isPositive = tx['isPositive'] ?? true;
                      final type = tx['type'] ?? '';
                      
                      IconData txIcon = isPositive ? Icons.south_west : Icons.north_east;
                      if (type == 'TOP_UP') txIcon = Icons.account_balance;
                      if (type == 'FUND_CONTRIBUTION') txIcon = Icons.account_balance_wallet;

                      return ListTile(
                        contentPadding: const EdgeInsets.symmetric(vertical: 8),
                        leading: Container(
                          width: 48, height: 48,
                          decoration: BoxDecoration(color: isPositive ? Colors.green.shade50 : Colors.red.shade50, borderRadius: BorderRadius.circular(12)),
                          child: Icon(txIcon, color: isPositive ? Colors.green : Colors.red),
                        ),
                        title: Text(tx['title'] ?? 'Giao dịch', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold, fontSize: 15)),
                        subtitle: Text(DateFormat('dd/MM/yyyy • HH:mm').format(DateTime.fromMillisecondsSinceEpoch(tx['timestamp'] ?? 0)), style: const TextStyle(fontSize: 12)),
                        trailing: Text('${isPositive ? "+" : "-"}${_formatCurrency((tx['amount'] ?? 0).toDouble())}',
                            style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold, fontSize: 16, color: isPositive ? Colors.green : Colors.red)),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- 3. THỐNG KÊ CHI TIÊU ---
  void _showStatistics() {
    showDialog(
      context: context,
      builder: (context) => StreamBuilder(
        stream: FirebaseDatabase.instance.ref('users/${currentUser!.uid}/transactions').onValue,
        builder: (context, snapshot) {
          double totalIn = 0;
          double totalOut = 0;
          
          if (snapshot.hasData && snapshot.data!.snapshot.value != null) {
            final data = snapshot.data!.snapshot.value as Map<dynamic, dynamic>;
            data.forEach((key, value) {
              double amt = double.tryParse(value['amount'].toString()) ?? 0;
              if (value['isPositive'] == true) {
                totalIn += amt;
              } else {
                totalOut += amt;
              }
            });
          }

          return AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
            title: Text('Thống kê Dòng tiền', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold), textAlign: TextAlign.center),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildStatCard('Tổng tiền đã nạp', totalIn, Colors.green, Icons.arrow_downward),
                const SizedBox(height: 12),
                _buildStatCard('Tổng tiền đã chi', totalOut, Colors.red, Icons.arrow_upward),
                const Padding(padding: EdgeInsets.symmetric(vertical: 16), child: Divider()),
                _buildStatRow('Số dư hiện tại', _balance, AppColors.primary),
              ],
            ),
            actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Đóng', style: TextStyle(fontWeight: FontWeight.bold)))],
          );
        },
      ),
    );
  }

  Widget _buildStatCard(String label, double value, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 26),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 77)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color), const SizedBox(width: 12),
          Expanded(child: Text(label, style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold, color: Colors.black87))),
          Text(_formatCurrency(value), style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold, color: color, fontSize: 16)),
        ],
      ),
    );
  }

  Widget _buildStatRow(String label, double value, Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
        Text(_formatCurrency(value), style: TextStyle(fontWeight: FontWeight.w900, color: color, fontSize: 20)),
      ],
    );
  }

  // --- 4. NẠP TIỀN CÓ CHỌN NGÂN HÀNG ---
  void _showTopUpDialog() {
    final TextEditingController amountController = TextEditingController();
    final List<int> quickAmounts = [50000, 100000, 200000, 500000];
    int selectedAmount = 0;
    int selectedBankIndex = 0;

    final List<Map<String, dynamic>> linkedBanks = [
      {'name': 'Vietcombank', 'number': '**** 9999', 'color': Colors.green, 'logo': 'VCB'},
      {'name': 'BIDV', 'number': '**** 8888', 'color': Colors.blue.shade800, 'logo': 'BIDV'},
      {'name': 'Thẻ ATM Nội địa', 'number': 'Chuyển khoản liên ngân hàng', 'color': Colors.orange, 'logo': 'ATM'},
    ];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) {
          return Container(
            padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom + 24, top: 24, left: 24, right: 24),
            decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Nạp tiền vào Ví', style: GoogleFonts.plusJakartaSans(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textDark)),
                      IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context)),
                    ],
                  ),
                  const SizedBox(height: 16),
                  
                  TextField(
                    controller: amountController, keyboardType: TextInputType.number,
                    onChanged: (val) => setModalState(() => selectedAmount = 0), 
                    style: GoogleFonts.plusJakartaSans(fontSize: 28, fontWeight: FontWeight.bold, color: AppColors.primary),
                    decoration: InputDecoration(
                      labelText: 'Số tiền nạp (VNĐ)', labelStyle: TextStyle(color: Colors.grey.shade500, fontSize: 14),
                      prefixIcon: const Icon(Icons.account_balance_wallet, color: AppColors.primary),
                      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: Colors.grey.shade300)),
                      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: AppColors.primary, width: 2)),
                    ),
                  ),
                  const SizedBox(height: 16),
              
                  Wrap(
                    spacing: 12, runSpacing: 12,
                    children: quickAmounts.map<Widget>((amount) {
                      bool isSelected = selectedAmount == amount;
                      return InkWell(
                        onTap: () {
                          setModalState(() {
                            selectedAmount = amount;
                            amountController.text = amount.toString();
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                          decoration: BoxDecoration(color: isSelected ? AppColors.primary : Colors.grey.shade100, borderRadius: BorderRadius.circular(12), border: Border.all(color: isSelected ? AppColors.primary : Colors.grey.shade300)),
                          child: Text(_formatCurrency(amount.toDouble()), style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold, color: isSelected ? Colors.white : AppColors.textDark)),
                        ),
                      );
                    }).toList(),
                  ),
                  
                  const SizedBox(height: 24),
                  Text('Nguồn tiền', style: GoogleFonts.plusJakartaSans(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textDark)),
                  const SizedBox(height: 12),
                  
                  Column(
                    children: List.generate(linkedBanks.length, (index) {
                      final bank = linkedBanks[index];
                      bool isSelected = selectedBankIndex == index;
                      return GestureDetector(
                        onTap: () => setModalState(() => selectedBankIndex = index),
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 12), padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(color: isSelected ? bank['color'].withOpacity(0.05) : Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: isSelected ? bank['color'] : Colors.grey.shade200, width: isSelected ? 1.5 : 1)),
                          child: Row(
                            children: [
                              Container(
                                width: 44, height: 44,
                                decoration: BoxDecoration(color: bank['color'].withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                                child: Center(child: Text(bank['logo'], style: GoogleFonts.plusJakartaSans(color: bank['color'], fontWeight: FontWeight.bold, fontSize: 13))),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(bank['name'], style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold, fontSize: 15, color: AppColors.textDark)),
                                    Text(bank['number'], style: GoogleFonts.plusJakartaSans(fontSize: 13, color: Colors.grey.shade600)),
                                  ],
                                ),
                              ),
                              if (isSelected) Icon(Icons.check_circle, color: bank['color'], size: 24)
                              else Icon(Icons.circle_outlined, color: Colors.grey.shade300, size: 24),
                            ],
                          ),
                        ),
                      );
                    }),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  SizedBox(
                    width: double.infinity, height: 56,
                    child: ElevatedButton(
                      onPressed: () async {
                        double? amount = double.tryParse(amountController.text);
                        if (amount != null && amount > 0 && currentUser != null) {
                          String bankName = linkedBanks[selectedBankIndex]['name'];
                          DatabaseReference userRef = FirebaseDatabase.instance.ref('users/${currentUser!.uid}');
                          
                          await userRef.child('balance').set(_balance + amount);
                          await userRef.child('transactions').push().set({
                            'type': 'TOP_UP', 'title': 'Nạp tiền từ $bankName', 'amount': amount, 'timestamp': ServerValue.timestamp, 'isPositive': true, 
                          });
              
                          if (mounted) {
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Đã nạp ${amount.toInt()}đ vào ví!'), backgroundColor: Colors.green));
                          }
                        }
                      },
                      style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
                      child: Text('Xác nhận Nạp', style: GoogleFonts.plusJakartaSans(fontSize: 16, color: Colors.white, fontWeight: FontWeight.bold)),
                    ),
                  )
                ],
              ),
            ),
          );
        }
      ),
    );
  }

  // --- 5. MÃ QR NHẬN TIỀN ---
  void _showMyQRDialog() {
    if (currentUser == null) return;
    String qrData = "TRIGO_PAY:${currentUser!.uid}:${currentUser!.email}";
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Mã QR Nhận Tiền', style: GoogleFonts.plusJakartaSans(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textDark)),
              const SizedBox(height: 8),
              Text('Đưa mã này cho bạn bè để nhận tiền vào ví', style: GoogleFonts.plusJakartaSans(fontSize: 13, color: Colors.grey), textAlign: TextAlign.center),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.grey.shade200)),
                child: QrImageView(data: qrData, version: QrVersions.auto, size: 200.0, foregroundColor: AppColors.primary),
              ),
              const SizedBox(height: 24),
              Text(_displayName, style: GoogleFonts.plusJakartaSans(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textDark)),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.grey.shade200, elevation: 0, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                  child: Text('Đóng', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold, color: Colors.black87)),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  // --- 6. HÀM MỚI: GỬI EMAIL ĐỔI MẬT KHẨU ---
  void _showChangePasswordDialog() {
    if (currentUser?.email == null) return;
    bool isSending = false;

    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            title: Text('Đổi mật khẩu', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold), textAlign: TextAlign.center),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.mark_email_read_outlined, size: 50, color: AppColors.primary),
                const SizedBox(height: 16),
                Text('Hệ thống sẽ gửi một đường link đặt lại mật khẩu đến email:', textAlign: TextAlign.center, style: GoogleFonts.plusJakartaSans(fontSize: 14, color: Colors.grey.shade700)),
                const SizedBox(height: 8),
                Text(currentUser!.email!, style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.textDark)),
              ],
            ),
            actions: [
              TextButton(
                onPressed: isSending ? null : () => Navigator.pop(dialogContext),
                child: const Text('Hủy', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold))
              ),
              ElevatedButton(
                onPressed: isSending ? null : () async {
                  setDialogState(() => isSending = true);
                  try {
                    await FirebaseAuth.instance.sendPasswordResetEmail(email: currentUser!.email!);
                    if (dialogContext.mounted) {
                      Navigator.pop(dialogContext);
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                        content: Text('Đã gửi link đổi mật khẩu! Vui lòng kiểm tra email.'),
                        backgroundColor: Colors.green,
                      ));
                    }
                  } catch (e) {
                    setDialogState(() => isSending = false);
                    if (dialogContext.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Lỗi: $e'), backgroundColor: Colors.red));
                    }
                  }
                },
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                child: isSending 
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : const Text('Gửi email', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              )
            ],
          );
        }
      ),
    );
  }

  String _formatCurrency(double amount) => NumberFormat.currency(locale: 'vi_VN', symbol: 'đ').format(amount);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFA),
      appBar: AppBar(backgroundColor: Colors.transparent, elevation: 0, leading: IconButton(icon: const Icon(Icons.arrow_back_ios_new, color: AppColors.textDark, size: 20), onPressed: () => Navigator.pop(context)), title: Text('Ví & Hồ sơ', style: GoogleFonts.plusJakartaSans(color: AppColors.textDark, fontWeight: FontWeight.bold, fontSize: 18)), centerTitle: true),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // --- GIAO DIỆN AVATAR ---
            Center(
              child: Column(children: [
                Container(
                  padding: const EdgeInsets.all(4), decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: AppColors.primary.withOpacity(0.2), width: 4)),
                  child: CircleAvatar(
                    radius: 40, 
                    backgroundColor: Colors.blue.shade50, 
                    backgroundImage: _getAvatarProvider(_avatarPath),
                    child: _avatarPath.isEmpty ? Text(_displayName[0].toUpperCase(), style: const TextStyle(fontSize: 30, fontWeight: FontWeight.bold, color: Colors.blue)) : null,
                  ),
                ),
                const SizedBox(height: 12),
                Text(_displayName, style: GoogleFonts.plusJakartaSans(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textDark)),
                Text(currentUser?.email ?? 'Chưa đăng nhập', style: GoogleFonts.plusJakartaSans(fontSize: 13, color: AppColors.textGrey)),
              ]),
            ),
            const SizedBox(height: 32),
            
            // --- THẺ VÍ ---
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(gradient: const LinearGradient(colors: [Color(0xFF1999B3), Color(0xFF106E82)]), borderRadius: BorderRadius.circular(20), boxShadow: [BoxShadow(color: AppColors.primary.withOpacity(0.3), blurRadius: 15, offset: const Offset(0, 8))]),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: const [Text('SỐ DƯ KHẢ DỤNG', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white70)), Icon(Icons.wallet, color: Colors.white70, size: 20)]),
                const SizedBox(height: 8),
                Text(_formatCurrency(_balance), style: GoogleFonts.plusJakartaSans(fontSize: 32, fontWeight: FontWeight.w800, color: Colors.white)),
                const SizedBox(height: 20),
                Row(children: [
                  Expanded(child: ElevatedButton.icon(onPressed: _showTopUpDialog, icon: const Icon(Icons.add_circle_outline, size: 18, color: AppColors.primary), label: Text('Nạp tiền', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold, color: AppColors.primary)), style: ElevatedButton.styleFrom(backgroundColor: Colors.white, elevation: 0, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)), padding: const EdgeInsets.symmetric(vertical: 12)))),
                  const SizedBox(width: 12),
                  Expanded(child: ElevatedButton.icon(onPressed: _showMyQRDialog, icon: const Icon(Icons.qr_code_2, size: 18, color: Colors.white), label: Text('Mã QR', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold, color: Colors.white)), style: ElevatedButton.styleFrom(backgroundColor: Colors.white.withOpacity(0.2), elevation: 0, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)), padding: const EdgeInsets.symmetric(vertical: 12)))),
                ])
              ]),
            ),
            const SizedBox(height: 24),
            
            // --- DANH SÁCH MENU ĐÃ ĐƯỢC CHÈN THÊM NÚT ĐỔI MẬT KHẨU ---
            Container(
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4))]),
              child: Column(children: [
                _buildListTile(Icons.history, 'Lịch sử giao dịch ví', _showTransactionHistory),
                const Divider(height: 1, thickness: 0.5, color: Color(0xFFF0F2F5), indent: 64, endIndent: 16),
                _buildListTile(Icons.analytics_outlined, 'Thống kê chi tiêu cá nhân', _showStatistics),
                const Divider(height: 1, thickness: 0.5, color: Color(0xFFF0F2F5), indent: 64, endIndent: 16),
                _buildListTile(Icons.person_outline, 'Cập nhật thông tin', _showUpdateProfileDialog),
                const Divider(height: 1, thickness: 0.5, color: Color(0xFFF0F2F5), indent: 64, endIndent: 16),
                _buildListTile(Icons.lock_outline, 'Đổi mật khẩu', _showChangePasswordDialog),
              ]),
            ),
            const SizedBox(height: 20),
            
            Container(
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
              child: ListTile(
                onTap: () async {
                   await FirebaseAuth.instance.signOut();
                   if (mounted) Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => const LoginScreen()), (route) => false);
                },
                leading: Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: Colors.red.withOpacity(0.1), borderRadius: BorderRadius.circular(12)), child: const Icon(Icons.logout, color: Colors.red)),
                title: Text('Đăng xuất', style: GoogleFonts.plusJakartaSans(fontSize: 15, fontWeight: FontWeight.w600, color: Colors.red)),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildListTile(IconData icon, String title, VoidCallback onTap) {
    return ListTile(
      onTap: onTap, 
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.1), borderRadius: BorderRadius.circular(12)), child: Icon(icon, color: AppColors.primary)),
      title: Text(title, style: GoogleFonts.plusJakartaSans(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.textDark)),
      trailing: const Icon(Icons.chevron_right, color: AppColors.textGrey),
    );
  }
}