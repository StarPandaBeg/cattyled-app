import 'package:flutter/widgets.dart';

class TextAnimated extends StatelessWidget {
  final dynamic animationKey;
  final String text;
  final TextStyle? style;

  const TextAnimated(this.text, this.animationKey, {super.key, this.style});

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      transitionBuilder: (child, animation) =>
          FadeTransition(opacity: animation, child: child),
      child: Text(
        text,
        key: ValueKey(animationKey),
        style: style,
      ),
    );
  }
}
