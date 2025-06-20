import 'package:flutter/material.dart';
import '../models/header_tab.dart';

class HeaderNavigator extends StatelessWidget {
  final List<HeaderTab> tabs;
  final String selectedApiUrl;
  final Function(HeaderTab) onTabSelected;

  const HeaderNavigator({
    super.key,
    required this.tabs,
    required this.selectedApiUrl,
    required this.onTabSelected,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        itemCount: tabs.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (context, index) {
          final tab = tabs[index];
          final isSelected = tab.apiUrl == selectedApiUrl;

          return GestureDetector(
            onTap: () => onTabSelected(tab),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: isSelected ? Colors.pinkAccent : Colors.grey[600],
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                tab.name,
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.black,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
