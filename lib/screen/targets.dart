import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sizer/sizer.dart';

class TaskScreen extends StatefulWidget {
  @override
  _TaskScreenState createState() => _TaskScreenState();
}

class _TaskScreenState extends State<TaskScreen> {
  List<Map<String, dynamic>> tasks = [];
  bool isLoading = true;
  int monthlyTarget = 50;
  int achievedTarget = 0; // Initialize based on fetched tasks
  String currentMonth = DateFormat.MMMM().format(DateTime.now());

  @override
  void initState() {
    super.initState();
    fetchEmployeeTasks();
  }

  Future<void> fetchEmployeeTasks() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        String currentEmployeeName = user.displayName ?? await _getEmployeeNameFromFirestore(user.uid);

        QuerySnapshot querySnapshot = await FirebaseFirestore.instance
            .collection('tasks')
            .where('employee', isEqualTo: currentEmployeeName)
            .get();

        if (querySnapshot.docs.isNotEmpty) {
          setState(() {
            tasks = querySnapshot.docs
                .map((doc) => {
                      ...doc.data() as Map<String, dynamic>,
                      'id': doc.id, // Store document ID for updates
                    })
                .toList();
            // Calculate achievedTarget based on existing "Done" tasks
            achievedTarget = tasks.where((task) => task['status'] == 'Done').length;
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
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<String> _getEmployeeNameFromFirestore(String uid) async {
    DocumentSnapshot doc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
    return doc['name'] ?? "Unknown";
  }

  Future<void> updateStatus(String taskId, String status) async {
    try {
      // Update Firestore
      await FirebaseFirestore.instance.collection('tasks').doc(taskId).update({
        'status': status,
      });

      // Update local state
      setState(() {
        int taskIndex = tasks.indexWhere((task) => task['id'] == taskId);
        if (taskIndex != -1) {
          tasks[taskIndex]['status'] = status;
          if (status == "Done" && tasks[taskIndex]['status'] != "Done") {
            achievedTarget++;
          } else if (status != "Done" && tasks[taskIndex]['status'] == "Done") {
            achievedTarget--;
          }
        }
      });

     
    } catch (e) {
      print("Error updating status: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Failed to update status: $e"),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

@override
Widget build(BuildContext context) {
  return Scaffold(
    body: isLoading
        ? Center(child: CircularProgressIndicator())
        : Column(
            children: [
              Padding(
                padding: EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Text(
                      "Total Tasks: ${tasks.length}",
                      style: TextStyle(fontSize: 17.sp, fontWeight: FontWeight.w600),
                    ),
                    Text(
                      "Target: $monthlyTarget",
                      style: TextStyle(fontSize: 17.sp, fontWeight: FontWeight.w600),
                    ),
                    Text(
                      "Achieved: $achievedTarget",
                      style: TextStyle(fontSize: 17.sp, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: tasks.length,
                  itemBuilder: (context, index) {
                    var task = tasks[index];
                    return Card(
                      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
                      elevation: 3,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Padding(
                        padding: EdgeInsets.all(4.w),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            RichText(
  text: TextSpan(
    children: [
      TextSpan(
        text: "Client : ",
        style: TextStyle(
          fontSize: 19.sp,
          fontWeight: FontWeight.w900,
          color: Colors.black,
        ),
      ),
      TextSpan(
        text: "${task['client'] ?? 'N/A'}",
        style: TextStyle(
          fontSize: 17.sp, // Different font size for the value
            fontWeight: FontWeight.w500,
          color: Colors.grey[800], // Or any other color
        ),
      ),
    ],
  ),
),

                            SizedBox(height: 1.h),
                           RichText(
  text: TextSpan(
    children: [
      TextSpan(
        text: "Description : ",
        style: TextStyle(
            fontSize: 19.sp,
          fontWeight: FontWeight.w900,
          color: Colors.black,
        ),
      ),
      TextSpan(
        text: "${task['taskDetails'] ?? 'N/A'}",
        style: TextStyle(
            fontSize: 17.sp,
          fontWeight: FontWeight.w500,
          color: Colors.grey[800],
        ),
      ),
    ],
  ),
),
  SizedBox(height: 1.h),
RichText(
  text: TextSpan(
    children: [
      TextSpan(
        text: "Work Type : ",
        style: TextStyle(
            fontSize: 19.sp,
          fontWeight: FontWeight.w900,
          color: Colors.black,
        ),
      ),
      TextSpan(
        text: "${task['workType'] ?? 'N/A'}",
        style: TextStyle(
           fontSize: 17.sp,
        fontWeight: FontWeight.w500,
          color: Colors.grey[800],
        ),
      ),
    ],
  ),
),

                            SizedBox(height: 2.h),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                Expanded(
                                  child: ElevatedButton(
                                    onPressed: () => updateStatus(task['id'], "In Process"),
                                    child: Text(
                                      "In Process",
                                      style: TextStyle(fontSize: 17.sp, fontWeight: FontWeight.w700, color: Colors.white),
                                    ),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: task['status'] == "In Process"
                                          ? Colors.blue
                                          : Colors.grey,
                                      foregroundColor: Colors.white,
                                      padding: EdgeInsets.symmetric(vertical: 1.5.h),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(width: 4.w),
                                Expanded(
                                  child: ElevatedButton(
                                    onPressed: () => updateStatus(task['id'], "Done"),
                                    child: Text(
                                      "Done",
                                      style: TextStyle(fontSize: 17.sp),
                                    ),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: task['status'] == "Done"
                                          ? Colors.green
                                          : Colors.grey,
                                      foregroundColor: Colors.white,
                                      padding: EdgeInsets.symmetric(vertical: 1.5.h),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
  );
}
}