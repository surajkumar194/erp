import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:erp/HR%20Screen/edithr.dart';
import 'package:erp/aftersplash/login.dart'; // Adjust import based on your login screen
import 'package:erp/profile/attendance.dart'; // Assuming you have an AttendanceScreen
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sizer/sizer.dart';

class HRProfileScreen extends StatefulWidget {
  const HRProfileScreen({super.key});

  @override
  State<HRProfileScreen> createState() => _HRProfileScreenState();
}

class _HRProfileScreenState extends State<HRProfileScreen> {
  File? _image;
  final picker = ImagePicker();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadProfileImage();
  }

  Future<void> _loadProfileImage() async {
    // Add logic to load profile image from Firebase Storage if implemented
    // For now, using local image as in managerprofile
  }

  void _showImagePicker() {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(15)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.all(3.h),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "Select Image Source",
                style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 2.h),
              ListTile(
                leading: Icon(Icons.camera, color: Colors.blue),
                title: Text("Camera"),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.camera);
                },
              ),
              ListTile(
                leading: Icon(Icons.photo_library, color: Colors.green),
                title: Text("Gallery"),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.gallery);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    final pickedFile = await picker.pickImage(source: source);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
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
                await FirebaseAuth.instance.signOut();
                Navigator.pop(context); // Close dialog
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => const Login()),
                  (route) => false,
                );
              },
              child: Text(
                "Logout",
                style: TextStyle(
                    color:Colors.blue, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showDeleteAccountDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Delete Account",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22.sp)),
          content: Text(
              "Are you sure you want to delete your account permanently? This action cannot be undone.",
              style: TextStyle(fontSize: 16.sp)),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Cancel",
                  style: TextStyle(color: Colors.blue, fontSize: 18.sp)),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _deleteAccount();
              },
              child: Text(
                "Delete",
                style: TextStyle(
                    color: Colors.redAccent,
                    fontWeight: FontWeight.bold,
                    fontSize: 18.sp),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _deleteAccount() async {
    setState(() {
      _isLoading = true;
    });

    try {
      User? user = _auth.currentUser;
      if (user != null) {
        try {
          // Delete Firestore data from HR collection
          await _firestore.collection("HR").doc(user.uid).delete();

          // Attempt to delete auth account
          await user.delete();

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Account deleted successfully"),
              backgroundColor: Colors.green,
            ),
          );

          setState(() {
            _image = null;
          });

          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (_) => const Login()),
            (Route<dynamic> route) => false,
          );
        } on FirebaseAuthException catch (e) {
          if (e.code == 'requires-recent-login') {
            await _auth.signOut();
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (_) => const Login()),
              (Route<dynamic> route) => false,
            );
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text("Please log in again to delete your account"),
                backgroundColor: Colors.orange,
              ),
            );
            return;
          }
          rethrow;
        }
      } else {
        throw Exception("No user logged in");
      }
    } on FirebaseAuthException catch (e) {
      String errorMessage = 'Error deleting account: ${e.message}';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage),
          backgroundColor: Colors.red,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Failed to delete account: ${e.toString()}"),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(),
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 3.h),
              child: Column(
                children: [
                  Stack(
                    children: [
                      Container(
                        width: 42.w,
                        height: 20.h,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          image: _image != null
                              ? DecorationImage(
                                  image: FileImage(_image!), fit: BoxFit.cover)
                              : DecorationImage(
                                  image: AssetImage("assets/de.jpg"),
                                  fit: BoxFit.fill),
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: GestureDetector(
                          onTap: _showImagePicker,
                          child: Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.red,
                              border: Border.all(color: Colors.white, width: 2),
                            ),
                            padding: EdgeInsets.all(6),
                            child: Icon(Icons.edit,
                                color: Colors.white, size: 18.sp),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    "HR Profile",
                    style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.w500),
                  ),
                  SizedBox(height: 2.h),
                  _buildProfileOption(Icons.person_outline, "My Account", () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>EditProfileHR(
                          onImageUpdated: (File? updatedImage) {
                            if (updatedImage != null) {
                              setState(() {
                                _image = updatedImage;
                              });
                            }
                          },
                        ),
                      ),
                    );
                  }),
               
                  _buildProfileOption(
                      Icons.assignment_turned_in_sharp, "Attendance", () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const AttendanceScreen(),
                      ),
                    );
                  }),
                  _buildProfileOption(
                      Icons.delete_forever, "Delete Account", _showDeleteAccountDialog),
                  _buildProfileOption(Icons.logout, "Log Out", _showLogoutDialog, true),
                ],
              ),
            ),
          ),
          if (_isLoading)
            Container(
              color: Colors.black.withOpacity(0.5),
              child: const Center(child: CircularProgressIndicator()),
            ),
        ],
      ),
    );
  }

  Widget _buildProfileOption(IconData icon, String title, VoidCallback? onTap,
      [bool isLogout = false]) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 1.h),
      child: ListTile(
        leading: Icon(icon,
            color: isLogout ? Colors.red : Colors.black, size: 20.sp),
        title: Text(
          title,
          style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.w500,
              color: isLogout ? Colors.red : Colors.black),
        ),
        trailing: Icon(Icons.arrow_forward_ios, size: 18.sp),
        onTap: onTap,
      ),
    );
  }
}
