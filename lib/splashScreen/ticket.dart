import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:erp/chatservice.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sizer/sizer.dart';

class TicketSelectionScreen extends StatefulWidget {
  final String managerId;
  final String managerName;

  const TicketSelectionScreen({
    super.key,
    required this.managerId,
    required this.managerName,
  });

  @override
  _TicketSelectionScreenState createState() => _TicketSelectionScreenState();
}

class _TicketSelectionScreenState extends State<TicketSelectionScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool isLoading = true;
  List<Map<String, dynamic>> tasks = [];

  @override
  void initState() {
    super.initState();
    _fetchTasks();
  }

  Future<void> _fetchTasks() async {
    setState(() {
      isLoading = true;
    });
    try {
      String employeeId = _auth.currentUser!.uid;
      QuerySnapshot snapshot = await _firestore
          .collection('tasks')
          .where('employeeId', isEqualTo: employeeId)
          .get();

      setState(() {
        tasks = snapshot.docs
            .map((doc) =>
                {...doc.data() as Map<String, dynamic>, 'taskId': doc.id})
            .toList();
        isLoading = false;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching tasks: $e')),
      );
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Select Ticket - ${widget.managerName}'),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : tasks.isEmpty
              ? Center(
                  child: Text(
                    'No tasks assigned',
                    style: TextStyle(fontSize: 18.sp, color: Colors.grey),
                  ),
                )
              : ListView.builder(
                  padding: EdgeInsets.all(4.w),
                  itemCount: tasks.length,
                  itemBuilder: (context, index) {
                    final task = tasks[index];
                    String formattedTimestamp = task['timestamp'] != null
                        ? DateFormat('dd MMM yyyy  |  hh:mm a').format(
                            (task['timestamp'] as Timestamp).toDate().toLocal())
                        : 'N/A';

                    return Card(
                      elevation: 3,
                      margin: EdgeInsets.only(bottom: 2.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: ListTile(
                        title: Text(
                          'Ticket: ${task['ticketId'] ?? 'N/A'}',
                          style: TextStyle(
                            fontSize: 18.sp,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue,
                          ),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Task: ${task['taskDetails'] ?? 'N/A'}',
                              style: TextStyle(fontSize: 16.sp),
                            ),
                            Text(
                              'Client: ${task['client'] ?? 'N/A'}',
                              style: TextStyle(
                                  fontSize: 14.sp, color: Colors.green),
                            ),
                            Text(
                              'Priority: ${task['priority'] ?? 'N/A'}',
                              style:
                                  TextStyle(fontSize: 14.sp, color: Colors.red),
                            ),
                          ],
                        ),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ChatConversationScreen(
                                receiverId: widget.managerId,
                                receiverName: widget.managerName,
                                isManager: false,
                                ticketId: task['ticketId'],
                               taskData: task, // 👈 Pass task data
                                // ticketId: task['ticketId'],
                                // taskId: task['taskId'],
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
    );
  }
}
