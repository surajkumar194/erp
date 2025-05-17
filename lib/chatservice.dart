import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sizer/sizer.dart';

class ChatConversationScreen extends StatefulWidget {
  final String receiverId;
  final String receiverName;
  final bool isManager;
  final String ticketId;
  final Map<String, dynamic> taskData;

  const ChatConversationScreen({
    super.key,
    required this.receiverId,
    required this.receiverName,
    required this.isManager,
    required this.ticketId,
    required this.taskData,
  });

  @override
  _ChatConversationScreenState createState() => _ChatConversationScreenState();
}

class _ChatConversationScreenState extends State<ChatConversationScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final TextEditingController _messageController = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  User? currentUser;
  late String chatId;
  bool showTasks = false;
  bool isLoadingTask = false;
  bool isSendingMessage = false; // Track the sending status
  Map<String, dynamic>? task;

  @override
  void initState() {
    super.initState();
    currentUser = _auth.currentUser;
    if (currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No user logged in.')),
      );
      return;
    }

    chatId = widget.isManager
        ? '${currentUser!.uid}_${widget.receiverId}_${widget.ticketId}'
        : '${widget.receiverId}_${currentUser!.uid}_${widget.ticketId}';

    _buildTaskInfo();
  }

  Widget _buildTaskInfo() {
  final task = widget.taskData;
  String taskDetails = task['taskDetails'] ?? 'N/A';
  String client = task['client'] ?? 'N/A';
  String submissionDate = task['date'] ?? 'N/A';
  String assignDate = task['timestamp'] != null
      ? _formatTimestamp(task['timestamp'])
      : 'N/A';

  return Card(
    margin: const EdgeInsets.all(12),
    child: Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInfoRow("Task Details", taskDetails, Colors.black87),
          _buildInfoRow("Client", client, Colors.green),
          _buildInfoRow("Submission Date", submissionDate, Colors.purple),
          _buildInfoRow("Assign Date/Time", assignDate, Colors.brown),
        ],
      ),
    ),
  );
}

Widget _buildInfoRow(String title, String value, Color color) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 4),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "$title: ",
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(color: color),
          ),
        ),
      ],
    ),
  );
}

