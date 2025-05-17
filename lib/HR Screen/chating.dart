import 'package:erp/HR%20Screen/chatingemployee.dart';
import 'package:erp/HR%20Screen/chatingmanager.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

class ChatScreen extends StatelessWidget {
  const ChatScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
     appBar: AppBar(
        backgroundColor: const Color(0xffF1E9D2),
        elevation: 0,
        title: Text(
      "Chating",
          style: TextStyle(
              fontSize: 20.sp,
              fontWeight: FontWeight.w600,
              color: Colors.black),
        ),
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton( style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xff013148), // Button color
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                minimumSize: Size(80.w, 8.h), // Button size: Same width and height
              ),
              onPressed: () {
               Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => Chatingemployee(),
                  ),
                );
              },
              child: Text("Chat with Employee",  style: TextStyle(fontSize: 16.sp, color: Colors.white)),
            
            ),
            SizedBox(height: 20),
            ElevatedButton(              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xff013148), // Button color
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                minimumSize: Size(80.w, 8.h), // Button size: Same width and height
              ),
              onPressed: () {
               Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => Chatingmanager(),
                  ),
                );
              },
              child: Text("Chat with Manager",  style: TextStyle(fontSize: 16.sp, color: Colors.white)),
             
            ),
          ],
        ),
      ),
    );
  }
}
