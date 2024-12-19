import 'package:cattyled_app/screens/main/widgets/color_sheet.dart';
import 'package:cattyled_app/store/lamp/store.dart';
import 'package:cattyled_app/widgets/status_icon.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class StatusBar extends StatelessWidget {
  const StatusBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(0),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            BlocBuilder<LampBloc, LampState>(
              buildWhen: (previous, current) {
                if (previous.isSynced != current.isSynced) return true;
                if (previous.mode != current.mode) {
                  return true;
                }
                return false;
              },
              builder: (context, state) {
                if (!state.isSynced || state.mode != LampMode.classic) {
                  return const SizedBox(width: 32);
                }
                return const ColorChangeButton();
              },
            ),
            BlocBuilder<LampBloc, LampState>(
              buildWhen: (previous, current) {
                if (previous.isSynced != current.isSynced) return true;
                if (previous.isRemoteActive != current.isRemoteActive) {
                  return true;
                }
                return false;
              },
              builder: (context, state) => Row(
                children: [
                  const StatusIcon(Icons.cloud_sync),
                  const SizedBox(width: 5),
                  StatusIcon(
                    Icons.cloud,
                    enabled: state.isSynced && state.isRemoteActive,
                  ),
                ],
              ),
            ),
            const SizedBox(
              width: 32,
              height: 32,
            ),
          ],
        ),
      ),
    );
  }
}

class ColorChangeButton extends StatelessWidget {
  const ColorChangeButton({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LampBloc, LampState>(
      buildWhen: (previous, current) => previous.color != current.color,
      builder: (context, state) => Stack(
        alignment: Alignment.center,
        children: [
          GestureDetector(
            onTap: () => _onColorChangeTap(context, state.color),
            child: Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: state.color,
              ),
            ),
          ),
          const IgnorePointer(
            child: Icon(
              Icons.edit,
              size: 16,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  void _onColorChangeTap(BuildContext context, Color initial) {
    showModalBottomSheet(
      context: context,
      useSafeArea: true,
      isScrollControlled: true,
      builder: (modalContext) => ColorSheetContent(
        initial: initial,
        onColorChange: (color) {
          final store = context.read<LampBloc>();
          store.add(
            LampCommandEvent(CommandColor(color: color)),
          );
        },
      ),
    );
  }
}
