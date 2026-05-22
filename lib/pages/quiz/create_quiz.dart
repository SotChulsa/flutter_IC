import 'package:flutter/material.dart';

class CreateQuizPage extends StatefulWidget {
  const CreateQuizPage({super.key});

  @override
  State<CreateQuizPage> createState() => _CreateQuizPageState();
}

class _CreateQuizPageState extends State<CreateQuizPage> {
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
                      value: 'Mathematics',

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

                      items: const [
                        DropdownMenuItem(
                          value: 'Mathematics',
                          child: Text('Mathematics'),
                        ),

                        DropdownMenuItem(
                          value: 'Science',
                          child: Text('Science'),
                        ),

                        DropdownMenuItem(
                          value: 'History',
                          child: Text('History'),
                        ),
                      ],

                      onChanged: (value) {},
                    ),

                    const SizedBox(height: 28),

                    // NEXT BUTTON
                    Center(
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF52DB69), Color(0xFF1B910D)],

                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          ),

                          borderRadius: BorderRadius.circular(16),
                        ),

                        child: ElevatedButton(
                          onPressed: () {},

                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,

                            shadowColor: Colors.transparent,

                            foregroundColor: Colors.white,

                            padding: const EdgeInsets.symmetric(
                              horizontal: 42,
                              vertical: 20,
                            ),

                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),

                          child: const Text('Next'),
                        ),
                      ),
                    ),
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
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,

                      children: [
                        const Text(
                          'Questions (1)',

                          style: TextStyle(
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
                            onPressed: () {},

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

                    // QUESTION CARD
                    Container(
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
                          const Text(
                            'Question 1',

                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          const SizedBox(height: 24),

                          const Text('Question Text*'),

                          const SizedBox(height: 10),

                          TextField(
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

                          answerField('Answer A'),

                          const SizedBox(height: 14),

                          answerField('Answer B'),

                          const SizedBox(height: 14),

                          answerField('Answer C'),

                          const SizedBox(height: 14),

                          answerField('Answer D'),
                        ],
                      ),
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

                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF52DB69), Color(0xFF1B910D)],
                        ),

                        borderRadius: BorderRadius.circular(14),
                      ),

                      child: ElevatedButton(
                        onPressed: () {},

                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,

                          shadowColor: Colors.transparent,

                          foregroundColor: Colors.white,

                          padding: const EdgeInsets.symmetric(vertical: 20),

                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),

                        child: const Text('Publish Quiz'),
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

  Widget answerField(String hint) {
    return TextField(
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
