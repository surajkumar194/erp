import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:erp/chatservice.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

class EmployeeChatScreen extends StatefulWidget {
  const EmployeeChatScreen({super.key});

  @override
  State<EmployeeChatScreen> createState() => _EmployeeChatScreenState();
}

class _EmployeeChatScreenState extends State<EmployeeChatScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  bool isLoading = true;
  List<Map<String, dynamic>> assignedTasks = [];

  @override
  void initState() {
    super.initState();
    _fetchAssignedTasks();
  }

  Future<void> _fetchAssignedTasks() async {
    setState(() {
      isLoading = true;
    });

    try {
      String employeeId = _auth.currentUser!.uid;

      QuerySnapshot taskSnapshot = await _firestore
          .collection('tasks')
          .where('employeeId', isEqualTo: employeeId)
          .get();

      List<Map<String, dynamic>> tasks = taskSnapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        data['taskId'] = doc.id;
        return data;
      }).toList();

      setState(() {
        assignedTasks = tasks;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching tasks: $e')),
      );
    }
  }

  String _formatTimestamp(Timestamp? timestamp) {
    if (timestamp == null) return '';
    final dateTime = timestamp.toDate();
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays == 0) {
      return '${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : assignedTasks.isEmpty
              ? Center(
                  child: Text(
                    'No tasks assigned',
                    style: TextStyle(fontSize: 16.sp, color: Colors.grey),
                  ),
                )
              : ListView.builder(
                  padding: EdgeInsets.all(3.w),
                  itemCount: assignedTasks.length,
                  itemBuilder: (context, index) {
                    final task = assignedTasks[index];
                    final managerName = task['managerName'] ?? 'Manager';
                    final ticketId = task['ticketId'] ?? 'N/A';

                    return Card(
                      elevation: 2,
                      margin: EdgeInsets.only(bottom: 2.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ListTile(
                        leading: CircleAvatar(
                          child: Text(managerName[0].toUpperCase()),
                        ),
                        title: Text(
                          'Client: ${task['client'] ?? ''}',
                          style: TextStyle(
                              fontSize: 16.sp, fontWeight: FontWeight.w500),
                        ),
                        subtitle: Text(
                          'Submission Date: ${task['date'] ?? ''}',
                          style: TextStyle(
                              fontSize: 14.sp,
                              color: Colors.blueGrey,
                              fontWeight: FontWeight.w500),
                        ),
                        trailing: IconButton(
                          icon: const Icon(
                           Icons.mark_unread_chat_alt,
                                    color: Colors.green
                          ),
                          onPressed: () {
                            final String? receiverId = task['managerId'];
                            final String? ticketId = task['taskId'];
                            final String managerName =
                                task['managerName'] ?? 'Manager';

                            print('Task Data: $task');
                            print('managerId: $receiverId');

                            if (receiverId == null || receiverId.isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                      'Manager ID is missing for this task.'),
                                ),
                              );
                              return;
                            }

                            if (ticketId == null || ticketId.isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Task ID is missing.'),
                                ),
                              );
                              return;
                            }

                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ChatConversationScreen(
                                  receiverId: receiverId,
                                  receiverName: managerName,
                                  isManager: false,
                                  ticketId: ticketId,
                                  taskData: task, // Pass task data
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
