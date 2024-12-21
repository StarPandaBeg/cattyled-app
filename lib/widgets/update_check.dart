import 'package:cattyled_app/util/updates.dart';
import 'package:flutter/material.dart';
import 'package:logging/logging.dart';

class UpdateChecker extends StatefulWidget {
  const UpdateChecker({super.key});

  @override
  State<UpdateChecker> createState() => _UpdateCheckerState();
}

class _UpdateCheckerState extends State<UpdateChecker> {
  static final _logger = Logger("_UpdateCheckerState");

  @override
  void initState() {
    super.initState();
    checkAppUpdates().then(_onUpdateStatus);
  }

  @override
  Widget build(BuildContext context) {
    return const SizedBox();
  }

  Future<void> _showAppUpdate() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Доступно обноввление'),
          content: const SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('Вышла новая версия приложения'),
                SizedBox(height: 10),
                Text('Рекомендуем обновиться!'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Не хочу'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              onPressed: _doUpdate,
              child: const Text('Давай'),
            ),
          ],
        );
      },
    );
  }

  void _doUpdate() async {
    Navigator.pop(context);
    await gotoAppUpdates();
  }

  void _onUpdateStatus(bool status) {
    if (!mounted) return;
    _logger.info("App update ${status ? "" : "not "}found");
    if (!status) return;
    _showAppUpdate();
  }
}
