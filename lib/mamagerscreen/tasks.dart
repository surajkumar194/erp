import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:erp/chatservice.dart'; // For ChatConversationScreen
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sizer/sizer.dart';

class Tasks extends StatefulWidget {
  const Tasks({super.key});

  @override
  State<Tasks> createState() => _TasksState();
}

class _TasksState extends State<Tasks> {
  String? selectedDesignation;
  String? selectedEmployee;
  bool isLoadingEmployees = false;
  List<Map<String, String>> employees = [];
  String? managerId;
  String? managerName;

  final List<String> designations = [
    'Development',
    'Design',
    'Testing',
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
    'Ads',
  ];

  @override
  void initState() {
    super.initState();
    _fetchManagerDetails();
  }

  Future<void> _fetchManagerDetails() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        DocumentSnapshot doc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();
        setState(() {
          managerId = user.uid;
          managerName = doc.data()?.containsKey('name') ?? false
              ? doc['name'] as String? ?? 'Unknown Manager'
              : 'Unknown Manager';
        });
        print('Manager details: ID=$managerId, Name=$managerName');
      } catch (e) {
        print('Error fetching manager details: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error fetching manager details: $e')),
        );
      }
    } else {
      print('No user logged in');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No user logged in. Please log in again.')),
      );
    }
  }

  Future<void> _fetchEmployeesForDesignation(String designation) async {
    setState(() {
      isLoadingEmployees = true;
      employees = [];
      selectedEmployee = null;
    });
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('role', isEqualTo: 'Employee')
          .where('designation', isEqualTo: designation)
          .get();

      List<Map<String, String>> tempEmployees = [];
      for (var doc in querySnapshot.docs) {
        // Safely access document fields with fallbacks
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        String name = data.containsKey('name') && data['name'] != null
            ? data['name'] as String
            : 'Unknown Employee';
        String uid = doc.id;
        String employeeId = data.containsKey('employeeId') && data['employeeId'] != null
            ? data['employeeId'] as String
            : uid;

        tempEmployees.add({
          'name': name,
          'uid': uid,
          'employeeId': employeeId,
        });
      }

      setState(() {
        employees = tempEmployees;
        isLoadingEmployees = false;
      });

      if (employees.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("No employees found for this designation"),
            backgroundColor: Colors.orange,
          ),
        );
      } else {
        print('Fetched employees: $employees');
      }
    } catch (e) {
      setState(() {
        isLoadingEmployees = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching employees: $e')),
      );
      print('Error in _fetchEmployeesForDesignation: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Padding(
            padding:
                EdgeInsets.only(left: 4.w, right: 4.w, top: 2.h, bottom: 2.h),
            child: DropdownButtonFormField<String>(
              value: selectedDesignation,
              hint: const Text('Select Designation'),
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20.sp),
                ),
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
              ),
              items: designations
                  .map((designation) => DropdownMenuItem<String>(
                        value: designation,
                        child: Text(designation),
                      ))
                  .toList(),
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
            padding: EdgeInsets.only(left: 4.w, right: 4.w),
            child: isLoadingEmployees
                ? const Center(child: CircularProgressIndicator())
                : DropdownButtonFormField<String>(
                    value: selectedEmployee,
                    hint: const Text('Select Employee'),
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20.sp),
                      ),
                      contentPadding:
                          EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
                    ),
                    items: employees
                        .map((employee) => DropdownMenuItem<String>(
                              value: employee['name'],
                              child: Text(employee['name']!),
                            ))
                        .toList(),
                    onChanged: employees.isEmpty
                        ? null
                        : (value) {
                            setState(() {
                              selectedEmployee = value;
                              if (value != null) {
                                bool isValid =
                                    employees.any((emp) => emp['name'] == value);
                                if (!isValid) {
                                  print('Invalid employee selected: $value');
                                  selectedEmployee = null;
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                        content: Text('Invalid employee selection')),
                                  );
                                } else {
                                  print('Selected employee: $value');
                                }
                              }
                            });
                          },
                  ),
          ),
          Expanded(
            child: selectedEmployee == null || employees.isEmpty
                ? Center(
                    child: Text(
                      "Please select a valid employee",
                      style: TextStyle(fontSize: 18.sp),
                    ),
                  )
                : StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('tasks')
                        .where('employee', isEqualTo: selectedEmployee)
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      if (snapshot.hasError) {
                        return Center(child: Text("Error: ${snapshot.error}"));
                      }
                      if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                        return Center(
                          child: Text("No tasks found for $selectedEmployee"),
                        );
                      }

                      List<Map<String, dynamic>> tasks = snapshot.data!.docs
                          .map((doc) => {
                                ...doc.data() as Map<String, dynamic>,
                                'taskId': doc.id,
                              })
                          .toList();

                      print('Tasks: ${tasks.length}');
                      print('Employees: $employees');
                      print('Selected Employee: $selectedEmployee');

                      return ListView(
                        padding: EdgeInsets.all(4.w),
                        children: tasks.map((task) {
                       String formattedTimestamp = 'N/A';
if (task['timestamp'] != null && task['timestamp'] is Timestamp) {
  formattedTimestamp = DateFormat('dd MMM yyyy  |  hh:mm a')
      .format((task['timestamp'] as Timestamp).toDate().toLocal());
}


                          // Safely find the employee's UID for the selected employee
                          String? employeeUid;
                          if (selectedEmployee != null && employees.isNotEmpty) {
                            try {
                              final employee = employees.firstWhere(
                                (emp) => emp['name'] == selectedEmployee,
                                orElse: () => {},
                              );
                              employeeUid = employee['uid'];
                              if (employeeUid == null) {
                                print('No UID found for employee: $selectedEmployee');
                              }
                            } catch (e) {
                              employeeUid = null;
                              print('Error finding employee UID: $e');
                            }
                          } else {
                            print('No selected employee or empty employees list');
                          }

                          return Card(
                            elevation: 3,
                            margin: EdgeInsets.only(bottom: 2.h),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Padding(
                              padding: EdgeInsets.symmetric(
                                horizontal: 4.w,
                                vertical: 1.h,
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Padding(
                                    padding:
                                        EdgeInsets.symmetric(vertical: 0.5.h),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Flexible(
                                          child: RichText(
                                            text: TextSpan(
                                              style: TextStyle(
                                                fontSize: 16.sp,
                                                color: Colors.black,
                                              ),
                                              children: [
                                                TextSpan(
                                                  text: "Ticket ID: ",
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.w800,
                                                    fontSize: 17.sp,
                                                  ),
                                                ),
                                                TextSpan(
                                                  text:
                                                      task['ticketId'] ?? 'N/A',
                                                  style: TextStyle(
                                                    fontSize: 16.sp,
                                                    fontWeight: FontWeight.w500,
                                                    color: Colors.blue,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                        Flexible(
                                          child: RichText(
                                            text: TextSpan(
                                              style: TextStyle(
                                                fontSize: 16.sp,
                                                color: Colors.black,
                                              ),
                                              children: [
                                                TextSpan(
                                                  text: "Priority: ",
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.w800,
                                                    fontSize: 17.sp,
                                                  ),
                                                ),
                                                TextSpan(
                                                  text:
                                                      task['priority'] ?? 'N/A',
                                                  style: TextStyle(
                                                    fontSize: 16.sp,
                                                    fontWeight: FontWeight.w500,
                                                    color: Colors.red,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
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
                                  _buildInfoRow(
                                    "Client",
                                    task['client'] ?? 'N/A',
                                    Colors.green,
                                  ),
                                  _buildInfoRow(
                                    "Submission Date",
                                    task['date'] ?? 'N/A',
                                    Colors.purple,
                                  ),
                                  _buildInfoRow(
                                    "Assign Date/Time",
                                    formattedTimestamp,
                                    Colors.brown,
                                  ),
                                  Align(
                                    alignment: Alignment.centerLeft,
                                    child: TextButton.icon(
                                      onPressed: managerId == null ||
                                              employeeUid == null ||
                                              selectedEmployee == null ||
                                              (task['taskId'] == null &&
                                                  task['ticketId'] == null)
                                          ? () {
                                              ScaffoldMessenger.of(context)
                                                  .showSnackBar(
                                                const SnackBar(
                                                  content: Text(
                                                      'Unable to start chat: Missing task or employee details'),
                                                ),
                                              );
                                            }
                                          : () {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) =>
                                                      ChatConversationScreen(
                                                    receiverId: employeeUid!,
                                                    receiverName:
                                                        selectedEmployee!,
                                                    isManager: true,
                                                    ticketId: task['taskId'] ??
                                                        task['ticketId'] ??
                                                        '',   taskData: task, // 👈 Pass task data
                                                  ),
                                                ),
                                              );
                                            },
                                      label: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            'Chat',
                                            style: TextStyle(
                                              fontSize: 18.sp,
                                              color: Colors.black,
                                            ),
                                          ),
                                          Icon(
                                            Icons.mark_unread_chat_alt,
                                  color: Colors.green,
                                  size: 22.sp,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  const Divider(),
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

  Widget _buildInfoRow(String label, String value, Color color,
      {bool isBold = false}) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 0.5.h),
      child: RichText(
        text: TextSpan(
          style: TextStyle(fontSize: 16.sp, color: Colors.black),
          children: [
            TextSpan(
              text: "$label: ",
              style: TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 17.sp,
              ),
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

extension on Object? {
  containsKey(String s) {}
}