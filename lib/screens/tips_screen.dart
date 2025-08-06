import 'package:flutter/material.dart';
import 'package:careercheckr/constants/colors.dart';
import 'package:careercheckr/widgets/career_bottom_nav.dart';
import 'package:url_launcher/url_launcher.dart';

class TipsScreen extends StatelessWidget {
  const TipsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Career Safety Tips'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text(
            'Career Safety Tips',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          const TipTile("Don't pay to get a job or internship."),
          const TipTile("Check the sender's email domain for authenticity."),
          const TipTile("Never share Aadhaar/Bank details unless verified."),
          const TipTile("Beware of offers that sound too good to be true."),
          const TipTile("Look for official company websites and contacts."),
          const TipTile("Ask for written offer letters and contracts."),
          const TipTile("Search for company reviews online."),
          const TipTile("Report suspicious jobs to authorities."),
          const SizedBox(height: 32),
          const Text(
            'Trusted Resources',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          const ResourceTile("LinkedIn Jobs", "https://www.linkedin.com/jobs/"),
          const ResourceTile("Naukri.com", "https://www.naukri.com/"),
          const ResourceTile("Internshala", "https://internshala.com/"),
          const ResourceTile("Resume Tips", "https://zety.com/blog/resume-tips"),
        ],
      ),
      bottomNavigationBar: const CareerBottomNav(currentIndex: 4),
    );
  }
}

class TipTile extends StatelessWidget {
  final String tip;

  const TipTile(this.tip, {super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white,
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: ListTile(
        leading: const Icon(Icons.shield, color: AppColors.primary),
        title: Text(
          tip,
          style: const TextStyle(fontSize: 16),
        ),
      ),
    );
  }
}

class ResourceTile extends StatelessWidget {
  final String label;
  final String url;

  const ResourceTile(this.label, this.url, {super.key});

  Future<void> _launchUrl(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri)) {
      debugPrint('Could not launch $url');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white,
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: ListTile(
        leading: const Icon(Icons.link, color: AppColors.accent),
        title: Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(
          url,
          style: const TextStyle(fontSize: 13, color: Colors.blue),
        ),
        onTap: () => _launchUrl(url),
      ),
    );
  }
}