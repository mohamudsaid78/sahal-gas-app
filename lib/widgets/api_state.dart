import 'package:flutter/material.dart';

import 'empty_state.dart';

class ApiState<T> extends StatelessWidget {
  const ApiState({
    super.key,
    required this.future,
    required this.builder,
    this.empty,
    this.isEmpty,
  });

  final Future<T> future;
  final Widget Function(BuildContext context, T data) builder;
  final Widget? empty;
  final bool Function(T data)? isEmpty;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<T>(
      future: future,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return EmptyState(
            icon: Icons.cloud_off_outlined,
            title: 'Could not load data',
            message: snapshot.error.toString().replaceFirst('Exception: ', ''),
          );
        }
        final data = snapshot.data;
        if (data == null) {
          return empty ??
              const EmptyState(
                icon: Icons.inbox_outlined,
                title: 'No data yet',
                message: 'Add records from the admin panel to get started.',
              );
        }
        if (isEmpty?.call(data) ?? false) {
          return empty ??
              const EmptyState(
                icon: Icons.inbox_outlined,
                title: 'No data yet',
                message: 'Add records from the admin panel to get started.',
              );
        }
        return builder(context, data);
      },
    );
  }
}
