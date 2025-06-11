import 'package:flutter/material.dart';
import '../models/footer_tab.dart';

class CategorySelector extends StatelessWidget {
  final List<FooterTab> categories;
  final FooterTab selected;
  final void Function(FooterTab) onChanged;

  const CategorySelector({
    super.key,
    required this.categories,
    required this.selected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        itemCount: categories.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (_, i) {
          final category = categories[i];
          final selectedFlag = category.title == selected.title;

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
                  category.title,
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
