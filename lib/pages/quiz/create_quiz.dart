// ignore_for_file: use_build_context_synchronously, deprecated_member_use

import 'package:flutter/material.dart';
import 'package:fluttergame_ic/config/services/quiz_service.dart';

class CreateQuizPage extends StatefulWidget {
  const CreateQuizPage({super.key, this.quizId, this.existingQuiz});
  final String?
  quizId; // If null, we're creating a new quiz. If not null, we're editing an existing quiz.
  final Map<String, dynamic>? existingQuiz;
  @override
  State<CreateQuizPage> createState() => _CreateQuizPageState();
}

class _CreateQuizPageState extends State<CreateQuizPage> {
  final TextEditingController titleController = TextEditingController();
  final TextEditingController questionController = TextEditingController();
  final TextEditingController optionAController = TextEditingController();
  final TextEditingController optionBController = TextEditingController();
  final TextEditingController optionCController = TextEditingController();
  final TextEditingController optionDController = TextEditingController();
  final List<String> categories = [
    'Mathematics',
    'Science',
    'History',
    'Biology',
    'Computer',
    'English',
  ];
  String? selectedCategory = 'Mathematics';
  List<Map<String, dynamic>> questions = [
    {
      'questionController': TextEditingController(),
      'optionAController': TextEditingController(),
      'optionBController': TextEditingController(),
      'optionCController': TextEditingController(),
      'optionDController': TextEditingController(),
    },
  ];

