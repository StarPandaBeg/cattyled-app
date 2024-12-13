import 'package:flutter/material.dart';

class ModeSheetContent extends StatelessWidget {
  const ModeSheetContent({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return SizedBox(
      height: 400,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 100,
              height: 4,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: colorScheme.secondary.withAlpha(50),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              "Выбор режима",
              style: theme.textTheme.headlineMedium,
            ),
            const SizedBox(height: 20),
            Expanded(
              child: GridView.builder(
                shrinkWrap: true,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 2 / 1,
                ),
                itemCount: 6,
                itemBuilder: (BuildContext context, int index) {
                  return const ModeCard(
                    icon: Icons.light,
                    label: "Классика",
                  );
                },
              ),
            )
          ],
        ),
      ),
    );
  }
}

class ModeCard extends StatelessWidget {
  final IconData icon;
  final String label;

  const ModeCard({super.key, required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 10,
          vertical: 5,
        ),
        child: Row(
          children: [
            Icon(icon),
            const SizedBox(width: 10),
            Text(
              label,
              style: textTheme.bodyLarge,
            ),
          ],
        ),
      ),
    );
  }
}
