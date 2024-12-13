import 'package:flutter/material.dart';

class StatusIcon extends StatelessWidget {
  final IconData icon;
  final bool enabled;

  const StatusIcon(this.icon, {super.key, this.enabled = true});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return Icon(
      icon,
      color: enabled ? colorScheme.primary : colorScheme.error,
      size: 20,
    );
  }
}
