class DateUtil {
  static int daysLeft(DateTime date) {
    DateTime now = DateTime.now();
    int difference = date.difference(now).inDays;
    return difference;
  }
}
