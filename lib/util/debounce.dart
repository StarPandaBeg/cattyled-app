import 'dart:async';

mixin DebounceMixin {
  Timer? _debounceTimer;

  void debounce(Duration duration, void Function() action) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(duration, action);
  }

  void disposeDebounce() {
    _debounceTimer?.cancel();
  }
}
