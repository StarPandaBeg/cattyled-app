import 'dart:ui';

import 'package:flutter/material.dart';

class LampIndicator extends StatelessWidget {
  final Color colorA;
  final Color colorB;

  const LampIndicator({super.key, required this.colorA, required this.colorB});

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Positioned.fill(
          child: ImageFiltered(
            imageFilter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
            child: Image.asset(
              "assets/images/cat.png",
              fit: BoxFit.contain,
              color: colorA.withAlpha(120),
            ),
          ),
        ),
        ShaderMask(
          shaderCallback: (bounds) {
            return LinearGradient(
              colors: [colorA, colorB],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ).createShader(bounds);
          },
          blendMode: BlendMode.modulate,
          child: Image.asset("assets/images/cat.png"),
        ),
        Image.asset("assets/images/eyes.png"),
      ],
    );
  }
}
