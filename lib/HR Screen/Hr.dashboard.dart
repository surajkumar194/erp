import 'package:erp/HR%20Screen/chating.dart';
import 'package:erp/HR%20Screen/employeeAll.dart';
import 'package:erp/HR%20Screen/hrprofile.dart';
import 'package:erp/HR%20Screen/leave.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

class HRDashboardScreen extends StatelessWidget {
  const HRDashboardScreen({super.key});

  // Function to show the Circular Progress Indicator (loading dialog)
  void showLoadingDialog(BuildContext context) {
    showDialog(
      barrierDismissible: false, // Disable dismissing dialog by tapping outside
      context: context,
      builder: (context) => Center(
        child: CircularProgressIndicator(),
      ),
    );
  }

//  void _showLogoutDialog(BuildContext context) {
//   showDialog(
//     context: context,
//     builder: (BuildContext context) {
//       return AlertDialog(
//         title: Text("Logout", style: TextStyle(fontWeight: FontWeight.bold)),
//         content: Text("Are you sure you want to log out?"),
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
//         actions: [
//           TextButton(
//             onPressed: () {
//               Navigator.pop(context);
//             },
//             child: Text("Cancel", style: TextStyle(color: Colors.grey)),
//           ),
//           TextButton(
//             onPressed: () async {
//               await FirebaseAuth.instance.signOut();
//               Navigator.pop(context); // Close dialog
//               Navigator.pushAndRemoveUntil(
//                 context,
//                 MaterialPageRoute(builder: (context) => HRLoginScreen()),
//                 (route) => false,
//               );
//             },
//             child: Text(
//               "Logout",
//               style:
//                   TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),
//             ),
//           ),
//         ],
//       );
//     },
//   );
// }

  void _showEmployeeData(BuildContext context) async {
    showLoadingDialog(context);
    await Future.delayed(Duration(milliseconds: 500)); // Simulate loading delay
    Navigator.pop(context); // Close the loading dialog
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => EmployeeDataScreen()),
    );
  }

  void _showLeaveRequests(BuildContext context) async {
    showLoadingDialog(context);
    await Future.delayed(Duration(milliseconds: 500)); // Simulate loading delay
    Navigator.pop(context); // Close the loading dialog
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => LeaveRequestsScreen()),
    );
  }

  void _showProfile(BuildContext context) async {
    showLoadingDialog(context);
    await Future.delayed(Duration(milliseconds: 500)); // Simulate loading delay
    Navigator.pop(context); // Close the loading dialog
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => HRProfileScreen()),
    );
  }

  void _startChat(BuildContext context) async {
    showLoadingDialog(context);
    await Future.delayed(Duration(milliseconds: 500)); // Simulate loading delay
    Navigator.pop(context); // Close the loading dialog
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ChatScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("HR Dashboard",
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            )),
        centerTitle: true,
        backgroundColor: const Color(0xff013148),
      ),
      body: Padding(
        padding: EdgeInsets.all(10.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Center(
                child: Text("Welcome HR!",
                    style: TextStyle(
                        fontSize: 20.sp, fontWeight: FontWeight.bold))),
            SizedBox(height: 2.h),

            // Button to show all employee data
            ElevatedButton(
              onPressed: () => _showEmployeeData(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xff013148), // Button color
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                minimumSize:
                    Size(80.w, 8.h), // Button size: Same width and height
              ),
              child: Text("View All Employee Data",
                  style: TextStyle(fontSize: 16.sp, color: Colors.white)),
            ),
            SizedBox(height: 2.h),

            // Button to show leave requests
            ElevatedButton(
              onPressed: () => _showLeaveRequests(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xff013148), // Button color
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                minimumSize: Size(80.w, 8.h), // Same width and height
              ),
              child: Text("View Leave Requests",
                  style: TextStyle(fontSize: 16.sp, color: Colors.white)),
            ),
            SizedBox(height: 2.h),

            // HR Profile Button (Icon Button)

            // Chat Button (Icon + Text)
            ElevatedButton(
              onPressed: () => _startChat(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xff013148), // Button color
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                minimumSize: Size(80.w, 8.h), // Same width and height
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.chat, size: 22.sp, color: Colors.white),
                  SizedBox(width: 2.w), // Space between the icon and the text
                  Text("Chat",
                      style: TextStyle(fontSize: 16.sp, color: Colors.white)),
                ],
              ),
            ),
            SizedBox(height: 2.h),
            ElevatedButton(
              onPressed: () => _showProfile(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xff013148), // Button color
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                minimumSize: Size(80.w, 8.h), // Same width and height
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.person,
                      size: 22.sp, color: Colors.white), // Profile icon
                  SizedBox(width: 2.w), // Space between the icon and the text
                  Text("Profile",
                      style: TextStyle(
                          fontSize: 16.sp, color: Colors.white)), // Text
                ],
              ),
            ),

            // Logout Button
//_buildProfileOption(Icons.logout, "Log Out", () => _showLogoutDialog(context), true),
          ],
        ),
      ),
    );
  }

//  Widget _buildProfileOption(IconData icon, String title, VoidCallback? onTap,
//       [bool isLogout = false]) {
//     return Padding(
//       padding: EdgeInsets.symmetric(vertical: 1.h),
//       child: ListTile(
//         leading: Icon(icon,
//             color: isLogout ? Colors.red : Colors.black, size: 20.sp),
//         title: Text(
//           title,
//           style: TextStyle(
//               fontSize: 18.sp,
//               fontWeight: FontWeight.w500,
//               color: isLogout ? Colors.red : Colors.black),
//         ),
//         trailing: Icon(Icons.arrow_forward_ios, size: 18.sp),
//         onTap: onTap,
//       ),
//     );
//   }
}
