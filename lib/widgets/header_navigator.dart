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
    return Padding(
      padding: const EdgeInsets.only(top: 8.0, bottom: 8.0), // Add bottom padding here
      child: SizedBox(
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
                  color: isSelected
                      ? Theme.of(context).colorScheme.primary
                      : Theme.of(context).colorScheme.surfaceVariant,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  tab.name,
                  style: TextStyle(
                    color: isSelected
                        ? Theme.of(context).colorScheme.onPrimary
                        : Theme.of(context).colorScheme.onSurface,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
