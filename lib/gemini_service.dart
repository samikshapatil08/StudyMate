import 'dart:convert';
import 'package:http/http.dart' as http;

class GeminiService {
  static const String _apiKey = "AIzaSyBoVLWsX4dQEA-BRjCNkjn3wn5ZxNY0F48";

  static const String _endpoint =
      "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash:generateContent";

  Future<String> getResponse(String prompt) async {
    if (prompt.trim().isEmpty) {
      return "Please enter a message.";
    }

    try {
      final response = await http.post(
        Uri.parse("$_endpoint?key=$_apiKey"),
        headers: {
          "Content-Type": "application/json",
        },
        body: jsonEncode({
          "contents": [
            {
              "role": "user",
              "parts": [
                {"text": prompt}
              ]
            }
          ]
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        return data["candidates"][0]["content"]["parts"][0]["text"];
      } else {
        return "Gemini ${response.statusCode}: ${response.body}";
      }
    } catch (e) {
      return "Network error: $e";
    }
  }
}
