import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:erp/aftersplash/login.dart';
import 'package:erp/bottomScreen/bottomemployee.dart';
import 'package:erp/bottomScreen/bottommanager.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Sizer(
      builder: (context, orientation, deviceType) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          home: const SplashScreen(),
        );
      },
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateAfterSplash();
  }

  Future<void> _navigateAfterSplash() async {
    await Future.delayed(const Duration(seconds: 3));
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => AuthWrapper()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Image.asset(
          'assets/4.webp',
          fit: BoxFit.cover,
          height: 30.h,
          width: double.infinity,
        ),
      ),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  AuthWrapper({super.key});

  Future<Widget> _getInitialScreen() async {
    User? user = _auth.currentUser;

    if (user != null) {
      try {
        DocumentSnapshot managerDoc =
            await _firestore.collection("Manager").doc(user.uid).get();

        if (managerDoc.exists && managerDoc.get("role") == "Manager") {
          return const bottommanager();
        }

        DocumentSnapshot employeeDoc =
            await _firestore.collection("users").doc(user.uid).get();

        if (employeeDoc.exists && employeeDoc.get("role") == "Employee") {
          return const BottomNavigationBarWidget();
        }
      } catch (e) {
        print("Error checking role: $e");
      }
    }
    return const Login();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Widget>(
      future: _getInitialScreen(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        return snapshot.data ?? const Login();
      },
    );
  }
}