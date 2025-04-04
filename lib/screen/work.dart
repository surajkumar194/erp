import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

class EmployeeProfile extends StatefulWidget {
  final String employeeId;

  const EmployeeProfile({Key? key, required this.employeeId}) : super(key: key);

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
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('tasks')
          .where('employeeId', isEqualTo: widget.employeeId)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        setState(() {
          tasks = querySnapshot.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();
          isLoading = false;
        });
      } else {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Employee Task")),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : tasks.isEmpty
              ? Center(child: Text("No tasks assigned"))
              : ListView.builder(
                  padding: EdgeInsets.all(4.w),
                  itemCount: tasks.length,
                  itemBuilder: (context, index) {
                    var task = tasks[index];
                    return Card(
                      elevation: 3,
                      margin: EdgeInsets.only(bottom: 2.h),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      child: Padding(
                        padding: EdgeInsets.all(4.w),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildInfoRow("Work Type", task['workType'], Colors.blue),
                            _buildInfoRow("Task Details", task['taskDetails'], Colors.black87),
                            Divider(),
                            _buildInfoRow("Client", task['client'], Colors.green),
                            _buildInfoRow("Priority", task['priority'], Colors.red, isBold: true),
                            Divider(),
                            _buildInfoRow("Status", task['status'], Colors.orange),
                            _buildInfoRow("Date", task['date'], Colors.purple),
                          ],
                        ),
                      ),
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
