import 'package:flutter/material.dart';
import 'package:flutter_xlider/flutter_xlider.dart';

class BrightnessSlider extends StatefulWidget {
  final Function(int, dynamic, dynamic)? onDragging;

  const BrightnessSlider({super.key, this.onDragging});

  @override
  State<BrightnessSlider> createState() => _BrightnessSliderState();
}

class _BrightnessSliderState extends State<BrightnessSlider> {
  double _value = 0;

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
            activeTrackBarHeight: 100,
            inactiveTrackBar: BoxDecoration(color: colorScheme.surface),
          ),
          tooltip: FlutterSliderTooltip(
            disabled: true,
          ),
          handlerWidth: 0,
        ),
        Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Padding(
                padding: const EdgeInsets.all(10),
                child: Transform.rotate(
                  angle: _value * 0.01,
                  child: Icon(
                    Icons.sunny,
                    color: _value > 25
                        ? colorScheme.surface
                        : colorScheme.secondary,
                    size: 20,
                  ),
                ),
              )
            ],
          ),
        ),
      ],
    );
  }
}
