import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'login_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MyRegisterPage extends StatefulWidget {
  const MyRegisterPage({super.key});

  @override
  State<MyRegisterPage> createState() => _MyRegisterPageState();
}
class TermsAndConditions {
  bool value = false;
}
class TermsAndConditionsprovider {
  static final TermsAndConditionsprovider _instance = TermsAndConditionsprovider();
  static TermsAndConditionsprovider get instance => _instance;
  bool _value = false;
  //ignore: unnecessary_getters_setters
  bool get value => _value;
  set value(bool v) => _value = v;
}

class _MyRegisterPageState extends State<MyRegisterPage> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();


Future<void> _register() async {
  if (_passwordController.text.trim() !=
      _confirmPasswordController.text.trim()) {

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Passwords do not match'),
      ),
    );
    return;
  }

  try {

    UserCredential userCredential =
        await FirebaseAuth.instance
            .createUserWithEmailAndPassword(
      email: _emailController.text.trim(),
      password: _passwordController.text.trim(),
    );

    await FirebaseFirestore.instance
    .collection('users')
    .doc(userCredential.user!.uid)
    .set({
    'email': _emailController.text.trim(),
    'username': _usernameController.text.trim(),
    'role': 'user',
    });

    String uid = userCredential.user!.uid;

    await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .set({

      'username': _usernameController.text.trim(),
      'email': _emailController.text.trim(),
      'totalScore': 0,
      'favoriteCategory': '',
      'quizzesCompleted': 0,
      'joinedAt': Timestamp.now(),
      'role': 'user',
    });

    // ignore: use_build_context_synchronously, this doesnt break anything
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Registration Successful'),
      ),
    );

  } on FirebaseAuthException catch (e) {

    // ignore: use_build_context_synchronously, surely this wont cause any issues in the future
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(e.message ?? 'Registration failed'),
      ),
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
                  Image.asset(
                    'images/logo.jpeg',
                    width: 200,
                    height: 200,
                  ),
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
                  // Add red asterisk to indicate required fields
                  Row (children: [
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
                  Row (children: [
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
                  Row (children: [
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
                  Row (children: [
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
                            TermsAndConditionsprovider.instance.value = newValue ?? false;
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
                        backgroundColor: const Color.fromARGB(255, 255, 255, 255),
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
                          MaterialPageRoute(builder: (context) => const MyLoginPage()),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromARGB(255, 255, 255, 255),
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
