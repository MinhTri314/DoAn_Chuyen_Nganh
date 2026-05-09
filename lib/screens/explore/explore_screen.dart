import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tri_go/constants.dart';
import 'package:tri_go/screens/create_trip/create_trip_screen.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:firebase_database/firebase_database.dart';

class ExploreScreen extends StatefulWidget {
  const ExploreScreen({super.key});

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  Map<String, Map<String, dynamic>> _weatherData = {};
  
  // 1. BIẾN LƯU TRỮ TOÀN BỘ ĐỊA ĐIỂM (Bao gồm mặc định + Firebase)
  List<Map<String, dynamic>> _allDestinations = [];
  
  // 2. BIẾN CHỈ HIỂN THỊ KẾT QUẢ TÌM KIẾM (Tối đa 5)
  List<Map<String, dynamic>> _filteredDestinations = []; 
  
  bool _isLoadingDestinations = true;

  final TextEditingController _searchController = TextEditingController();
  String _selectedCategory = 'Tất cả';

  // 3. DANH SÁCH MẶC ĐỊNH (Cứu cánh khi Firebase trống)
  final List<Map<String, dynamic>> _defaultDestinations = [
    {'title': 'Đà Lạt', 'rating': 4.8, 'predictedPrice': 3.5, 'location': 'Lâm Đồng'},
    {'title': 'Hà Nội', 'rating': 4.7, 'predictedPrice': 2.5, 'location': 'Thủ Đô'},
    {'title': 'Nha Trang', 'rating': 4.6, 'predictedPrice': 4.0, 'location': 'Khánh Hòa'},
    {'title': 'Hạ Long', 'rating': 4.9, 'predictedPrice': 4.5, 'location': 'Quảng Ninh'},
    {'title': 'Phú Quốc', 'rating': 4.8, 'predictedPrice': 5.5, 'location': 'Kiên Giang'},
    {'title': 'Sapa', 'rating': 4.5, 'predictedPrice': 3.0, 'location': 'Lào Cai'},
    {'title': 'Đà Nẵng', 'rating': 4.7, 'predictedPrice': 3.2, 'location': 'Miền Trung'},
  ];

