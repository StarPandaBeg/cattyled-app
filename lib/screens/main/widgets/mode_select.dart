import 'package:flutter/material.dart';

class ModeSelect extends StatelessWidget {
  final VoidCallback? onTap;

  const ModeSelect({super.key, this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    return Card(
      margin: const EdgeInsets.all(0),
      clipBehavior: Clip.hardEdge,
      child: InkWell(
        onTap: onTap,
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
      ),
    );
  }
}
