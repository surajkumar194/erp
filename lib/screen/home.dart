import 'package:flutter/material.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  @override
  Widget build(BuildContext context) {
    
    return Scaffold(
      // appBar: AppBar(
      //   backgroundColor: Color(0xffF1E9D2),
      //   title: Text(
      //     "Home",
      //     style: TextStyle(fontSize: 21.sp, fontWeight: FontWeight.w500),
      //   ),
      //   centerTitle: true,
      // ), 
      //  drawer: Drawer(
      //   child: ListView(
      //     padding: EdgeInsets.zero,
      //     children: [
      //       DrawerHeader(
      //         decoration: BoxDecoration(
      //           color: Colors.blue.shade300,
      //         ),
      //         child: Column(
      //           crossAxisAlignment: CrossAxisAlignment.start,
      //           mainAxisAlignment: MainAxisAlignment.center,
      //           children: [
      //              CircleAvatar(
      //               radius: 4.h,
      //               backgroundImage: AssetImage("assets/cat.jpg"), // Add your profile image
      //             ),
      //             SizedBox(height: 1.h),
      //             Text(
      //               "User Name",
      //               style: TextStyle(fontSize: 17.sp, fontWeight: FontWeight.bold, color: Colors.white),
      //             ),
      //             Text(
      //               "user@example.com",
      //               style: TextStyle(fontSize: 17.sp, color: Colors.white70),
      //             ),
      //           ],
      //         ),
      //       ),
      //       ListTile(
      //         leading:  Icon(Icons.home,size: 22.sp,),
      //         title:  Text('Home',style: TextStyle(fontSize: 18.sp),),
      //         onTap: () {
      //           Navigator.pop(context); // Close drawer
      //         },
      //       ),
      //       ListTile(
      //         leading:  Icon(Icons.person,size: 22.sp,),
      //         title:  Text('Profile',style: TextStyle(fontSize: 18.sp),),
      //         onTap: () {
      //           // Handle navigation to Profile page
      //         },
      //       ),
      //       // ListTile(
      //       //   leading:  Icon(Icons.settings,size: 22.sp,),
      //       //   title: Text('Settings',style: TextStyle(fontSize: 18.sp),),
      //       //   onTap: () {
      //       //     // Handle navigation to Settings
      //       //   },
      //       // ),
      //       ListTile(
      //         leading: Icon(Icons.logout,size: 22.sp,),
      //         title:  Text('Logout',style: TextStyle(fontSize: 18.sp),),
      //         onTap: () {
      //           // Handle logout functionality
      //         },
      //       ),
      //     ],
      //   ),
      // ),
      body: Container(),
    );
  }
}
