import 'package:cattyled_app/store/lamp/store.dart';
import 'package:flutter/material.dart';

class ModeSelect extends StatelessWidget {
  final VoidCallback? onTap;
  final LampMode mode;

  const ModeSelect({
    super.key,
    required this.mode,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final modeData = lampModes[mode]!;

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
              Icon(
                modeData["icon"],
                size: 48,
              ),
              const SizedBox(
                height: 15,
              ),
              Text(
                modeData["name"],
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
