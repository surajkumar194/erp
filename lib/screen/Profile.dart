import 'dart:io';

import 'package:erp/login/Login.dart';
import 'package:erp/profile/EditProfileScreen.dart';
import 'package:erp/profile/attendance.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sizer/sizer.dart';

class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  File? _image;
  final picker = ImagePicker();

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
              Text("Select Image Source",
                  style:
                      TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold)),
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
          title: Text("Logout",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22.sp)),
          content: Text("Are you sure you want to log out?",style: TextStyle(fontSize: 16.sp),),
          
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close the dialog
              },
              child: Text("Cancel",
                  style: TextStyle(color: Colors.blue, fontSize: 18.sp)),
            ),
            TextButton(
              onPressed: () {
                Navigator.push(
                    context, MaterialPageRoute(builder: (_) => LoginScreen()));
              },
              child: Text("Logout",
                  style: TextStyle(
                      color: Colors.redAccent,
                      fontWeight: FontWeight.bold,
                      fontSize: 18.sp)),
            ),
          ],
        );
      },
    );
  }

  void _showDeleteAccountDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Delete Account",
            style: TextStyle(fontSize: 22.sp, fontWeight: FontWeight.bold)),
        content: Text(
            "Are you sure you want to delete your account permanently?",
            style: TextStyle(fontSize: 16.sp)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              "Cancel",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18.sp),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text("Account Deleted Successfully")),
              );
            },
            child: Text("Delete",
                style: TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                    fontSize: 18.sp)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
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
                      child: Icon(Icons.edit, color: Colors.white, size: 18.sp),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 2.h),
            Text("Profile Page",
                style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.w500)),
            SizedBox(height: 2.h),
            _buildProfileOption(Icons.person_outline, "My Account", () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => EditProfileScreen(
                              onImageUpdated: (File? updatedImage) {
                            if (updatedImage != null) {
                              setState(() {
                                _image = updatedImage;
                              });
                            }
                          })));
            }),
            _buildProfileOption(Icons.assignment_turned_in_sharp, "Attendance",
                () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const AttendanceScreen()),
              );
            }),
            _buildProfileOption(Icons.delete_forever, "Delete Account",
                _showDeleteAccountDialog),
            _buildProfileOption(
                Icons.logout, "Log Out", _showLogoutDialog, true),
          ],
        ),
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
