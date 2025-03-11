import 'dart:convert';
import 'package:allen/constant.dart';
import 'package:http/http.dart' as http;

class OpenAIService {
  final List<Map<String, String>> messages = [];

  Future<String> isArtPromptAPI(String prompt) async {
    try {
      final res = await http.post(
        Uri.parse('https://api.openai.com/v1/chat/completions'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $openAIAPIKey',
        },
        body: jsonEncode({
          "model": "gpt-3.5-turbo",
          "messages": [
            {
              'role': 'user',
              'content': 'Does this message want to generate an AI picture, image, art or anything similar? $prompt. Simply answer with a yes or no.',
            }
          ],
        }),
      );

      if (res.statusCode == 200) {
        final content = jsonDecode(res.body)['choices'][0]['message']['content'].trim().toLowerCase();

        if (content == 'yes' || content == 'yes.') {
          return await dallEAPI(prompt);
        } else {
          return await chatGPTAPI(prompt);
        }
      }
      return 'An internal error occurred';
    } catch (e) {
      return 'Error: ${e.toString()}';
    }
  }

  Future<String> chatGPTAPI(String prompt) async {
    messages.add({'role': 'user', 'content': prompt});
    try {
      final res = await http.post(
        Uri.parse('https://api.openai.com/v1/chat/completions'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $openAIAPIKey',
        },
        body: jsonEncode({
          "model": "gpt-3.5-turbo",
          "messages": messages,
        }),
      );

      if (res.statusCode == 200) {
        final content = jsonDecode(res.body)['choices'][0]['message']['content'].trim();
        messages.add({'role': 'assistant', 'content': content});
        return content;
      }
      return 'An internal error occurred';
    } catch (e) {
      return 'Error: ${e.toString()}';
    }
  }

  Future<String> dallEAPI(String prompt) async {
    messages.add({'role': 'user', 'content': prompt});
    try {
      final res = await http.post(
        Uri.parse('https://api.openai.com/v1/images/generations'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $openAIAPIKey',
        },
        body: jsonEncode({
          'prompt': prompt,
          'n': 1,
        }),
      );

      if (res.statusCode == 200) {
        final imageUrl = jsonDecode(res.body)['data'][0]['url'].trim();
        messages.add({'role': 'assistant', 'content': imageUrl});
        return imageUrl;
      }
      return 'An internal error occurred';
    } catch (e) {
      return 'Error: ${e.toString()}';
    }
  }
}
