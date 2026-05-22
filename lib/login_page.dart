import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fluttergame_ic/password.dart';
import 'register_page.dart';
import 'package:google_sign_in/google_sign_in.dart';

class MyLoginPage extends StatefulWidget {
  const MyLoginPage({super.key});

  @override
  State<MyLoginPage> createState() => _MyLoginPageState();
}

//This helps change the state of the remember me checkbox
class RememberMe {
  bool value = false;
}

//Google Sign-In Provider
Future<UserCredential?> signInWithGoogle() async {
  try {
    // WEB
    if (kIsWeb) {
      GoogleAuthProvider googleProvider = GoogleAuthProvider();

      return await FirebaseAuth.instance.signInWithPopup(googleProvider);
    }

    // ANDROID / IOS
    final GoogleSignIn googleSignIn = GoogleSignIn.instance;
    await googleSignIn.initialize(
      clientId:
          '108723258802-hqieffurfoamcilkajackt5uf66vpfrl.apps.googleusercontent.com',
    );

    final GoogleSignInAccount googleUser = await googleSignIn.authenticate();
    final GoogleSignInAuthentication googleAuth = googleUser.authentication;
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );
    return await FirebaseAuth.instance.signInWithCredential(credential);
  } catch (e) {
    // ignore: avoid_print, this is for debugging purposes
    print("Google Sign-In error: $e");
    return null;
  }
}

extension on GoogleSignInAuthentication {
  String? get accessToken => null;
}

class RememberMeProvider {
  static final RememberMe _instance = RememberMe();
  static RememberMe get instance => _instance;
}

// ignore: camel_case_types, this means ignore the fact that the class name is not in Upper Case
class decoration {
  static const BoxDecoration boxDecoration = BoxDecoration(
    gradient: LinearGradient(
      colors: [
        Color.fromARGB(255, 108, 255, 59),
        Color.fromARGB(255, 255, 255, 255),
      ],
      stops: [0.0, 1.0],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    borderRadius: BorderRadius.all(Radius.circular(10)),
  );
}

class _MyLoginPageState extends State<MyLoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  //PUT THE FUNCTION HERE
  Future<void> signIn() async {
    try {
      UserCredential userCredential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(
            email: _emailController.text.trim(),
            password: _passwordController.text.trim(),
          );
      // GET USER ROLE
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userCredential.user!.uid)
          .get();

      String role = doc['role'];

      if (role == 'admin') {
        debugPrint('Logged in as ADMIN');
        ScaffoldMessenger.of(
          //ignore: use_build_context_synchronously, this is for showing a snackbar after login
          context,
        ).showSnackBar(const SnackBar(content: Text('Logged in as ADMIN')));
      } else {
        debugPrint('Logged in as USER');
        ScaffoldMessenger.of(
          //ignore: use_build_context_synchronously, this is for showing a snackbar after login
          context,
        ).showSnackBar(const SnackBar(content: Text('Logged in as USER')));
      }
    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(
        //ignore: use_build_context_synchronously, this is for showing a snackbar after login failure
        context,
      ).showSnackBar(SnackBar(content: Text(e.message ?? 'Login failed')));
    } catch (e) {
      ScaffoldMessenger.of(
        //ignore: use_build_context_synchronously, this is for showing a snackbar after unexpected error
        context,
      ).showSnackBar(const SnackBar(content: Text('Unexpected error')));
    }
  }

  Future<UserCredential?> signInWithGoogle() async {
    try {
      //WEB
      if (kIsWeb) {
        GoogleAuthProvider googleProvider = GoogleAuthProvider();

        return await FirebaseAuth.instance.signInWithPopup(googleProvider);
      }
      //ANDROID/IOS
      final GoogleSignIn googleSignIn = GoogleSignIn.instance;
      await googleSignIn.initialize();
      final GoogleSignInAccount googleUser = await googleSignIn.authenticate();
      final GoogleSignInAuthentication googleAuth = googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      return await FirebaseAuth.instance.signInWithCredential(credential);
    } catch (e) {
      debugPrint("Google Sign-In error: $e");
      return null;
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color.fromARGB(255, 46, 255, 23),
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
                    'Login',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.bold,
                      fontSize: 36,
                      color: Color(0xFF1C1C1C),
                    ),
                  ),
                  const SizedBox(height: 26),
                  //Add a red asterick next to the email and password text fields to indicate that they are required fields
                  Row(
                    children: const [
                      Text(
                        'Email',
                        style: TextStyle(
                          fontSize: 16,
                          color: Color(0xFF1C1C1C),
                        ),
                      ),
                      SizedBox(width: 4),
                      Image(
                        image: AssetImage('images/required_asterick.png'),
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
                      // Change border radius to 20
                      filled: true,
                      fillColor: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: const [
                      Text(
                        'Password',
                        style: TextStyle(
                          fontSize: 16,
                          color: Color(0xFF1C1C1C),
                        ),
                      ),
                      SizedBox(width: 4),
                      Image(
                        image: AssetImage('images/required_asterick.png'),
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
                      // Change border radius to 20
                      filled: true,
                      fillColor: Colors.white,
                    ),
                    obscureText: true,
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Checkbox(
                            value: RememberMeProvider.instance.value,
                            onChanged: (newValue) {
                              setState(() {
                                RememberMeProvider.instance.value =
                                    newValue ?? false;
                              });
                            },
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            'Remember me',
                            style: TextStyle(
                              fontSize: 14,
                              color: Color.fromARGB(255, 0, 0, 0),
                            ),
                          ),
                        ],
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const ForgotPassword(),
                            ),
                          );
                        },
                        child: const Text(
                          'Forgot Password?',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 14,
                            color: Color.fromARGB(255, 28, 190, 249),
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 26),
                  SizedBox(
                    width: double.infinity,
                    height: 49,
                    child: ElevatedButton(
                      onPressed: signIn,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromARGB(
                          255,
                          255,
                          255,
                          255,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                          // Create border ouline for the button
                          side: const BorderSide(
                            color: Color.fromARGB(255, 0, 0, 0),
                            width: 1,
                          ),
                        ),
                      ),
                      child: const Text(
                        'Login',
                        style: TextStyle(
                          color: Color.fromARGB(255, 0, 0, 0),
                          fontSize: 16,
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    height: 49,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const MyRegisterPage(),
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
                          // Create border ouline for the button
                          side: const BorderSide(
                            color: Color.fromARGB(255, 0, 0, 0),
                            width: 1,
                          ),
                        ),
                      ),
                      child: const Text(
                        'Create an account',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 16,
                          color: Color.fromARGB(255, 0, 0, 0),
                        ),
                      ),
                    ),
                  ),
                  // Add a or continue with Google Sign-In option line before the Google Sign-In button
                  const SizedBox(height: 16),
                  Row(
                    children: const [
                      Expanded(
                        child: Divider(color: Color(0xFF87879D), thickness: 1),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 8.0),
                        child: Text(
                          'or continue with',
                          style: TextStyle(
                            fontSize: 14,
                            color: Color(0xFF87879D),
                          ),
                        ),
                      ),
                      Expanded(
                        child: Divider(color: Color(0xFF87879D), thickness: 1),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    height: 49,
                    child: ElevatedButton(
                      onPressed: () async {
                        final userCredential = await signInWithGoogle();
                        if (userCredential != null) {
                          //ignore: avoid_print, this is for debugging purposes and will be removed later
                          print("Login Success");
                        } else {
                          //ignore: avoid_print, this is for debugging purposes and will be removed later
                          print("Login Failed");
                        }
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
                      child: const Image(
                        image: AssetImage('images/google.png'),
                        width: 24,
                        height: 24,
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