String _formatTimestamp(Timestamp timestamp) {
  final date = timestamp.toDate();
  return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
}


  Future<void> _pickAndSendImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image == null || currentUser == null) return;

    setState(() {
      isSendingMessage = true; 
    });

     try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image == null) return;

      // Upload image to Firebase Storage
      String fileName = '${DateTime.now().millisecondsSinceEpoch}_${currentUser!.uid}';
      Reference storageRef = _storage.ref().child('chat_images/$chatId/$fileName');
      UploadTask uploadTask = storageRef.putFile(File(image.path));
      TaskSnapshot snapshot = await uploadTask;
      String downloadUrl = await snapshot.ref.getDownloadURL();


  await _firestore.collection('chats').doc(chatId).collection('messages').add({
        'senderId': currentUser!.uid,
        'senderName': currentUser!.displayName ?? 'Manager',
        'imageUrl': downloadUrl,
        'timestamp': FieldValue.serverTimestamp(),
      });

      // Update chat metadata
      await _firestore.collection('chats').doc(chatId).set({
        'participants': [currentUser!.uid, widget.receiverId],
        'lastMessage': '[Image]',
        'lastMessageTime': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to send image: $e')),
      );
    }
  }

   void _sendMessage() async {
    if (_messageController.text.trim().isEmpty || currentUser == null) return;

    try {
      await _firestore.collection('chats').doc(chatId).collection('messages').add({
        'senderId': currentUser!.uid,
        'senderName': currentUser!.displayName ?? 'Manager',
        'message': _messageController.text.trim(),
        'timestamp': FieldValue.serverTimestamp(),
      });

      await _firestore.collection('chats').doc(chatId).set({
        'participants': [currentUser!.uid, widget.receiverId],
        'lastMessage': _messageController.text.trim(),
        'lastMessageTime': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      _messageController.clear();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to send message: $e')),
      );
    }
  }



  @override
  Widget build(BuildContext context) {
    if (currentUser == null) {
      return const Scaffold(body: Center(child: Text('No user found')));
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xffF1E9D2),
        elevation: 0,
        title: Row(
          children: [
            Text(widget.receiverName, style: TextStyle(fontSize: 16.sp, color: Colors.black)),
            const Spacer(),
            IconButton(
              icon: Icon(showTasks ? Icons.task_alt : Icons.task, size: 20.sp, color: Colors.blue),
              onPressed: () => setState(() => showTasks = !showTasks),
            )
          ],
        ),
      ),
        body: Column(
        children: [
          Expanded(
            child: Container(
              padding: EdgeInsets.all(2.w),
              color: Colors.white,
              child: StreamBuilder<QuerySnapshot>(
                stream: _firestore
                    .collection('chats')
                    .doc(chatId)
                    .collection('messages')
                    .orderBy('timestamp', descending: true)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  }
                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return Center(
                      child: Text(
                        'No messages yet',
                        style: TextStyle(fontSize: 16.sp, color: Colors.grey),
                      ),
                    );
                  }
                  if (snapshot.hasError) {
                    return Center(
                      child: Text(
                        'Error: ${snapshot.error}',
                        style: TextStyle(color: Colors.red),
                      ),
                    );
                  }

                  var messages = snapshot.data!.docs;

                  return ListView.builder(
                    reverse: true,
                    itemCount: messages.length,
                    itemBuilder: (context, index) {
                      var message = messages[index].data() as Map<String, dynamic>;
                      bool isMe = message['senderId'] == currentUser!.uid;
                      String timeAgo = _getTimeAgo(message['timestamp']);

                      return Padding(
                        padding: EdgeInsets.symmetric(vertical: 0.5.h),
                        child: Row(
                          mainAxisAlignment:
                              isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            if (!isMe) ...[
                              CircleAvatar(
                                radius: 3.w,
                                child: Text(
                                  message['senderName'][0].toUpperCase(),
                                  style: TextStyle(
                                      fontSize: 14.sp, color: Colors.white),
                                ),
                                backgroundColor: Colors.red,
                              ),
                              SizedBox(width: 1.w),
                            ],
                            Flexible(
                              child: Column(
                                crossAxisAlignment:
                                    isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    padding: EdgeInsets.all(2.w),
                                    decoration: BoxDecoration(
                                      color: isMe ? Colors.blue[100] : Colors.orange[200],
                                      borderRadius: BorderRadius.circular(10.sp),
                                    ),
                                    child: message.containsKey('imageUrl')
                                        ? Image.network(
                                            message['imageUrl'],
                                            width: 40.w,
                                            height: 40.w,
                                            fit: BoxFit.cover,
                                          )
                                        : Text(
                                            message['message'] ?? '',
                                            style: TextStyle(
                                                fontSize: 16.sp, color: Colors.black),
                                          ),
                                  ),
                                  SizedBox(height: 0.5.h),
                                  Text(
                                    timeAgo,
                                    style: TextStyle(fontSize: 14.sp, color: Colors.grey),
                                  ),
                                ],
                              ),
                            ),
                            if (isMe) ...[
                              SizedBox(width: 1.w),
                              CircleAvatar(
                                radius: 3.w,
                                child: Text(
                                  (currentUser!.displayName?.isNotEmpty ?? false)
                                      ? currentUser!.displayName![0].toUpperCase()
                                      : 'M',
                                  style: TextStyle(
                                      fontSize: 14.sp, color: Colors.white),
                                ),
                                backgroundColor: Colors.green,
                              ),
                            ],
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(2.w),
            child: Row(
              children: [
                IconButton(
                  icon: Icon(Icons.image, color: Colors.blue, size: 20.sp),
                  onPressed: _pickAndSendImage,
                ),
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(20.sp),
                    ),
                    child: TextField(
                      controller: _messageController,
                      decoration: InputDecoration(
                        hintText: 'Type a message...',
                        border: InputBorder.none,
                        contentPadding:
                            EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 2.w),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.blue,
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    icon: Icon(Icons.send, color: Colors.white, size: 20.sp),
                    onPressed: _sendMessage,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  String _getTimeAgo(dynamic timestamp) {
    if (timestamp == null) return '';
    DateTime dateTime = (timestamp as Timestamp).toDate();
    Duration difference = DateTime.now().difference(dateTime);
    if (difference.inMinutes < 1) return 'just now';
    if (difference.inMinutes < 60) return '${difference.inMinutes}m';
    if (difference.inHours < 24) return '${difference.inHours}h';
    return '${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}