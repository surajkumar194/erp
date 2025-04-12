import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

class Performance extends StatefulWidget {
  const Performance({super.key});

  @override
  State<Performance> createState() => _PerformanceState();
}

class _PerformanceState extends State<Performance> {
  String? selectedDesignation;
  String? selectedEmployee;
  bool isLoadingEmployees = false;
  bool isLoadingPerformance = false;
  List<String> employees = [];
  Map<String, dynamic>? employeePerformance;

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

  @override
  void initState() {
    super.initState();
  }

  // Fetch employees based on selected designation
  Future<void> _fetchEmployeesForDesignation(String designation) async {
    setState(() {
      isLoadingEmployees = true;
      employees = [];
      selectedEmployee = null; // Reset selected employee when designation changes
      employeePerformance = null; // Reset performance data
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

  // Fetch performance data for the selected employee
  Future<void> _fetchEmployeePerformance() async {
    if (selectedEmployee == null) return;

    setState(() {
      isLoadingPerformance = true;
      employeePerformance = null;
    });

    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('tasks')
          .where('employee', isEqualTo: selectedEmployee)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        int inProcess = 0;
        int done = 0;

        for (var doc in querySnapshot.docs) {
          var data = doc.data() as Map<String, dynamic>;
          String status = data['status'] ?? 'N/A';
          if (status == 'In Process') {
            inProcess++;
          } else if (status == 'Done') {
            done++;
          }
        }

        setState(() {
          employeePerformance = {
            'employee': selectedEmployee,
            'inProcess': inProcess,
            'done': done,
          };
          isLoadingPerformance = false;
        });
      } else {
        setState(() {
          employeePerformance = {
            'employee': selectedEmployee,
            'inProcess': 0,
            'done': 0,
          };
          isLoadingPerformance = false;
        });
      }
    } catch (e) {
      print("Error fetching performance data: $e");
      setState(() {
        isLoadingPerformance = false;
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
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
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
          // Employee Dropdown
          Padding(
            padding: EdgeInsets.only(left: 4.w,right: 4.w),
            child: isLoadingEmployees
                ? Center(child: CircularProgressIndicator())
                : DropdownButtonFormField<String>(
                    value: selectedEmployee,
                    hint: Text('Select Employee'),
                    decoration: InputDecoration(
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(20.sp)),
                      contentPadding:
                          EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
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
                        if (value != null) {
                          _fetchEmployeePerformance();
                        }
                      });
                    },
                  ),
          ),
          // Performance Display
          Expanded(
            child: isLoadingPerformance
                ? Center(
                    child: CircularProgressIndicator(
                      color: Colors.blue,
                    ),
                  )
                : selectedEmployee == null
                    ? Center(child: Text("Please select an employee",style: TextStyle(fontSize: 18.sp),))
                    : employeePerformance == null
                        ? Center(child: Text("No performance data available"))
                        : Padding(
                            padding: EdgeInsets.all(4.w),
                            child: Card(
                              margin: EdgeInsets.symmetric(vertical: 1.h),
                              elevation: 4,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Padding(
                                padding: EdgeInsets.all(4.w),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          employeePerformance!['employee'],
                                          style: TextStyle(
                                            fontSize: 20.sp,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black,
                                          ),
                                        ),
                                        Container(
                                          padding: EdgeInsets.symmetric(
                                              horizontal: 3.w, vertical: 0.5.h),
                                          decoration: BoxDecoration(
                                            color: Colors.grey.shade200,
                                            borderRadius:
                                                BorderRadius.circular(8),
                                          ),
                                          child: Text(
                                            "Total: ${employeePerformance!['inProcess'] + employeePerformance!['done']}",
                                            style: TextStyle(
                                              fontSize: 17.sp,
                                              fontWeight: FontWeight.w900,
                                              color: Colors.black,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 1.h),
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.hourglass_empty,
                                          size: 20.sp,
                                          color: Colors.blue.shade700,
                                        ),
                                        SizedBox(width: 2.w),
                                        Text(
                                          "In Process: ${employeePerformance!['inProcess']}",
                                          style: TextStyle(
                                            fontSize: 17.sp,
                                            fontWeight: FontWeight.w800,
                                            color: Colors.blue.shade700,
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 0.5.h),
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.check_circle,
                                          size: 20.sp,
                                          color: Colors.green.shade700,
                                        ),
                                        SizedBox(width: 2.w),
                                        Text(
                                          "Completed: ${employeePerformance!['done']}",
                                          style: TextStyle(
                                            fontSize: 17.sp,
                                            fontWeight: FontWeight.w800,
                                            color: Colors.green.shade700,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
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