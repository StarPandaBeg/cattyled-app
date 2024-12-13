import 'package:flutter/material.dart';

class ModeSelect extends StatelessWidget {
  const ModeSelect({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    return Card(
      margin: const EdgeInsets.all(0),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 25,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(
              Icons.light,
              size: 48,
            ),
            const SizedBox(
              height: 15,
            ),
            Text(
              "Классика",
              style: textTheme.headlineLarge,
            ),
            Text(
              "Режим",
              style: textTheme.bodyLarge,
            )
          ],
        ),
      ),
    );
  }
}
