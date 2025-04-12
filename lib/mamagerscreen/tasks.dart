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
  String? expandedEmployee;
  String? selectedDesignation;
  String? selectedEmployee;
  bool isLoadingEmployees = false;
  List<String> employees = [];

  // List of designations
  final List<String> designations = [
    'Development',
    'Design',
    'Testing',
    'Deployment',
    'Maintenance',
    'Research',
    'Project Management',
    'Training',
    'Quality Assurance',
    'Consulting',
    'Video Editing',
    'Graphic Design',
    'Website',
    'SEO',
    'Ads'
  ];

  // Fetch employees based on selected designation
  Future<void> _fetchEmployeesForDesignation(String designation) async {
    setState(() {
      isLoadingEmployees = true;
      employees = [];
      selectedEmployee = null; // Reset selected employee when designation changes
    });

    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('role', isEqualTo: 'Employee')
          .where('designation', isEqualTo: designation)
          .get();

      setState(() {
        employees =
            querySnapshot.docs.map((doc) => doc['name'] as String).toList();
        isLoadingEmployees = false;
      });
    } catch (e) {
      print("Error fetching employees: $e");
      setState(() {
        isLoadingEmployees = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
     
      body: Column(
        children: [
          // Designation Dropdown
          Padding(
            padding: EdgeInsets.only(left: 4.w,right: 4.w,top: 2.h,bottom: 2.h),
            child: DropdownButtonFormField<String>(
              value: selectedDesignation,
              hint: Text('Select Designation'),
              decoration: InputDecoration(
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(20.sp)),
                contentPadding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
              ),
              items: designations.map((designation) {
                return DropdownMenuItem<String>(
                  value: designation,
                  child: Text(designation),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  selectedDesignation = value;
                  if (value != null) {
                    _fetchEmployeesForDesignation(value);
                  }
                });
              },
            ),
          ),
        
          Padding(
            padding: EdgeInsets.only(left: 4.w,right: 4.w),
            child: isLoadingEmployees
                ? Center(child: CircularProgressIndicator())
                : DropdownButtonFormField<String>(
                    value: selectedEmployee,
                    hint: Text('Select Employee'),
                    decoration: InputDecoration(
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(20.sp)),
                      contentPadding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
                    ),
                    items: employees.map((employee) {
                      return DropdownMenuItem<String>(
                        value: employee,
                        child: Text(employee),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        selectedEmployee = value;
                      });
                    },
                  ),
          ),
          // Tasks List
          Expanded(
            child: selectedEmployee == null
                ? Center(child: Text("Please select an employee",style: TextStyle(fontSize: 18.sp),))
                : StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('tasks')
                        .where('employee', isEqualTo: selectedEmployee)
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(child: CircularProgressIndicator());
                      }
                      if (snapshot.hasError) {
                        return Center(child: Text("Error: ${snapshot.error}"));
                      }
                      if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                        return Center(child: Text("No tasks found for $selectedEmployee"));
                      }

                      List<Map<String, dynamic>> tasks = snapshot.data!.docs
                          .map((doc) => doc.data() as Map<String, dynamic>)
                          .toList();

                      return ListView(
                        padding: EdgeInsets.all(4.w),
                        children: tasks.map((task) {
                          String formattedTimestamp = task['timestamp'] != null
                              ? DateFormat('dd MMM yyyy  |  hh:mm a').format(
                                  (task['timestamp'] as Timestamp)
                                      .toDate()
                                      .toLocal())
                              : 'N/A';

                          return Card(
                            elevation: 3,
                            margin: EdgeInsets.only(bottom: 2.h),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10)),
                            child: Padding(
                              padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _buildInfoRow("Work Type", task['workType'] ?? 'N/A', Colors.blue),
                                  _buildInfoRow("Task Details", task['taskDetails'] ?? 'N/A', Colors.black87),
                                  _buildInfoRow("Client", task['client'] ?? 'N/A', Colors.green),
                                  _buildInfoRow("Priority", task['priority'] ?? 'N/A', Colors.red, isBold: true),
                                  _buildInfoRow("Submission Date", task['date'] ?? 'N/A', Colors.purple),
                                  _buildInfoRow("Assign Date/Time", formattedTimestamp, Colors.brown),
                                  Divider(),
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, Color color, {bool isBold = false}) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 0.5.h),
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