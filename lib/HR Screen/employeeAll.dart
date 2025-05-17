import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

class EmployeeDataScreen extends StatefulWidget {
  const EmployeeDataScreen({super.key});

  @override
  _EmployeeDataScreenState createState() => _EmployeeDataScreenState();
}

class _EmployeeDataScreenState extends State<EmployeeDataScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  bool _isLoadingEmployees = false;
  List<Map<String, dynamic>> _users = [];
  String? _selectedDesignation;

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
    // Optionally, fetch employees for the first designation on init
    // _fetchEmployeesForDesignation(designations.first);
  }

  Future<void> _fetchEmployeesForDesignation(String designation) async {
    setState(() {
      _isLoadingEmployees = true;
      _users = [];
    });

    try {
      QuerySnapshot querySnapshot = await _firestore
          .collection('users')
          .where('role', isEqualTo: 'Employee')
          .where('designation', isEqualTo: designation)
          .get();

      setState(() {
        _users = querySnapshot.docs
            .map((doc) => {
                  'name': doc['name'] as String? ?? 'Unknown Employee',
                  'uid': doc.id,
                  'email': doc['email'] as String? ?? 'Unknown Email',
                  'phone': doc['phone'] as String? ?? 'Unknown Phone',
                  'gender': doc['gender'] as String? ?? 'Unknown Gender',
                })
            .toList();
        _isLoadingEmployees = false;
      });

      if (_users.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("No employees found for this designation"),
            backgroundColor: Colors.orange,
          ),
        );
      }
    } catch (e) {
      print("Error fetching employees: $e");
      setState(() {
        _isLoadingEmployees = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error fetching employees: $e"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Employee Data")),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: DropdownButtonFormField<String>(
              value: _selectedDesignation,
              hint: const Text('Select Designation'),
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.work),
              ),
              items: designations.map((designation) {
                return DropdownMenuItem<String>(
                  value: designation,
                  child: Text(designation),
                );
              }).toList(),
              onChanged: (newDesignation) {
                if (newDesignation != null) {
                  setState(() {
                    _selectedDesignation = newDesignation;
                    _fetchEmployeesForDesignation(newDesignation);
                  });
                }
              },
              validator: (value) =>
                  value == null ? 'Please select a designation' : null,
            ),
          ),
          Expanded(
            child: _isLoadingEmployees
                ? const Center(child: CircularProgressIndicator())
                : _users.isEmpty
                    ? const Center(child: Text("No employees found"))
                    : ListView.builder(
                        itemCount: _users.length,
                        itemBuilder: (context, index) {
                          final user = _users[index];
                          return Card(
                            margin: const EdgeInsets.all(8.0),
                            child: ListTile(
                              title: Text(
                                user['name'],
                                style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.w800),
                              ),
                              subtitle: Text(
                                "Email: ${user['email']}\nPhone: ${user['phone']}\nGender: ${user['gender']}",
                                style: TextStyle(fontSize: 17.sp,fontWeight: FontWeight.w400),
                              ),
                             // trailing: const Icon(Icons.chevron_right),
                              // onTap: () {
                              //   // Add navigation or action for employee details
                              // },
                              isThreeLine: true,
                              contentPadding: const EdgeInsets.all(8.0),
                              dense: true,
                              leading: CircleAvatar( radius: 20.sp, backgroundColor: Colors.red,
                                child: Text(user['name']?.substring(0, 1) ?? '',
                                style: TextStyle(fontSize: 22.sp,color: Colors.white),),
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
