import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:erp/profile/EditProfileScreen.dart';
import 'package:erp/profile/attendance.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
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
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadProfileImage();
  }

  // Load the profile image from Firestore
  Future<void> _loadProfileImage() async {
  User? user = _auth.currentUser;
  if (user != null) {
    DocumentSnapshot userDoc = await _firestore.collection('users').doc(user.uid).get();

    // Check if the 'imageUrl' field exists in the document
    if (userDoc.exists && userDoc.data() != null) {
      var data = userDoc.data() as Map<String, dynamic>;

      // If 'imageUrl' exists, use it, otherwise use a default image
      String imageUrl = data['imageUrl'] ?? '';
      setState(() {
        _image = imageUrl.isNotEmpty ? File(imageUrl) : null; // Default image or null
      });
    } else {
      // Handle the case where the document does not exist or doesn't have the 'imageUrl' field
      setState(() {
        _image = null; // No image available, or use a default one
      });
    }
  }
}

  // Show bottom sheet to choose image source (Camera or Gallery)
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
                  style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold)),
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

  // Pick an image from the camera or gallery
  Future<void> _pickImage(ImageSource source) async {
    final pickedFile = await picker.pickImage(source: source);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
      _uploadImageToFirebase(pickedFile);
    }
  }

  // Upload the image to Firebase Storage and update Firestore
  Future<void> _uploadImageToFirebase(XFile pickedFile) async {
    setState(() {
      _isLoading = true;
    });

    try {
      User? user = _auth.currentUser;
      if (user != null) {
        // Upload the image to Firebase Storage
        String fileName = DateTime.now().millisecondsSinceEpoch.toString();
        Reference storageRef = FirebaseStorage.instance.ref().child('profile_images/$fileName');
        await storageRef.putFile(File(pickedFile.path));

        // Get the URL of the uploaded image
        String imageUrl = await storageRef.getDownloadURL();

        // Update Firestore with the new image URL
        await _firestore.collection('users').doc(user.uid).update({
          'imageUrl': imageUrl,
          
        });

        setState(() {
          _image = File(pickedFile.path); // Update the image locally
        });

        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text("Profile image updated successfully!"),
          backgroundColor: Colors.green,
        ));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Failed to upload image: $e"),
        backgroundColor: Colors.red,
      ));
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Handle account deletion (for demonstration)
  void _showDeleteAccountDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Delete Account"),
        content: Text("Are you sure you want to delete your account?"),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              // Delete account logic here
            },
            child: Text("Delete"),
          ),
        ],
      ),
    );
  }

  // Handle logout (for demonstration)
  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Log Out"),
        content: Text("Are you sure you want to log out?"),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text("Cancel"),
          ),
          TextButton(
            onPressed: () async {
              await _auth.signOut();
              Navigator.pop(context);
            },
            child: Text("Log Out"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          Padding(
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
            _image = updatedImage;  // Update the profile image with the selected one
          });
        }
      },
    ),
  ),
);
                }),
                _buildProfileOption(Icons.assignment_turned_in_sharp, "Attendance", () {
                   Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const AttendanceScreen()),
                    );
                }),
                _buildProfileOption(Icons.delete_forever, "Delete Account", _showDeleteAccountDialog),
                _buildProfileOption(Icons.logout, "Log Out", _showLogoutDialog, true),
              ],
            ),
          ),
          if (_isLoading)
            Container(
              color: Colors.black.withOpacity(0.5),
              child: Center(child: CircularProgressIndicator()),
            ),
        ],
      ),
    );
  }

  // Helper widget to build profile options
  Widget _buildProfileOption(IconData icon, String title, VoidCallback? onTap, [bool isLogout = false]) {
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
