import 'package:cattyled_app/screens/main/widgets/brightness_slider.dart';
import 'package:cattyled_app/screens/main/widgets/header.dart';
import 'package:cattyled_app/screens/main/widgets/lamp.dart';
import 'package:cattyled_app/screens/main/widgets/mode_select.dart';
import 'package:cattyled_app/screens/main/widgets/mode_sheet.dart';
import 'package:cattyled_app/screens/main/widgets/status_bar.dart';
import 'package:cattyled_app/store/lamp/store.dart';
import 'package:cattyled_app/widgets/update_check.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ScreenMain extends StatelessWidget {
  const ScreenMain({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => LampBloc(),
      child: Center(
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
                const UpdateChecker(),
                SizedBox(
                  height: 170,
                  child: Row(
                    children: [
                      Expanded(
                        child: BlocBuilder<LampBloc, LampState>(
                          buildWhen: (previous, current) {
                            if (previous.isSynced != current.isSynced) {
                              return true;
                            }
                            if (previous.brightness != current.brightness) {
                              return true;
                            }
                            return false;
                          },
                          builder: (context, state) =>
                              DebouncedBrightnessSlider(
                            disabled: !state.isSynced,
                            initial: state.brightness.toDouble(),
                            onChange: (value) {
                              final store = context.read<LampBloc>();
                              store.add(
                                LampCommandEvent(
                                  CommandBrightness(brightness: value.toInt()),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      BlocBuilder<LampBloc, LampState>(
                        buildWhen: (previous, current) {
                          if (previous.isSynced != current.isSynced) {
                            return true;
                          }
                          if (previous.mode != current.mode) return true;
                          return false;
                        },
                        builder: (context, state) => Expanded(
                          flex: 4,
                          child: ModeSelect(
                            mode: state.mode,
                            onTap: state.isSynced
                                ? () => _onModeChangeTap(context, state.mode)
                                : null,
                          ),
                        ),
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
      ),
    );
  }

  void _onModeChangeTap(BuildContext context, LampMode initial) {
    showModalBottomSheet(
      context: context,
      useSafeArea: true,
      isScrollControlled: true,
      builder: (modalContext) => ModeSheetContent(
        initial: initial,
        onModeChange: (mode) {
          final store = context.read<LampBloc>();
          store.add(
            LampCommandEvent(CommandMode(mode: mode)),
          );
        },
      ),
    );
  }
}
