import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:erp/bottomScreen/bottommanager.dart';
import 'package:erp/login/ManagerSignupScreen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

class ManagerLoginScreen extends StatefulWidget {
  const ManagerLoginScreen({super.key});

  @override
  State<ManagerLoginScreen> createState() => _ManagerLoginScreenState();
}

class _ManagerLoginScreenState extends State<ManagerLoginScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isPasswordVisible = false;
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
    // Sign in with Firebase Auth
    UserCredential userCredential = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );

    // Check manager Firestore document
    final userDoc = await _firestore
        .collection("Manager")
        .doc(userCredential.user!.uid)
        .get();

    if (userDoc.exists) {
      final userData = userDoc.data() as Map<String, dynamic>;

      if (userData["role"] == "Manager") {
        if (userData["isApproved"] == true) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => bottommanager()),
          );
        } else {
          await _auth.signOut();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Your account is not yet approved."),
              backgroundColor: Colors.orange,
            ),
          );
        }
      } else {
        await _auth.signOut();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Only managers can access this portal."),
            backgroundColor: Colors.red,
          ),
        );
      }
    } else {
      // Not a manager - check if it's an employee
      DocumentSnapshot employeeDoc = await _firestore
          .collection("users")
          .doc(userCredential.user!.uid)
          .get();

      if (employeeDoc.exists) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Employees cannot log in to Manager portal."),
            backgroundColor: Colors.red,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Manager account not found. Please sign up."),
            backgroundColor: Colors.black,
            action: SnackBarAction(
              label: 'Sign Up',
              textColor: Colors.white,
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ManagerSignupScreen()),
                );
              },
            ),
          ),
        );
      }

      await _auth.signOut(); // Sign out if not approved or invalid
    }
  } on FirebaseAuthException catch (e) {
    String errorMessage;
    switch (e.code) {
      case 'wrong-password':
        errorMessage = 'Incorrect password';
        break;
      case 'user-not-found':
        errorMessage = 'Email not found. Please sign up first';
        break;
      case 'invalid-email':
        errorMessage = 'Invalid email format';
        break;
      default:
        errorMessage = 'Login Failed: ${e.message}';
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(errorMessage), backgroundColor: Colors.red),
    );
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Login Failed: ${e.toString()}"),
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
        title: Text("Manager Login", style: TextStyle(fontSize: 18.sp)),
        centerTitle: true,
        backgroundColor: Colors.blue,
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset("assets/4.webp", height: 18.h, fit: BoxFit.contain),
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
                controller: _passwordController,
                obscureText: !_isPasswordVisible,
                decoration: InputDecoration(
                  labelText: "Password",
                  prefixIcon: Icon(Icons.lock),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                    ),
                    onPressed: () {
                      setState(() {
                        _isPasswordVisible = !_isPasswordVisible;
                      });
                    },
                  ),
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 4.h),
              SizedBox(
                width: double.infinity,
                height: 6.h,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.topRight,
                      end: Alignment.bottomLeft,
                      colors: [
                        Color(0xffe7dcc0),
                        Color(0xff013148),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(10.sp),
                  ),
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _login,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.sp),
                      ),
                    ),
                    child: _isLoading
                        ? CircularProgressIndicator(color: Colors.white)
                        : Text(
                            "Login", // Changed from "Sign Up" to "Login"
                            style: TextStyle(fontSize: 17.sp, color: Colors.white),
                          ),
                  ),
                ),
              ),
              SizedBox(height: 2.h),
              TextButton(
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const ManagerSignupScreen()));
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("Don't have an account?",
                        style: TextStyle(fontSize: 16.sp, color: Colors.grey)),
                    Text(" Sign Up",
                        style: TextStyle(fontSize: 18.sp, color: Color(0xff120A8F))),
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