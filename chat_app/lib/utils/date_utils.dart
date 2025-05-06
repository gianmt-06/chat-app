import 'package:intl/intl.dart';

bool isToday(DateTime date) {
  final now = DateTime.now();
  return date.year == now.year &&
      date.month == now.month &&
      date.day == now.day;
}

bool isYesterday(DateTime date) {
  final now = DateTime.now();
  final yesterday = DateTime(
    now.year,
    now.month,
    now.day,
  ).subtract(Duration(days: 1));
  return date.year == yesterday.year &&
      date.month == yesterday.month &&
      date.day == yesterday.day;
}

String hourMin(DateTime date) {
  return DateFormat('hh:mm a').format(date);
}

String getDate(DateTime date) {
  return DateFormat('dd/MM/yyyy').format(DateTime.now());
}
