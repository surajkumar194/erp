import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sizer/sizer.dart';

class EditProfileScreen extends StatefulWidget {
  final Function(File?) onImageUpdated;
  const EditProfileScreen({super.key, required this.onImageUpdated});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  File? _image;
  final picker = ImagePicker();
  final _formKey = GlobalKey<FormState>();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  bool _isLoading = false;
  String _selectedGender = "Male";
  String _selectedRole = "Employee";

  @override
  void initState() {
    super.initState();
    _fetchUserData();
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
            _nameController.text = userData["name"] ?? "";
            _emailController.text = userData["email"] ?? "";
            _phoneController.text = userData["phone"] ?? "";
            _selectedGender = userData["gender"] ?? "Male";
            _selectedRole = userData["role"] ?? "Employee";
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


  Future<void> _pickImage(ImageSource source) async {
    final pickedFile = await picker.pickImage(source: source);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
      widget.onImageUpdated(_image);
    }
  }

  Future<void> _saveProfile() async {
  if (_formKey.currentState!.validate()) {
    setState(() {
      _isLoading = true;
    });

    try {
      User? user = _auth.currentUser;
      if (user != null) {
        String? imageUrl;

        // Upload image if picked
        if (_image != null) {
          final storageRef = FirebaseStorage.instance
              .ref()
              .child('profile_images/${user.uid}.jpg');

          await storageRef.putFile(_image!);
          imageUrl = await storageRef.getDownloadURL();
        }

        await _firestore.collection("users").doc(user.uid).update({
          "name": _nameController.text.trim(),
          "email": user.email,
          "phone": _phoneController.text.trim(),
          "gender": _selectedGender,
          "role": _selectedRole,
          "updatedAt": FieldValue.serverTimestamp(),
          if (imageUrl != null) "imageUrl": imageUrl,
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Profile Updated Successfully")),
        );
        Navigator.pop(context);
      }
    } on FirebaseAuthException catch (e) {
      String errorMessage;
      switch (e.code) {
        case 'email-already-in-use':
          errorMessage = 'This email is already in use';
          break;
        case 'requires-recent-login':
          errorMessage = 'Please log in again to update email';
          break;
        default:
          errorMessage = 'Error updating profile: ${e.message}';
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMessage), backgroundColor: Colors.red),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error updating profile: $e"), backgroundColor: Colors.red),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xffF1E9D2),
        elevation: 0,
        title: Text("Edit Profile",
            style: TextStyle(
                color: Colors.black,
                fontSize: 18.sp,
                fontWeight: FontWeight.w600)),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Stack(
        children: [
          Padding(
            padding: EdgeInsets.all(5.w),
            child: Form(
              key: _formKey,
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    // Profile Picture
                    Stack(
                      children: [
                        Container(
                          width: 42.w,
                          height: 20.h,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            image: _image != null
                                ? DecorationImage(
                                    image: FileImage(_image!),
                                    fit: BoxFit.cover,
                                  )
                                : DecorationImage(
                                    image: AssetImage("assets/de.jpg"),
                                    fit: BoxFit.fill,
                                  ),
                          ),
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: GestureDetector(
                            onTap: _showImagePicker,
                            child: CircleAvatar(
                              backgroundColor: Colors.red,
                              child: Icon(Icons.edit,
                                  color: Colors.white, size: 18.sp),
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 2.h),

                    _buildTextField(_nameController, "Name", Icons.person),
                    _buildTextField(_emailController, "Email", Icons.email, isEditable: false),
                    _buildTextField(_phoneController, "Phone", Icons.phone),

                    SizedBox(height: 2.h),

                    _buildDropdown("Role", _selectedRole, ["Employee"],
                        (value) => setState(() => _selectedRole = value!)),

                    SizedBox(height: 2.h),

                    _buildDropdown("Gender", _selectedGender,
                        ["Male", "Female"],
                        (value) => setState(() => _selectedGender = value!)),

                    SizedBox(height: 3.h),

                    ElevatedButton(
                      onPressed: _isLoading ? null : _saveProfile,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        padding:
                            EdgeInsets.symmetric(vertical: 1.5.h, horizontal: 20.w),
                      ),
                      child: _isLoading
                          ? CircularProgressIndicator(color: Colors.white)
                          : Text(
                              "Save",
                              style: TextStyle(fontSize: 18.sp, color: Colors.white),
                            ),
                    ),
                  ],
                ),
              ),
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

  Widget _buildTextField(
      TextEditingController controller, String label, IconData icon, {bool isEditable = true}) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 1.h),
      child: TextFormField(
        controller: controller,
        enabled: isEditable, // Set to false to make the field non-editable
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        ),
        validator: (value) => value!.isEmpty ? "$label cannot be empty" : null,
      ),
    );
  }

  Widget _buildDropdown(
      String label, String value, List<String> items, ValueChanged<String?> onChanged) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 1.h),
      child: DropdownButtonFormField<String>(
        value: value,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        ),
        items: items.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
        onChanged: onChanged,
      ),
    );
  }
}
