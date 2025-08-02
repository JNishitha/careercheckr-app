//result_screen.dart

import 'package:flutter/material.dart';
// ignore: depend_on_referenced_packages
import 'package:percent_indicator/circular_percent_indicator.dart';
import '../constants/colors.dart';

class ResultScreen extends StatelessWidget {
  final double score;
  ResultScreen({required this.score});

  @override
  Widget build(BuildContext context) {
    final isScam = score < 50;

    return Scaffold(
      appBar: AppBar(title: Text("Result")),
      body: Center(
        child: CircularPercentIndicator(
          radius: 130.0,
          lineWidth: 13.0,
          animation: true,
          percent: score / 100,
          center: Text(
            "${score.toStringAsFixed(1)}%",
            style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold),
          ),
          footer: Padding(
            padding: const EdgeInsets.only(top: 12.0),
            child: Text(
              isScam ? "⚠️ Potential Scam" : "✅ Likely Genuine",
              style: TextStyle(
                fontSize: 18.0,
                fontWeight: FontWeight.w600,
                color: isScam ? AppColors.danger : AppColors.safe,
              ),
            ),
          ),
          progressColor: isScam ? AppColors.danger : AppColors.safe,
        ),
      ),
    );
  }
}
