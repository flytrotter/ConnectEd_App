import 'package:intl/intl.dart';

String formatDateRange(String startDateTime, String startTime, String endTime) {
  // Parse the starting date and time
  DateTime startDate = DateTime.parse(startDateTime).toUtc();

  // Format date in desired format: September 18, 2024
  String formattedDate = DateFormat('MMMM d, y').format(startDate);

  // Prepare final sentence
  String result = '$formattedDate from $startTime to $endTime';

  return result;
}
