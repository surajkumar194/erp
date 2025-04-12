import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:erp/chatservice.dart'; // Assuming this is the correct import
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

      setState(() {
        employees = querySnapshot.docs
            .map((doc) => {
                  'id': doc.id,
                  'name': doc['name'] as String,
                  'email': doc['email'] as String,
                  // Add a sample last message and timestamp for design (fetch from Firestore if available)
                  'lastMessage': 'Hello, how can I assist you?', // Replace with actual data if available
                  'timestamp': DateTime.now().subtract(Duration(hours: 2)), // Replace with actual data
                })
            .toList();
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

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inDays == 0) {
      return '${timestamp.hour}:${timestamp.minute.toString().padLeft(2, '0')}';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return '${timestamp.day}/${timestamp.month}/${timestamp.year}';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
    
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : employees.isEmpty
              ? Center(
                  child: Text(
                    'No employees found',
                    style: TextStyle(fontSize: 16.sp, color: Colors.grey),
                  ),
                )
              : ListView.separated(
                  padding: EdgeInsets.all(2.w),
                  itemCount: employees.length,
                  separatorBuilder: (context, index) => Divider(height: 1.h, color: Colors.grey[300]),
                  itemBuilder: (context, index) {
                    final employee = employees[index];
                    return ListTile(
                      leading: CircleAvatar(
                        radius: 6.w,
                         backgroundColor: Colors.blue,
                        //backgroundImage: AssetImage('assets/de.jpg'), // Replace with actual image if available
                        child: employee['name'].isNotEmpty
                            ? Text(
                                employee['name'][0].toUpperCase(),
                                style: TextStyle(fontSize: 18.sp, color: Colors.white),
                              )
                            : null,
                      ),
                      title: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            employee['name'],
                            style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
                          ),
                          Icon(Icons.check, size: 18.sp, color: Colors.green), // Status indicator
                        ],
                      ),
                      subtitle: Text(
                        employee['lastMessage'] ?? 'No message yet',
                        style: TextStyle(fontSize: 14.sp, color: Colors.grey),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      trailing: Text(
                        _formatTimestamp(employee['timestamp']),
                        style: TextStyle(fontSize: 14.sp, color: Colors.grey),
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ChatConversationScreen(
                              receiverId: employee['id'],
                              receiverName: employee['name'],
                              isManager: true,
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
    );
  }
}