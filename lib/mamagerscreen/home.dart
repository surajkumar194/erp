import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

class MAnagerHome extends StatefulWidget {
  const MAnagerHome({super.key});

  @override
  State<MAnagerHome> createState() => _MAnagerHomeState();
}

class _MAnagerHomeState extends State<MAnagerHome> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _taskDetailsController = TextEditingController();

  String? _selectedClient;
  String? _selectedEmployee;
  String? _selectedWorkType;
  String? _priority ;
  DateTime? _selectedDate;

  List<String> employees = [];
  bool isLoadingEmployees = false;

  List<String> clients = [
    'Infosys Limited',
    'Dell Technologies',
    'Ola Cabs',
    'BYJUS',
    'Apple'
  ];

  List<String> designations = [
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

  List<String> priorities = ['Low', 'Medium', 'High', 'Urgent'];

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _fetchEmployeesForDesignation(String designation) async {
    setState(() {
      isLoadingEmployees = true;
      employees = [];
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

  Future<void> _submitDataToFirebase() async {
if (_formKey.currentState!.validate() && 
      _taskDetailsController.text.isNotEmpty && 
      _selectedDate != null) {
      try {
        await FirebaseFirestore.instance.collection('tasks').add({
          'client': _selectedClient,
          'workType': _selectedWorkType,
          'employee': _selectedEmployee,
          'taskDetails': _taskDetailsController.text.trim(),
          'priority': _priority,
          'date': _selectedDate!.toLocal().toString().split(' ')[0],
          'timestamp': FieldValue.serverTimestamp(),
        });

        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(
            "Task added successfully",
            style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600),
          ),
          backgroundColor: Colors.green,
        ));

        _formKey.currentState!.reset();
        setState(() {
          _selectedClient = null;
          _selectedWorkType = null;
          _selectedEmployee = null;
          _taskDetailsController.clear();
          _priority = null ;
          _selectedDate = null;
          employees = [];
        });
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(
            "Failed to add task: $e",
            style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600),
          ),
          backgroundColor: Colors.red,
        ));
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(
          "Please fill all required fields",
          style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600),
        ),
        backgroundColor: Colors.red,
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: EdgeInsets.only(left: 4.w, right: 4.w, top: 2.h),
        child: Container(
          height: 75.h,
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8.sp),
            color: Colors.white,
            border: Border.all(width: 0.1),
          ),
          child: Padding(
            padding: EdgeInsets.all(18.sp),
            child: SingleChildScrollView(
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    Text("Manager",
                        style: TextStyle(
                            fontSize: 20.sp, fontWeight: FontWeight.w600)),
                    SizedBox(height: 1.h),
                    DropdownButtonFormField<String>(
                      value: _selectedClient,
                      hint: const Text('Select Client'),
                      decoration: const InputDecoration(
                          prefixIcon: Icon(Icons.person),
                          border: OutlineInputBorder()),
                      items: clients
                          .map((String client) => DropdownMenuItem(
                              value: client, child: Text(client)))
                          .toList(),
                      onChanged: (value) =>
                          setState(() => _selectedClient = value),
                      validator: (value) =>
                          value == null ? 'Please select a client' : null,
                    ),
                    SizedBox(height: 2.h),
                    DropdownButtonFormField<String>(
                      value: _selectedWorkType,
                      hint: const Text('Select Designation'),
                      decoration: const InputDecoration(
                          prefixIcon: Icon(Icons.work),
                          border: OutlineInputBorder()),
                      items: designations
                          .map((String designation) => DropdownMenuItem(
                              value: designation, child: Text(designation)))
                          .toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedWorkType = value;
                          _selectedEmployee = null;
                          _fetchEmployeesForDesignation(value!);
                        });
                      },
                      validator: (value) =>
                          value == null ? 'Please select designation' : null,
                    ),
                    SizedBox(height: 2.h),
                    isLoadingEmployees
                        ? const Center(child: CircularProgressIndicator())
                        : DropdownButtonFormField<String>(
                            value: _selectedEmployee,
                            hint: const Text('Select Employee'),
                            decoration: const InputDecoration(
                                prefixIcon: Icon(Icons.people),
                                border: OutlineInputBorder()),
                            items: employees
                                .map((String employee) => DropdownMenuItem(
                                    value: employee, child: Text(employee)))
                                .toList(),
                            onChanged: (value) =>
                                setState(() => _selectedEmployee = value),
                            validator: (value) => value == null
                                ? 'Please select an employee'
                                : null,
                          ),
                    SizedBox(height: 2.h),

                    DropdownButtonFormField<String>(
                      value: _priority,
                      hint:  Text('Select Priority'),
                      decoration: InputDecoration(
                          prefixIcon: Icon(Icons.priority_high),
                          border: OutlineInputBorder(),
                          errorStyle: TextStyle(
      color: Colors.red,
      fontSize: 14.sp,
    ),
                          ),
                      items: priorities
                          .map((String priority) => DropdownMenuItem(
                              value: priority, child: Text(priority)))
                          .toList(),
                      onChanged: (value) => setState(() => _priority = value),
                      validator: (value) =>
                          value == null ? 'Please select priority' : null,
                    ),

                    SizedBox(height: 2.h),
                    Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(20.sp),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Task:",
                                  style: TextStyle(
                                    fontSize: 20.sp,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.black,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),

                                // Text(
                                //   "Date: ${_selectedDate != null ? _selectedDate!.toLocal().toString().split(' ')[0] : 'Not Set'}",
                                //   style: TextStyle(
                                //     fontSize: 14.sp,
                                //     color: Colors.grey[700],
                                //   ),
                                // ),
                              ],
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              showModalBottomSheet(
                                context: context,
                                shape: const RoundedRectangleBorder(
                                  borderRadius: BorderRadius.vertical(
                                      top: Radius.circular(20)),
                                ),
                                isScrollControlled: true,
                                builder: (context) {
                                  String? taskError;
                                  String? dateError;

                                  return StatefulBuilder(
                                    builder: (BuildContext context,
                                        StateSetter setModalState) {
                                      return Padding(
                                        padding: EdgeInsets.only(
                                          bottom: MediaQuery.of(context)
                                              .viewInsets
                                              .bottom,
                                          left: 16,
                                          right: 16,
                                          top: 20,
                                        ),
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Center(
                                              child: Text(
                                                "Add Task Details",
                                                style: TextStyle(
                                                  fontSize: 18.sp,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                            SizedBox(height: 12),
                                            TextFormField(
                                              controller:
                                                  _taskDetailsController,
                                              decoration: InputDecoration(
                                                hintText:
                                                    "Enter your task here...",
                                                border:
                                                    const OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.all(
                                                          Radius.circular(12)),
                                                ),
                                                errorText: taskError,
                                              ),
                                              maxLines: 3,
                                            ),
                                            SizedBox(height: 1.h),
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Text(
                                                  "Assign Date: ${_selectedDate != null ? _selectedDate!.toLocal().toString().split(' ')[0] : 'Not Assigned'}",
                                                  style: TextStyle(
                                                      fontSize: 18.sp),
                                                ),
                                                IconButton(
                                                  icon: const Icon(
                                                    Icons.date_range,
                                                    color: Color.fromARGB(
                                                        255, 2, 54, 96),
                                                    size: 24,
                                                  ),
                                                  onPressed: () async {
                                                    final DateTime? picked =
                                                        await showDatePicker(
                                                      context: context,
                                                      initialDate:
                                                          _selectedDate ??
                                                              DateTime.now(),
                                                      firstDate: DateTime.now(),
                                                      lastDate: DateTime(2100),
                                                    );
                                                    if (picked != null) {
                                                      setState(() {
                                                        _selectedDate = picked;
                                                      });
                                                      setModalState(() {
                                                        dateError =
                                                            null; // Clear date error when date is picked
                                                      });
                                                    }
                                                  },
                                                ),
                                              ],
                                            ),
                                            if (dateError !=
                                                null) // Show date error message
                                              Padding(
                                                padding:
                                                    EdgeInsets.only(top: 8),
                                                child: Text(
                                                  dateError!,
                                                  style: TextStyle(
                                                    color: Colors.red,
                                                    fontSize: 17.sp,
                                                  ),
                                                ),
                                              ),
                                            SizedBox(height: 2.h),
                                            Center(
                                              child: ElevatedButton(
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor: Colors.blue,
                                                  foregroundColor: Colors.white,
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            10),
                                                  ),
                                                ),
                                                onPressed: () {
                                                  setModalState(() {
                                                    // Reset errors
                                                    taskError = null;
                                                    dateError = null;

                                                    // Validate task details
                                                    if (_taskDetailsController
                                                        .text
                                                        .trim()
                                                        .isEmpty) {
                                                      taskError =
                                                          'Task details are required';
                                                    }

                                                    // Validate date
                                                    if (_selectedDate == null) {
                                                      dateError =
                                                          'Please select a date';
                                                    }

                                                    // If no errors, proceed
                                                    if (taskError == null &&
                                                        dateError == null) {
                                                      setState(() {});
                                                      Navigator.pop(context);
                                                    }
                                                  });
                                                },
                                                child: const Text("Submit"),
                                              ),
                                            ),
                                            SizedBox(height: 20),
                                          ],
                                        ),
                                      );
                                    },
                                  );
                                },
                              );
                            },
                            child: Container(
                              decoration: const BoxDecoration(
                                color: Colors.blue,
                                shape: BoxShape.circle,
                              ),
                              padding: const EdgeInsets.all(8),
                              child: const Icon(
                                Icons.add,
                                size: 20,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 2.h),
                    ElevatedButton(
                      onPressed: _submitDataToFirebase,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(
                            horizontal: 20.w, vertical: 15),
                        textStyle: TextStyle(
                            fontSize: 18.sp, fontWeight: FontWeight.bold),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                      ),
                      child: const Text('Submit'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
