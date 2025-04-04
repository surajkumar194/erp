// import 'package:erp/aftersplash/login.dart';
// import 'package:erp/bottomScreen/bottomemployee.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'package:sizer/sizer.dart';

// class SplashScreen extends StatefulWidget {
//   const SplashScreen({super.key});

//   @override
//   _SplashScreenState createState() => _SplashScreenState();
// }

// class _SplashScreenState extends State<SplashScreen> {
//   @override
//   void initState() {
//     super.initState();

//     Future.delayed(Duration(seconds: 3), () {
//       User? user = FirebaseAuth.instance.currentUser;
// try {
//         // Check Manager collection
//         DocumentSnapshot managerDoc = await _firestore
//             .collection("Manager")
//             .doc(user.uid)
//             .get();

//         if (managerDoc.exists && managerDoc.get("role") == "Manager") {
//           return const bottommanager();
//         }

//         // Check users (Employee) collection
//         DocumentSnapshot employeeDoc = await _firestore
//             .collection("users")
//             .doc(user.uid)
//             .get();

//         if (employeeDoc.exists && employeeDoc.get("role") == "Employee") {
//           return const BottomNavigationBarWidget();
//         }
//       } catch (e) {
//         print("Error checking role: $e");
//       }
//     }
//     // If no user or role not found, show login screen
//     return const Loginboth();
//   }
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Center(
//         child: Image.asset(
//           'assets/4.webp',  
//           fit: BoxFit.cover, // Better scaling
//           height: 30.h,
//           width: double.infinity,
//         ),
//       ),
//     );
//   }
// }