  @override
  void initState() {
    super.initState();
    _fetchAndMergeDestinations();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // --- HÀM HÒA TRỘN DỮ LIỆU ---
  Future<void> _fetchAndMergeDestinations() async {
    // Khởi tạo bằng danh sách mặc định trước
    List<Map<String, dynamic>> mergedList = List.from(_defaultDestinations);

    try {
      final snapshot = await FirebaseDatabase.instance.ref('reviews').get();
      
      if (snapshot.exists) {
        Map<dynamic, dynamic> reviewsData = snapshot.value as Map<dynamic, dynamic>;

        reviewsData.forEach((destName, destReviews) {
          if (destReviews is Map) {
            double totalStars = 0;
            double totalCost = 0;
            int count = 0;

            destReviews.forEach((key, review) {
              totalStars += (review['stars'] ?? 0);
              totalCost += (review['costPerPerson'] ?? 0);
              count++;
            });

            if (count > 0) {
              double avgRating = totalStars / count;
              double avgPrice = (totalCost / count) / 1000000;
              String title = destName.toString();

              // Kiểm tra xem địa điểm trên Firebase có trùng với danh sách mặc định không
              int existingIndex = mergedList.indexWhere((element) => 
                  element['title'].toString().toLowerCase() == title.toLowerCase());

              if (existingIndex != -1) {
                // Nếu trùng -> Cập nhật số sao và giá tiền thực tế
                mergedList[existingIndex]['rating'] = avgRating;
                mergedList[existingIndex]['predictedPrice'] = avgPrice;
              } else {
                // Nếu là địa điểm hoàn toàn mới -> Thêm vào list
                mergedList.add({
                  'title': title,
                  'rating': avgRating,
                  'predictedPrice': avgPrice,
                  'location': 'Việt Nam', 
                });
              }
            }
          }
        });
      }
    } catch (e) {
      debugPrint("Lỗi Firebase: $e (Sẽ dùng data mặc định)");
    }

    // Nạp ảnh cho tất cả
    for (var item in mergedList) {
      item['imageUrl'] = _getMockImageForDest(item['title']);
    }

    // Sắp xếp TẤT CẢ theo rating giảm dần
    mergedList.sort((a, b) => b['rating'].compareTo(a['rating']));

    if (mounted) {
      setState(() {
        _allDestinations = mergedList;
        _isLoadingDestinations = false;
      });
      // Lọc và hiển thị lần đầu
      _runFilter(); 
    }
  }

  String _removeDiacritics(String str) {
    const withDia = 'áàảãạăắằẳẵặâấầẩẫậéèẻẽẹêếềểễệíìỉĩịóòỏõọôốồổỗộơớờởỡợúùủũụưứừửữựýỳỷỹỵđÁÀẢÃẠĂẮẰẲẴẶÂẤẦẨẪẬÉÈẺẼẸÊẾỀỂỄỆÍÌỈĨỊÓÒỎÕỌÔỐỒỔỖỘƠỚỜỞỠỢÚÙỦŨỤƯỨỪỬỮỰÝỲỶỸỴĐ';
    const withoutDia = 'aaaaaaaaaaaaaaaaaeeeeeeeeeeeiiiiiooooooooooooooooouuuuuuuuuuuyyyyydAAAAAAAAAAAAAAAAAEEEEEEEEEEEIIIIIOOOOOOOOOOOOOOOOOUUUUUUUUUUUYYYYYD';
    for (int i = 0; i < withDia.length; i++) {
      str = str.replaceAll(withDia[i], withoutDia[i]);
    }
    return str;
  }

  String _getCategoryForDest(String destName) {
    String lowerName = destName.toLowerCase();
    if (lowerName.contains('nha trang') || lowerName.contains('hạ long') || lowerName.contains('ha long') || lowerName.contains('phú quốc') || lowerName.contains('vũng tàu') || lowerName.contains('đà nẵng') || lowerName.contains('quy nhơn')) {
      return 'Biển';
    }
    if (lowerName.contains('sapa') || lowerName.contains('đà lạt') || lowerName.contains('da lat') || lowerName.contains('hà giang') || lowerName.contains('mộc châu') || lowerName.contains('tam đảo')) {
      return 'Núi';
    }
    if (lowerName.contains('hà nội') || lowerName.contains('ha noi') || lowerName.contains('hồ chí minh') || lowerName.contains('sài gòn') || lowerName.contains('cần thơ') || lowerName.contains('huế')) {
      return 'Thành phố';
    }
    return 'Khác'; 
  }

  void _runFilter() {
    String enteredKeyword = _searchController.text;
    
    // Lấy từ nguồn TẤT CẢ ĐỊA ĐIỂM
    List<Map<String, dynamic>> results = List.from(_allDestinations);

    // 1. Lọc theo danh mục
    if (_selectedCategory != 'Tất cả') {
      results = results.where((dest) {
        return _getCategoryForDest(dest['title']) == _selectedCategory;
      }).toList();
    }

    // 2. Lọc theo chữ tìm kiếm
    if (enteredKeyword.isNotEmpty) {
      String searchKey = _removeDiacritics(enteredKeyword.toLowerCase());
      results = results.where((dest) {
        String destTitle = _removeDiacritics(dest['title'].toLowerCase());
        return destTitle.contains(searchKey);
      }).toList();
    }

    // 3. GIỚI HẠN HIỂN THỊ TỐI ĐA 5 ĐỊA ĐIỂM 1 SCREEN
    if (results.length > 5) {
      results = results.sublist(0, 5);
    }

    setState(() {
      _filteredDestinations = results;
    });

    // Sau khi lọc xong, mới gọi API thời tiết cho 5 địa điểm đó để tiết kiệm tài nguyên
    for (var dest in _filteredDestinations) {
      if (!_weatherData.containsKey(dest['title'])) {
        _fetchWeatherForCard(dest['title']);
      }
    }
  }

  String _getMockImageForDest(String destName) {
    String lowerName = destName.toLowerCase();
    if (lowerName.contains('nha trang')) return 'https://picsum.photos/id/1043/800/600';
    if (lowerName.contains('sapa')) return 'https://picsum.photos/id/1018/800/600';
    if (lowerName.contains('hạ long') || lowerName.contains('ha long')) return 'https://picsum.photos/id/1016/800/600';
    if (lowerName.contains('đà lạt') || lowerName.contains('da lat')) return 'https://picsum.photos/id/1015/800/600';
    return 'https://picsum.photos/seed/${destName.replaceAll(' ', '')}/800/600';
  }

  String _extractCityName(String fullTitle) {
    String clean = fullTitle.toLowerCase()
        .replaceAll('chuyến đi', '')
        .replaceAll('du lịch', '')
        .replaceAll('đến', '')
        .replaceAll('tour', '')
        .trim();
    
    if (clean.isEmpty) return 'Địa điểm';
    return clean.split(' ').map((w) => w.isNotEmpty ? '${w[0].toUpperCase()}${w.substring(1)}' : '').join(' ');
  }

  Future<void> _fetchWeatherForCard(String titleKey) async {
    String searchCity = _extractCityName(titleKey);
    final apiKey = 'd3c44294527a57cc6a6940c89ca35259';
    final url = 'https://api.openweathermap.org/data/2.5/weather?q=$searchCity&appid=$apiKey&units=metric&lang=vi';
    
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        
        String rawDesc = data['weather'][0]['description'];
        String desc = rawDesc.isNotEmpty ? '${rawDesc[0].toUpperCase()}${rawDesc.substring(1)}' : '';

        if (mounted) {
          setState(() {
            _weatherData[titleKey] = {
              'temp': data['main']['temp'].round().toString(),
              'temp_max': data['main']['temp_max'].round().toString(),
              'temp_min': data['main']['temp_min'].round().toString(),
              'desc': desc,
              'display_name': searchCity,
            };
          });
        }
      } else {
        if (mounted) {
          setState(() {
            _weatherData[titleKey] = {
              'temp': '--',
              'temp_max': '--',
              'temp_min': '--',
              'desc': 'Không có dữ liệu',
              'display_name': searchCity,
            };
          });
        }
      }
    } catch (e) {
      debugPrint('Weather error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background.withValues(alpha: 0.9),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Khám phá', style: GoogleFonts.epilogue(fontSize: 24, fontWeight: FontWeight.w800, color: AppColors.textDark)),
            Container(
              width: 40, height: 40,
              decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle, border: Border.all(color: Colors.grey.shade200)),
              child: const Icon(Icons.notifications_outlined, color: Colors.black54),
            )
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 100),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Container(
                height: 56,
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4))]),
                child: TextField(
                  controller: _searchController, 
                  onChanged: (value) => _runFilter(),
                  decoration: InputDecoration(
                    hintText: 'Tìm kiếm điểm đến (vd: Hà Nội)...',
                    hintStyle: GoogleFonts.epilogue(color: Colors.grey.shade400, fontSize: 14),
                    prefixIcon: const Icon(Icons.search, color: Colors.grey),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(vertical: 18),
                  ),
                ),
              ),
            ),

            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  _buildChip('Tất cả'),
                  _buildChip('Biển'),
                  _buildChip('Núi'),
                  _buildChip('Thành phố'),
                ],
              ),
            ),
            
            const SizedBox(height: 24),

            if (_searchController.text.isEmpty && _selectedCategory == 'Tất cả') ...[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Container(
                  height: 220,
                  decoration: BoxDecoration(borderRadius: BorderRadius.circular(24), image: const DecorationImage(image: NetworkImage('https://picsum.photos/id/1016/800/600'), fit: BoxFit.cover)),
                  child: Container(decoration: BoxDecoration(borderRadius: BorderRadius.circular(24), gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Colors.transparent, Colors.black.withOpacity(0.8)]))),
                ),
              ),
              const SizedBox(height: 24),
            ],

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                (_searchController.text.isEmpty && _selectedCategory == 'Tất cả') ? 'Top điểm đến đánh giá cao' : 'Kết quả tìm kiếm', 
                style: GoogleFonts.epilogue(fontSize: 20, fontWeight: FontWeight.w800, color: AppColors.textDark)
              ),
            ),
            
            const SizedBox(height: 16),

            _isLoadingDestinations 
              ? const Center(child: Padding(padding: EdgeInsets.all(20), child: CircularProgressIndicator()))
              : _filteredDestinations.isEmpty 
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Text("Không tìm thấy địa điểm nào phù hợp.", style: TextStyle(color: Colors.grey.shade500)),
                      )
                    )
                  : Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Column(
                        children: _filteredDestinations.map((dest) {
                          return _buildDestinationCard(
                            context,
                            title: dest['title'],
                            location: dest['location'],
                            imageUrl: dest['imageUrl'],
                            rating: dest['rating'],
                            predictedPrice: dest['predictedPrice'],
                          );
                        }).toList(),
                      ),
                    ),
          ],
        ),
      ),
    );
  }

  Widget _buildChip(String label) {
    bool isActive = _selectedCategory == label;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedCategory = label;
        });
        _runFilter(); 
      },
      child: Container(
        margin: const EdgeInsets.only(right: 12),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: isActive ? AppColors.orange : Colors.white, 
          borderRadius: BorderRadius.circular(30), 
          border: Border.all(color: isActive ? AppColors.orange : Colors.grey.shade200)
        ),
        child: Text(label, style: GoogleFonts.epilogue(fontSize: 13, fontWeight: FontWeight.w600, color: isActive ? Colors.white : Colors.grey.shade600)),
      ),
    );
  }

  Widget _buildDestinationCard(BuildContext context, {required String title, required String location, required String imageUrl, required double rating, required double predictedPrice}) {
    final weather = _weatherData[title];

    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      decoration: BoxDecoration(
        color: Colors.white, 
        borderRadius: BorderRadius.circular(24), 
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.08), blurRadius: 20, offset: const Offset(0, 8))]
      ),
      child: Column(
        children: [
          Stack(
            children: [
              Container(
                height: 280, 
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(24)), 
                  image: DecorationImage(image: NetworkImage(imageUrl), fit: BoxFit.cover)
                )
              ),
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                    color: Colors.black.withValues(alpha: 0.35), 
                  ),
                ),
              ),
              
              if (weather == null)
                 const Positioned.fill(child: Center(child: CircularProgressIndicator(color: Colors.white)))
              else
                Positioned.fill(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        weather['display_name'] ?? '',
                        style: GoogleFonts.epilogue(
                          fontSize: 24, 
                          fontWeight: FontWeight.w400, 
                          color: Colors.white,
                          shadows: const [Shadow(color: Colors.black45, blurRadius: 8)]
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${weather['temp']}°',
                        style: GoogleFonts.epilogue(
                          fontSize: 84, 
                          fontWeight: FontWeight.w200,
                          color: Colors.white, 
                          height: 1.1,
                          letterSpacing: -3,
                          shadows: const [Shadow(color: Colors.black45, blurRadius: 12)]
                        ),
                      ),
                      Text(
                        weather['desc'],
                        style: GoogleFonts.epilogue(
                          fontSize: 18, 
                          fontWeight: FontWeight.w500, 
                          color: Colors.white,
                          shadows: const [Shadow(color: Colors.black45, blurRadius: 8)]
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'C:${weather['temp_max']}°   T:${weather['temp_min']}°',
                        style: GoogleFonts.epilogue(
                          fontSize: 16, 
                          fontWeight: FontWeight.w500, 
                          color: Colors.white,
                          shadows: const [Shadow(color: Colors.black45, blurRadius: 8)]
                        ),
                      ),
                    ],
                  ),
                ),

              Positioned(
                top: 16, right: 16,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.95), 
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 8)]
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.star, color: Colors.amber, size: 16),
                      const SizedBox(width: 4),
                      Text(rating.toStringAsFixed(1), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13))
                    ]
                  ),
                ),
              )
            ]
          ),
          
          Padding(
            padding: const EdgeInsets.all(20), 
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween, 
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start, 
                      children: [
                        Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(Icons.location_on, size: 14, color: Colors.grey.shade400), 
                            const SizedBox(width: 4),
                            Text(location, style: TextStyle(fontSize: 13, color: Colors.grey.shade600))
                          ]
                        ),
                      ]
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end, 
                      children: [
                        Text('DỰ ĐOÁN/NGƯỜI', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey.shade500, letterSpacing: 0.5)),
                        const SizedBox(height: 2),
                        Text('${predictedPrice.toStringAsFixed(1)}M VNĐ', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: AppColors.orange)),
                      ]
                    ),
                  ]
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity, 
                  child: ElevatedButton(
                    onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => CreateTripScreen(initialDestination: title))), 
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.orange.withValues(alpha: 0.1), 
                      foregroundColor: AppColors.orange, 
                      elevation: 0, 
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))
                    ), 
                    child: const Text('Lên kế hoạch ngay', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15))
                  )
                ),
              ]
            )
          ),
        ]
      ),
    );
  }
}