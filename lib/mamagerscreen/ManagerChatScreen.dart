import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:erp/chatservice.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

class ManagerChatScreen extends StatefulWidget {
  const ManagerChatScreen({super.key});

  @override
  _ManagerChatScreenState createState() => _ManagerChatScreenState();
}

class _ManagerChatScreenState extends State<ManagerChatScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  List<Map<String, dynamic>> employees = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchEmployees();
  }

  Future<void> _fetchEmployees() async {
    setState(() {
      isLoading = true;
    });
    try {
      QuerySnapshot querySnapshot = await _firestore
          .collection('users')
          .where('role', isEqualTo: 'Employee')
          .get();

      List<Map<String, dynamic>> tempEmployees = [];

      for (var doc in querySnapshot.docs) {
        QuerySnapshot taskSnapshot = await _firestore
            .collection('tasks')
            .where('employeeId', isEqualTo: doc['employeeId'])
            .get();

        List<Map<String, dynamic>> tasks = taskSnapshot.docs.map((taskDoc) {
          final taskData = taskDoc.data() as Map<String, dynamic>;

          // Ensure managerId is always present
          taskData['managerId'] ??= _auth.currentUser?.uid ?? '';

          return {
            ...taskData,
            'taskId': taskDoc.id,
          };
        }).toList();

        tempEmployees.add({
          'id': doc['employeeId'] as String,
          'name': doc['name'] as String,
          'email': doc['email'] as String,
          'tasks': tasks,
        });
      }

      setState(() {
        employees = tempEmployees;
        isLoading = false;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching employees: $e')),
      );
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : employees.isEmpty
              ? Center(
                  child: Text(
                    'No employees found',
                    style: TextStyle(fontSize: 16.sp, color: Colors.grey),
                  ),
                )
              : ListView.builder(
                  padding: EdgeInsets.all(2.w),
                  itemCount: employees.length,
                  itemBuilder: (context, index) {
                    final employee = employees[index];
                    final tasks =
                        employee['tasks'] as List<Map<String, dynamic>>;

                    return ExpansionTile(
                      leading: CircleAvatar(
                        radius: 6.w,
                        backgroundColor: Colors.blue,
                        child: employee['name'].isNotEmpty
                            ? Text(
                                employee['name'][0].toUpperCase(),
                                style: TextStyle(
                                    fontSize: 20.sp, color: Colors.white),
                              )
                            : null,
                      ),
                      title: Text(
                        employee['name'],
                        style: TextStyle(
                            fontSize: 20.sp, fontWeight: FontWeight.w900),
                      ),
                      subtitle: Text(
                        '${tasks.length} tasks assigned',
                        style: TextStyle(fontSize: 17.sp, color: Colors.grey,fontWeight: FontWeight.w800),
                      ),
                      children: tasks.isEmpty
                          ? [
                              ListTile(
                                title: Text(
                                  'No tasks assigned',
                                  style: TextStyle(
                                      fontSize: 17.sp, color: Colors.grey),
                                ),
                              ),
                            ]
                          : tasks.map((task) {
                              return ListTile(
                                title: Text(
                                  'Client: ${task['client'] ?? 'N/A'}',
                                  style: TextStyle(
                                      fontSize: 17.sp,
                                      fontWeight: FontWeight.w800),
                                ),
                                subtitle: Text(
                                  'Submission Date: ${task['date'] ?? 'N/A'}',
                                  style: TextStyle(
                                      fontSize: 15.sp,
                                      color: Colors.grey,
                                      fontWeight: FontWeight.w700),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                trailing: Icon(
                                  Icons.mark_unread_chat_alt,
                                  color: Colors.green,
                                  size: 22.sp,
                                ),
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          ChatConversationScreen(
                                        receiverId: employee['id'],
                                        receiverName: employee['name'],
                                        isManager: true,
                                        ticketId: task['taskId'],
                                        taskData: task, // 👈 Pass task data
                                      ),
                                    ),
                                  );
                                },
                              );
                            }).toList(),
                    );
                  },
                ),
    );
  }
}
