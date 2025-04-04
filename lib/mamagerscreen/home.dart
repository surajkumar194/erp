import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:erp/screen/work.dart';
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
  String? _priority = 'Low';
  String? _status = 'To-Do';
  DateTime? _selectedDate;
  String? _selectedEmployeeId; // Store employeeId

  // Sample employee list with IDs
  Map<String, String> employees = {
    'Gurveen': 'EMP001',
    'Harman': 'EMP002',
    'Ayush': 'EMP003',
    'Sunny': 'EMP004',
    'Tanish': 'EMP005',
    'Mohammad': 'EMP006',
  };

  List<String> clients = ['Infosys Limited', 'Dell Technologies', 'Ola Cabs', 'BYJUS', 'Apple'];
  List<String> workTypes = ['Development', 'Design', 'Testing', 'Deployment', 'Maintenance', 'Research', 'Project Management', 'Training', 'Quality Assurance', 'Consulting'];
  List<String> statuses = ['To-Do', 'In-Process', 'Work Review', 'Done'];
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

 Future<void> _submitDataToFirebase() async {
  if (_formKey.currentState!.validate() && _selectedDate != null) {
    try {
      await FirebaseFirestore.instance.collection('tasks').add({
        'client': _selectedClient,
        'workType': _selectedWorkType,
        'employee': _selectedEmployee,
        'employeeId': _selectedEmployeeId, // Save employee ID
        'taskDetails': _taskDetailsController.text,
        'priority': _priority,
        'status': _status,
        'date': _selectedDate!.toLocal().toString().split(' ')[0],
        'timestamp': FieldValue.serverTimestamp(),
      });

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Task added successfully"),
        backgroundColor: Colors.green,
      ));

      // Navigate to EmployeeProfile after success
      if (_selectedEmployeeId != null) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => EmployeeProfile(employeeId: _selectedEmployeeId!),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Failed to add task: $e"),
        backgroundColor: Colors.red,
      ));
    }
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
                    Text("Manager", style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.w600)),
                    SizedBox(height: 1.h),

                    DropdownButtonFormField<String>(
                      value: _selectedClient,
                      hint: Text('Select Client'),
                      decoration: InputDecoration(prefixIcon: Icon(Icons.person), border: OutlineInputBorder()),
                      items: clients.map((String client) => DropdownMenuItem(value: client, child: Text(client))).toList(),
                      onChanged: (value) => setState(() => _selectedClient = value),
                      validator: (value) => value == null ? 'Please select a client' : null,
                    ),
                    SizedBox(height: 2.h),

                    DropdownButtonFormField<String>(
                      value: _selectedWorkType,
                      hint: Text('Type of Work'),
                      decoration: InputDecoration(prefixIcon: Icon(Icons.work), border: OutlineInputBorder()),
                      items: workTypes.map((String type) => DropdownMenuItem(value: type, child: Text(type))).toList(),
                      onChanged: (value) => setState(() => _selectedWorkType = value),
                      validator: (value) => value == null ? 'Please select work type' : null,
                    ),
                    SizedBox(height: 2.h),

                    DropdownButtonFormField<String>(
                      value: _selectedEmployee,
                      hint: Text('Select Employee'),
                      decoration: InputDecoration(prefixIcon: Icon(Icons.people), border: OutlineInputBorder()),
                      items: employees.keys.map((String employee) {
                        return DropdownMenuItem(
                          value: employee,
                          child: Text(employee),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedEmployee = value;
                          _selectedEmployeeId = employees[value!]; // Set employeeId
                        });
                      },
                      validator: (value) => value == null ? 'Please select an employee' : null,
                    ),
                    SizedBox(height: 2.h),

                    TextFormField(
                      controller: _taskDetailsController,
                      decoration: InputDecoration(labelText: 'Task Details', prefixIcon: Icon(Icons.description), border: OutlineInputBorder()),
                      validator: (value) => value!.isEmpty ? 'Task details are required' : null,
                    ),
                    SizedBox(height: 2.h),

                    DropdownButtonFormField<String>(
                      value: _priority,
                      hint: Text('Select Priority'),
                      decoration: InputDecoration(prefixIcon: Icon(Icons.priority_high), border: OutlineInputBorder()),
                      items: priorities.map((String priority) => DropdownMenuItem(value: priority, child: Text(priority))).toList(),
                      onChanged: (value) => setState(() => _priority = value),
                      validator: (value) => value == null ? 'Please select priority' : null,
                    ),
                    SizedBox(height: 2.h),

                    DropdownButtonFormField<String>(
                      value: _status,
                      hint: Text('Select Status'),
                      decoration: InputDecoration(prefixIcon: Icon(Icons.list), border: OutlineInputBorder()),
                      items: statuses.map((String status) => DropdownMenuItem(value: status, child: Text(status))).toList(),
                      onChanged: (value) => setState(() => _status = value),
                      validator: (value) => value == null ? 'Please select status' : null,
                    ),
                    SizedBox(height: 2.h),

                    Row(
                      children: [
                        Icon(Icons.calendar_today),
                        SizedBox(width: 10),
                        Text('Date: ${_selectedDate != null ? _selectedDate!.toLocal().toString().split(' ')[0] : 'Select Date'}', style: TextStyle(fontSize: 17.sp)),
                        Spacer(),
                        ElevatedButton(
                          onPressed: () => _selectDate(context),
                          child: Text('Select Date', style: TextStyle(fontSize: 16.sp)),
                        ),
                      ],
                    ),
                    SizedBox(height: 2.h),

                    ElevatedButton(
                      onPressed: _submitDataToFirebase,
                      child: Text('Submit'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 15),
                        textStyle: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
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
