import 'dart:async';

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'dart:io';
import 'package:multi_select_flutter/multi_select_flutter.dart';

class LessonPlanGenerator extends StatefulWidget {
  final String jobTitle;
  final List<dynamic> interestsList;
  final String bio;

  const LessonPlanGenerator(
      {Key? key,
      required this.jobTitle,
      required this.interestsList,
      required this.bio})
      : super(key: key);

  @override
  _LessonPlanGeneratorState createState() => _LessonPlanGeneratorState();
}

class _LessonPlanGeneratorState extends State<LessonPlanGenerator> {
  final _gradeController = TextEditingController();
  final _subjectController = TextEditingController();
  final _timeController = TextEditingController();
  final _messageController = TextEditingController();
  final _apiKey = 'AIzaSyAx72fcPP3jc8cSAmmK5kMSfakjDjq4ouA';

  // Initialize the Gemini model
  late final GenerativeModel _model;

  // Variables
  List<String> _selectedGrades = [];
  List<String> _selectedSubjects = [];
  String _generatedText = '';
  bool _isGenerating = false;

  // Data Lists
  final List<String> gradeLevels = [
    'Kindergarten',
    '1st Grade',
    '2nd Grade',
    '3rd Grade',
    '4th Grade',
    '5th Grade',
    '6th Grade',
    '7th Grade',
    '8th Grade',
    '9th Grade',
    '10th Grade',
    '11th Grade',
    '12th Grade',
  ];

  static const List<String> interests = [
    'Math 🧮',
    'Biology 🧬',
    'History 🏺',
    'English 📚',
    'Computer Science 💻',
    'Chemistry 🧪',
    'Business/Econ 💸',
    'Studio Art 🧑‍🎨',
    'Performing Arts 🎼',
    'Elementary Education 🏫',
    'Engineering ⚙️',
    'Social Justice ⚖️',
    'Human Health 🧑🏽‍⚕️'
  ];

  @override
  void initState() {
    super.initState();
    print('Hello my api key is:$_apiKey');
    if (_apiKey.isEmpty) {
      throw Exception(
          'API_KEY not found. Please set the API_KEY environment variable.');
    }
    _model = GenerativeModel(
      model: 'gemini-1.5-flash',
      apiKey: _apiKey,
    );
  }

