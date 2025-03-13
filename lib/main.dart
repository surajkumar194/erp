import 'package:erp/firebase/firebase_optional.dart';
import 'package:erp/login/Login.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

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
    return Sizer(
      builder: (context, orientation, deviceType) {
        return MaterialApp(
          // Add return here
          debugShowCheckedModeBanner: false,
          title: 'Bleu Tech',
          theme: ThemeData(
            primarySwatch: Colors.blue,
          ),
          home:LoginScreen(),
        );
      },
    );
  }
}
