import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sizer/sizer.dart';

class Tasks extends StatefulWidget {
  const Tasks({super.key});

  @override
  State<Tasks> createState() => _TasksState();
}

class _TasksState extends State<Tasks> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
    
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('tasks').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text("No tasks found"));
          }

          List<Map<String, dynamic>> tasks = snapshot.data!.docs
              .map((doc) => doc.data() as Map<String, dynamic>)
              .toList();

          return ListView.builder(
            padding: EdgeInsets.all(4.w),
            itemCount: tasks.length,
            itemBuilder: (context, index) {
              var task = tasks[index];
              // Format timestamp if it exists
           String formattedTimestamp = task['timestamp'] != null
    ? DateFormat('dd MMMM yyyy   hh:mm:ss a').format(
        (task['timestamp'] as Timestamp).toDate().toLocal())
    : 'N/A';

              return Card(
                elevation: 3,
                margin: EdgeInsets.only(bottom: 2.h),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                child: Padding(
                  padding: EdgeInsets.all(4.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildInfoRow("Work Type", task['workType'] ?? 'N/A', Colors.blue),
                      _buildInfoRow("Task Details", task['taskDetails'] ?? 'N/A', Colors.black87),
                      Divider(),
                      _buildInfoRow("Client", task['client'] ?? 'N/A', Colors.green),
                      _buildInfoRow("Employee", task['employee'] ?? 'N/A', Colors.teal),
                      _buildInfoRow("Employee ID", task['employeeId'] ?? 'N/A', Colors.grey),
                      _buildInfoRow("Priority", task['priority'] ?? 'N/A', Colors.red, isBold: true),
                      Divider(),
                      _buildInfoRow("Status", task['status'] ?? 'N/A', Colors.orange),
                      _buildInfoRow("Submission Date", task['date'] ?? 'N/A', Colors.purple),
                      _buildInfoRow("Assign Date/time", formattedTimestamp, Colors.brown),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, Color color, {bool isBold = false}) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 0.8.h),
      child: RichText(
        text: TextSpan(
          style: TextStyle(fontSize: 14.sp, color: Colors.black),
          children: [
            TextSpan(
              text: "$label: ",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14.sp),
            ),
            TextSpan(
              text: value,
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}