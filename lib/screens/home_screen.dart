import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _jobController = TextEditingController();
  String _result = "";

  void _checkFakeOrReal() {
    final description = _jobController.text.trim();

    if (description.isEmpty) {
      _showMessage("Please paste a job/internship description.");
      return;
    }

    if (description.toLowerCase().contains("registration fee") ||
        description.toLowerCase().contains("pay to get offer") ||
        description.toLowerCase().contains("non-refundable") ||
        description.toLowerCase().contains("whatsapp only") ||
        description.toLowerCase().contains("100% placement guarantee")) {
      setState(() => _result = "⚠️ This may be a fake internship/job.");
    } else {
      setState(() => _result = "✅ This seems like a real opportunity.");
    }
  }

  void _showMessage(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  void _logout() {
    Navigator.pushReplacementNamed(context, '/auth'); // Navigate to login screen
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text('CareerCheckr'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: _logout,
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Welcome 👋',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              "Paste any job or internship description below and let CareerCheckr analyze it.",
              style: TextStyle(fontSize: 16, color: Colors.black87),
            ),
            const SizedBox(height: 24),
            const Text(
              'Paste Job/Internship Description',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _jobController,
              maxLines: 8,
              decoration: InputDecoration(
                hintText: 'Paste the full job or internship details here...',
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Center(
              child: ElevatedButton(
                onPressed: _checkFakeOrReal,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 40, vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text(
                  "Check Now",
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
              ),
            ),
            const SizedBox(height: 30),
            if (_result.isNotEmpty)
              Center(
                child: Text(
                  _result,
                  style: TextStyle(
                    fontSize: 18,
                    color: _result.contains("✅") ? Colors.green : Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
          ],
        ),
      ),
    );
  }
}