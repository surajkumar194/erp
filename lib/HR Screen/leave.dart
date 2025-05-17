import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class LeaveRequestsScreen extends StatelessWidget {
  const LeaveRequestsScreen({super.key});

  void _updateStatus(String docId, String newStatus, BuildContext context) {
    FirebaseFirestore.instance
        .collection('leaveRequests')
        .doc(docId)
        .update({
          'status': newStatus,
          'decisionTimestamp': FieldValue.serverTimestamp(),
        })
        .then((_) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Leave marked as $newStatus")),
      );
    }).catchError((error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $error")),
      );
    });
  }

  void _confirmStatusChange(String docId, String newStatus, BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Confirm $newStatus"),
        content: Text("Are you sure you want to mark this leave as $newStatus?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context); // close dialog
              _updateStatus(docId, newStatus, context);
            },
            child: Text(newStatus),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Leave Requests")),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('leaveRequests')
            .orderBy('timestamp', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final docs = snapshot.data?.docs ?? [];

          if (docs.isEmpty) {
            return const Center(child: Text("No leave requests found"));
          }

          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final data = docs[index].data() as Map<String, dynamic>;
              final docId = docs[index].id;

              return Card(
                margin: const EdgeInsets.all(8),
                child: ListTile(
                  title: Text(data['employeeName'] ?? 'Unknown'),
                  subtitle: Text(
                    "Reason: ${data['reason']}\nStatus: ${data['status']}",
                  ),
                  trailing: data['status'] == 'Pending'
                      ? Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.check, color: Colors.green),
                              onPressed: () => _confirmStatusChange(docId, "Approved", context),
                            ),
                            IconButton(
                              icon: const Icon(Icons.close, color: Colors.red),
                              onPressed: () => _confirmStatusChange(docId, "Rejected", context),
                            ),
                          ],
                        )
                      : Text(
                          data['status'],
                          style: TextStyle(
                            color: data['status'] == 'Approved'
                                ? Colors.green
                                : Colors.red,
                            fontWeight: FontWeight.bold,
                          ),
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
