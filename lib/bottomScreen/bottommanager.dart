import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:erp/mamagerscreen/ManagerChatScreen.dart';
import 'package:erp/mamagerscreen/home.dart';
import 'package:erp/mamagerscreen/performance.dart';
import 'package:erp/mamagerscreen/profile.dart';
import 'package:erp/mamagerscreen/tasks.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

class bottommanager extends StatefulWidget {
  const bottommanager({super.key});

  @override
  _bottommanagerState createState() => _bottommanagerState();
}

class _bottommanagerState extends State<bottommanager> {
  int _currentIndex = 0;

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String _name = "";
  String _email = "";
  bool _isLoading = false;

  List<Widget> get _pages => [
       ManagerHome(),
        Tasks(),
        Performance(),
          ManagerChatScreen(),
        managerprofile(),
       // Updated to ManagerChatScreen
      ];

  List<String> get _titles => [
        "Home",
        "Tasks",
        "Performance",
          "Chat with Employees", // Updated title
        "Profile",
      
      ];

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  void _onDrawerItemSelected(int index) {
    setState(() {
      _currentIndex = index;
      Navigator.pop(context); // Close the drawer
    });
  }

  Future<void> _fetchUserData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      User? user = _auth.currentUser;
      if (user != null) {
        DocumentSnapshot userDoc =
            await _firestore.collection("Manager").doc(user.uid).get();

        if (userDoc.exists) {
          Map<String, dynamic> userData =
              userDoc.data() as Map<String, dynamic>;

          setState(() {
            _name = userData["name"] ?? "";
            _email = userData["email"] ?? "";
          });
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("User data not found")),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("No user logged in")),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error fetching user data: $e")),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _logout() async {
    await FirebaseAuth.instance.signOut();
    // Navigate to login screen
    // Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => ManagerLoginScreen()));
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Logout", style: TextStyle(fontWeight: FontWeight.bold)),
          content: Text("Are you sure you want to log out?"),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text("Cancel", style: TextStyle(color: Colors.grey)),
            ),
            TextButton(
              onPressed: () async {
                Navigator.pop(context);
                await _logout();
              },
              child: Text("Logout", style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
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
            color: Colors.black,
          ),
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
                    _name.isNotEmpty ? _name : "Loading...",
                    style: TextStyle(
                      fontSize: 17.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                  ),
                  Text(
                    _email.isNotEmpty ? _email : "",
                    style: TextStyle(fontSize: 17.sp, color: Colors.blue),
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
              leading: Icon(Icons.task),
              title: Text('Tasks'),
              onTap: () => _onDrawerItemSelected(1),
            ),
            ListTile(
              leading: Icon(Icons.data_thresholding),
              title: Text('Performance'),
              onTap: () => _onDrawerItemSelected(2),
            ),
                ListTile(
              leading: Icon(Icons.chat),
              title: Text('Chating'),
              onTap: () => _onDrawerItemSelected(3),
            ),
            ListTile(
              leading: Icon(Icons.person),
              title: Text('Profile'),
              onTap: () => _onDrawerItemSelected(4),
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
      body: _pages[_currentIndex],
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
            icon: Icon(Icons.task, size: 21.sp),
            label: 'Tasks',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.data_thresholding, size: 21.sp),
            label: 'Performance',
          ),
           BottomNavigationBarItem(
            icon: Icon(Icons.chat, size: 21.sp),
            label: 'Chating',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person, size: 21.sp),
            label: 'Profile',
          ),
         
        ],
      ),
    );
  }
}