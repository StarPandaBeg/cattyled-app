import 'package:cattyled_app/screens/main/widgets/header.dart';
import 'package:cattyled_app/screens/main/widgets/mode_select.dart';
import 'package:cattyled_app/screens/main/widgets/status_bar.dart';
import 'package:cattyled_app/widgets/lamp.dart';
import 'package:flutter/material.dart';

class ScreenMain extends StatelessWidget {
  const ScreenMain({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const PageHeader(),
          const SizedBox(
            height: 40,
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 60),
              child: LampIndicator(
                colorA: Colors.blue[800]!,
                colorB: Colors.blue[800]!,
              ),
            ),
          ),
          const SizedBox(
            height: 40,
          ),
          Column(
            children: [
              IntrinsicHeight(
                child: Row(
                  children: [
                    Container(
                      width: 65,
                      color: Colors.white,
                    ),
                    const SizedBox(width: 10),
                    const Expanded(
                      child: ModeSelect(),
                    )
                  ],
                ),
              ),
              const SizedBox(height: 10),
              const StatusBar(),
            ],
          ),
        ],
      ),
    );
  }
}
