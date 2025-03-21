import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:html_unescape/html_unescape.dart';
import 'result_screen.dart';

class QuizScreen extends StatefulWidget {
  const QuizScreen({super.key});

  @override
  _QuizScreenState createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  List questions = [];
  int currentQuestionIndex = 0;
  int correctAnswers = 0;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchQuestions();
  }

  Future<void> fetchQuestions() async {
    setState(() {
      isLoading = true;
      currentQuestionIndex = 0;
      correctAnswers = 0;
    });

    final response = await http.get(Uri.parse('https://opentdb.com/api.php?amount=10&type=multiple'));

    if (response.statusCode == 200) {
      setState(() {
        questions = json.decode(response.body)['results'];
        isLoading = false;
      });
    } else {
      setState(() {
        isLoading = false;
        questions = [];
      });
    }
  }

  void checkAnswer(String selectedAnswer) {
    String correctAnswer = questions[currentQuestionIndex]['correct_answer'];
    if (selectedAnswer == correctAnswer) {
      correctAnswers++;
    }
    if (currentQuestionIndex < questions.length - 1) {
      setState(() {
        currentQuestionIndex++;
      });
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => ResultScreen(
            score: correctAnswers,
            total: questions.length,
            onTryAgain: fetchQuestions,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (questions.isEmpty) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                "❌ Failed to load questions.",
                style: TextStyle(fontSize: 18, color: Colors.red),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: fetchQuestions,
                child: const Text("Retry"),
              ),
            ],
          ),
        ),
      );
    }

    final unescape = HtmlUnescape();
    var question = questions[currentQuestionIndex];
    String questionText = unescape.convert(question['question']);
    List options = List.from(question['incorrect_answers'])..add(question['correct_answer']);
    options.shuffle();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 144, 84, 104),
        title: const Text(
          'Quiz App',
          style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold), // تكبير الخط
        ),
        centerTitle: true, // لجعل العنوان في المنتصف
      ),
      body: Padding(
        padding: const EdgeInsets.all(22.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(questionText, style: const TextStyle(fontSize: 20)),
            const SizedBox(height: 20),
            ...options.map((option) => Column(
                  children: [
                    ElevatedButton(
                      onPressed: () => checkAnswer(option),
                      child: Text(unescape.convert(option)),
                    ),
                    const SizedBox(height: 23),
                  ],
                )),
          ],
        ),
      ),
    );
  }
}
