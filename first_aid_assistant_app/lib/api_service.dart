import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  final String baseUrl = "http://192.168.1.131:8000"; 

  Future<Map<String, dynamic>> predictIntent(String text) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/predict'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'text': text}),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return {"intent": "Błąd serwera: ${response.statusCode}", "confidence": 0.0};
      }
    } catch (e) {
      return {"intent": "Błąd połączenia", "confidence": 0.0};
    }
  }
}