  @override
  void dispose() {
    _gradeController.dispose();
    _subjectController.dispose();
    _timeController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Lesson Plan Generator'),
          backgroundColor: Colors.blue,
        ),
        body: Container(
          color: Colors.grey[100],
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                MultiSelectDialogField(
                  items: gradeLevels
                      .map((grade) => MultiSelectItem<String>(grade, grade))
                      .toList(),
                  title: Text('Select Grades'),
                  selectedColor: Colors.indigo,
                  decoration: BoxDecoration(
                    color: Colors.indigo.withOpacity(0.1),
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                    border: Border.all(color: Colors.grey),
                  ),
                  buttonIcon: Icon(Icons.school, color: Colors.indigo),
                  buttonText: Text(
                    'Select Grades',
                    style: TextStyle(color: Colors.grey[800], fontSize: 13),
                  ),
                  onConfirm: (results) {
                    setState(() {
                      _selectedGrades = List<String>.from(results);
                    });
                  },
                ),
                SizedBox(height: 16),
                Text(
                  'Select Subjects:',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 10),
                Wrap(
                  spacing: 6.0,
                  runSpacing: 1.0,
                  children: interests.map((subject) {
                    final isSelected = _selectedSubjects.contains(subject);
                    return FilterChip(
                      label: Text(
                        subject,
                        style: TextStyle(fontSize: 12),
                      ),
                      selected: isSelected,
                      selectedColor: Colors.indigo.withOpacity(0.2),
                      onSelected: (bool selected) {
                        setState(() {
                          if (selected) {
                            _selectedSubjects.add(subject);
                          } else {
                            _selectedSubjects.remove(subject);
                          }
                        });
                      },
                    );
                  }).toList(),
                ),
                SizedBox(height: 16),
                SizedBox(
                  width: 400,
                  height: 40,
                  child: TextFormField(
                    controller: _timeController,
                    decoration: InputDecoration(
                      labelStyle: TextStyle(fontSize: 13),
                      labelText: 'Class Time (minutes)',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ),
                SizedBox(height: 16),
                SizedBox(
                  child: TextFormField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      labelStyle: TextStyle(fontSize: 13),
                      labelText: 'Description of lesson plan',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 3,
                  ),
                ),
                SizedBox(height: 24),
                Center(
                  child: ElevatedButton(
                    onPressed: _isGenerating ? null : _generateLessonPlan,
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(
                          horizontal: 20.0, vertical: 11.0),
                      backgroundColor: Colors.indigo,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: Text('Generate',
                        style: TextStyle(fontSize: 16, color: Colors.white)),
                  ),
                ),
                SizedBox(height: 24),
                if (_generatedText.isNotEmpty) _buildGeneratedText(),
                if (_generatedText.isNotEmpty) _buildExportOptions(),
              ],
            ),
          ),
        ));
  }

  Widget _buildGeneratedText() {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.only(bottom: 24.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey),
      ),
      padding: EdgeInsets.all(16.0),
      child: SingleChildScrollView(
        child: Text(
          _generatedText,
          style: TextStyle(fontSize: 16),
        ),
      ),
    );
  }

  Widget _buildExportOptions() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        IconButton(
          iconSize: 48,
          icon: Image.asset('assets/gmail.png'),
          onPressed: _exportToGmail,
          tooltip: 'Export to Gmail',
        ),
        IconButton(
          iconSize: 48,
          icon: Image.asset('assets/google_classroom.jpg'),
          onPressed: _exportToGoogleClassroom,
          tooltip: 'Export to Google Classroom',
        ),
      ],
    );
  }

  // TODO: Implement the methods below
  void _generateLessonPlan() async {
    if (_selectedGrades.isEmpty || _selectedSubjects.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Please select at least one grade and subject.')),
      );
      return;
    }

    setState(() {
      _isGenerating = true;
      _generatedText = '';
    });

    final grades = _selectedGrades.join(', ');
    final subjects = _selectedSubjects.join(', ');
    final time = _timeController.text;
    final message = _messageController.text;
    final jobTitle = widget.jobTitle;
    final interestsList = widget.interestsList;

    final prompt = '''
I am a teacher, and today we are hosting an industry expert, who is a $jobTitle who is an expert in the following topics: $interestsList.
Accompanying their visit today, I would like to have a really nice lesson plan that lasts $time minutes.
It should be appropriate and targeted to $grades grade(s) $subjects class. Here is a quick note on what I want to focus on: $message
Finally ensure that the lesson plan has the following components: a warmup activity, a lesson followed by an interesting, related activity, questions for the speaker, and finally a closing fun activity to finish off!
Please make sure the lesson plan uses bullets and does not exceed 300 words.
''';

    try {
      // Set a timeout duration (e.g., 10 seconds)
      final response = await _model.generateContent(
          [Content.text(prompt)]).timeout(Duration(seconds: 10));

      // Set the generated text all at once
      setState(() {
        _generatedText = response.text ?? 'No text was generated.';
      });
    } on TimeoutException catch (_) {
      // Handle the timeout exception
      setState(() {
        _generatedText = 'The request timed out. Please try again.';
      });
    } catch (e) {
      setState(() {
        _generatedText = 'Error generating lesson plan: $e';
      });
    } finally {
      setState(() {
        _isGenerating = false;
      });
    }
  }

  void _exportToGmail() async {
    final subject = Uri.encodeComponent('Lesson Plan');
    final body = Uri.encodeComponent(_generatedText);
    final url = 'mailto:?subject=$subject&body=$body';

    if (await canLaunch(url)) {
      await launch(url);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not open email client.')),
      );
    }
  }

  void _exportToGoogleClassroom() {}
}

class BlinkingDots extends StatefulWidget {
  @override
  _BlinkingDotsState createState() => _BlinkingDotsState();
}

class _BlinkingDotsState extends State<BlinkingDots>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<int> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 900),
    )..repeat();
    _animation = StepTween(begin: 0, end: 3).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    String dots = '.' * (_animation.value % 4);
    return Text('Generating$dots',
        style: TextStyle(fontSize: 16, color: Colors.white));
  }
}

// Placeholder for UserData class
class UserData {
  @override
  String toString() {
    // Return a string representation of userData
    return '';
  }
}
