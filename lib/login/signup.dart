import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:erp/bottomScreen/bottom.dart';
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

  String _selectedRole = "Manager";
  String _selectedGender = "Male";
  bool _isLoading = false;

  Future<void> _signUp() async {
  // Check for empty fields
  if (_nameController.text.trim().isEmpty ||
      _emailController.text.trim().isEmpty ||
      _phoneController.text.trim().isEmpty ||
      _passwordController.text.trim().isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Please fill all the fields"), backgroundColor: Colors.red),
    );
    return; // Exit if any field is empty
  }

  // Validate email format
  if (!_emailController.text.trim().contains('@')) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Please enter a valid email address"), backgroundColor: Colors.red),
    );
    return; // Exit if email format is invalid
  }

  // Validate password strength
  if (_passwordController.text.trim().length < 6) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Password must be at least 6 characters long"), backgroundColor: Colors.red),
    );
    return; // Exit if password length is too short
  }

  setState(() {
    _isLoading = true;
  });

  try {
    UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
      email: _emailController.text.trim(),
      password: _passwordController.text.trim(),
    );

    await _firestore.collection("users").doc(userCredential.user!.uid).set({
      "uid": userCredential.user!.uid,
      "name": _nameController.text.trim(),
      "email": _emailController.text.trim(),
      "phone": _phoneController.text.trim(),
      "role": _selectedRole,
      "gender": _selectedGender,
      "createdAt": FieldValue.serverTimestamp(),
    });

    // Navigate to the Bottom Navigation Screen after signup
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => BottomNavigationBarWidget()),
    );
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Signup Failed: ${e.toString()}"),
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
      appBar: AppBar(
        title: Text("Sign Up", style: TextStyle(fontSize: 18.sp)),
        centerTitle: true,
        backgroundColor: Colors.blue,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
          child: Column(
            children: [
              Image.asset("assets/4.webp", height: 15.h, fit: BoxFit.contain),
              SizedBox(height: 2.h),
              TextField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: "Full Name",
                  prefixIcon: Icon(Icons.person),
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 2.h),
              TextField(
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: "Email",
                  prefixIcon: Icon(Icons.email),
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 2.h),
              TextField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  labelText: "Phone",
                  prefixIcon: Icon(Icons.phone),
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 2.h),
              TextField(
                controller: _passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: "Password",
                  prefixIcon: Icon(Icons.lock),
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 2.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Select Role:", style: TextStyle(fontSize: 17.sp)),
                  DropdownButton<String>(
                    value: _selectedRole,
                    items: ["Manager", "Employee"].map((role) {
                      return DropdownMenuItem(value: role, child: Text(role));
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedRole = value!;
                      });
                    },
                  ),
                ],
              ),
              SizedBox(height: 2.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Select Gender:", style: TextStyle(fontSize: 17.sp)),
                  DropdownButton<String>(
                    value: _selectedGender,
                    items: ["Male", "Female"].map((gender) {
                      return DropdownMenuItem(
                          value: gender, child: Text(gender));
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedGender = value!;
                      });
                    },
                  ),
                ],
              ),
              SizedBox(height: 2.h),
              SizedBox(
                width: double.infinity,
                height: 6.h,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _signUp,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5)),
                  ),
                  child: _isLoading
                      ? CircularProgressIndicator(color: Colors.white)
                      : Text("Sign Up",
                          style:
                              TextStyle(fontSize: 17.sp, color: Colors.white)),
                ),
              ),
              SizedBox(height: 2.h),
              TextButton(
                onPressed: () {
                  Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const LoginScreen()));
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("Already have an account?",
                        style: TextStyle(fontSize: 16.sp, color: Colors.grey)),
                    Text(" Login",
                        style: TextStyle(
                            fontSize: 18.sp, color: Color(0xff120A8F))),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
