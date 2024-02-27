import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Translation App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => SplashScreenPage(),
        '/translation': (context) => TranslationScreen(),
      },
    );
  }
}

class SplashScreenPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}

class TranslationScreen extends StatefulWidget {
  @override
  _TranslationScreenState createState() => _TranslationScreenState();
}

class _TranslationScreenState extends State<TranslationScreen> {
  final apiKey = "3591a177b8mshbbf4b9f472d339ap1e0489jsn3851d9616c15";
  final inputTextController = TextEditingController();
  String translatedText = '';
  String selectedLanguage = '';
  List<dynamic>? languages;

  @override
  void initState() {
    super.initState();
    fetchLanguages();
  }

  Future<void> fetchLanguages() async {
    final response = await http.get(Uri.parse('https://translation.googleapis.com/language/translate/v2/languages?key=$apiKey'));
    if (response.statusCode == 200) {
      final body = jsonDecode(response.body);
      setState(() {
        languages = body['data']['languages'];
      });
    }
  }

  String getLanguageCode(String language) {
    final lang = languages!.firstWhere((lang) => lang['name'] == language, orElse: () => {});
    return lang['language'];
  }

  Future<void> translateText() async {
    final inputText = inputTextController.text;
    if (inputText.isEmpty) return;

    final translatedTextResponse = await http.get(Uri.parse('https://translation.googleapis.com/language/translate/v2?key=$apiKey&q=$inputText&target=${getLanguageCode(selectedLanguage)}'));
    if (translatedTextResponse.statusCode == 200) {
      final decodedTranslatedText = jsonDecode(translatedTextResponse.body);
      setState(() {
        translatedText = decodedTranslatedText['data']['translations'][0]['translatedText'];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Translation App'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: inputTextController,
              decoration: InputDecoration(
                hintText: 'Enter text to translate',
              ),
            ),
            SizedBox(height: 16),
            DropdownButton<String>(
              value: selectedLanguage,
              onChanged: (value) {
                setState(() {
                  selectedLanguage = value!;
                });
              },
              items: languages?.map((lang) {
                return DropdownMenuItem<String>(
                  value: lang['language'],
                  child: Text(lang['name']),
                );
              }).toList() ?? [],
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: translateText,
              child: Text('Translate'),
            ),
            SizedBox(height: 16),
            Text(translatedText),
          ],
        ),
      ),
    );
  }
} 
