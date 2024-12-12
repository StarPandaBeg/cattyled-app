import 'package:flutter/material.dart';

class PageHeader extends StatelessWidget {
  const PageHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    return Padding(
      padding: const EdgeInsets.all(15),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const SizedBox(),
          Column(
            children: [
              Text(
                "Доброе утро!",
                style: textTheme.headlineMedium,
              ),
              const Text(
                "Кот найден. Мяу!",
              ),
            ],
          ),
          const SizedBox(),
        ],
      ),
    );
  }
}
