import 'package:flutter/material.dart';

class TranslationCard extends StatelessWidget {
  const TranslationCard({
    super.key,
    required this.starIconColor,
    required this.saveToFavorites,
    required this.copyToClipboard,
    required this.shareText,
    required this.clearText,
    required this.translatedText,
  });

  final Color starIconColor;
  final void Function() saveToFavorites;
  final void Function() copyToClipboard;
  final void Function() shareText;
  final void Function() clearText;
  final String translatedText;

  @override
  Widget build(BuildContext context) {
    return Container(
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
                  translatedText,
                  style: const TextStyle(fontSize: 16, color: Colors.black87),
                ),
              ),
              // Text-to-Speech Button
              IconButton(
                icon: const Icon(Icons.volume_up),
                onPressed: () {},
              ),
              // Favorite Button
              IconButton(
                icon: Icon(Icons.star, color: starIconColor),
                onPressed: saveToFavorites,
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
                label: const Text('Copy', style: TextStyle(color: Colors.blue)),
                onPressed: copyToClipboard,
              ),
              TextButton.icon(
                icon: const Icon(Icons.share, color: Colors.blue),
                label: const Text('Share', style: TextStyle(color: Colors.blue)),
                onPressed: shareText,
              ),
              TextButton.icon(
                icon: const Icon(Icons.clear, color: Colors.red),
                label: const Text('Clear', style: TextStyle(color: Colors.red)),
                onPressed: clearText,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
