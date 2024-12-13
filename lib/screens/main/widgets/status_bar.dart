import 'package:cattyled_app/widgets/status_icon.dart';
import 'package:flutter/material.dart';

class StatusBar extends StatelessWidget {
  const StatusBar({super.key});

  @override
  Widget build(BuildContext context) {
    return const Card(
      margin: EdgeInsets.all(0),
      child: Padding(
        padding: EdgeInsets.all(10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            SizedBox(),
            Row(
              children: [
                StatusIcon(Icons.cloud_sync),
                SizedBox(width: 5),
                StatusIcon(Icons.wifi),
                SizedBox(width: 5),
                StatusIcon(Icons.cloud),
              ],
            ),
            SizedBox(),
          ],
        ),
      ),
    );
  }
}
