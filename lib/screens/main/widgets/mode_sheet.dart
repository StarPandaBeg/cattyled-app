import 'package:cattyled_app/api/commands.dart';
import 'package:flutter/material.dart';

class ModeSheetContent extends StatefulWidget {
  final LampMode initial;
  final void Function(LampMode mode)? onModeChange;

  const ModeSheetContent({super.key, required this.initial, this.onModeChange});

  @override
  State<ModeSheetContent> createState() => _ModeSheetContentState();
}

class _ModeSheetContentState extends State<ModeSheetContent> {
  LampMode selectedMode = LampMode.classic;

  @override
  void initState() {
    super.initState();
    selectedMode = widget.initial;
  }

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
                itemCount: lampModes.length,
                itemBuilder: (BuildContext context, int index) {
                  final mode = LampMode.values[index];
                  final modeData = lampModes[mode]!;

                  return ModeCard(
                    onTap: () {
                      if (selectedMode == mode) return;
                      setState(() {
                        selectedMode = mode;
                        if (widget.onModeChange != null) {
                          widget.onModeChange!(mode);
                        }
                      });
                    },
                    active: mode == selectedMode,
                    icon: modeData["icon"],
                    label: modeData["name"],
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
  final bool active;
  final void Function()? onTap;

  const ModeCard({
    super.key,
    required this.icon,
    required this.label,
    required this.active,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    return Card(
      clipBehavior: Clip.hardEdge,
      child: InkWell(
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(
              color: active ? theme.colorScheme.primary : Colors.transparent,
              width: 1,
            ),
            borderRadius: BorderRadius.circular(8),
          ),
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
        ),
      ),
    );
  }
}
