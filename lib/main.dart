import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:erp/HR%20Screen/Hr_Login.dart';
import 'package:erp/bottomScreen/bottomemployee.dart';
import 'package:erp/bottomScreen/bottommanager.dart';
import 'package:erp/service/sing.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (kIsWeb) {
    await Firebase.initializeApp(
      options: const FirebaseOptions(
        apiKey: "AIzaSyB3x0RupYfE19rJbFYXgMpc-QljuTwZrnA",
        authDomain: "erp-app-6eb85.firebaseapp.com",
        projectId: "erp-app-6eb85",
        storageBucket: "erp-app-6eb85.firebasestorage.app",
        messagingSenderId: "343320367868",
        appId: "1:343320367868:web:3f88440d11b94804c6bd79",
        measurementId: "G-SBXMYEWED6",
      ),
    );
  } else {
    await Firebase.initializeApp();
  }

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
          home: HRLoginScreen(),
          //ManagerLoginScreen
          //EmpoyeeLoginScreen
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
    return const SignupScreenfirst(); 
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
        return snapshot.data ?? const SignupScreenfirst(); 
      },
    );
  }
}








// rules_version = '2';
// service cloud.firestore {
//   match /databases/{database}/documents {
//     // General rule for authenticated users (fallback, can be restrictive based on your needs)
//     match /{document=**} {
//       allow read, write: if request.auth != null;
//     }

//     // Rule for users collection
//     match /users/{userId} {
//       // Allow read and write for users to access their own data
//       allow read, write: if request.auth != null && request.auth.uid == userId;

//       // Allow updating user data, but prevent role change
//       allow update: if request.auth != null && request.auth.uid == userId 
//         && request.resource.data.role == resource.data.role; // Prevent role changes by users

//       // Allow employees to read data (or fetch employee data)
//       allow read: if request.auth != null && resource.data.role == 'Employee';
//     }