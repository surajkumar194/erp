// import 'dart:io';

// import 'package:flutter/material.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:sizer/sizer.dart';

// class EditProfileScreen extends StatefulWidget {
//   final Function(File?) onImageUpdated; // Callback function to update image
//   const EditProfileScreen({super.key, required this.onImageUpdated});

//   @override
//   State<EditProfileScreen> createState() => _EditProfileScreenState();
// }

// class _EditProfileScreenState extends State<EditProfileScreen> {
//   File? _image;
//   final picker = ImagePicker();
//   final _formKey = GlobalKey<FormState>();

//   final TextEditingController _nameController =
//       TextEditingController(text: "suraj kumar");
//   final TextEditingController _emailController =
//       TextEditingController(text: "Surajkumar@gmail.com");
//   final TextEditingController _passwordController =
//       TextEditingController(text: "Suraj1234@");

//   bool _isPasswordVisible = false;

//   String _selectedGender = "Male";
//   String _selectedEmployee = "Software Engineer";

//   // Function to show options for Camera or Gallery
//   void _showImagePicker() {
//     showModalBottomSheet(
//       context: context,
//       shape: RoundedRectangleBorder(
//         borderRadius: BorderRadius.vertical(top: Radius.circular(15)),
//       ),
//       builder: (context) {
//         return Padding(
//           padding: EdgeInsets.all(3.h),
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               Text("Select Image Source",
//                   style:
//                       TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold)),
//               SizedBox(height: 2.h),
//               ListTile(
//                 leading: Icon(Icons.camera, color: Colors.blue),
//                 title: Text("Camera"),
//                 onTap: () {
//                   Navigator.pop(context);
//                   _pickImage(ImageSource.camera);
//                 },
//               ),
//               ListTile(
//                 leading: Icon(Icons.photo_library, color: Colors.green),
//                 title: Text("Gallery"),
//                 onTap: () {
//                   Navigator.pop(context);
//                   _pickImage(ImageSource.gallery);
//                 },
//               ),
//             ],
//           ),
//         );
//       },
//     );
//   }

//   Future<void> _pickImage(ImageSource source) async {
//     final pickedFile = await picker.pickImage(source: source);
//     if (pickedFile != null) {
//       setState(() {
//         _image = File(pickedFile.path);
//       });

//       // Call the callback function to update the Profile screen image
//       widget.onImageUpdated(_image);
//     }
//   }

//   void _saveProfile() {
//     if (_formKey.currentState!.validate()) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text("Profile Updated Successfully")),
//       );
//       Navigator.pop(context);
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         backgroundColor: Color(0xffF1E9D2),
//         elevation: 0,
//         title: Text("Edit Profile",
//             style: TextStyle(
//                 color: Colors.black,
//                 fontSize: 18.sp,
//                 fontWeight: FontWeight.w600)),
//         centerTitle: true,
//         iconTheme: const IconThemeData(color: Colors.black),
//       ),
//       body: Padding(
//         padding: EdgeInsets.all(5.w),
//         child: Form(
//           key: _formKey,
//           child: SingleChildScrollView(
//             child: Column(
//               children: [
//                 // Profile Picture with Edit Icon
//                 Stack(
//                   children: [
//                     // Profile Image
                    // Container(
                    //   width: 42.w,
                    //   height: 20.h,
                    //   decoration: BoxDecoration(
                    //     shape: BoxShape.circle,
                    //     image: _image != null
                    //         ? DecorationImage(
                    //             image: FileImage(_image!),
                    //             fit: BoxFit.cover,
                    //           )
                    //         : DecorationImage(
                    //             image: AssetImage("assets/de.jpg"),
                    //             fit: BoxFit.fill,
                    //           ),
                    //   ),
                    // ),

//                     // Edit Icon at Bottom-Right
//                     Positioned(
//                       bottom: 0,
//                       right: 0,
//                       child: GestureDetector(
//                         onTap: _showImagePicker,
//                         child: Container(
//                           decoration: BoxDecoration(
//                             shape: BoxShape.circle,
//                             color: Colors.red,
//                             border: Border.all(color: Colors.white, width: 2),
//                           ),
//                           padding: EdgeInsets.all(6),
//                           child: Icon(Icons.edit,
//                               color: Colors.white, size: 18.sp),
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//                 SizedBox(height: 2.h),

//                 _buildTextField(_nameController, "Name", Icons.person),
//                 _buildTextField(_emailController, "Email", Icons.email),
//                 _buildPasswordField(),

//                 SizedBox(height: 2.h),

//                 // Employee Dropdown
//                 DropdownButtonFormField<String>(
//                   value: _selectedEmployee,
//                   decoration: InputDecoration(
//                     labelText: "Employee",
//                     prefixIcon: Icon(Icons.work),
//                     border: OutlineInputBorder(
//                         borderRadius: BorderRadius.circular(10)),
//                   ),
//                   items: [
//                     "Software Engineer",
//                     "Manager",
//                     "HR",
//                     "Developer",
//                     "Sales Executive",
//                     "Marketing Manager",
//                     "Designer",
//                   ]
//                       .map((job) =>
//                           DropdownMenuItem(value: job, child: Text(job)))
//                       .toList(),
//                   onChanged: (value) {
//                     setState(() {
//                       _selectedEmployee = value!;
//                     });
//                   },
//                 ),

//                 SizedBox(height: 2.h),

//                 // Gender Dropdown
//                 DropdownButtonFormField<String>(
//                   value: _selectedGender,
//                   decoration: InputDecoration(
//                     labelText: "Gender",
//                     prefixIcon: Icon(Icons.people),
//                     border: OutlineInputBorder(
//                         borderRadius: BorderRadius.circular(10)),
//                   ),
//                   items: ["Male", "Female", "Other"]
//                       .map((gender) =>
//                           DropdownMenuItem(value: gender, child: Text(gender)))
//                       .toList(),
//                   onChanged: (value) {
//                     setState(() {
//                       _selectedGender = value!;
//                     });
//                   },
//                 ),

//                 SizedBox(height: 3.h),

//                 // Save Button
//                 ElevatedButton(
//                   onPressed: _saveProfile,
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: Colors.blue,
//                     padding:
//                         EdgeInsets.symmetric(vertical: 1.5.h, horizontal: 20.w),
//                   ),
//                   child: Text(
//                     "Save",
//                     style: TextStyle(fontSize: 18.sp, color: Colors.white),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildTextField(
//       TextEditingController controller, String label, IconData icon) {
//     return Padding(
//       padding: EdgeInsets.symmetric(vertical: 1.h),
//       child: TextFormField(
//         controller: controller,
//         decoration: InputDecoration(
//           labelText: label,
//           prefixIcon: Icon(icon),
//           border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
//         ),
//         validator: (value) {
//           if (value == null || value.isEmpty) {
//             return "$label cannot be empty";
//           }
//           return null;
//         },
//       ),
//     );
//   }

//   Widget _buildPasswordField() {
//     return Padding(
//       padding: EdgeInsets.symmetric(vertical: 1.h),
//       child: TextFormField(
//         controller: _passwordController,
//         obscureText: !_isPasswordVisible,
//         decoration: InputDecoration(
//           labelText: "Password",
//           prefixIcon: Icon(Icons.lock),
//           suffixIcon: IconButton(
//             icon: Icon(
//                 _isPasswordVisible ? Icons.visibility : Icons.visibility_off),
//             onPressed: () {
//               setState(() {
//                 _isPasswordVisible = !_isPasswordVisible;
//               });
//             },
//           ),
//           border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
//         ),
//         validator: (value) {
//           if (value == null || value.isEmpty) {
//             return "Password cannot be empty";
//           }
//           return null;
//         },
//       ),
//     );
//   }
// }







import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
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
        }
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

      widget.onImageUpdated(_image);
    }
  }

  Future<void> _saveProfile() async {
    if (_formKey.currentState!.validate()) {
      try {
        User? user = _auth.currentUser;
        if (user != null) {
          await _firestore.collection("users").doc(user.uid).update({
            "name": _nameController.text.trim(),
            "email": _emailController.text.trim(),
            "phone": _phoneController.text.trim(),
            "gender": _selectedGender,
            "role": _selectedRole,
          });

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Profile Updated Successfully")),
          );
          Navigator.pop(context);
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error updating profile: $e")),
        );
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
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : Padding(
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
                                child:
                                    Icon(Icons.edit, color: Colors.white, size: 18.sp),
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 2.h),

                      _buildTextField(_nameController, "Name", Icons.person),
                      _buildTextField(_emailController, "Email", Icons.email),
                      _buildTextField(_phoneController, "Phone", Icons.phone),

                      SizedBox(height: 2.h),

                      _buildDropdown("Role", _selectedRole, ["Manager", "Employee"],
                          (value) => setState(() => _selectedRole = value!)),

                      SizedBox(height: 2.h),

                      _buildDropdown("Gender", _selectedGender, ["Male", "Female", "Other"],
                          (value) => setState(() => _selectedGender = value!)),

                      SizedBox(height: 3.h),

                      ElevatedButton(
                        onPressed: _saveProfile,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          padding: EdgeInsets.symmetric(vertical: 1.5.h, horizontal: 20.w),
                        ),
                        child: Text(
                          "Save",
                          style: TextStyle(fontSize: 18.sp, color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, IconData icon) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 1.h),
      child: TextFormField(
        controller: controller,
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
    return DropdownButtonFormField<String>(
      value: value,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      ),
      items: items.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
      onChanged: onChanged,
    );
  }
}
