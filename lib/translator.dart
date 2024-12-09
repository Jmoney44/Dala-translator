// ignore_for_file: avoid_print

import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:share/share.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:http/http.dart' as http;

import 'camera_screen.dart';
import 'history_screen.dart';
import 'settings_screen.dart';

class TranslatorScreen extends StatefulWidget {
  const TranslatorScreen({super.key});

  @override
  State<TranslatorScreen> createState() => _TranslatorScreenState();
}

class _TranslatorScreenState extends State<TranslatorScreen> {
  String _sourceLanguage = 'en'; // Default source language
  String _targetLanguage = 'es'; // Default target language
  final TextEditingController _textController = TextEditingController();
  String _translatedText = ''; // Stores the translated text
  bool _isListening = false; // Speech-to-text status
  List<String> _favorites = []; // List of favorite translations
  int _selectedIndex = 0; // Bottom navigation bar index

  // API and Speech instances
  late FlutterTts flutterTts;
  late stt.SpeechToText _speech;
  final String _apiKey = dotenv.env['API_KEY']!;

  @override
  void initState() {
    super.initState();
    flutterTts = FlutterTts();
    _speech = stt.SpeechToText();
    _loadFavorites(); // Load saved favorites on start
  }

  // Translation API call
  Future<void> _translateText() async {
    final String inputText = _textController.text;
    if (inputText.isEmpty) return;

    final url = Uri.parse(
        'https://translation.googleapis.com/language/translate/v2?key=$_apiKey');

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
        final translatedText =
            data['data']['translations'][0]['translatedText'];
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

  // Method to handle Text-to-Speech pronunciation
  Future<void> _speak() async {
    if (_translatedText.isNotEmpty) {
      await flutterTts.speak(_translatedText);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nothing to pronounce')),
      );
    }
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
  void _shareText() {
    if (_translatedText.isNotEmpty) {
      Share.share(_translatedText, subject: 'Translation Result');
    } else {
      // Show a snack bar if there's no text to share
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No text to share')),
      );
    }
  }

  // Method to clear output
  void _clearOutput() {
    setState(() {
      _translatedText = '';
    });
  }

  // Define the screens for each tab
  static const List<Widget> _pages = <Widget>[
    HistoryScreen(),
    CameraScreen(),
    SettingsScreen(),
  ];

  // Method to handle tab selection
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Image.asset(
            'assets/logo/logo.jpeg', // Place your logo image in assets folder and add in pubspec.yaml
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
              backgroundImage: AssetImage(
                  'assets/profile/johnson.jpg'), // Profile picture asset
              radius: 18, // Size of profile picture
            ),
          ),
        ],
      ),
      body: _selectedIndex == 0
          ? _buildTranslatorBody()
          : _pages[_selectedIndex - 1],
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(
              icon: Icon(Icons.translate), label: 'Translate'),
          BottomNavigationBarItem(icon: Icon(Icons.history), label: 'History'),
          BottomNavigationBarItem(
              icon: Icon(Icons.camera_alt), label: 'Camera'),
          BottomNavigationBarItem(
              icon: Icon(Icons.settings), label: 'Settings'),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.blue, // Color for the selected icon and label
        unselectedItemColor: Colors.grey, // Color for unselected items
        onTap: _onItemTapped,
      ),
    );
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
            Container(
              padding: const EdgeInsets.all(16),
              margin: const EdgeInsets.only(top: 20),
              decoration: BoxDecoration(
                color: Colors.blue[50], // Light background for readability
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.shade300,
                    offset: const Offset(0, 2),
                    blurRadius: 4,
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      // Translated Text Display
                      Expanded(
                        child: Text(
                          _translatedText,
                          style: const TextStyle(
                              fontSize: 16, color: Colors.black87),
                        ),
                      ),
                      // Text-to-Speech Button
                      IconButton(
                        icon: const Icon(Icons.volume_up),
                        onPressed: _speak,
                      ),
                      // Favorite Button
                      IconButton(
                        icon: Icon(
                          Icons.star,
                          color: _favorites.contains(_translatedText)
                              ? Colors.yellow
                              : Colors.grey,
                        ),
                        onPressed: _saveToFavorites,
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  // Actions Row: Copy, Share, Clear
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      TextButton.icon(
                        icon: const Icon(Icons.copy, color: Colors.blue),
                        label: const Text('Copy',
                            style: TextStyle(color: Colors.blue)),
                        onPressed: _copyToClipboard,
                      ),
                      TextButton.icon(
                        icon: const Icon(Icons.share, color: Colors.blue),
                        label: const Text('Share',
                            style: TextStyle(color: Colors.blue)),
                        onPressed: _shareText,
                      ),
                      TextButton.icon(
                        icon: const Icon(Icons.clear, color: Colors.red),
                        label: const Text('Clear',
                            style: TextStyle(color: Colors.red)),
                        onPressed: _clearOutput,
                      ),
                    ],
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
