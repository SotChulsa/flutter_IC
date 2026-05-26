// ignore_for_file: use_build_context_synchronously, avoid_print, deprecated_member_use

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fluttergame_ic/pages/profile/result_page.dart';
import 'dart:typed_data';
import 'package:image_picker/image_picker.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  Uint8List? selectedImageBytes;
  final ImagePicker picker = ImagePicker();
  final currentUser = FirebaseAuth.instance.currentUser;
  bool isLoading = true;
  //firebase data
  String fullName = '';
  String email = '';
  String bio = '';
  String role = '';
  int quizzesCompleted = 0;
  int accuracyRate = 0;
  int dailyGoal = 3;
  int todayCompletedQuizzes = 0;
  int totalCorrectAnswers = 0;
  int totalQuestionsAnswered = 0;
  bool emailNotification = true;
  List<String> selectedCategories = [];
  String profileImage = '';
  final List<String> categories = [
    'Mathematics',
    'Science',
    'History',
    'Biology',
    'English',
    'Computers',
  ];

  //controllers
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController bioController = TextEditingController();

  Future<void> getUserData() async {
    try {
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser!.uid)
          .get();
      if (userDoc.exists) {
        final data = userDoc.data()!;
        final completedCount = await FirebaseFirestore.instance
            .collection('results')
            .where('userId', isEqualTo: currentUser!.uid)
            .get();

        final totalCompleted = completedCount.docs.length;
        setState(() {
          fullName = data['fullName'] ?? '';
          email = data['email'] ?? '';
          bio = data['bio'] ?? '';
          role = data['role'] ?? 'user';
          quizzesCompleted = totalCompleted;
          accuracyRate = data['accuracyRate'] ?? 0;
          emailNotification = data['notifications'] ?? true;
          selectedCategories = List<String>.from(
            data['selectedCategories'] ?? [],
          );
          profileImage = data['profileImage'] ?? '';
          //Fill controllers
          firstNameController.text = data['firstName'] ?? '';
          lastNameController.text = data['lastName'] ?? '';
          emailController.text = data['email'] ?? '';
          bioController.text = data['bio'] ?? '';
          dailyGoal = data['dailyGoal'] ?? 3;
          totalCorrectAnswers = data['totalCorrectAnswers'] ?? 0;
          totalQuestionsAnswered = data['totalQuestionsAnswered'] ?? 0;
          isLoading = false;
        });
      }
    } catch (e) {
      print(e);

      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> loadDailyProgress() async {
    final completed = await getTodayCompletedQuizzes();
    setState(() {
      todayCompletedQuizzes = completed;
    });
  }

  Future<int> getTodayCompletedQuizzes() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return 0;
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    final snapshot = await FirebaseFirestore.instance
        .collection('results')
        .where('userId', isEqualTo: user.uid)
        .where(
          'completedAt',
          isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay),
        )
        .get();
    return snapshot.docs.length;
  }

  @override
  void initState() {
    super.initState();
    getUserData();
    loadDailyProgress();
  }

  Future<void> pickImage() async {
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image == null) return;
    //read images as bytes
    Uint8List imageBytes = await image.readAsBytes();
    //convert to base64
    String base64Image = base64Encode(imageBytes);
    //save to the database
    await FirebaseFirestore.instance
        .collection('users')
        .doc(currentUser!.uid)
        .update({'profileImage': base64Image});
    //update profile ui to show the image
    setState(() {
      selectedImageBytes = imageBytes;
      profileImage = base64Image;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.black,
        title: const Text(
          'Exit Profile',
          style: TextStyle(fontWeight: FontWeight.w500),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            //Profile
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                border: Border.all(
                  color: const Color.fromARGB(255, 97, 241, 105),
                  width: 2,
                ),
                borderRadius: BorderRadius.circular(28),
                color: Colors.white,
              ),
              child: Column(
                children: [
                  //Profile image
                  Stack(
                    children: [
                      CircleAvatar(
                        radius: 40,
                        backgroundColor: Colors.white,
                        backgroundImage:
                            //Newly selected image
                            selectedImageBytes != null
                            ? MemoryImage(selectedImageBytes!)
                            //Saved firestore image
                            : profileImage.isNotEmpty
                            ? MemoryImage(base64Decode(profileImage))
                            : null,
                        child:
                            selectedImageBytes == null && profileImage.isEmpty
                            ? const Icon(
                                Icons.person_outline,
                                size: 60,
                                color: Colors.black,
                              )
                            : null,
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: IconButton(
                            icon: const Icon(
                              Icons.camera_alt_outlined,
                              size: 18,
                            ),
                            onPressed: () async {
                              await pickImage();
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  Text(
                    fullName,
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  Text(role, style: TextStyle(color: Colors.grey)),
                  const SizedBox(height: 24),

                  //Email
                  Row(
                    children: [
                      Icon(Icons.email_outlined),
                      SizedBox(width: 12),
                      Text(email),
                    ],
                  ),
                  const SizedBox(height: 16),

                  //john date
                  const Row(
                    children: [
                      Icon(Icons.calendar_month_outlined),
                      SizedBox(width: 12),
                      Text('Joined February 2026'),
                    ],
                  ),
                  const SizedBox(height: 16),

                  //Completed quiz stats
                  StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('results')
                        .where(
                          'userId',
                          isEqualTo: FirebaseAuth.instance.currentUser!.uid,
                        )
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Row(
                          children: [
                            Icon(Icons.emoji_events_outlined),
                            SizedBox(width: 12),
                            Text('Loading...'),
                          ],
                        );
                      }

                      //Error state when flutter fails to fetch data
                      if (snapshot.hasError) {
                        return const Row(
                          children: [
                            Icon(Icons.error_outline),
                            SizedBox(width: 12),
                            Text('Error loading quizzes'),
                          ],
                        );
                      }
                      final quizzesCompleted = snapshot.data?.docs.length ?? 0;
                      return Row(
                        children: [
                          const Icon(Icons.emoji_events_outlined),
                          const SizedBox(width: 12),
                          Text('Completed $quizzesCompleted Quizzes'),
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
            const SizedBox(height: 24),

            //Quick states
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                border: Border.all(
                  color: const Color.fromARGB(255, 97, 241, 105),
                  width: 2,
                ),
                borderRadius: BorderRadius.circular(28),
                color: Colors.white,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Quick Stats',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                  ),
                  const SizedBox(height: 16),

                  //checks how many quizzes the current user completed today, then compares it to their daily goal.
                  buildStatRow('Total Quizzes', quizzesCompleted.toString()),
                  buildStatRow('Accuracy Rate', '$accuracyRate%'),
                  StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('results')
                        .where(
                          'userId',
                          isEqualTo: FirebaseAuth.instance.currentUser!.uid,
                        )
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return buildStatRow('Daily Goal', '0 / $dailyGoal');
                      }
                      final now = DateTime.now();
                      final todayResults = snapshot.data!.docs.where((doc) {
                        final completedAt = (doc['completedAt'] as Timestamp)
                            .toDate();
                        return completedAt.year == now.year &&
                            completedAt.month == now.month &&
                            completedAt.day == now.day;
                      }).length;
                      return buildStatRow(
                        'Daily Goal',
                        '${todayResults > dailyGoal ? dailyGoal : todayResults} / $dailyGoal',
                      );
                    },
                  ),
                  const SizedBox(height: 24),

                  Center(
                    child: SizedBox(
                      width: 150,
                      height: 45,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const ResultPage(),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green[200],
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text('Results'),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            //Account settings
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                border: Border.all(
                  color: const Color.fromARGB(255, 97, 241, 105),
                  width: 2,
                ),
                borderRadius: BorderRadius.circular(28),
                color: Colors.white,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Account Settings',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
                  ),
                  const SizedBox(height: 20),

                  const Text(
                    'Personal Information',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),

                  //firt and last name row
                  Row(
                    children: [
                      Expanded(
                        child: buildTextField(
                          label: 'First Name',
                          controller: firstNameController,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: buildTextField(
                          label: 'Last Name',
                          controller: lastNameController,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  //Email
                  buildTextField(label: 'Email', controller: emailController),
                  const SizedBox(height: 16),

                  //Biography
                  buildTextField(
                    label: 'Bio',
                    controller: bioController,
                    maxLines: 4,
                  ),
                  const SizedBox(height: 28),

                  //Learning preferences
                  const Text(
                    'Learning Preferences',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),

                  const Text(
                    'Preferred Categories',
                    style: TextStyle(fontSize: 13, color: Colors.grey),
                  ),
                  const SizedBox(height: 12),
                  //code for selecting categories
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: categories.map((category) {
                      final isSelected = selectedCategories.contains(category);
                      return FilterChip(
                        label: Text(
                          category,
                          style: TextStyle(
                            color: isSelected ? Colors.black : Colors.black,
                          ),
                        ),
                        selected: isSelected,
                        backgroundColor: const Color.fromARGB(
                          255,
                          255,
                          255,
                          255,
                        ),
                        selectedColor: Colors.greenAccent,
                        checkmarkColor: Colors.black,
                        onSelected: (value) {
                          setState(() {
                            if (value) {
                              selectedCategories.add(category);
                            } else {
                              selectedCategories.remove(category);
                            }
                          });
                        },
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 24),

                  //Daily quiz goals button
                  const Text(
                    'Daily Quiz Goal',
                    style: TextStyle(fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 10),

                  DropdownButtonFormField<int>(
                    value: dailyGoal,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: const Color.fromARGB(255, 97, 241, 105),
                        ),
                      ),
                    ),
                    items: [1, 3, 5, 10].map((goal) {
                      return DropdownMenuItem<int>(
                        value: goal,

                        child: Text('$goal quizzes per day'),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        //Save quiz goal to Firestore
                        dailyGoal = value!;
                      });
                    },
                  ),
                  const SizedBox(height: 24),

                  //Email notification
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color.fromARGB(255, 224, 255, 229),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: const Color.fromARGB(255, 97, 241, 105),
                        width: 2.5,
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Email Notification',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            SizedBox(height: 4),

                            Text(
                              'Receive quiz reminders and achievements',
                              style: TextStyle(
                                fontSize: 12,
                                color: Color.fromARGB(255, 0, 0, 0),
                              ),
                            ),
                          ],
                        ),
                        Switch(
                          value: emailNotification,
                          onChanged: (value) {
                            setState(() {
                              //Save notification setting to Firestore
                              emailNotification = value;
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 28),

                  //Save or cancel changes button
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () async {
                            await FirebaseFirestore.instance
                                .collection('users')
                                .doc(currentUser!.uid)
                                .update({
                                  'firstName': firstNameController.text.trim(),
                                  'lastName': lastNameController.text.trim(),
                                  'fullName':
                                      '${firstNameController.text.trim()} ${lastNameController.text.trim()}',
                                  'email': emailController.text.trim(),
                                  'bio': bioController.text.trim(),
                                  'dailyGoal': dailyGoal,
                                  'selectedCategories': selectedCategories,
                                  'notifications': emailNotification,
                                });
                            //refresh page
                            await getUserData();
                            //update the frontend
                            setState(() {
                              fullName =
                                  '${firstNameController.text.trim()} ${lastNameController.text.trim()}';
                              email = emailController.text.trim();
                              bio = bioController.text.trim();
                            });
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Changes saved successfully'),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                            minimumSize: const Size(0, 50),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          child: const Text('Save Changes'),
                        ),
                      ),
                      const SizedBox(width: 12),

                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            //Reset fields or navigate back
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.grey[300],
                            foregroundColor: Colors.black,
                            minimumSize: const Size(0, 50),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          child: const Text('Cancel'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        try {
                          //Get current user
                          final currentUser = FirebaseAuth.instance.currentUser;
                          //update Firestore status
                          if (currentUser != null) {
                            await FirebaseFirestore.instance
                                .collection('users')
                                .doc(currentUser.uid)
                                .update({
                                  'isOnline': false,
                                  'lastActive': FieldValue.serverTimestamp(),
                                });
                          }
                          //Logout from Firebase Auth
                          await FirebaseAuth.instance.signOut();
                          //Navigate back to login
                          if (!context.mounted) return;
                          Navigator.pushNamedAndRemoveUntil(
                            context,
                            '/login',
                            (route) => false,
                          );
                        } catch (e) {
                          print('Logout Error: $e');
                        }
                      },
                      icon: const Icon(Icons.logout),
                      label: const Text(
                        'Logout',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  //Resuable stats field
  Widget buildStatRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  //Reusable texts
  Widget buildTextField({
    required String label,
    required TextEditingController controller,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 13)),
        const SizedBox(height: 6),

        TextField(
          controller: controller,
          maxLines: maxLines,
          decoration: InputDecoration(
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            filled: true,
            fillColor: Colors.white,
          ),
        ),
      ],
    );
  }
}
