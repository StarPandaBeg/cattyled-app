import 'package:cattyled_app/screens/settings/widgets/header.dart';
import 'package:flutter/material.dart';

class ScreenSettings extends StatelessWidget {
  const ScreenSettings({super.key});

  static final List<Map<String, dynamic>> _listEntries = [
    {
      "icon": Icons.wifi,
      "name": "WiFi",
      "route": "/settings/wifi",
    },
    {
      "icon": Icons.cloud,
      "name": "Синхронизация",
      "route": "/settings/sync",
    },
    {
      "icon": Icons.update,
      "name": "Обновления",
      "route": "/settings/updates",
    },
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          const PageHeader(),
          Expanded(
            child: ListView.builder(
              itemCount: _listEntries.length,
              itemBuilder: (context, index) {
                final itemData = _listEntries[index];
                return _SettingsListEntry(
                  icon: itemData["icon"],
                  title: itemData["name"],
                  onTap: () {},
                );
              },
            ),
          ),
          _SettingsListEntry(
            icon: Icons.settings,
            title: "Приложение",
            onTap: () {},
          ),
        ],
      ),
    );
  }
}

class _SettingsListEntry extends StatelessWidget {
  final IconData icon;
  final String title;
  final void Function()? onTap;

  const _SettingsListEntry({
    required this.icon,
    required this.title,
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
        child: Padding(
          padding: const EdgeInsets.symmetric(
            vertical: 30,
            horizontal: 20,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon),
              const SizedBox(width: 20),
              Text(title, style: textTheme.headlineMedium),
              const Expanded(
                child: Align(
                  alignment: Alignment.centerRight,
                  child: Icon(Icons.chevron_right_rounded),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
