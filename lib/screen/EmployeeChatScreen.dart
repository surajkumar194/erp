import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:erp/chatservice.dart'; // Assuming this is the correct import
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

class EmployeeChatScreen extends StatefulWidget {
  const EmployeeChatScreen({super.key});

  @override
  _EmployeeChatScreenState createState() => _EmployeeChatScreenState();
}

class _EmployeeChatScreenState extends State<EmployeeChatScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  String? managerId;
  String? managerName;
  String? lastMessage;
  DateTime? lastTimestamp;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchManager();
  }

  Future<void> _fetchManager() async {
    setState(() {
      isLoading = true;
    });
    try {
      // Fetch the first approved manager
      QuerySnapshot querySnapshot = await _firestore
          .collection('Manager')
          .where('isApproved', isEqualTo: true)
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        var managerDoc = querySnapshot.docs.first;
        String employeeId = _auth.currentUser!.uid;
        String chatId = '${managerDoc.id}_$employeeId';

        // Fetch the latest message from the chats collection
        QuerySnapshot chatSnapshot = await _firestore
            .collection('chats')
            .doc(chatId)
            .collection('messages')
            .orderBy('timestamp', descending: true)
            .limit(1)
            .get();

        String? latestMessage = chatSnapshot.docs.isNotEmpty
            ? chatSnapshot.docs.first['message'] as String?
            : 'Tap to start chatting';
        Timestamp? latestTimestamp = chatSnapshot.docs.isNotEmpty
            ? chatSnapshot.docs.first['timestamp'] as Timestamp?
            : Timestamp.now();

        setState(() {
          managerId = managerDoc.id;
          managerName = managerDoc['name'] as String;
          lastMessage = latestMessage;
          lastTimestamp = latestTimestamp?.toDate();
          isLoading = false;
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('No manager found')),
        );
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching manager: $e')),
      );
      setState(() {
        isLoading = false;
      });
    }
  }

  String _formatTimestamp(DateTime? timestamp) {
    if (timestamp == null) return '';
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
          : managerId == null
              ? Center(
                  child: Text(
                    'No manager available',
                    style: TextStyle(fontSize: 18.sp, color: Colors.grey),
                  ),
                )
              : Column(
                  children: [
                    SizedBox(height: 2.h), // Add some top padding
                    ListTile(
                      leading: CircleAvatar(
                        radius: 4.w,
                        child: Text(
                          managerName![0].toUpperCase(),
                          style: TextStyle(fontSize: 16.sp, color: Colors.white),
                        ),
                        backgroundColor: Colors.blue,
                      ),
                      title: Row(
                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            managerName!,
                            style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
                          ), Icon(Icons.check, size: 18.sp, color: Colors.green),
                        ],
                      ),
                      subtitle: Text(
                        lastMessage ?? 'Tap to start chatting',
                        style: TextStyle(fontSize: 14.sp, color: Colors.grey),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      trailing: Text(
                        _formatTimestamp(lastTimestamp),
                        style: TextStyle(fontSize: 14.sp, color: Colors.grey),
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ChatConversationScreen(
                              receiverId: managerId!,
                              receiverName: managerName!,
                              isManager: false,
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
    );
  }
}