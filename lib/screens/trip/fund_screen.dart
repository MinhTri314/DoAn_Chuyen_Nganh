import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:intl/intl.dart';

class FundScreen extends StatefulWidget {
  const FundScreen({super.key});

  @override
  State<FundScreen> createState() => _FundScreenState();
}

class _FundScreenState extends State<FundScreen> {
  final double totalBudget = 10000000; 

  String _formatCurrency(double amount) {
    final formatter = NumberFormat('#,###', 'vi_VN');
    return formatter.format(amount);
  }

  String _formatDateTime(String isoString) {
    try {
      DateTime date = DateTime.parse(isoString);
      return DateFormat('dd/MM/yyyy - HH:mm').format(date);
    } catch (e) {
      return "Không rõ thời gian";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        backgroundColor: Colors.white, elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black54), onPressed: () => Navigator.pop(context)),
        title: Text('Quỹ nhóm & Lịch sử', style: GoogleFonts.plusJakartaSans(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 18)),
        centerTitle: true,
      ),
      body: StreamBuilder(
        stream: FirebaseDatabase.instance.ref('expenses').onValue,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator(color: Colors.blue));
          if (snapshot.hasError) return Center(child: Text('Lỗi tải dữ liệu!', style: GoogleFonts.plusJakartaSans()));

          List<Map<dynamic, dynamic>> expensesList = [];
          double totalSpent = 0;

          if (snapshot.hasData && snapshot.data!.snapshot.value != null) {
            final data = snapshot.data!.snapshot.value as Map<dynamic, dynamic>;
            data.forEach((key, value) {
              expensesList.add({'key': key, ...value as Map<dynamic, dynamic>});
              totalSpent += (double.tryParse(value['amount'].toString()) ?? 0);
            });
            expensesList.sort((a, b) => (b['createdAt'] ?? "").compareTo(a['createdAt'] ?? ""));
          }

          double remaining = totalBudget - totalSpent;

          return Column(
            children: [
              Container(
                width: double.infinity, margin: const EdgeInsets.all(16), padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: [Color(0xFF111617), Color(0xFF2C3E50)], begin: Alignment.topLeft, end: Alignment.bottomRight),
                  borderRadius: BorderRadius.circular(24), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 10, offset: const Offset(0, 5))],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('TỔNG NGÂN SÁCH', style: GoogleFonts.plusJakartaSans(color: Colors.grey.shade400, fontSize: 12, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Text('${_formatCurrency(totalBudget)} đ', style: GoogleFonts.plusJakartaSans(color: Colors.white, fontSize: 32, fontWeight: FontWeight.w800)),
                    const Padding(padding: EdgeInsets.symmetric(vertical: 16), child: Divider(color: Colors.white24, height: 1)),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Đã chi', style: GoogleFonts.plusJakartaSans(color: Colors.grey.shade400, fontSize: 12)),
                            Text('${_formatCurrency(totalSpent)} đ', style: GoogleFonts.plusJakartaSans(color: Colors.redAccent.shade100, fontSize: 16, fontWeight: FontWeight.bold)),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text('Còn lại', style: GoogleFonts.plusJakartaSans(color: Colors.grey.shade400, fontSize: 12)),
                            Text('${_formatCurrency(remaining)} đ', style: GoogleFonts.plusJakartaSans(color: Colors.greenAccent.shade400, fontSize: 16, fontWeight: FontWeight.bold)),
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
                    Text('Lịch sử giao dịch', style: GoogleFonts.plusJakartaSans(fontSize: 18, fontWeight: FontWeight.bold)),
                    const Spacer(),
                    Text('${expensesList.length} khoản', style: GoogleFonts.plusJakartaSans(fontSize: 14, color: Colors.grey)),
                  ],
                ),
              ),
              Expanded(
                child: expensesList.isEmpty
                  ? Center(child: Text('Chưa có khoản chi nào!', textAlign: TextAlign.center, style: GoogleFonts.plusJakartaSans(color: Colors.grey)))
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8).copyWith(bottom: 20), 
                      itemCount: expensesList.length,
                      itemBuilder: (context, index) {
                        final item = expensesList[index];
                        final double amount = (double.tryParse(item['amount'].toString()) ?? 0);
                        final String note = item['note'] ?? "Không có nội dung";
                        
                        // KÉO LIST MÓN ĂN TỪ FIREBASE XUỐNG
                        final List<dynamic> subItems = item['items'] ?? [];

                        return Container(
                          margin: const EdgeInsets.only(bottom: 12), padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.grey.shade200)),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Hàng 1: Tổng quan bill
                              Row(
                                children: [
                                  Container(
                                    width: 48, height: 48, decoration: BoxDecoration(color: Colors.blue.shade50, borderRadius: BorderRadius.circular(12)),
                                    child: Icon(Icons.receipt_long, color: Colors.blue.shade600),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(note, style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold, fontSize: 15), maxLines: 1, overflow: TextOverflow.ellipsis),
                                        const SizedBox(height: 4),
                                        Text(_formatDateTime(item['createdAt'] ?? ""), style: GoogleFonts.plusJakartaSans(color: Colors.grey.shade500, fontSize: 12)),
                                      ],
                                    ),
                                  ),
                                  Text('- ${_formatCurrency(amount)}đ', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.red.shade700)),
                                ],
                              ),
                              
                              // Hàng 2: Nếu bill này có list món ăn thì xổ xuống đây
                              if (subItems.isNotEmpty) ...[
                                const SizedBox(height: 12),
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade50,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: subItems.map((subItem) {
                                      final double itemPrice = double.tryParse(subItem['price'].toString()) ?? 0;
                                      return Padding(
                                        padding: const EdgeInsets.only(bottom: 6),
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Expanded(
                                              child: Text(
                                                '${subItem['qty'] ?? 1}x ${subItem['name'] ?? 'Món'}', 
                                                style: GoogleFonts.plusJakartaSans(fontSize: 13, color: Colors.grey.shade700),
                                                maxLines: 1, overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                            Text(
                                              '${_formatCurrency(itemPrice)}đ', 
                                              style: GoogleFonts.plusJakartaSans(fontSize: 13, color: Colors.grey.shade700, fontWeight: FontWeight.w600)
                                            ),
                                          ],
                                        ),
                                      );
                                    }).toList(),
                                  ),
                                ),
                              ]
                            ],
                          ),
                        );
                      },
                    ),
              ),
            ],
          );
        },
      ),
    );
  }
}