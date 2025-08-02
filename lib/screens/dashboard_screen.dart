import 'package:flutter/material.dart';

class DashboardScreen extends StatelessWidget {
  final String userName;
  final int totalScans;

  const DashboardScreen({
    Key? key,
    required this.userName,
    required this.totalScans,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '👋 Welcome back, $userName!',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 16),
            Text(
              '📊 You’ve scanned $totalScans descriptions so far.',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () => Navigator.pushNamed(context, '/detector'),
              icon: const Icon(Icons.search),
              label: const Text('Check Description'),
            ),
            ElevatedButton.icon(
              onPressed: () => Navigator.pushNamed(context, '/history'),
              icon: const Icon(Icons.history),
              label: const Text('View History'),
            ),
            ElevatedButton.icon(
              onPressed: () => Navigator.pushNamed(context, '/help'),
              icon: const Icon(Icons.info_outline),
              label: const Text('Help & Tips'),
            ),
            const SizedBox(height: 32),
            const Text(
              '🎓 Tip: Fake jobs often ask for money upfront or personal details without verification.',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            )
          ],
        ),
      ),
    );
  }
}