import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Bắt buộc phải import thư viện này
import 'firebase_options.dart';

import 'screens/login/login_screen.dart'; 
import 'screens/home_screen.dart'; // Import trang Home

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Tri Go',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      // --- DÙNG STREAM BUILDER ĐỂ TỰ ĐỘNG ĐIỀU HƯỚNG ---
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          // 1. Trong lúc đang chờ Firebase phản hồi -> Hiển thị vòng xoay loading
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              backgroundColor: Colors.white,
              body: Center(child: CircularProgressIndicator()),
            );
          }
          
          // 2. Nếu đã có dữ liệu user (Đã đăng nhập và chưa đăng xuất) -> Vào thẳng Home
          if (snapshot.hasData) {
            return const HomeScreen();
          }
          
          // 3. Nếu chưa có user (Chưa đăng nhập hoặc đã đăng xuất) -> Vào màn hình Login
          return const LoginScreen();
        },
      ),
    );
  }
}