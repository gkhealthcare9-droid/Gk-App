import 'package:intl/intl.dart';

class Helpers {
  String formatToDDMMYYYY(DateTime date) {
    try {
      final formatter = DateFormat('dd-MM-yyyy');
      return formatter.format(date);
    } catch (e) {
      return 'Invalid date';
    }
  }
}
