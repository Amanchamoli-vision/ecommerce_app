import 'package:clothes_ecommerce/Admin/add_product.dart';
import 'package:clothes_ecommerce/pages/bottom_nav.dart';
import 'package:clothes_ecommerce/pages/login.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: const FirebaseOptions(
      apiKey: "AIzaSyD2A3xxhwacIEljfEhzoO_-2LJ6dFjBYW8",
      appId: "1:250806353932:android:05c3d8ec73459352c4ee29",
      messagingSenderId: "250806353932",
      projectId: "clothingapp-6ee5e",
      storageBucket: "clothingapp-6ee5e.firebasestorage.app",
    ),
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // ✅ Apni admin email yahan set karo
  static const String _adminEmail = "amanchamoli9761@gmail.com";

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Clothes E-commerce',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xff6e5038)),
        useMaterial3: true,
      ),
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {

          // App load ho raha hai — spinner dikhao
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              backgroundColor: Color(0xff1A0F0A),
              body: Center(
                child: CircularProgressIndicator(
                  color: Color(0xffD4A57A),
                ),
              ),
            );
          }

          // User logged in hai
          if (snapshot.hasData && snapshot.data != null) {
            final String? email = snapshot.data!.email;

            // Admin hai toh admin panel
            if (email == _adminEmail) {
              return const AddProduct();
            }

            // Normal user — BottomNav (Home + NavBar)
            return const BottomNav();
          }

          // Logged out — Login screen
          return const Login();
        },
      ),
    );
  }
}