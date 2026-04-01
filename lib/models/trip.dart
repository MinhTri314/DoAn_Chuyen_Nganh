class Trip {
  String id;
  String title;
  String destinationName;
  String imageUrl; // Chỉ lưu link ảnh mạng
  DateTime startDate;
  DateTime endDate;
  double budgetLimit;

  Trip({
    required this.id,
    required this.title,
    required this.destinationName,
    required this.imageUrl,
    required this.startDate,
    required this.endDate,
    required this.budgetLimit,
  });
}