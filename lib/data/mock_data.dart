import '../models/trip.dart';

// Tạo một danh sách các chuyến đi giả định
final List<Trip> mockTrips = [
  Trip(
    id: 'T001',
    title: 'Chuyến đi Phú Quốc',
    destinationName: 'Phú Quốc', // Đã sửa thành destinationName
    imageUrl: 'assets/images/phu_quoc.webp', // Thêm imageUrl bị thiếu
    startDate: DateTime(2024, 9, 15),
    endDate: DateTime(2024, 9, 18),
    budgetLimit: 15000000,
  ),
  Trip(
    id: 'T002',
    title: 'Nghỉ dưỡng Đà Lạt',
    destinationName: 'Đà Lạt', // Đã sửa thành destinationName
    imageUrl: 'assets/images/da_lat.webp', // Thêm imageUrl bị thiếu
    startDate: DateTime(2024, 10, 20),
    endDate: DateTime(2024, 10, 23),
    budgetLimit: 8000000,
  ),
];