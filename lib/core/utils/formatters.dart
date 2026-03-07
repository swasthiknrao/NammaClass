import 'package:intl/intl.dart';

/// Date and currency formatters for NammaClass.
class AppFormatters {
  AppFormatters._();

  /// Display date: '5 Mar 2026'
  static String formatDate(DateTime date) =>
      DateFormat('d MMM yyyy').format(date);

  /// Display date with day: 'Thu, 5 Mar'
  static String formatDateWithDay(DateTime date) =>
      DateFormat('EEE, d MMM').format(date);

  /// Display time: '10:30 AM'
  static String formatTime(DateTime date) => DateFormat('h:mm a').format(date);

  /// INR currency from paise: 250000 → '₹2,500.00'
  static String formatPaise(int paise) {
    final rupees = paise / 100.0;
    return NumberFormat.currency(
      locale: 'en_IN',
      symbol: '₹',
      decimalDigits: 0,
    ).format(rupees);
  }

  /// INR currency from rupees
  static String formatRupees(double rupees) => NumberFormat.currency(
    locale: 'en_IN',
    symbol: '₹',
    decimalDigits: 0,
  ).format(rupees);

  /// Compact: 1250000 → '₹12.5L'
  static String formatPaiseCompact(int paise) {
    final rupees = paise / 100.0;
    if (rupees >= 10000000) {
      return '₹${(rupees / 10000000).toStringAsFixed(1)}Cr';
    }
    if (rupees >= 100000) {
      return '₹${(rupees / 100000).toStringAsFixed(1)}L';
    }
    if (rupees >= 1000) {
      return '₹${(rupees / 1000).toStringAsFixed(1)}K';
    }
    return '₹${rupees.toStringAsFixed(0)}';
  }

  /// Time ago: '2 hrs ago', 'Just now'
  static String timeAgo(DateTime dateTime) {
    final diff = DateTime.now().difference(dateTime);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return formatDate(dateTime);
  }

  /// Month year: 'March 2026'
  static String formatMonthYear(DateTime date) =>
      DateFormat('MMMM yyyy').format(date);

  /// Short date for chips: 'Mar 5'
  static String formatShortDate(DateTime date) =>
      DateFormat('MMM d').format(date);

  // ── Convenience aliases used in screens ──────────────────────────────────────

  /// currency(int rupees) → '₹X,XXX'
  static String currency(int rupees) => formatRupees(rupees.toDouble());

  /// shortDate(DateTime) → 'Mar 5'
  static String shortDate(DateTime date) => formatShortDate(date);

  /// time(DateTime) → '10:30 AM'
  static String time(DateTime date) => formatTime(date);
}
