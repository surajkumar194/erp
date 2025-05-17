import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:erp/HR%20Screen/Hr_Login.dart';
import 'package:erp/login/Login.dart'; // Employee Login
import 'package:erp/login/ManagerLoginScreen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

class SignupScreenfirst extends StatefulWidget {
  const SignupScreenfirst({super.key});

  @override
  State<SignupScreenfirst> createState() => _SignupScreenfirstState();
}

class _SignupScreenfirstState extends State<SignupScreenfirst> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _isPasswordVisible = false;
  String _selectedGender = "Male";
  String _selectedRole = "Employee";
  bool _isLoading = false;

  final List<String> _designations = [
    'Select Designation',
    'Development',
    'Design',
    'Testing',
    'Deployment',
    'Maintenance',
    'Research',
    'Project Management',
    'Training',
    'Quality Assurance',
    'Consulting',
    'Video Editing',
    'Graphic Design',
    'Website',
    'SEO',
    'Ads'
  ];

  final List<String> _roles = ["Employee", "Manager", "HR"];
  String _selectedDesignation = 'Select Designation';

  Future<void> _signUp() async {
    if (_nameController.text.trim().isEmpty ||
        _emailController.text.trim().isEmpty ||
        _phoneController.text.trim().isEmpty ||
        _passwordController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Please fill all the fields", style: TextStyle(fontSize: 18.sp)),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_selectedRole == "Employee" && _selectedDesignation == 'Select Designation') {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Please select a valid designation", style: TextStyle(fontSize: 18.sp)),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (!RegExp(r"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$")
        .hasMatch(_emailController.text.trim())) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please enter a valid email address"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_passwordController.text.trim().length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Password must be at least 6 characters long"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      List<String> signInMethods =
          await _auth.fetchSignInMethodsForEmail(_emailController.text.trim());

      if (signInMethods.isNotEmpty) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text("This email is already registered. Please login instead."),
            backgroundColor: Colors.orange,
            action: SnackBarAction(
              label: 'Login',
              textColor: Colors.white,
              onPressed: () {
                if (_selectedRole == "Manager") {
                  Navigator.pushReplacement(context,
                      MaterialPageRoute(builder: (context) => const ManagerLoginScreen()));
                } else if (_selectedRole == "HR") {
                  Navigator.pushReplacement(context,
                      MaterialPageRoute(builder: (context) =>  HRLoginScreen()));
                } else {
                  Navigator.pushReplacement(context,
                      MaterialPageRoute(builder: (context) => const EmployeeLoginScreen()));
                }
              },
            ),
          ),
        );
        return;
      }

      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      await userCredential.user!.updateDisplayName(_nameController.text.trim());

      final uid = userCredential.user!.uid;

      final commonData = {
        "uid": uid,
        "name": _nameController.text.trim(),
        "email": _emailController.text.trim(),
        "phone": _phoneController.text.trim(),
        "role": _selectedRole,
        "gender": _selectedGender,
        "createdAt": FieldValue.serverTimestamp(),
        "isApproved": false,
      };

      if (_selectedRole == "Employee") {
        await _firestore.collection("users").doc(uid).set({
          ...commonData,
          "employeeId": uid,
          "designation": _selectedDesignation,
        });
        _navigateAndShowMessage("Signup successful. Awaiting admin approval.",
            const EmployeeLoginScreen());
      } else if (_selectedRole == "Manager") {
        await _firestore.collection("Manager").doc(uid).set({
          ...commonData,
          "managerId": uid,
        });
        _navigateAndShowMessage("Signup successful. Awaiting admin approval.",
            const ManagerLoginScreen());
      } else if (_selectedRole == "HR") {
        await _firestore.collection("HR").doc(uid).set({
          ...commonData,
          "hrId": uid,
        });
        _navigateAndShowMessage("Signup successful. Awaiting admin approval.",
            const HRLoginScreen());
      }
    } on FirebaseAuthException catch (e) {
      String errorMessage;
      switch (e.code) {
        case 'email-already-in-use':
          errorMessage = 'This email is already registered. Please login instead';
          break;
        case 'invalid-email':
          errorMessage = 'Invalid email format';
          break;
        case 'weak-password':
          errorMessage = 'Password is too weak';
          break;
        default:
          errorMessage = 'Signup Failed: ${e.message}';
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMessage), backgroundColor: Colors.red),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Signup Failed: ${e.toString()}"), backgroundColor: Colors.red),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _navigateAndShowMessage(String message, Widget screen) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.green),
    );
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => screen));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Fill the Form", style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w700)),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topRight,
              end: Alignment.bottomLeft,
              colors: [Color(0xffe7dcc0), Color(0xff013148)],
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 8.w),
        child: Column(
          children: [
            Image.asset("assets/4.webp", scale: 7.sp, fit: BoxFit.fill),
            SizedBox(height: 1.h),
            _buildTextField(_nameController, "Full Name", Icons.person),
            _buildTextField(_emailController, "Email", Icons.email),
            _buildTextField(_phoneController, "Phone", Icons.phone, isPhone: true),
            _buildPasswordField(),
            _buildDropdownRow("Gender:", _selectedGender, ["Male", "Female"], (val) {
              setState(() => _selectedGender = val!);
            }),
            _buildDropdownRow("Role:", _selectedRole, _roles, (val) {
              setState(() {
                _selectedRole = val!;
                if (_selectedRole != "Employee") {
                  _selectedDesignation = 'Select Designation';
                }
              });
            }),
            if (_selectedRole == "Employee")
              _buildDropdownRow("Designation:", _selectedDesignation, _designations, (val) {
                setState(() => _selectedDesignation = val!);
              }),
            SizedBox(height: 2.h),
            _buildSubmitButton(),
            SizedBox(height: 2.h),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, IconData icon,
      {bool isPhone = false}) {
    return Padding(
      padding: EdgeInsets.only(bottom: 1.h),
      child: TextField(
        controller: controller,
        keyboardType: isPhone ? TextInputType.phone : TextInputType.text,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon),
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }

  Widget _buildPasswordField() {
    return Padding(
      padding: EdgeInsets.only(bottom: 1.h),
      child: TextField(
        controller: _passwordController,
        obscureText: !_isPasswordVisible,
        decoration: InputDecoration(
          labelText: "Password",
          prefixIcon: const Icon(Icons.lock),
          suffixIcon: IconButton(
            icon: Icon(_isPasswordVisible ? Icons.visibility : Icons.visibility_off),
            onPressed: () => setState(() => _isPasswordVisible = !_isPasswordVisible),
          ),
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }

  Widget _buildDropdownRow(
      String label, String value, List<String> options, ValueChanged<String?> onChanged) {
    return Padding(
      padding: EdgeInsets.only(bottom: 1.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontSize: 17.sp)),
          DropdownButton<String>(
            value: value,
            items: options.map((option) {
              return DropdownMenuItem(
                value: option,
                child: Text(
                  option,
                  style: TextStyle(
                      color: (option == 'Select Designation') ? Colors.grey : Colors.black),
                ),
              );
            }).toList(),
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      height: 6.h,
      child: Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
            colors: [Color(0xffe7dcc0), Color(0xff013148)],
          ),
          borderRadius: BorderRadius.circular(10.sp),
        ),
        child: ElevatedButton(
          onPressed: _isLoading ? null : _signUp,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.sp)),
          ),
          child: _isLoading
              ? const CircularProgressIndicator(color: Colors.white)
              : Text("Sign Up", style: TextStyle(fontSize: 17.sp, color: Colors.white)),
        ),
      ),
    );
  }
}
