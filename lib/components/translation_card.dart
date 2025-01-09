import 'package:flutter/material.dart';

class TranslationCard extends StatelessWidget {
  final String translatedText;
  final VoidCallback saveToFavorites;
  final VoidCallback copyToClipboard;
  final VoidCallback clearText;
  final VoidCallback shareText;
  final VoidCallback speakText;
  final Color starIconColor;

  const TranslationCard({
    super.key,
    required this.translatedText,
    required this.saveToFavorites,
    required this.copyToClipboard,
    required this.clearText,
    required this.shareText,
    required this.speakText,
    required this.starIconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              translatedText,
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                IconButton(
                  icon: Icon(Icons.star, color: starIconColor),
                  onPressed: saveToFavorites,
                ),
                IconButton(
                  icon: const Icon(Icons.copy),
                  onPressed: copyToClipboard,
                ),
                IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: clearText,
                ),
                IconButton(
                  icon: const Icon(Icons.share),
                  onPressed: shareText,
                ),
                IconButton(
                  icon: const Icon(Icons.volume_up),
                  onPressed: speakText,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
