// ignore_for_file: use_build_context_synchronously
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fluttergame_ic/pages/auth/check_auth.dart';
import 'package:fluttergame_ic/pages/auth/password.dart';
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
      serverClientId:
          "108723258802-hqieffurfoamcilkajackt5uf66vpfrl.apps.googleusercontent.com",
    );

    // Authenticate user with Google Sign-In
    final GoogleSignInAccount googleUser = await googleSignIn.authenticate();
    // Get the authentication details from the Google Sign-In process
    final GoogleSignInAuthentication googleAuth = googleUser.authentication;
    // Create a new credential using the authentication details obtained from Google Sign-In
    final credential = GoogleAuthProvider.credential(
      idToken: googleAuth.idToken,
    );
    //Returns a UserCredential if the sign-in was successful, or null if it failed
    return await FirebaseAuth.instance.signInWithCredential(credential);
    //error handling, if sign-in fails, print error and return null
  } catch (e) {
    // ignore: avoid_print, this is for debugging purposes and will be removed later
    print("Google Sign-In error: $e");
    return null;
  }
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

//class that represents the login page
class _MyLoginPageState extends State<MyLoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  //PUT THE FUNCTION HERE
  Future<void> signIn() async {
    try {
      //Login user
      UserCredential userCredential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(
            email: _emailController.text.trim(),
            password: _passwordController.text.trim(),
          );
      // Get logged in user
      final user = userCredential.user;
      if (user != null) {
        await AuthService().handleUserLogin(context, user);
      }
      await FirebaseFirestore.instance.collection('users').doc(user?.uid).set({
        'isOnline': true,
        'lastActive': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
      // Create Firestore document if missing
      if (user != null) {
        final userDoc = FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid);
        final snapshot = await userDoc.get();
        // the rare chance that if user exists in Authentication
        // but NOT in Firestore database for some reason, we create a new document for them in Firestore with default values
        if (!snapshot.exists) {
          await userDoc.set({
            'uid': user.uid,
            'email': user.email,
            'username': user.displayName ?? 'User',
            'role': 'user',
            'totalScore': 0,
            'selectedCategory': '',
            'quizzesCompleted': 0,
            'joinedAt': Timestamp.now(),
            'isOnline': true,
          });
        } else {
          //update online status
          await userDoc.update({'isOnline': true});
        }
      }
      //if login is successful, show success message and navigate back to home page
      if (!context.mounted) return;
      //Close login page
      Navigator.pop(context);
    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.message ?? 'Login failed')));
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Unexpected error')));
    }
  }

  Future<UserCredential?> signInWithGoogle() async {
    try {
      UserCredential? userCredential;
      //Webpage login
      if (kIsWeb) {
        GoogleAuthProvider googleProvider = GoogleAuthProvider();
        userCredential = await FirebaseAuth.instance.signInWithPopup(
          googleProvider,
        );
      } else {
        //Andriod/ios login
        final GoogleSignIn googleSignIn = GoogleSignIn.instance;

        await googleSignIn.initialize(
          serverClientId:
              "108723258802-hqieffurfoamcilkajackt5uf66vpfrl.apps.googleusercontent.com",
        );
        //Open google-account picker
        final GoogleSignInAccount googleUser = await googleSignIn
            .authenticate();
        //Get Google authentication tokens
        final GoogleSignInAuthentication googleAuth = googleUser.authentication;
        //Create Firebase credential
        final credential = GoogleAuthProvider.credential(
          idToken: googleAuth.idToken,
        );
        //Login to Firebase
        userCredential = await FirebaseAuth.instance.signInWithCredential(
          credential,
        );
      }
      //User Document Creation
      final user = userCredential.user;
      if (user != null) {
        final userDoc = FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid);
        final docSnapshot = await userDoc.get();
        //Create document if first login
        if (!docSnapshot.exists) {
          await userDoc.set({
            'uid': user.uid,
            'name': user.displayName ?? '',
            'email': user.email ?? '',
            'photoUrl': user.photoURL ?? '',
            'createdAt': FieldValue.serverTimestamp(),
          });
        }
      }
      return userCredential;
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
                  Image.asset(
                    'assets/images/logo.jpeg',
                    width: 200,
                    height: 200,
                  ),
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
                        image: AssetImage(
                          'assets/images/required_asterick.png',
                        ),
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
                        image: AssetImage(
                          'assets/images/required_asterick.png',
                        ),
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
                        //Check if sign-in was successful
                        if (userCredential != null) {
                          final user = userCredential.user;
                          //Check if user document exists in Firestore, if not, create a new document with default values,
                          //this is for users who sign in with Google for the first time,
                          //since they dont have a document in Firestore yet
                          if (user != null) {
                            final userDoc = FirebaseFirestore.instance
                                .collection('users')
                                .doc(user.uid);
                            final snapshot = await userDoc.get();
                            //if user does not exist in Firestore yet
                            if (!snapshot.exists) {
                              await userDoc.set({
                                'uid': user.uid,
                                'email': user.email,
                                'username': user.displayName ?? 'User',
                                'role': 'user',
                                'totalScore': 0,
                                'selectedCategory': '',
                                'quizzesCompleted': 0,
                                'joinedAt': Timestamp.now(),
                                //ACTIVE USER TRACKING
                                'isOnline': true,
                                'lastActive': FieldValue.serverTimestamp(),
                              });
                            } else {
                              //update existing user's online status
                              await userDoc.update({
                                'isOnline': true,
                                'lastActive': FieldValue.serverTimestamp(),
                              });
                            }
                          }
                          if (!context.mounted) return;
                          Navigator.pop(context);
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
                        image: AssetImage('assets/images/google.png'),
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
