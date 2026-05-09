import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:url_launcher/url_launcher.dart'; // THƯ VIỆN GỌI GOOGLE MAPS
import 'dart:async';
import 'add_activity_screen.dart';

class ScheduleScreen extends StatefulWidget {
  final String tripId; // BẮT BUỘC PHẢI CÓ ĐỂ FIX LỖI 
  const ScheduleScreen({super.key, required this.tripId});

  @override
  State<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends State<ScheduleScreen> {
  static const Color primaryColor = Color(0xFF1999B3);
  
  List<Map<dynamic, dynamic>> _scheduleList = [];
  StreamSubscription<DatabaseEvent>? _scheduleSubscription;

  @override
  void initState() {
    super.initState();
    _listenToSchedule();
  }

  @override
  void dispose() {
    _scheduleSubscription?.cancel();
    super.dispose();
  }

  void _listenToSchedule() {
    _scheduleSubscription = FirebaseDatabase.instance.ref('trips/${widget.tripId}/activities').onValue.listen((event) {
      if (!mounted) return;
      if (event.snapshot.value != null) {
        final data = event.snapshot.value as Map<dynamic, dynamic>;
        List<Map<dynamic, dynamic>> tempList = [];
        data.forEach((key, value) {
          tempList.add({'id': key, ...value});
        });

        tempList.sort((a, b) => (a['time'] ?? '').toString().compareTo((b['time'] ?? '').toString()));
        setState(() => _scheduleList = tempList);
      } else {
        setState(() => _scheduleList = []);
      }
    });
  }

  void _deleteActivity(String activityId) {
    FirebaseDatabase.instance.ref('trips/${widget.tripId}/activities/$activityId').remove();
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Đã xóa hoạt động khỏi lịch trình'), backgroundColor: Colors.orange));
  }

// --- HÀM DẪN ĐƯỜNG CHẾ ĐỘ LÁI XE (NAVIGATION MODE) ---
  Future<void> _openGoogleMaps(double? lat, double? lng, String locationName) async {
    Uri url;
    
    // 1. Tạo chuỗi đích đến (Ưu tiên tọa độ để chính xác tuyệt đối)
    final String destination = (lat != null && lng != null) 
        ? '$lat,$lng' 
        : Uri.encodeComponent(locationName);

    // 2. SỬA LINK: Thêm lệnh "navigation=1" để nó tự hiện chữ "Bắt đầu" luôn
    // google.navigation:q=... là lệnh cưỡng chế bật chế độ chỉ đường trên Android
    final Uri googleMapsIntent = Uri.parse("google.navigation:q=$destination&mode=d"); // mode=d là Driving (Ô tô/Xe máy)
    
    // Link web dự phòng (cũng thêm chế độ chỉ đường)
    final Uri webUrl = Uri.parse("https://www.google.com/maps/dir/?api=1&destination=$destination&travelmode=driving");

    try {
      if (await launchUrl(googleMapsIntent)) {
        // Mở thẳng App Maps vào chế độ "Bắt đầu"
      } else {
        // Mở trình duyệt web vào chế độ Chỉ đường (Direction)
        await launchUrl(webUrl, mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Không thể kích hoạt bộ chỉ đường!'))
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white, elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black), onPressed: () => Navigator.pop(context)),
        title: Text('Lịch trình Chuyến đi', style: GoogleFonts.plusJakartaSans(color: Colors.black, fontWeight: FontWeight.w800)),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Container(
            height: 60, padding: const EdgeInsets.symmetric(vertical: 8),
            child: ListView(
              scrollDirection: Axis.horizontal, padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                _buildDayTab('Toàn bộ lịch trình', true), 
              ],
            ),
          ),
          
          Expanded(
            child: _scheduleList.isEmpty
              ? _buildEmptyState()
              : ListView.builder(
                  padding: const EdgeInsets.all(24),
                  itemCount: _scheduleList.length + 1, 
                  itemBuilder: (context, index) {
                    
                    if (index == _scheduleList.length) {
                      return _buildAddButton();
                    }

                    final act = _scheduleList[index];
                    IconData icon = IconData(act['iconCode'] ?? Icons.explore.codePoint, fontFamily: 'MaterialIcons');
                    Color color = Color(act['colorCode'] ?? 0xFF1999B3);
                    double? lat = act['lat'] != null ? double.tryParse(act['lat'].toString()) : null;
                    double? lng = act['lng'] != null ? double.tryParse(act['lng'].toString()) : null;

                    return Dismissible(
                      key: Key(act['id']),
                      direction: DismissDirection.endToStart,
                      background: Container(
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.only(right: 20),
                        decoration: BoxDecoration(color: Colors.red, borderRadius: BorderRadius.circular(16)),
                        child: const Icon(Icons.delete, color: Colors.white, size: 28),
                      ),
                      onDismissed: (direction) => _deleteActivity(act['id']),
                      child: _buildTimelineItem(
                        time: act['time'] ?? '--:--',
                        title: act['title'] ?? 'Hoạt động',
                        location: act['location'] ?? '',
                        lat: lat,
                        lng: lng,
                        icon: icon,
                        color: color,
                        isFirst: index == 0,
                        isLast: index == _scheduleList.length - 1, 
                      ),
                    );
                  },
                ),
          )
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.event_busy, size: 80, color: Colors.grey.shade300),
        const SizedBox(height: 16),
        Text('Chưa có lịch trình nào!', style: GoogleFonts.plusJakartaSans(color: Colors.grey, fontSize: 16)),
        const SizedBox(height: 24),
        Padding(padding: const EdgeInsets.symmetric(horizontal: 40), child: _buildAddButton()),
      ],
    );
  }

  Widget _buildAddButton() {
    return InkWell(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (context) => AddActivityScreen(tripId: widget.tripId)));
      },
      child: Container(
        height: 56, margin: const EdgeInsets.only(top: 16),
        decoration: BoxDecoration(
          color: primaryColor.withOpacity(0.1), borderRadius: BorderRadius.circular(16),
          border: Border.all(color: primaryColor.withOpacity(0.3), style: BorderStyle.solid),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.add_circle, color: primaryColor),
            const SizedBox(width: 8),
            Text('Thêm hoạt động mới', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold, color: primaryColor)),
          ],
        ),
      ),
    );
  }

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

  Widget _buildTimelineItem({required String time, required String title, required String location, double? lat, double? lng, required IconData icon, required Color color, bool isFirst = false, bool isLast = false}) {
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
                if (!isLast) Expanded(child: Container(width: 2, color: Colors.grey.shade200))
              ],
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 32),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.grey.shade100), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10)]),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(time, style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w900, color: color, fontSize: 16)),
                        const Spacer(),
                        
                        // --- NÚT DẪN ĐƯỜNG ĐÂY RỒI ---
                        GestureDetector(
                          onTap: () => _openGoogleMaps(lat, lng, location),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(color: Colors.blue.shade50, borderRadius: BorderRadius.circular(12)),
                            child: Row(
                              children: [
                                const Icon(Icons.directions, color: Colors.blue, size: 14),
                                const SizedBox(width: 4),
                                Text('Dẫn đường', style: GoogleFonts.plusJakartaSans(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.blue)),
                              ],
                            ),
                          ),
                        )
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(title, style: GoogleFonts.plusJakartaSans(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black)),
                    const SizedBox(height: 8),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.location_on, size: 14, color: Colors.grey.shade400),
                        const SizedBox(width: 4),
                        Expanded(child: Text(location, style: GoogleFonts.plusJakartaSans(fontSize: 13, color: Colors.grey.shade500), maxLines: 2, overflow: TextOverflow.ellipsis)),
                      ],
                    )
                  ],
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}