import 'dart:async';
import 'dart:math';
import 'dart:ui' as ui;

import 'package:cattyled_app/store/lamp/store.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class LampIndicator extends StatelessWidget {
  final Color colorA;
  final Color colorB;

  const LampIndicator({super.key, required this.colorA, required this.colorB});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LampBloc, LampState>(
      buildWhen: (previous, current) {
        if (previous.isEnabled != current.isEnabled) return true;
        if (previous.color != current.color) return true;
        if (previous.mode != current.mode) return true;
        return false;
      },
      builder: (context, state) => Stack(
        alignment: Alignment.center,
        children: [
          Positioned.fill(child: _LampShadow(state: state)),
          _Lamp(state: state),
          Image.asset("assets/images/eyes.png"),
        ],
      ),
    );
  }
}

class _LampShadow extends StatefulWidget {
  final LampState state;

  const _LampShadow({required this.state});

  @override
  State<_LampShadow> createState() => _LampShadowState();
}

class _LampShadowState extends State<_LampShadow> {
  @override
  Widget build(BuildContext context) {
    return ImageFiltered(
      imageFilter: ui.ImageFilter.blur(sigmaX: 20, sigmaY: 20),
      child: Image.asset(
        "assets/images/cat.png",
        fit: BoxFit.contain,
        color: _getColor(),
      ),
    );
  }

  Color _getColor() {
    final mode = widget.state.mode;
    final color = widget.state.color;
    final opacity = widget.state.isEnabled ? 120 : 0;

    final shadowColor = switch (mode) {
      LampMode.rainbow => Colors.grey,
      LampMode.lights => Colors.grey,
      LampMode.glow => Colors.purple,
      LampMode.pulse => Colors.red[500]!,
      LampMode.fire => Colors.orange[800]!,
      _ => color,
    };
    return shadowColor.withAlpha(opacity);
  }
}

class _Lamp extends StatefulWidget {
  final LampState state;

  const _Lamp({required this.state});

  @override
  State<_Lamp> createState() => __LampState();
}

class __LampState extends State<_Lamp> with SingleTickerProviderStateMixin {
  ui.Image? _image;
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _loadImage();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) => RepaintBoundary(
        child: CustomPaint(
          painter: _LampPainter(
            animationValue: _controller.value,
            state: widget.state,
            image: _image,
          ),
          child: const SizedBox(
            width: double.infinity,
            height: double.infinity,
          ),
        ),
      ),
    );
  }

  Future<void> _loadImage() async {
    final ByteData data = await rootBundle.load('assets/images/cat.png');
    final Completer<ui.Image> completer = Completer();
    ui.decodeImageFromList(data.buffer.asUint8List(), (image) {
      completer.complete(image);
    });
    final loadedImage = await completer.future;
    setState(() {
      _image = loadedImage;
    });
  }
}

class _LampPainter extends CustomPainter {
  double animationValue;
  LampState state;
  final ui.Image? image;

  _LampPainter({
    required this.animationValue,
    required this.state,
    required this.image,
  }) : super();

  @override
  void paint(Canvas canvas, Size size) {
    if (image == null) return;
    final bounds = Rect.fromLTWH(0, 0, size.width, size.height);

    // Draw transparent layer
    final paintBase = Paint()..blendMode = BlendMode.srcOver;
    canvas.saveLayer(bounds, paintBase);

    // Draw actual lamp image
    paintImage(canvas: canvas, rect: bounds, image: image!);

    // Draw shader
    final shader = _modeShader(bounds);
    if (shader == null) {
      canvas.restore();
      return;
    }

    final paint = Paint()
      ..shader = shader
      ..blendMode = BlendMode.modulate;
    canvas.drawRect(bounds, paint);
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _LampPainter oldDelegate) {
    if (animationValue != oldDelegate.animationValue) return true;
    if (state.isEnabled != oldDelegate.state.isEnabled) return true;
    if (state.color != oldDelegate.state.color) return true;
    if (state.mode != oldDelegate.state.mode) return true;
    return false;
  }

  Shader? _modeShader(Rect bounds) {
    if (!state.isEnabled) {
      return const LinearGradient(
        colors: [Color(0xFF2A2727), Color(0xFF2A2727)],
      ).createShader(bounds);
    }

    return switch (state.mode) {
      LampMode.classic => _solidColorShader(bounds, state.color),
      LampMode.rainbow => _rainbowColorShader(bounds),
      LampMode.glow => _glowColorShader(bounds),
      LampMode.pulse => _pulseColorShader(bounds),
      LampMode.fire => _fireColorShader(bounds),
      LampMode.lights => _lightsColorShader(bounds),
      _ => null,
    };
  }

  Shader _solidColorShader(Rect bounds, Color c) {
    return LinearGradient(
      colors: [state.color, state.color],
    ).createShader(bounds);
  }

  Shader _rainbowColorShader(Rect bounds) {
    final rainbowPosition = animationValue * 360;
    final colors = List<Color>.generate(2, (index) {
      final hue = (360 * (index / 7) + rainbowPosition) % 360;
      return HSLColor.fromAHSL(1.0, hue, 0.8, 0.45).toColor();
    });

    return LinearGradient(
      colors: colors,
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ).createShader(bounds);
  }

  Shader _glowColorShader(Rect bounds) {
    final angle = animationValue * 360;
    final colors = [
      Colors.pink,
      Colors.purple,
    ];

    return LinearGradient(
      colors: colors,
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      transform: GradientRotation(angle * 3.1415927 / 180 * 3),
    ).createShader(bounds);
  }

  Shader _pulseColorShader(Rect bounds) {
    final coefA = sin(animationValue * 10 * pi);
    final coefB = sin(animationValue * 5 * pi * 0.5);
    final pulseValue = coefA * coefB;
    final color = Color.lerp(
      const Color.fromARGB(255, 174, 25, 14),
      const Color.fromARGB(255, 196, 15, 15),
      pulseValue,
    )!;

    return LinearGradient(
      colors: [color, color],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ).createShader(bounds);
  }

  Shader _fireColorShader(Rect bounds) {
    final angle = animationValue * 360;
    final colors = [
      const ui.Color.fromARGB(255, 255, 0, 0),
      Colors.orange,
    ];

    return LinearGradient(
      colors: colors,
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      transform: GradientRotation(angle * 3.1415927 / 180 * 5),
    ).createShader(bounds);
  }

  Shader _lightsColorShader(Rect bounds) {
    final rainbowPosition = animationValue * 360;
    final hue = (360 + rainbowPosition) % 360;
    final color = HSLColor.fromAHSL(1.0, hue, 1, 0.5).toColor();

    return LinearGradient(
      colors: [color, color],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ).createShader(bounds);
  }
}
