import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sizer/sizer.dart';

class EmployeeProfile extends StatefulWidget {
  const EmployeeProfile({super.key});

  @override
  _EmployeeProfileState createState() => _EmployeeProfileState();
}

class _EmployeeProfileState extends State<EmployeeProfile> {
  List<Map<String, dynamic>> tasks = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchEmployeeTasks();
  }
  Future<void> fetchEmployeeTasks() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        String currentEmployeeName =
            user.displayName ?? await _getEmployeeNameFromFirestore(user.uid);

        QuerySnapshot querySnapshot = await FirebaseFirestore.instance
            .collection('tasks')
            .where('employee', isEqualTo: currentEmployeeName)
            .get();

        if (querySnapshot.docs.isNotEmpty) {
          setState(() {
            tasks = querySnapshot.docs
                .map((doc) => doc.data() as Map<String, dynamic>)
                .toList();
            isLoading = false;
          });
        } else {
          setState(() {
            isLoading = false;
          });
        }
      } else {
        print("User is not logged in");
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      print("Error fetching data: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load tasks: $e')),
      );
      setState(() {
        isLoading = false;
      });
    }
  }
  Future<String> _getEmployeeNameFromFirestore(String uid) async {
    try {
      DocumentSnapshot doc =
          await FirebaseFirestore.instance.collection('users').doc(uid).get();
      return doc.exists ? doc['name'] ?? "Unknown" : "Unknown";
    } catch (e) {
      print("Error fetching employee name: $e");
      return "Unknown";
    }
  }
 String _formatTimestamp(dynamic timestamp) {
  if (timestamp == null || timestamp is! Timestamp) return "N/A";
  DateTime dt = timestamp.toDate();
  return DateFormat('dd/MM/yyyy | hh:mm a').format(dt);
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : tasks.isEmpty
              ? Center(
                  child: Text(
                    "No tasks assigned",
                    style: TextStyle(fontSize: 16.sp, color: Colors.grey),
                  ),
                )
              : ListView.builder(
                  padding: EdgeInsets.all(4.w),
                  itemCount: tasks.length,
                  itemBuilder: (context, index) {
                    var task = tasks[index];
                    return Card(
                      elevation: 3,
                      margin: EdgeInsets.only(bottom: 2.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Padding(
                        padding: EdgeInsets.all(4.w),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildInfoRow(
                              "Work Type",
                              task['workType'] ?? 'N/A',
                              Colors.blue,
                            ),
                            _buildInfoRow(
                              "Task Details",
                              task['taskDetails'] ?? 'N/A',
                              Colors.black87,
                            ),
                    
                            if (task['imageUrl'] != null) ...[
                              Padding(
                                padding: EdgeInsets.symmetric(vertical: 1.h),
                                child: Image.network(
                                  task['imageUrl'],
                                  width: 40.w,
                                  height: 40.w,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) =>
                                      Text(
                                    'Image not available',
                                    style: TextStyle(
                                        fontSize: 14.sp, color: Colors.grey),
                                  ),
                                ),
                              ),
                            ],
                            Divider(),
                            _buildInfoRow(
                              "Client",
                              task['client'] ?? 'N/A',
                              Colors.green,
                            ),
                            _buildInfoRow(
                              "Priority",
                              task['priority'] ?? 'N/A',
                              Colors.red,
                              isBold: true,
                            ),
                            Divider(),
                              _buildInfoRow(
                              "Assign Date/Time",
                              _formatTimestamp(task['timestamp']),
                              Colors.brown,
                            ),
                            _buildInfoRow(
                              "Submission Date",
                              task['date'] ?? 'N/A',
                              Colors.purple,
                            ),
                          
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
  Widget _buildInfoRow(String label, String value, Color color,
      {bool isBold = false}) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 0.8.h),
      child: RichText(
        text: TextSpan(
          style: TextStyle(fontSize: 20.sp, color: Colors.black),
          children: [
            TextSpan(
              text: "$label: ",
              style: TextStyle(fontWeight: FontWeight.w800, fontSize: 17.sp),
            ),
            TextSpan(
              text: value,
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: isBold ? FontWeight.w500 : FontWeight.normal,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}