import 'package:flutter/widgets.dart';

class AppNavigation extends InheritedWidget {
  const AppNavigation({
    super.key,
    required this.onSelect,
    required super.child,
  });

  final ValueChanged<int> onSelect;

  static AppNavigation? maybeOf(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<AppNavigation>();
  }

  @override
  bool updateShouldNotify(AppNavigation oldWidget) {
    return onSelect != oldWidget.onSelect;
  }
}
