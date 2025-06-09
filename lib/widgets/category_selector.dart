import 'package:flutter/material.dart';

class CategorySelector extends StatelessWidget {
  final String selected;
  final void Function(String) onChanged;
  const CategorySelector({
    super.key,
    required this.selected,
    required this.onChanged,
  });

  static const _categories = [
    'All', 'Korean', 'Lifestyle', 'Web Stories',
    'Videos', 'Trending', 'TV', 'Web series',
    'Fashion', 'Entertainment',
  ];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        itemCount: _categories.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (_, i) {
          final category = _categories[i];
          final selectedFlag = category == selected;
          return GestureDetector(
            onTap: () => onChanged(category),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: selectedFlag ? Colors.pinkAccent : Colors.grey[800],
                borderRadius: BorderRadius.circular(20),
              ),
              child: Center(
                child: Text(
                  category,
                  style: TextStyle(
                    color: selectedFlag ? Colors.white : Colors.grey[300],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
