import 'package:url_launcher/url_launcher.dart';

Future<void> searchCompany(String companyName) async {
  final query = Uri.encodeComponent(companyName);
  final url = Uri.parse("https://www.google.com/search?q=$query");
  if (await canLaunchUrl(url)) {
    await launchUrl(url);
  } else {
    throw 'Could not launch $url';
  }
}