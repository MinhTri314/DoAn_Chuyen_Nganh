import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tri_go/constants.dart';

class AddMemberScreen extends StatefulWidget {
  const AddMemberScreen({super.key});

  @override
  State<AddMemberScreen> createState() => _AddMemberScreenState();
}

class _AddMemberScreenState extends State<AddMemberScreen> {
  // Giả lập trạng thái checkbox
  bool isChecked1 = false;
  bool isChecked2 = true; // Đỗ Thùy Linh (checked mặc định)
  bool isChecked3 = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      // 1. App Bar
      appBar: AppBar(
        backgroundColor: AppColors.background.withValues(alpha: 0.9),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textDark),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('Chọn Thành viên Đồng hành',
            style: GoogleFonts.plusJakartaSans(
                color: AppColors.textDark, fontWeight: FontWeight.w600, fontSize: 18)),
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: Colors.grey.shade200, height: 1),
        ),
      ),
      
      // 2. Nội dung chính
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(bottom: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header text
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Mời bạn đồng hành',
                            style: GoogleFonts.plusJakartaSans(
                                fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.textDark)),
                        const SizedBox(height: 4),
                        Text('Chia sẻ kế hoạch và quản lý chi tiêu cùng nhóm',
                            style: GoogleFonts.plusJakartaSans(fontSize: 14, color: AppColors.textGrey)),
                      ],
                    ),
                  ),

                  // Input Email
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.grey.shade100),
                        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 4)],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Nhập email thành viên',
                              style: GoogleFonts.plusJakartaSans(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textDark)),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Expanded(
                                child: Container(
                                  height: 56,
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade50,
                                    borderRadius: const BorderRadius.horizontal(left: Radius.circular(12)),
                                    border: Border.all(color: Colors.grey.shade200),
                                  ),
                                  padding: const EdgeInsets.symmetric(horizontal: 16),
                                  alignment: Alignment.centerLeft,
                                  child: TextField(
                                    decoration: InputDecoration(
                                      border: InputBorder.none,
                                      hintText: 'example@email.com',
                                      hintStyle: GoogleFonts.plusJakartaSans(color: Colors.grey.shade400),
                                    ),
                                  ),
                                ),
                              ),
                              Container(
                                height: 56,
                                width: 56,
                                decoration: const BoxDecoration(
                                  color: AppColors.primary,
                                  borderRadius: BorderRadius.horizontal(right: Radius.circular(12)),
                                ),
                                child: const Icon(Icons.alternate_email, color: Colors.white),
                              )
                            ],
                          )
                        ],
                      ),
                    ),
                  ),

                  // Danh sách gợi ý (Chuyến đi trước)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Thành viên từ chuyến đi trước',
                            style: GoogleFonts.plusJakartaSans(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textDark)),
                        Text('Chọn nhiều thành viên để mời nhanh',
                            style: GoogleFonts.plusJakartaSans(fontSize: 12, color: AppColors.textGrey)),
                      ],
                    ),
                  ),

                  _buildMemberOption(
                    name: 'Phạm Minh Hoàng',
                    email: 'hoang.pm@email.com',
                    imageUrl: 'https://i.pravatar.cc/150?img=11',
                    isChecked: isChecked1,
                    onTap: () => setState(() => isChecked1 = !isChecked1),
                  ),
                  _buildMemberOption(
                    name: 'Đỗ Thùy Linh',
                    email: 'linh.dt@email.com',
                    imageUrl: 'https://i.pravatar.cc/150?img=5',
                    isChecked: isChecked2,
                    onTap: () => setState(() => isChecked2 = !isChecked2),
                  ),
                  _buildMemberOption(
                    name: 'Hoàng Anh Tuấn',
                    email: 'tuan.ha@email.com',
                    imageUrl: 'https://i.pravatar.cc/150?img=3',
                    isChecked: isChecked3,
                    onTap: () => setState(() => isChecked3 = !isChecked3),
                  ),

                  const SizedBox(height: 24),

                  // Danh sách đã tham gia
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text('Thành viên đã tham gia (3)',
                        style: GoogleFonts.plusJakartaSans(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textDark)),
                  ),
                  const SizedBox(height: 12),
                  
                  // Card Admin (Trưởng nhóm)
                  _buildJoinedMember(
                    name: 'Nguyễn Văn A',
                    email: 'vana@email.com',
                    imageUrl: 'https://i.pravatar.cc/150?img=12', // Avatar Admin
                    role: 'Trưởng nhóm',
                    isLeader: true,
                  ),
                  
                  // Card Member
                  _buildJoinedMember(
                    name: 'Lê Thị B',
                    email: 'thib@email.com',
                    imageUrl: 'https://i.pravatar.cc/150?img=9',
                    role: 'Thành viên',
                    isLeader: false,
                  ),
                ],
              ),
            ),
          ),
          
          // 3. Bottom Button (Fixed)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.background,
              border: Border(top: BorderSide(color: Colors.grey.shade200)),
            ),
            child: SafeArea(
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () {
                     // Logic mời thành viên xong quay về
                     Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    elevation: 8,
                    shadowColor: AppColors.primary.withValues(alpha: 0.3),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.send, color: Colors.white, size: 20),
                      const SizedBox(width: 8),
                      Text('Gửi lời mời', style: GoogleFonts.plusJakartaSans(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                    ],
                  ),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  // Widget hiển thị 1 dòng gợi ý thành viên (Có Checkbox tròn)
  Widget _buildMemberOption({required String name, required String email, required String imageUrl, required bool isChecked, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: isChecked ? AppColors.primary : Colors.grey.shade100),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 4)],
        ),
        child: Row(
          children: [
            CircleAvatar(radius: 24, backgroundImage: NetworkImage(imageUrl)),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name, style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600, fontSize: 16, color: AppColors.textDark)),
                  Text(email, style: GoogleFonts.plusJakartaSans(fontSize: 12, color: AppColors.textGrey)),
                ],
              ),
            ),
            // Custom Checkbox
            Container(
              width: 24, height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isChecked ? AppColors.primary : Colors.transparent,
                border: Border.all(color: isChecked ? AppColors.primary : Colors.grey.shade300, width: 2),
              ),
              child: isChecked ? const Icon(Icons.check, size: 16, color: Colors.white) : null,
            )
          ],
        ),
      ),
    );
  }

  // Widget hiển thị thành viên ĐÃ tham gia
  Widget _buildJoinedMember({required String name, required String email, required String imageUrl, required String role, required bool isLeader}) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Row(
        children: [
          // Avatar có icon ngôi sao nếu là Leader
          Stack(
            children: [
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: isLeader ? AppColors.primary.withValues(alpha: 0.3) : Colors.transparent, width: 2)
                ),
                child: CircleAvatar(radius: 24, backgroundImage: NetworkImage(imageUrl))
              ),
              if (isLeader)
                Positioned(
                  bottom: 0, right: 0,
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
                    child: const Icon(Icons.star, color: Colors.white, size: 10),
                  ),
                )
            ],
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(name, style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600, fontSize: 16, color: AppColors.textDark)),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: isLeader ? AppColors.primary.withValues(alpha: 0.1) : Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(role.toUpperCase(), style: GoogleFonts.plusJakartaSans(fontSize: 10, fontWeight: FontWeight.bold, color: isLeader ? AppColors.primary : AppColors.textGrey)),
                    )
                  ],
                ),
                Text(email, style: GoogleFonts.plusJakartaSans(fontSize: 12, color: AppColors.textGrey)),
              ],
            ),
          ),
          Icon(isLeader ? Icons.more_vert : Icons.close, color: Colors.grey.shade400),
        ],
      ),
    );
  }
}