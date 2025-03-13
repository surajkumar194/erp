import 'package:erp/screen/taskScreen.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

class Targets extends StatefulWidget {
  const Targets({super.key});

  @override
  State<Targets> createState() => _TargetsState();
}

class _TargetsState extends State<Targets> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            Navigator.pushReplacement(
              context, 
              MaterialPageRoute(builder: (_) => TaskScreen()),
            );
          },
          style: ElevatedButton.styleFrom(
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 2.h),
            textStyle: TextStyle(fontSize: 18.sp),
          ),
          child: Text("Employee"),
        ),
      ),
    );
  }
}
