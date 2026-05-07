import 'package:intl/intl.dart';

class CurrencyFormatter {
  CurrencyFormatter._();

  static final NumberFormat _format = NumberFormat('#,##0', 'en_IN');
  static final NumberFormat _decimalFormat = NumberFormat('#,##0.00', 'en_IN');

  // Stores are in paisa (integer), display in Taka
  static String format(int paisa) {
    final taka = paisa / 100;
    if (taka == taka.truncate()) {
      return '৳${_format.format(taka.toInt())}';
    }
    return '৳${_decimalFormat.format(taka)}';
  }

  static String formatTaka(double taka) {
    if (taka == taka.truncateToDouble()) {
      return '৳${_format.format(taka.toInt())}';
    }
    return '৳${_decimalFormat.format(taka)}';
  }

  static int parseTaka(String value) {
    final cleaned = value.replaceAll(RegExp(r'[৳,\s]'), '');
    final parsed = double.tryParse(cleaned) ?? 0;
    return (parsed * 100).round();
  }

  static String shortFormat(int paisa) {
    final taka = paisa / 100;
    if (taka >= 100000) return '৳${(taka / 100000).toStringAsFixed(1)}L';
    if (taka >= 1000) return '৳${(taka / 1000).toStringAsFixed(1)}K';
    return format(paisa);
  }

  static double toPaisa(double taka) => taka * 100;
  static double toTaka(int paisa) => paisa / 100;
}
