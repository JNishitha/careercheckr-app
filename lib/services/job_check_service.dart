//job_check_service.dart

import 'package:http/http.dart' as http;
import 'dart:convert';

class JobCheckService {
  final _baseUrl = 'http://10.0.2.2:5000';

  Future<double> checkDescription(String description) async {
    final response = await http.post(
      Uri.parse("$_baseUrl/check"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"description": description}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['score'] * 1.0;
    } else {
      throw Exception("Failed to connect to AI service");
    }
  }
}