  @override
  void initState() {
    super.initState();

    // default first empty question
    if (questions.isEmpty) {
      questions.add({
        'questionController': TextEditingController(),
        'optionAController': TextEditingController(),
        'optionBController': TextEditingController(),
        'optionCController': TextEditingController(),
        'optionDController': TextEditingController(),
      });
    }

    // edit mode
    if (widget.existingQuiz != null) {
      titleController.text = widget.existingQuiz!['title'] ?? '';
      selectedCategory = widget.existingQuiz!['category'] ?? 'Mathematics';
      final loadedQuestions = List<Map<String, dynamic>>.from(
        widget.existingQuiz!['questions'] ?? [],
      );

      //clear default question
      questions.clear();
      //convert firebase data into controllers
      for (var question in loadedQuestions) {
        final options = List<String>.from(question['options'] ?? []);
        questions.add({
          'questionController': TextEditingController(
            text: question['questionText'] ?? '',
          ),
          'optionAController': TextEditingController(
            text: options.isNotEmpty ? options[0] : '',
          ),
          'optionBController': TextEditingController(
            text: options.length > 1 ? options[1] : '',
          ),
          'optionCController': TextEditingController(
            text: options.length > 2 ? options[2] : '',
          ),
          'optionDController': TextEditingController(
            text: options.length > 3 ? options[3] : '',
          ),
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FB),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // BACK BUTTON
              Row(
                children: [
                  IconButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    icon: const Icon(Icons.arrow_back_ios_new_rounded),
                  ),
                  const Text(
                    'Back to Dashboard',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              // QUIZ INFORMATION CONTAINER
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(32),
                  border: Border.all(color: const Color(0xFF52DB69), width: 2),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Quiz Information',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 28),
                    // QUIZ TITLE
                    const Text(
                      'Quiz Title*',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: titleController,
                      groupId: DropdownButton<String>(
                        value: selectedCategory,
                        items: categories.map((category) {
                          return DropdownMenuItem(
                            value: category,
                            child: Text(category),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            selectedCategory = value!;
                          });
                        },
                      ),
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 16,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: Color(0xFF52DB69),
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),

                          borderSide: const BorderSide(
                            color: Color(0xFF52DB69),
                            width: 2,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    // CATEGORY
                    const Text(
                      'Category*',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 10),
                    DropdownButtonFormField<String>(
                      value: selectedCategory,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.white,
                        prefixIcon: const Icon(
                          Icons.sell_rounded,
                          color: Colors.black,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: Color(0xFF52DB69),
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: Color(0xFF52DB69),
                            width: 2,
                          ),
                        ),
                      ),

                      items: categories.map((category) {
                        return DropdownMenuItem(
                          value: category,
                          child: Text(category),
                        );
                      }).toList(),

                      onChanged: (value) {
                        setState(() {
                          selectedCategory = value;
                        });
                      },
                    ),
                    const SizedBox(height: 28),
                  ],
                ),
              ),

              const SizedBox(height: 28),
              // QUESTIONS CONTAINER
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(32),
                  border: Border.all(color: const Color(0xFF52DB69), width: 2),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // top row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Questions (${questions.length})',
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        Container(
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF52DB69), Color(0xFF1B910D)],
                            ),
                            borderRadius: BorderRadius.circular(14),
                          ),

                          child: ElevatedButton(
                            onPressed: () {
                              setState(() {
                                questions.add({
                                  'questionController': TextEditingController(),
                                  'optionAController': TextEditingController(),
                                  'optionBController': TextEditingController(),
                                  'optionCController': TextEditingController(),
                                  'optionDController': TextEditingController(),
                                });
                              });
                            },

                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              shadowColor: Colors.transparent,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            child: const Text('+ Add Question'),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    //dynamic question cards
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: questions.length,
                      itemBuilder: (context, index) {
                        return Container(
                          margin: const EdgeInsets.only(bottom: 20),
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(28),
                            border: Border.all(
                              color: const Color(0xFF52DB69),
                              width: 2,
                            ),
                          ),

                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Question ${index + 1}',
                                    style: const TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),

                                  IconButton(
                                    onPressed: () {
                                      setState(() {
                                        questions.removeAt(index);
                                      });
                                    },
                                    icon: const Icon(Icons.delete),
                                  ),
                                ],
                              ),

                              const SizedBox(height: 24),
                              const Text('Question Text*'),
                              const SizedBox(height: 10),

                              TextField(
                                controller:
                                    questions[index]['questionController'],
                                decoration: InputDecoration(
                                  hintText: 'Enter text here',
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: const BorderSide(
                                      color: Color(0xFF52DB69),
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: const BorderSide(
                                      color: Color(0xFF52DB69),
                                      width: 2,
                                    ),
                                  ),
                                ),
                              ),

                              const SizedBox(height: 24),
                              const Text('Answer Options*'),
                              const SizedBox(height: 16),
                              answerField(
                                'Answer A',
                                questions[index]['optionAController'],
                              ),
                              const SizedBox(height: 14),
                              answerField(
                                'Answer B',
                                questions[index]['optionBController'],
                              ),
                              const SizedBox(height: 14),
                              answerField(
                                'Answer C',
                                questions[index]['optionCController'],
                              ),
                              const SizedBox(height: 14),
                              answerField(
                                'Answer D',
                                questions[index]['optionDController'],
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 28),
              // BOTTOM BUTTONS
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey.shade300,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),

                      child: const Text('Save as Draft'),
                    ),
                  ),
                  const SizedBox(width: 16),

                  //Container for quiz titles
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF52DB69), Color(0xFF1B910D)],
                        ),
                        borderRadius: BorderRadius.circular(14),
                      ),

                      child: ElevatedButton(
                        onPressed: () async {
                          if (titleController.text.trim().isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Please enter a quiz title'),
                              ),
                            );
                            return;
                          }
                          //CREATE
                          List<Map<String, dynamic>> questionsData = questions
                              .map((question) {
                                return {
                                  'questionText': question['questionController']
                                      .text
                                      .trim(),
                                  'options': [
                                    question['optionAController'].text.trim(),
                                    question['optionBController'].text.trim(),
                                    question['optionCController'].text.trim(),
                                    question['optionDController'].text.trim(),
                                  ],
                                  'correctAnswer': question['optionAController']
                                      .text
                                      .trim(),
                                };
                              })
                              .toList();

                          //CREATE
                          if (widget.quizId == null) {
                            await QuizService().createQuiz(
                              title: titleController.text.trim(),
                              category: selectedCategory!,
                              questions: questionsData,
                              isPublished: true,
                            );
                          }
                          //UPDATE
                          else {
                            await QuizService().updateQuiz(
                              quizId: widget.quizId!,
                              updatedTitle: titleController.text.trim(),
                              updatedCategory: selectedCategory!,
                              updatedQuestions: questionsData,
                            );
                          }
                          Navigator.pop(context);
                        },
                        //Actions for Publishing and updating quizzes
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 20),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: Text(
                          widget.quizId == null
                              ? 'Publish Quiz'
                              : 'Update Quiz',
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  //border for the page
  Widget answerField(String hint, TextEditingController controller) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: const Icon(
          Icons.circle_outlined,
          size: 18,
          color: Colors.grey,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF52DB69)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF52DB69), width: 2),
        ),
      ),
    );
  }
}
