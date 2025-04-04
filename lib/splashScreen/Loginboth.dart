import 'package:erp/login/Login.dart';
import 'package:erp/login/ManagerLoginScreen.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';

class Loginboth extends StatefulWidget {
  const Loginboth({super.key});

  @override
  State<Loginboth> createState() => _LoginbothState();
}

class _LoginbothState extends State<Loginboth> {
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffffffff),
      appBar: AppBar(
        backgroundColor: const Color(0xffffffff),
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Padding(
            padding: EdgeInsets.only(
              left: 4.w,
            ),
            child: Icon(
              Icons.arrow_back,
              color: const Color(0xff013148),
              size: 24.sp,
            ),
          ),
        ),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Center(
              child: Padding(
            padding: EdgeInsets.all(8.0.sp),
             child: SizedBox(
       height: 20.h, 
          width: 100.w, 
          child: Image.asset("assets/4.webp"),
        ),
          )),
         Padding(
            padding: EdgeInsets.symmetric(horizontal: 8.w,
             vertical: 1.h),
            child: ElevatedButton(
              onPressed: () {
                setState(() {
                //  isWholesaler = false; 
                });
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const EmpoyeeLoginScreen(),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                elevation: 0,
                padding: EdgeInsets.zero,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.sp)),
              ),
              child: Ink(
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topRight,
                    end: Alignment.bottomLeft,
                    colors: [
                      Color(0xffe7dcc0),
                      Color(0xff013148),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(10.sp),
                ),
                child: Container(
                  height: 8.h,
                  width: double.infinity,
                  alignment: Alignment.center,
                  child: Text(
                    "Employee Login",
                    style: GoogleFonts.montserrat(
                      color: Colors.white,
                      fontSize: 20.sp,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ),
          ),
         Padding(
            padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 1.h),
            child: ElevatedButton(
              onPressed: () {
                setState(() {
                //  isWholesaler = true; 
                });
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ManagerLoginScreen(),
                  ),
                );
              }, style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                elevation: 0,
                padding: EdgeInsets.zero,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.sp)),
              ),
              child: Ink(
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                    end: Alignment.topRight,
                    colors: [
                     Color(0xffe7dcc0),
                      Color(0xff013148),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(10.sp),
                ),
                child: Container(
                  height: 8.h,
                  width: double.infinity,
                  alignment: Alignment.center,
                  child: Text(
                    "Manager Login",
                    style: GoogleFonts.montserrat(
                      color: Colors.white,
                      fontSize: 20.sp,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
