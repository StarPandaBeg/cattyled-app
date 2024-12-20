import 'package:flutter/material.dart';

class PageHeader extends StatelessWidget {
  final String header;

  const PageHeader({super.key, required this.header});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.all(15),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: Icon(
              Icons.arrow_back,
              color: colorScheme.secondary,
            ),
          ),
          Text(header, style: theme.textTheme.headlineMedium),
          const SizedBox(width: 48),
        ],
      ),
    );
  }
}
