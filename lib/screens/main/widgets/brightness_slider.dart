import 'dart:async';

import 'package:cattyled_app/widgets/brightness_slider.dart';
import 'package:flutter/material.dart';

class DebouncedBrightnessSlider extends StatefulWidget {
  final double initial;
  final void Function(double value)? onChange;
  final bool disabled;

  const DebouncedBrightnessSlider({
    super.key,
    required this.initial,
    this.onChange,
    this.disabled = false,
  });

  @override
  State<DebouncedBrightnessSlider> createState() =>
      _DebouncedBrightnessSliderState();
}

class _DebouncedBrightnessSliderState extends State<DebouncedBrightnessSlider> {
  double _currentSliderValue = 0;
  Timer? _debounceTimer;

  @override
  void initState() {
    super.initState();
    setState(() {
      _currentSliderValue = widget.initial;
    });
  }

  @override
  void didUpdateWidget(covariant DebouncedBrightnessSlider oldWidget) {
    super.didUpdateWidget(oldWidget);
    setState(() {
      _currentSliderValue = widget.initial;
    });
  }

  @override
  Widget build(BuildContext context) {
    return BrightnessSlider(
      initialValue: _currentSliderValue,
      onDragging: (p0, p1, p2) {
        _onSliderChanged(p1);
      },
      disabled: widget.disabled,
    );
  }

  void _onSliderChanged(double value) {
    if (value == _currentSliderValue) return;

    setState(() {
      _currentSliderValue = value;
    });
    _debounceTimer?.cancel();
    _debounceTimer = Timer(
      const Duration(milliseconds: 50),
      () {
        if (widget.onChange == null) return;
        widget.onChange!(value);
      },
    );
  }
}
