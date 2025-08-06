import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class ResourcesScreen extends StatelessWidget {
  const ResourcesScreen({super.key});

  final resources = const [
    {
      'title': 'CV/Resume Templates',
      'url': 'https://www.overleaf.com/latex/templates/tagged/cv'
    },
    {
      'title': 'Interview Prep',
      'url': 'https://www.interviewbit.com/'
    },
    {
      'title': 'Internship Platforms',
      'url': 'https://internshala.com/'
    },
  ];

  void _launch(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Resources")),
      body: ListView.builder(
        itemCount: resources.length,
        itemBuilder: (context, index) {
          final res = resources[index];
          return ListTile(
            title: Text(res['title']!),
            trailing: const Icon(Icons.open_in_new),
            onTap: () => _launch(res['url']!),
          );
        },
      ),
    );
  }
}