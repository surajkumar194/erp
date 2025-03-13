import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:erp/bottomScreen/bottom.dart';
import 'package:erp/login/signup.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _isLoading = false;

  Future<void> _login() async {
  String email = _emailController.text.trim();
  String password = _passwordController.text.trim();

  if (email.isEmpty || password.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
          content: Text("Please enter both email and password."),
          backgroundColor: Colors.red),
    );
    return;
  }

  if (!RegExp(r"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$")
      .hasMatch(email)) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
          content: Text("Please enter a valid email address."),
          backgroundColor: Colors.red),
    );
    return;
  }

  setState(() {
    _isLoading = true;
  });

  try {
    UserCredential userCredential = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );

    // Navigate to BottomNavigationBarWidget after login
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (context) => BottomNavigationBarWidget()));
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
          content: Text("Login Failed: ${e.toString()}"),
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
        title: Text("Login", style: TextStyle(fontSize: 18.sp)),
        centerTitle: true,
        backgroundColor: Colors.blue,
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset("assets/4.webp", height: 15.h, fit: BoxFit.contain),
              SizedBox(height: 2.h),
          
              // Email Input
              TextField(
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: "Email",
                  prefixIcon: Icon(Icons.email),
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 2.h),
          
              // Password Input
              TextField(
                controller: _passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: "Password",
                  prefixIcon: Icon(Icons.lock),
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 4.h),
          
              // Login Button
              SizedBox(
                width: double.infinity,
                height: 6.h,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _login,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5)),
                  ),
                  child: _isLoading
                      ? CircularProgressIndicator(color: Colors.white)
                      : Text("Login",
                          style: TextStyle(fontSize: 17.sp, color: Colors.white)),
                ),
              ),
              SizedBox(height: 2.h),
          
              // Navigate to Sign-Up Screen
              TextButton(
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const SignupScreen()));
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("Don't have an account?",
                        style: TextStyle(fontSize: 16.sp, color: Colors.grey)),
                    Text(" Sign Up",
                        style:
                            TextStyle(fontSize: 18.sp, color: Color(0xff120A8F))),
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
