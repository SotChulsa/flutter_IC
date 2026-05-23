// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fluttergame_ic/pages/home/home_page.dart';
import 'login_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MyRegisterPage extends StatefulWidget {
  const MyRegisterPage({super.key});

  @override
  State<MyRegisterPage> createState() => _MyRegisterPageState();
}

// Class to manage terms and conditions checkbox state,
//a singleton class to hold the state of the checkbox
class TermsAndConditions {
  bool value = false;
}

//Provider for terms and conditions checkbox state
class TermsAndConditionsprovider {
  static final TermsAndConditionsprovider _instance =
      TermsAndConditionsprovider();
  static TermsAndConditionsprovider get instance => _instance;
  bool _value = false;
  //ignore: unnecessary_getters_setters
  bool get value => _value;
  set value(bool v) => _value = v;
}

//Default user data in Firestore for new user should include email, username, role, totalScore, favoriteCategory, quizzesCompleted, joinedAt
class _MyRegisterPageState extends State<MyRegisterPage> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  //Check if registered user password and confirm password match, if not show error message, if they match, create user with email and password,
  //if registration is successful, set default user data in Firestore for new user,
  //if registration fails, show error message
  Future<void> _register() async {
    if (_passwordController.text.trim() !=
        _confirmPasswordController.text.trim()) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Passwords do not match')));
      return;
    }

    //Try to create user with email and password
    try {
      UserCredential userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
            email: _emailController.text.trim(),
            password: _passwordController.text.trim(),
          );

      //Set default user data in Firestore for new user
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userCredential.user!.uid)
          .set({
            'email': _emailController.text.trim(),
            'username': _usernameController.text.trim(),
            'role': 'user',
          });

      String uid = userCredential.user!.uid;

      //Set default user data in Firestore for new user with additional fields for quiz app
      await FirebaseFirestore.instance.collection('users').doc(uid).set({
        'username': _usernameController.text.trim(),
        'email': _emailController.text.trim(),
        'totalScore': 0,
        'favoriteCategory': '',
        'quizzesCompleted': 0,
        'joinedAt': Timestamp.now(),
        'role': 'user',
        'isOnline': true,
      });

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Registration Successful')));

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomePage()),
      );
    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message ?? 'Registration failed')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color.fromARGB(255, 108, 255, 59),
              Color.fromARGB(255, 255, 255, 255),
            ],
            stops: [0.0, 0.5],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(30.0),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Image.asset('images/logo.jpeg', width: 200, height: 200),
                  const SizedBox(height: 6),
                  const Text(
                    'Register',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.normal,
                      fontSize: 36,
                      color: Color(0xFF1C1C1C),
                    ),
                  ),
                  const SizedBox(height: 26),
                  Row(
                    children: [
                      Text(
                        'Username',
                        style: TextStyle(
                          fontSize: 16,
                          color: Color(0xFF1C1C1C),
                        ),
                      ),
                      SizedBox(width: 4),
                      Image.asset(
                        'images/required_asterick.png',
                        width: 8,
                        height: 8,
                      ),
                    ],
                  ),
                  TextField(
                    controller: _usernameController,
                    decoration: const InputDecoration(
                      labelText: 'Username',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(20)),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Text(
                        'Email',
                        style: TextStyle(
                          fontSize: 16,
                          color: Color(0xFF1C1C1C),
                        ),
                      ),
                      SizedBox(width: 4),
                      Image.asset(
                        'images/required_asterick.png',
                        width: 8,
                        height: 8,
                      ),
                    ],
                  ),
                  TextField(
                    controller: _emailController,
                    decoration: const InputDecoration(
                      labelText: 'Email',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(20)),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Text(
                        'Password',
                        style: TextStyle(
                          fontSize: 16,
                          color: Color(0xFF1C1C1C),
                        ),
                      ),
                      SizedBox(width: 4),
                      Image.asset(
                        'images/required_asterick.png',
                        width: 8,
                        height: 8,
                      ),
                    ],
                  ),
                  TextField(
                    controller: _passwordController,
                    decoration: const InputDecoration(
                      labelText: 'Password',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(20)),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                    obscureText: true,
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Text(
                        'Confirm Password',
                        style: TextStyle(
                          fontSize: 16,
                          color: Color(0xFF1C1C1C),
                        ),
                      ),
                      SizedBox(width: 4),
                      Image.asset(
                        'images/required_asterick.png',
                        width: 8,
                        height: 8,
                      ),
                    ],
                  ),
                  TextField(
                    controller: _confirmPasswordController,
                    decoration: const InputDecoration(
                      labelText: 'Confirm Password',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(20)),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                    obscureText: true,
                  ),
                  const SizedBox(height: 12),
                  // I agree to the terms and conditions checkbox placed closer
                  Row(
                    children: [
                      Checkbox(
                        value: TermsAndConditionsprovider.instance.value,
                        onChanged: (newValue) {
                          setState(() {
                            TermsAndConditionsprovider.instance.value =
                                newValue ?? false;
                          });
                        },
                      ),
                      const Text(
                        'I agree to the terms and conditions',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 14,
                          color: Color.fromARGB(255, 0, 0, 0),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    width: double.infinity,
                    height: 49,
                    child: ElevatedButton(
                      onPressed: _register,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromARGB(
                          255,
                          255,
                          255,
                          255,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                          side: const BorderSide(
                            color: Color.fromARGB(255, 0, 0, 0),
                            width: 1,
                          ),
                        ),
                      ),
                      child: const Text(
                        'Register',
                        style: TextStyle(
                          color: Color.fromARGB(255, 0, 0, 0),
                          fontSize: 16,
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    height: 49,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const MyLoginPage(),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromARGB(
                          255,
                          255,
                          255,
                          255,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                          side: const BorderSide(
                            color: Color.fromARGB(255, 0, 0, 0),
                            width: 1,
                          ),
                        ),
                      ),
                      child: const Text(
                        'Already have an account? Login',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 16,
                          color: Color.fromARGB(255, 0, 0, 0),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
