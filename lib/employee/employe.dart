// import 'package:erp/bottomScreen/bottom.dart';
// import 'package:flutter/material.dart';
// import 'package:sizer/sizer.dart';
// import 'package:url_launcher/url_launcher.dart';

// class EmployeeTaskPage extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//           appBar: AppBar(
//         backgroundColor: Color(0xffF1E9D2),
//         leading: IconButton(
//           icon: Icon(Icons.arrow_back, size: 22.0.sp, color: Colors.black),
//           onPressed: () {
//   Navigator.pushReplacement(
//           context, MaterialPageRoute(builder: (_) => BottomNavigationBarWidget()));
//           },
//         ),
//         title: Text(
//           'Employee Tasks',
//           style: TextStyle(
//             fontSize: 20.0.sp,
//             fontWeight: FontWeight.w600,
//             color: Colors.black,
//           ),
//         ),
//         centerTitle: true,
//       ),
//       body: ListView(
//         padding: EdgeInsets.all(16.0),
//         children: [
//           TaskCard(
//             clientName: 'ABC Corp',
//             typeOfWork: 'App Development',
//             status: 'In Progress',
//             priority: 'Urgent',
//             detailsUrl: 'https://example.com/task1',
//           ),
//           TaskCard(
//             clientName: 'XYZ Ltd',
//             typeOfWork: 'Website Design',
//             status: 'Pending',
//             priority: 'High',
//             detailsUrl: 'https://example.com/task2',
//           ),
//         ],
//       ),
//     );
//   }
// }

// class TaskCard extends StatelessWidget {
//   final String clientName;
//   final String typeOfWork;
//   final String status;
//   final String priority;
//   final String detailsUrl;

//   TaskCard({
//     required this.clientName,
//     required this.typeOfWork,
//     required this.status,
//     required this.priority,
//     required this.detailsUrl,
//   });

//   void _launchURL(String url) async {
//     if (await canLaunch(url)) {
//       await launch(url);
//     } else {
//       throw 'Could not launch $url';
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Card(
//       margin: EdgeInsets.symmetric(vertical: 8.0),
//       child: Padding(
//         padding: EdgeInsets.all(16.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             RichText(
//               text: TextSpan(
//                 style: TextStyle(fontSize: 17.0),
//                 children: [
//                   TextSpan(
//                     text: 'Client : ',
//                     style: TextStyle(
//                       fontWeight: FontWeight.bold,
//                       color: Colors.black,
//                       fontSize: 18.sp,
//                     ),
//                   ),
//                   TextSpan(
//                     text: clientName,
//                     style: TextStyle(
//                         fontWeight: FontWeight.normal,
//                         color: Colors.blue,
//                         fontSize: 16.sp),
//                   ),
//                 ],
//               ),
//             ),
//             SizedBox(height: 5),
//             RichText(
//               text: TextSpan(
//                 style: TextStyle(fontSize: 16.0, color: Colors.black),
//                 children: [
//                   TextSpan(
//                       text: 'Type of Work : ',
//                       style: TextStyle(
//                         fontWeight: FontWeight.bold,
//                         fontSize: 18.sp,
//                       )),
//                   TextSpan(
//                       text: typeOfWork,
//                       style: TextStyle(color: Colors.green, fontSize: 16.sp)),
//                 ],
//               ),
//             ),
//             SizedBox(height: 5),
//             RichText(
//               text: TextSpan(
//                 style: TextStyle(fontSize: 16.0, color: Colors.black),
//                 children: [
//                   TextSpan(
//                       text: 'Status : ',
//                       style: TextStyle(
//                         fontWeight: FontWeight.bold,
//                         fontSize: 18.sp,
//                       )),
//                   TextSpan(
//                       text: status,
//                       style: TextStyle(color: Colors.blue, fontSize: 16.sp)),
//                 ],
//               ),
//             ),
//             SizedBox(height: 5),
//             RichText(
//               text: TextSpan(
//                 style: TextStyle(fontSize: 16.0, color: Colors.black),
//                 children: [
//                   TextSpan(
//                       text: 'Priority : ',
//                       style: TextStyle(
//                         fontWeight: FontWeight.bold,
//                         fontSize: 18.sp,
//                       )),
//                   TextSpan(
//                       text: priority,
//                       style: TextStyle(
//                           color: Colors.red,
//                           fontWeight: FontWeight.bold,
//                           fontSize: 16.sp)),
//                 ],
//               ),
//             ),
//             SizedBox(height: 10),
//             GestureDetector(
//               onTap: () => _launchURL(detailsUrl),
//               child: RichText(
//                 text: TextSpan(
//                   style: TextStyle(color: Colors.black),
//                   children: [
//                     TextSpan(
//                       text: 'Task Details : ',
//                       style: TextStyle(
//                           color: Colors.black,
//                           fontSize: 18.sp,
//                           fontWeight: FontWeight.bold),
//                     ),
//                     TextSpan(
//                       text: detailsUrl,
//                       style: TextStyle(
//                           color: Colors.blue,
//                           decoration: TextDecoration.underline,
//                           fontSize: 16.sp),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }




import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
class EmployeeProfile extends StatelessWidget {
  final Map<String, dynamic> data;

  const EmployeeProfile({Key? key, required this.data}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Employee Profile"),
        centerTitle: true,
        backgroundColor: Colors.blueAccent,
      ),
      body: Padding(
        padding: EdgeInsets.all(4.w),
        child: Card(
          elevation: 3,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          child: Padding(
            padding: EdgeInsets.all(4.w),
            child: ListView(
              shrinkWrap: true,
              children: [
                // Employee Name
                _buildInfoRow("Assigned Employee", data['employee'], Colors.black, isTitle: true),

                SizedBox(height: 1.h),
                Divider(),

                // Work Type & Task Details
                _buildInfoRow("Work Type", data['workType'], Colors.blue),
                _buildInfoRow("Task Details", data['taskDetails'], Colors.black87),

                SizedBox(height: 1.h),
                Divider(),

                // Client & Priority
                _buildInfoRow("Client", data['client'], Colors.green),
                _buildInfoRow("Priority", data['priority'], Colors.red, isBold: true),

                SizedBox(height: 1.h),
                Divider(),

                // Status & Date
                _buildInfoRow("Status", data['status'], Colors.orange),
                _buildInfoRow("Date", data['date'], Colors.purple),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Function to create a reusable information row
  Widget _buildInfoRow(String label, String value, Color color, {bool isBold = false, bool isTitle = false}) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 0.8.h),
      child: RichText(
        text: TextSpan(
          style: TextStyle(fontSize: 14.sp, color: Colors.black),
          children: [
            TextSpan(
              text: "$label: ",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: isTitle ? 16.sp : 14.sp,
              ),
            ),
            TextSpan(
              text: value,
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
