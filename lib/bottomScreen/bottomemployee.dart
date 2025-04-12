import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:erp/screen/EmployeeChatScreen.dart';
import 'package:erp/screen/Profile.dart';
import 'package:erp/screen/targets.dart';
import 'package:erp/screen/work.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

class BottomNavigationBarWidget extends StatefulWidget {
  const BottomNavigationBarWidget({super.key});

  @override
  _BottomNavigationBarWidgetState createState() =>
      _BottomNavigationBarWidgetState();
}

class _BottomNavigationBarWidgetState extends State<BottomNavigationBarWidget> {
  int _currentIndex = 0;

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String _name = "";
  String _email = "";
  bool _isLoading = false;

  List<Widget> get _pages => [
        const EmployeeProfile(),
        TaskScreen(),
          const EmployeeChatScreen(), // Updated to EmployeeChatScreen
        const Profile(),
      
      ];

  List<String> get _titles => [
        "My Work",
        "Targets",
               "Chating",
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
      Navigator.pop(context);
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
            await _firestore.collection("users").doc(user.uid).get();

        if (userDoc.exists) {
          Map<String, dynamic> userData =
              userDoc.data() as Map<String, dynamic>;

          setState(() {
            _name = userData["name"] ?? "";
            _email = userData["email"] ?? "";
          });
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("User data not found")),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("No user logged in")),
        );
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

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Logout", style: TextStyle(fontWeight: FontWeight.bold)),
          content: const Text("Are you sure you want to log out?"),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text("Cancel", style: TextStyle(color: Colors.grey)),
            ),
            TextButton(
              onPressed: () async {
                Navigator.pop(context);
                await FirebaseAuth.instance.signOut();
                // Optionally navigate to login screen
                // Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => EmpoyeeLoginScreen()));
              },
              child: const Text(
                "Logout",
                style: TextStyle(
                    color: Colors.redAccent, fontWeight: FontWeight.bold),
              ),
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
        backgroundColor: const Color(0xffF1E9D2),
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
              decoration: const BoxDecoration(color: Color(0xffF1E9D2)),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircleAvatar(
                    radius: 4.h,
                    backgroundImage: const AssetImage("assets/de.jpg"),
                  ),
                  SizedBox(height: 1.h),
                  Text(
                    _name.isNotEmpty ? _name : "Loading...",
                    style: TextStyle(
                        fontSize: 17.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue),
                  ),
                  Text(
                    _email.isNotEmpty ? _email : "",
                    style: TextStyle(fontSize: 17.sp, color: Colors.blue),
                  ),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.work),
              title: const Text('My Work'),
              onTap: () => _onDrawerItemSelected(0),
            ),
            ListTile(
              leading: const Icon(Icons.business),
              title: const Text('Targets'),
              onTap: () => _onDrawerItemSelected(1),
            ),
               ListTile(
              leading: const Icon(Icons.chat),
              title: const Text('Manager message'),
              onTap: () => _onDrawerItemSelected(2),
            ),
            ListTile(
              leading: const Icon(Icons.person),
              title: const Text('Profile'),
              onTap: () => _onDrawerItemSelected(3),
            ),
         
            const Divider(),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text('Logout', style: TextStyle(color: Colors.red)),
              onTap: _showLogoutDialog,
            ),
          ],
        ),
      ),
      body: _auth.currentUser == null
          ? const Center(child: Text("Please log in"))
          : _pages[_currentIndex],
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
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.work, size: 21),
            label: 'My Work',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.business, size: 21),
            label: 'Targets',
          ),
           BottomNavigationBarItem(
            icon: Icon(Icons.chat, size: 21),
            label: 'Chating',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person, size: 21),
            label: 'Profile',
          ),
         
        ],
      ),
    );
  }
}