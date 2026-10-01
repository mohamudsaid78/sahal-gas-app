class RowReader {
  static String text(
    Map<String, dynamic> row,
    List<String> keys, {
    String fallback = '',
  }) {
    final value = _value(row, keys);
    if (value == null) return fallback;
    final text = value.toString();
    return text.isEmpty ? fallback : text;
  }

  static int integer(
    Map<String, dynamic> row,
    List<String> keys, {
    int fallback = 0,
  }) {
    final value = _value(row, keys);
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '') ?? fallback;
  }

  static double decimal(
    Map<String, dynamic> row,
    List<String> keys, {
    double fallback = 0,
  }) {
    final value = _value(row, keys);
    if (value is double) return value;
    if (value is num) return value.toDouble();
    return double.tryParse(value?.toString() ?? '') ?? fallback;
  }

  static bool boolean(
    Map<String, dynamic> row,
    List<String> keys, {
    bool fallback = true,
  }) {
    final value = _value(row, keys);
    if (value is bool) return value;
    if (value is num) return value != 0;
    final normalized = value?.toString().trim().toLowerCase();
    if (normalized == null || normalized.isEmpty) return fallback;
    return ['1', 'true', 'yes', 'active', 'enabled'].contains(normalized);
  }

  static DateTime? date(Map<String, dynamic> row, List<String> keys) {
    final value = _value(row, keys);
    if (value == null) return null;
    return DateTime.tryParse(value.toString());
  }

  static Object? _value(Map<String, dynamic> row, List<String> keys) {
    for (final key in keys) {
      if (row.containsKey(key) && row[key] != null) return row[key];
    }
    return null;
  }
}
