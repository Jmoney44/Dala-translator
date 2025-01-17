import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:google/components/bottom_navbar.dart';
import 'package:google/components/translated_card.dart';
import 'package:google/constants/utils.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

class TranslatorScreen extends StatefulWidget {
  static const routeName = 'translator_Screen';

  const TranslatorScreen({super.key});

  @override
  State<TranslatorScreen> createState() => _TranslatorScreenState();
}

class _TranslatorScreenState extends State<TranslatorScreen> {
  final String _apiKey = 'AIzaSyDdvd0KEeUv222k0Rgh-bcxxeW-VU5c5I4';

  String _sourceLanguage = 'en'; // Default source language
  String _targetLanguage = 'es'; // Default target language
  final TextEditingController _textController = TextEditingController();
  String _translatedText = ''; // Stores the translated text
  bool _isListening = false; // Speech-to-text status
  List<String> _favorites = []; // List of favorite translations

  // API and Speech instances
  late stt.SpeechToText _speech;
  // final String _apiKey = API_KEY;
  late FlutterTts flutterTts;

  @override
  void initState() {
    super.initState();
    flutterTts = FlutterTts();
    _initTts();
    _speech = stt.SpeechToText();
    _loadFavorites(); // Load saved favorites on start
  }

  Future<void> _initTts() async {
    await flutterTts.setLanguage(_targetLanguage); // Set language based on target
    await flutterTts.setSpeechRate(0.5); // Adjust speech rate (0.0 to 1.0)
    await flutterTts.setVolume(1.0); // Set volume (0.0 to 1.0)
    await flutterTts.setPitch(1.0); // Set pitch (0.0 to 2.0)
  }

  // Method to speak text
  Future<void> _speakText() async {
    if (_translatedText.isNotEmpty) {
      await flutterTts.setLanguage(_targetLanguage); // Update language before speaking
      await flutterTts.speak(_translatedText);
    }
  }

  @override
  void dispose() {
    flutterTts.stop();
    super.dispose();
  }

  // Future<void> _setTargetLanguage(String newValue) async {
  //   setState(() {
  //     _targetLanguage = newValue;
  //   });
  //
  //   try {
  //     final isLanguageAvailable = await flutterTts.isLanguageAvailable(newValue);
  //     if (isLanguageAvailable) {
  //       await flutterTts.setLanguage(newValue);
  //     } else {
  //       if (mounted) {
  //         ScaffoldMessenger.of(context).showSnackBar(
  //           SnackBar(content: Text('Language $newValue is not available for text-to-speech')),
  //         );
  //       }
  //     }
  //   } catch (e) {
  //     if (mounted) {
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         SnackBar(content: Text('Failed to set language: ${e.toString()}')),
  //       );
  //     }
  //   }
  // }

  // Translation API call

