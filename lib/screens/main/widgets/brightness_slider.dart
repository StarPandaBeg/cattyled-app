import 'package:flutter/material.dart';
import 'package:flutter_xlider/flutter_xlider.dart';

class BrightnessSlider extends StatefulWidget {
  final double initialValue;
  final Function(int, dynamic, dynamic)? onDragging;

  const BrightnessSlider({super.key, this.onDragging, this.initialValue = 0});

  @override
  State<BrightnessSlider> createState() => _BrightnessSliderState();
}

class _BrightnessSliderState extends State<BrightnessSlider> {
  double _value = 0;

  bool get _invertColors => _value > 25;
  double get _iconRotationAngle => _value * 0.01;

  @override
  void initState() {
    super.initState();
    _value = widget.initialValue;
  }

  @override
  void didUpdateWidget(covariant BrightnessSlider oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialValue != oldWidget.initialValue &&
        widget.initialValue != _value) {
      setState(() {
        _value = widget.initialValue;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Stack(
      children: [
        FlutterSlider(
          values: [_value],
          min: 0,
          max: 255,
          axis: Axis.vertical,
          rtl: true,
          onDragging: (handlerIndex, lowerValue, upperValue) {
            setState(() {
              _value = lowerValue;
            });
            if (widget.onDragging != null) {
              widget.onDragging!(handlerIndex, lowerValue, upperValue);
            }
          },
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: BorderRadius.circular(8),
          ),
          handler: FlutterSliderHandler(
            child: const Material(
              type: MaterialType.canvas,
            ),
          ),
          trackBar: FlutterSliderTrackBar(
            activeTrackBar: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: colorScheme.secondary,
            ),
            activeTrackBarHeight: double.infinity,
            inactiveTrackBar: BoxDecoration(color: colorScheme.surface),
          ),
          tooltip: FlutterSliderTooltip(
            disabled: true,
          ),
          handlerWidth: 0,
        ),
        IgnorePointer(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Padding(
                  padding: const EdgeInsets.all(10),
                  child: Transform.rotate(
                    angle: _iconRotationAngle,
                    child: Icon(
                      Icons.sunny,
                      color: _invertColors
                          ? colorScheme.surface
                          : colorScheme.secondary,
                      size: 20,
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ],
    );
  }
}
