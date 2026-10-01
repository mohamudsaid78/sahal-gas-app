import 'package:intl/intl.dart';

class AppFormatters {
  static final _money = NumberFormat.currency(symbol: r'$', decimalDigits: 2);
  static final _dateTime = DateFormat('MMM d, yyyy - h:mm a');

  static String money(num value) => _money.format(value);

  static String dateTime(DateTime? value) {
    if (value == null) return 'No date';
    return _dateTime.format(value);
  }
}
