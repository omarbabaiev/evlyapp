import 'package:intl/intl.dart';
import '../localization/app_strings.dart';

class DateUtils {
  /// Tarixi format edir: bugün isə "Bugün HH:mm", dünən isə "Dünən HH:mm", əks halda "d MMM yyyy" və ya "d MMM" (cari il)
  static String formatDate(String dateString) {
    try {
      DateTime dateTime = DateTime.parse(dateString);
      DateTime now = DateTime.now();

      // Bugünkü tarixi yoxla
      bool isToday = dateTime.year == now.year &&
          dateTime.month == now.month &&
          dateTime.day == now.day;

      // Dünənki tarixi yoxla
      DateTime yesterday = now.subtract(const Duration(days: 1));
      bool isYesterday = dateTime.year == yesterday.year &&
          dateTime.month == yesterday.month &&
          dateTime.day == yesterday.day;

      if (isToday) {
        return '${AppStrings.today} ${DateFormat('HH:mm').format(dateTime)}';
      } else if (isYesterday) {
        return '${AppStrings.yesterday} ${DateFormat('HH:mm').format(dateTime)}';
      } else {
        String turkishMonth = AppStrings.monthNames[dateTime.month];
        // Cari il isə ili göstərmə
        if (dateTime.year == now.year) {
          return '${dateTime.day} $turkishMonth';
        } else {
          return '${dateTime.day} $turkishMonth ${dateTime.year}';
        }
      }
    } catch (e) {
      return dateString; // Xəta olduqda orijinal stringi qaytar
    }
  }

  /// DateTime obyektindən format edir
  static String formatDateTime(DateTime dateTime) {
    DateTime now = DateTime.now();

    // Bugünkü tarixi yoxla
    bool isToday = dateTime.year == now.year &&
        dateTime.month == now.month &&
        dateTime.day == now.day;

    // Dünənki tarixi yoxla
    DateTime yesterday = now.subtract(const Duration(days: 1));
    bool isYesterday = dateTime.year == yesterday.year &&
        dateTime.month == yesterday.month &&
        dateTime.day == yesterday.day;

    if (isToday) {
      return '${AppStrings.today} ${DateFormat('HH:mm').format(dateTime)}';
    } else if (isYesterday) {
      return '${AppStrings.yesterday} ${DateFormat('HH:mm').format(dateTime)}';
    } else {
      String turkishMonth = AppStrings.monthNames[dateTime.month];
      // Cari il isə ili göstərmə
      if (dateTime.year == now.year) {
        return '${dateTime.day} $turkishMonth';
      } else {
        return '${dateTime.day} $turkishMonth ${dateTime.year}';
      }
    }
  }

  /// Timestamp-dan format edir
  static String formatTimestamp(int timestamp) {
    DateTime dateTime = DateTime.fromMillisecondsSinceEpoch(timestamp);
    return formatDateTime(dateTime);
  }
}
