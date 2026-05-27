import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class Helpers {

  // ======================================================
  // FORMAT DATE
  // ======================================================

  static String formatDate(
    DateTime date,
  ) {

    return DateFormat(
      'yyyy-MM-dd',
    ).format(date);

  }

  // ======================================================
  // FORMAT HUMAN DATE
  // ======================================================

  static String formatHumanDate(
    DateTime date,
  ) {

    return DateFormat(
      'MMM dd, yyyy',
    ).format(date);

  }

  // ======================================================
  // FORMAT TIME
  // ======================================================

  static String formatTime(
    DateTime date,
  ) {

    return DateFormat(
      'hh:mm a',
    ).format(date);

  }

  // ======================================================
  // SHOW SNACKBAR
  // ======================================================

  static void showSnackBar({
    required BuildContext context,
    required String message,
    Color backgroundColor =
        Colors.black,
  }) {

    ScaffoldMessenger.of(context)
        .showSnackBar(

      SnackBar(

        content: Text(message),

        backgroundColor:
            backgroundColor,

        behavior:
            SnackBarBehavior.floating,

      ),

    );

  }

  // ======================================================
  // VALIDATE EMAIL
  // ======================================================

  static bool isValidEmail(
    String email,
  ) {

    final regex = RegExp(
      r'^[^@]+@[^@]+\.[^@]+',
    );

    return regex.hasMatch(email);

  }

  // ======================================================
  // VALIDATE PHONE
  // ======================================================

  static bool isValidPhone(
    String phone,
  ) {

    final regex = RegExp(
      r'^\+?[0-9]{7,15}$',
    );

    return regex.hasMatch(phone);

  }

  // ======================================================
  // FORMAT CURRENCY
  // ======================================================

  static String formatCurrency(
    double amount,
  ) {

    return NumberFormat.currency(
      symbol: 'Rs ',
      decimalDigits: 2,
    ).format(amount);

  }

  // ======================================================
  // CALCULATE BMI
  // ======================================================

  static double calculateBMI({
    required double weight,
    required double height,
  }) {

    final heightInMeters =
        height / 100;

    return weight /
        (
          heightInMeters *
          heightInMeters
        );

  }

  // ======================================================
  // BMI CATEGORY
  // ======================================================

  static String getBMICategory(
    double bmi,
  ) {

    if (bmi < 18.5) {
      return 'Underweight';
    }

    if (bmi < 25) {
      return 'Normal';
    }

    if (bmi < 30) {
      return 'Overweight';
    }

    return 'Obese';

  }

  // ======================================================
  // NEXT PERIOD DATE
  // ======================================================

  static DateTime calculateNextPeriod({
    required DateTime lastPeriod,
    int cycleLength = 28,
  }) {

    return lastPeriod.add(
      Duration(days: cycleLength),
    );

  }

  // ======================================================
  // OVULATION DATE
  // ======================================================

  static DateTime calculateOvulation({
    required DateTime lastPeriod,
    int cycleLength = 28,
  }) {

    return lastPeriod.add(
      Duration(
        days: cycleLength - 14,
      ),
    );

  }

  // ======================================================
  // DAYS DIFFERENCE
  // ======================================================

  static int daysBetween(
    DateTime from,
    DateTime to,
  ) {

    return to
        .difference(from)
        .inDays;

  }

  // ======================================================
  // CAPITALIZE
  // ======================================================

  static String capitalize(
    String text,
  ) {

    if (text.isEmpty) {
      return text;
    }

    return text[0]
            .toUpperCase() +
        text.substring(1);

  }

  // ======================================================
  // TITLE CASE
  // ======================================================

  static String toTitleCase(
    String text,
  ) {

    return text
        .split(' ')
        .map(
          (word) =>
              capitalize(word),
        )
        .join(' ');

  }

  // ======================================================
  // MASK EMAIL
  // ======================================================

  static String maskEmail(
    String email,
  ) {

    final parts =
        email.split('@');

    final name =
        parts.first;

    final domain =
        parts.last;

    if (name.length <= 2) {
      return email;
    }

    final masked =
        '${name.substring(0, 2)}****';

    return '$masked@$domain';

  }

  // ======================================================
  // MASK PHONE
  // ======================================================

  static String maskPhone(
    String phone,
  ) {

    if (phone.length < 5) {
      return phone;
    }

    return '${phone.substring(0, 3)}*****${phone.substring(phone.length - 2)}';

  }

  // ======================================================
  // LOADING DIALOG
  // ======================================================

  static void showLoadingDialog(
    BuildContext context,
  ) {

    showDialog(

      context: context,

      barrierDismissible: false,

      builder: (_) {

        return const Center(
          child:
              CircularProgressIndicator(),
        );

      },

    );

  }

  // ======================================================
  // HIDE LOADING
  // ======================================================

  static void hideLoading(
    BuildContext context,
  ) {

    Navigator.of(context).pop();

  }

  // ======================================================
  // DEBUG PRINT
  // ======================================================

  static void log(
    dynamic message,
  ) {

    debugPrint(
      message.toString(),
    );

  }

}