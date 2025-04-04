import 'package:erp/mamagerscreen/home.dart';
import 'package:erp/mamagerscreen/profile.dart';
import 'package:erp/screen/targets.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

class bottommanager extends StatefulWidget {
  const bottommanager({super.key});

  @override
  _bottommanagerState createState() => _bottommanagerState();
}

class _bottommanagerState extends State<bottommanager> {
  int _currentIndex = 0;

  List<Widget> get _pages => [
        MAnagerHome(),
        TaskScreen(),
        managerprofile(),
      ];

  List<String> get _titles => [
        "Home",
        "Tasks",
        "Profile",
      ];

  void _onDrawerItemSelected(int index) {
    setState(() {
      _currentIndex = index;
      Navigator.pop(context); // Close the drawer
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xffF1E9D2),
        elevation: 0,
        title: Text(
          _titles[_currentIndex],
          style: TextStyle(
              fontSize: 20.sp,
              fontWeight: FontWeight.w600,
              color: Colors.black),
        ),
        centerTitle: true,
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(color: Color(0xffF1E9D2)),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircleAvatar(
                    radius: 4.h,
                    backgroundImage: AssetImage("assets/de.jpg"),
                  ),
                  SizedBox(height: 1.h),
                  Text(
                    "User Name",
                    style: TextStyle(
                        fontSize: 17.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
                  ),
                  Text(
                    "user@example.com",
                    style: TextStyle(fontSize: 17.sp, color: Colors.white70),
                  ),
                ],
              ),
            ),
            ListTile(
              leading: Icon(Icons.home),
              title: Text('Home'),
              onTap: () => _onDrawerItemSelected(0),
            ),
            ListTile(
              leading: Icon(Icons.business),
              title: Text('Tasks'),
              onTap: () => _onDrawerItemSelected(1),
            ),
            ListTile(
              leading: Icon(Icons.person),
              title: Text('Profile'),
              onTap: () => _onDrawerItemSelected(2),
            ),
            Divider(),
            ListTile(
              leading: Icon(Icons.logout, color: Colors.red),
              title: Text('Logout', style: TextStyle(color: Colors.red)),
              onTap: _showLogoutDialog,
            ),
          ],
        ),
      ),
      body: _pages[_currentIndex], // Display selected screen
      bottomNavigationBar: BottomNavigationBar(
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        currentIndex: _currentIndex,
        backgroundColor: const Color(0xffffffff),
        unselectedItemColor: const Color(0xff777777),
        selectedItemColor: const Color(0xff120A8F),
        selectedLabelStyle: TextStyle(fontSize: 17.sp),
        unselectedLabelStyle: TextStyle(fontSize: 17.sp),
        type: BottomNavigationBarType.fixed,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home, size: 21.sp),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.business, size: 21.sp),
            label: 'Tasks',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person, size: 21.sp),
            label: 'Profile',
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Logout", style: TextStyle(fontWeight: FontWeight.bold)),
          content: Text("Are you sure you want to log out?"),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close the dialog
              },
              child: Text("Cancel", style: TextStyle(color: Colors.grey)),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close the dialog first
                // Perform logout action (e.g., navigate to login screen or clear session)
              },
              child: Text("Logout",
                  style: TextStyle(
                      color: Colors.redAccent, fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }
}
