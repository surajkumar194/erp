import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class EmployeeLeaveScreen extends StatefulWidget {
  const EmployeeLeaveScreen({super.key});

  @override
  State<EmployeeLeaveScreen> createState() => _EmployeeLeaveScreenState();
}

class _EmployeeLeaveScreenState extends State<EmployeeLeaveScreen> {
  final TextEditingController _reasonController = TextEditingController();
  bool _isSubmitting = false;

  Future<void> _submitLeaveRequest() async {
    if (_reasonController.text.isEmpty) return;

    setState(() => _isSubmitting = true);
    final user = FirebaseAuth.instance.currentUser;

    await FirebaseFirestore.instance.collection('leaveRequests').add({
      'employeeId': user!.uid,
      'employeeName': user.displayName ?? "Unknown",
      'reason': _reasonController.text.trim(),
      'status': 'Pending',
      'timestamp': FieldValue.serverTimestamp(),
    });

    setState(() {
      _isSubmitting = false;
      _reasonController.clear();
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Leave request submitted")),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Request Leave")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _reasonController,
              maxLines: 4,
              decoration: const InputDecoration(
                labelText: "Reason for leave",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            _isSubmitting
                ? const CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: _submitLeaveRequest,
                    child: const Text("Submit Leave Request"),
                  ),
          ],
        ),
      ),
    );
  }
}
