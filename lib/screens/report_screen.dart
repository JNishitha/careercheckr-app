import 'package:flutter/material.dart';

class ReportScreen extends StatelessWidget {
  final _controller = TextEditingController();

  ReportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Report a Scam")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Text("Describe the suspicious job/internship:"),
            const SizedBox(height: 10),
            TextField(
              controller: _controller,
              maxLines: 5,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: "Type here...",
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Simulate local success message
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Thank you! Report submitted.")),
                );
                _controller.clear();
              },
              child: const Text("Submit"),
            ),
          ],
        ),
      ),
    );
  }
} 