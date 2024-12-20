import 'package:flutter/material.dart';

class PageHeader extends StatelessWidget {
  final String header;
  final bool enableBack;

  const PageHeader({super.key, required this.header, this.enableBack = true});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.all(15),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          enableBack
              ? IconButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  icon: Icon(
                    Icons.arrow_back,
                    color: colorScheme.secondary,
                  ),
                )
              : const SizedBox(width: 48),
          Text(header, style: theme.textTheme.headlineMedium),
          const SizedBox(width: 48),
        ],
      ),
    );
  }
}
