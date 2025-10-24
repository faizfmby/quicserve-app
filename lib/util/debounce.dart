import 'dart:ui';

bool _isDebouncing = false;

Future<void> debounceAsync({
  required VoidCallback action,
  Duration delay = const Duration(milliseconds: 800),
}) async {
  if (_isDebouncing) return;

  _isDebouncing = true;
  action(); // Still works with VoidCallback
  await Future.delayed(delay);
  _isDebouncing = false;
}
