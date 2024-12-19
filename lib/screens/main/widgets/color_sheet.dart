import 'package:flex_color_picker/flex_color_picker.dart';
import 'package:flutter/material.dart';

class ColorSheetContent extends StatefulWidget {
  final Color initial;
  final void Function(Color mode)? onColorChange;

  const ColorSheetContent({
    super.key,
    required this.initial,
    this.onColorChange,
  });

  @override
  State<ColorSheetContent> createState() => _ColorSheetContentState();
}

class _ColorSheetContentState extends State<ColorSheetContent> {
  late Color screenPickerColor;
  late List<Color> _recentColors = [];

  final Map<ColorSwatch<Object>, String> customSwatches = {
    ColorTools.createPrimarySwatch(const Color(0xffff0000)): 'MyRed',
    ColorTools.createPrimarySwatch(const Color(0xff00ff00)): 'MyGreen',
    ColorTools.createPrimarySwatch(const Color(0xff0000ff)): 'MyBlue',
    ColorTools.createPrimarySwatch(const Color(0xffffffff)): 'MyWhite',
    ColorTools.createPrimarySwatch(const Color(0xff00ffff)): 'MyCyan',
    ColorTools.createPrimarySwatch(const Color(0xffff00ff)): 'MyPurple',
    ColorTools.createPrimarySwatch(const Color(0xffffff00)): 'MyYellow',
    ColorTools.createPrimarySwatch(const Color(0xff6b91bf)): 'MyCustom',
  };

  @override
  void initState() {
    super.initState();
    screenPickerColor = widget.initial;
  }

  @override
  void didUpdateWidget(covariant ColorSheetContent oldWidget) {
    super.didUpdateWidget(oldWidget);
    setState(() {
      screenPickerColor = widget.initial;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final viewInsets = MediaQuery.of(context).viewInsets;

    return SizedBox(
      child: Padding(
        padding: EdgeInsets.only(bottom: viewInsets.bottom),
        child: Padding(
          padding: const EdgeInsets.only(left: 20, right: 20, top: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 100,
                height: 4,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: colorScheme.secondary.withAlpha(50),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                "Выбор цвета",
                style: theme.textTheme.headlineMedium,
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ColorPicker(
                  color: screenPickerColor,
                  onColorChanged: (Color color) => setState(
                    () => screenPickerColor = color,
                  ),
                  onColorChangeEnd: (Color color) {
                    if (widget.onColorChange != null) {
                      widget.onColorChange!(color);
                    }
                  },
                  width: 80,
                  height: 48,
                  borderRadius: 4,
                  columnSpacing: 20,
                  pickersEnabled: const {
                    ColorPickerType.primary: false,
                    ColorPickerType.accent: false,
                    ColorPickerType.wheel: true,
                    ColorPickerType.custom: true,
                  },
                  enableTonalPalette: false,
                  enableShadesSelection: false,
                  padding: const EdgeInsets.all(0),
                  wheelDiameter: 250,
                  showColorCode: true,
                  colorCodeHasColor: true,
                  // Temporary disable recent color pallete due to strange logic
                  showRecentColors: false,
                  recentColors: _recentColors,
                  maxRecentColors: 8,
                  onRecentColorsChanged: (value) {
                    setState(() {
                      _recentColors = value;
                    });
                  },
                  recentColorsSubheading: const Padding(
                    padding: EdgeInsets.only(top: 20),
                    child: Text("Недавние цвета"),
                  ),
                  customColorSwatchesAndNames: customSwatches,
                  pickerTypeLabels: const {
                    ColorPickerType.custom: "Цвета",
                    ColorPickerType.wheel: "Колесо",
                  },
                  pickerTypeTextStyle: theme.textTheme.bodyMedium,
                  copyPasteBehavior: const ColorPickerCopyPasteBehavior(
                    copyFormat: ColorPickerCopyFormat.numHexRRGGBB,
                    longPressMenu: false,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
