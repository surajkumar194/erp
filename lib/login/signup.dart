// signup_screen.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:erp/login/Login.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _isPasswordVisible = false;
  String _selectedGender = "Male";
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

    if (_selectedDesignation == 'Select Designation') {
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
        SnackBar(content: Text("Please enter a valid email address"), backgroundColor: Colors.red),
      );
      return;
    }

    if (_passwordController.text.trim().length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Password must be at least 6 characters long"), backgroundColor: Colors.red),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      List<String> signInMethods =
          await _auth.fetchSignInMethodsForEmail(_emailController.text.trim());

      if (signInMethods.isNotEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("This email is already registered. Please login instead."),
            backgroundColor: Colors.orange,
            action: SnackBarAction(
              label: 'Login',
              textColor: Colors.white,
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const EmployeeLoginScreen()),
                );
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

      await _firestore.collection("users").doc(userCredential.user!.uid).set({
        "employeeId": userCredential.user!.uid,
        "name": _nameController.text.trim(),
        "email": _emailController.text.trim(),
        "phone": _phoneController.text.trim(),
        "role": "Employee", // Corrected
        "designation": _selectedDesignation, // Added field
        "gender": _selectedGender,
        "createdAt": FieldValue.serverTimestamp(),
         "isApproved": false,
      });

     ScaffoldMessenger.of(context).showSnackBar(
  SnackBar(
    content: Text("Signup successful. Awaiting admin approval."),
    backgroundColor: Colors.green,
  ),
);
Navigator.pushReplacement(
  context,
  MaterialPageRoute(builder: (context) => const EmployeeLoginScreen()),
);
    } on FirebaseAuthException catch (e) {
      String errorMessage;
      switch (e.code) {
        case 'email-already-in-use':
          errorMessage =
              'This email is already registered. Please login instead';
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
        SnackBar(
            content: Text("Signup Failed: ${e.toString()}"),
            backgroundColor: Colors.red),
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
      appBar: AppBar(
        title: Text("Employee Sign Up", style: TextStyle(fontSize: 18.sp)),
        centerTitle: true,
      backgroundColor: const Color(0xffF1E9D2),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
          child: Column(
            children: [
              Image.asset("assets/4.webp", height: 18.h, fit: BoxFit.cover),
              SizedBox(height: 2.h),
              TextField(
                controller: _nameController,
                decoration: InputDecoration(labelText: "Full Name", prefixIcon: Icon(Icons.person), border: OutlineInputBorder()),
              ),
              SizedBox(height: 2.h),
              TextField(
                controller: _emailController,
                decoration: InputDecoration(labelText: "Email", prefixIcon: Icon(Icons.email), border: OutlineInputBorder()),
              ),
              SizedBox(height: 2.h),
              TextField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(labelText: "Phone", prefixIcon: Icon(Icons.phone), border: OutlineInputBorder()),
              ),
              SizedBox(height: 2.h),
              TextField(
                controller: _passwordController,
                obscureText: !_isPasswordVisible,
                decoration: InputDecoration(
                  labelText: "Password",
                  prefixIcon: Icon(Icons.lock),
                  suffixIcon: IconButton(
                    icon: Icon(_isPasswordVisible ? Icons.visibility : Icons.visibility_off),
                    onPressed: () => setState(() => _isPasswordVisible = !_isPasswordVisible),
                  ),
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 2.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Designation:", style: TextStyle(fontSize: 17.sp)),
                  DropdownButton<String>(
                    value: _selectedDesignation,
                    items: _designations.map((designation) {
                      return DropdownMenuItem(
                        value: designation,
                        child: Text(
                          designation,
                          style: TextStyle(
                            color: designation == 'Select Designation' ? Colors.grey : Colors.black,
                          ),
                        ),
                      );
                    }).toList(),
                    onChanged: (value) => setState(() => _selectedDesignation = value!),
                  ),
                ],
              ),
              SizedBox(height: 2.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Gender:", style: TextStyle(fontSize: 17.sp)),
                  DropdownButton<String>(
                    value: _selectedGender,
                    items: ["Male", "Female", "Others"].map((gender) {
                      return DropdownMenuItem(value: gender, child: Text(gender));
                    }).toList(),
                    onChanged: (value) => setState(() => _selectedGender = value!),
                  ),
                ],
              ),
              SizedBox(height: 2.h),
              SizedBox(
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
                        ? CircularProgressIndicator(color: Colors.white)
                        : Text("Sign Up", style: TextStyle(fontSize: 17.sp, color: Colors.white)),
                  ),
                ),
              ),
              // SizedBox(height: 2.h),
              // TextButton(
              //   onPressed: () {
              //     Navigator.pushReplacement(
              //       context,
              //       MaterialPageRoute(builder: (context) => const EmpoyeeLoginScreen()),
              //     );
              //   },
              //   child: Text("Already have an account? Login", style: TextStyle(fontSize: 16.sp, color: Color(0xff120A8F))),
              // ),
            ],
          ),
        ),
      ),
    );
  }
}