  Future<void> _translateText() async {
    final String inputText = _textController.text;
    if (inputText.isEmpty) return;

    final url = Uri.parse('https://translation.googleapis.com/language/translate/v2?key=$_apiKey');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'q': inputText,
          'source': _sourceLanguage,
          'target': _targetLanguage,
          'format': 'text',
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final translatedText = data['data']['translations'][0]['translatedText'];
        setState(() {
          _translatedText = translatedText;
          _addToHistory(translatedText); // Save translation to history
        });
      } else {
        stderr.write("Translation Error: ${response.body}");
        throw Exception('Failed to load translation');
      }
    } catch (error) {
      stderr.write("Error in translation: $error");
    }
  }

  // Method to save translation to history
  Future<void> _addToHistory(String translation) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> history = prefs.getStringList('history') ?? [];
    history.add(translation);
    await prefs.setStringList('history', history);
  }

  // Method to save translation to favorites
  Future<void> _saveToFavorites() async {
    setState(() {
      if (!_favorites.contains(_translatedText)) {
        _favorites.add(_translatedText);
        _saveFavorites();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Added to favorites')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Already in favorites')),
        );
      }
    });
  }

  // Method to save favorites list to SharedPreferences
  Future<void> _saveFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('favorites', _favorites);
  }

  // Method to load favorites list from SharedPreferences
  Future<void> _loadFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _favorites = prefs.getStringList('favorites') ?? [];
    });
  }

  // Speech-to-Text functionality
  void _startListening() async {
    bool available = await _speech.initialize();
    if (available) {
      setState(() => _isListening = true);
      _speech.listen(onResult: (result) {
        setState(() {
          _textController.text = result.recognizedWords;
        });
      });
    }
  }

  void _stopListening() {
    setState(() => _isListening = false);
    _speech.stop();
  }

  // Method to copy translated text
  void _copyToClipboard() {
    Clipboard.setData(ClipboardData(text: _translatedText));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Copied to clipboard')),
    );
  }

  // Method to share translated text using native share dialog
  // void _shareText() {
  //   if (_translatedText.isNotEmpty) {
  //     Share.share(_translatedText, subject: 'Translation Result');
  //   } else {
  //     // Show a snack bar if there's no text to share
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       const SnackBar(content: Text('No text to share')),
  //     );
  //   }
  // }

  // Method to clear output
  void _clearOutput() {
    setState(() {
      _translatedText = '';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        bottomNavigationBar: const CustomNavigationBar(currentIndex: 0),
        appBar: AppBar(
          leading: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Image.asset(
              kAppLogo,
              fit: BoxFit.contain,
            ),
          ),
          title: const Text(
            'DALA',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          centerTitle: true,
          actions: const [
            Padding(
              padding: EdgeInsets.only(right: 8.0),
              child: CircleAvatar(
                backgroundImage: AssetImage(kProfilePlaceHolder),
                radius: 18,
              ),
            ),
          ],
        ),
        body: _buildTranslatorBody());
  }

  Widget _buildTranslatorBody() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Language Selector Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Source Language Dropdown
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: _sourceLanguage,
                  onChanged: (String? newValue) {
                    setState(() {
                      _sourceLanguage = newValue!;
                    });
                  },
                  decoration: const InputDecoration(labelText: 'From'),
                  items: const [
                    DropdownMenuItem(value: 'en', child: Text('English')),
                    DropdownMenuItem(value: 'es', child: Text('Spanish')),
                    DropdownMenuItem(value: 'fr', child: Text('French')),
                    DropdownMenuItem(value: 'de', child: Text('German')),
                    DropdownMenuItem(value: 'ig', child: Text('Igbo')),
                    DropdownMenuItem(value: 'yo', child: Text('Yoruba')),
                    DropdownMenuItem(value: 'iso', child: Text('Isoko')),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              // Swap Icon
              const Icon(Icons.swap_horiz),
              const SizedBox(width: 16),
              // Target Language Dropdown
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: _targetLanguage,
                  onChanged: (String? newValue) {
                    setState(() {
                      _targetLanguage = newValue!;
                    });
                  },
                  decoration: const InputDecoration(labelText: 'To'),
                  items: const [
                    DropdownMenuItem(value: 'es', child: Text('Spanish')),
                    DropdownMenuItem(value: 'en', child: Text('English')),
                    DropdownMenuItem(value: 'fr', child: Text('French')),
                    DropdownMenuItem(value: 'de', child: Text('German')),
                    DropdownMenuItem(value: 'ig', child: Text('Igbo')),
                    DropdownMenuItem(value: 'yo', child: Text('Yoruba')),
                    DropdownMenuItem(value: 'iso', child: Text('Isoko')),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          // Text Input Area with Speech-to-Text
          TextField(
            controller: _textController,
            maxLines: 4,
            decoration: InputDecoration(
              labelText: 'Enter text',
              border: const OutlineInputBorder(),
              suffixIcon: IconButton(
                icon: Icon(_isListening ? Icons.mic : Icons.mic_none),
                onPressed: _isListening ? _stopListening : _startListening,
              ),
            ),
          ),
          const SizedBox(height: 20),
          // Translate Button
          ElevatedButton(
            onPressed: _translateText,
            child: const Text("Translate"),
          ),
          const SizedBox(height: 20),

          // Output Area with Text-to-Speech
          if (_translatedText.isNotEmpty)
            TranslationCard(
              starIconColor: _favorites.contains(_translatedText) ? Colors.yellow : Colors.red,
              saveToFavorites: _saveToFavorites,
              copyToClipboard: _copyToClipboard,
              clearText: _clearOutput,
              // shareText: _shareText,
              translatedText: _translatedText,
              speakText: _speakText, // Add the speech callback
            ),
        ],
      ),
    );
  }
}
