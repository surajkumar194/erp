import 'package:flutter/material.dart';

class Chatingemployee extends StatefulWidget {
  const Chatingemployee({super.key});

  @override
  State<Chatingemployee> createState() => _ChatingemployeeState();
}

class _ChatingemployeeState extends State<Chatingemployee> {
  @override
  Widget build(BuildContext context) {
   return Scaffold(
      appBar: AppBar(title: Text("Chat with Manager")),
      body: Center(child: Text("This is the Manager Chat screen")),
    );
  }
}