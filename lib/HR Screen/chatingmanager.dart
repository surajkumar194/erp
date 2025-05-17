import 'package:flutter/material.dart';

class Chatingmanager extends StatefulWidget {
  const Chatingmanager({super.key});

  @override
  State<Chatingmanager> createState() => _ChatingmanagerState();
}

class _ChatingmanagerState extends State<Chatingmanager> {
  @override
  Widget build(BuildContext context) {
     return Scaffold(
      appBar: AppBar(title: Text("Chat with Manager")),
      body: Center(child: Text("This is the Manager Chat screen")),
    );
  }
}