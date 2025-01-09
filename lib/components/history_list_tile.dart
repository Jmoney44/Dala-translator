import 'package:flutter/material.dart';

class HistoryListTile extends StatelessWidget {
  final String translation;
  final VoidCallback addToFavorites;

  const HistoryListTile({
    super.key,
    required this.translation,
    required this.addToFavorites,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(translation),
      trailing: IconButton(
        icon: const Icon(Icons.star_border),
        onPressed: addToFavorites,
      ),
    );
  }
}
