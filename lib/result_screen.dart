import 'package:flutter/material.dart';
import 'quiz_screen.dart';

class ResultScreen extends StatelessWidget {
  final int score;
  final int total;
  final VoidCallback onTryAgain;

  const ResultScreen({super.key, required this.score, required this.total, required this.onTryAgain});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Quiz Result')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Your Score: $score / $total', style: const TextStyle(
              fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 18),
            ElevatedButton(
              onPressed: () {
                onTryAgain(); // استدعاء إعادة تحميل الأسئلة
                Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const QuizScreen()));
              },
              child: const Text('Try Again'),
            ),
          ],
        ),
      ),
    );
  }
}
