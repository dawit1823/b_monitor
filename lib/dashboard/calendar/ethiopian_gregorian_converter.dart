class EthiopianGregorianConverter {
  static DateTime ethiopianToGregorian(int year, int month, int day) {
    final jdn = _ethiopicToJdn(year, month, day);
    return _jdnToGregorian(jdn);
  }

  static EthiopianDate gregorianToEthiopian(DateTime date) {
    final jdn = _gregorianToJdn(date.year, date.month, date.day);
    return _jdnToEthiopic(jdn);
  }

  static bool isValidEthiopianDate(int year, int month, int day) {
    if (month < 1 || month > 13) return false;
    if (day < 1) return false;
    if (month <= 12 && day > 30) return false;
    if (month == 13) {
      return day <= (isEthiopianLeapYear(year) ? 6 : 5);
    }
    return true;
  }

  static int daysInEthiopianMonth(int year, int month) {
    if (month == 13) return isEthiopianLeapYear(year) ? 6 : 5;
    return 30;
  }

  static bool isEthiopianLeapYear(int year) => (year % 4) == 3;

  // Corrected JDN calculation
  static int _ethiopicToJdn(int year, int month, int day) {
    return 1724221 + // Corrected epoch
        (year - 1) * 365 + // Use year-1 instead of eraYear
        (year ~/ 4) +
        30 * (month - 1) +
        (day - 1); // Subtract 1 from day
  }

  static DateTime _jdnToGregorian(int jdn) {
    final a = jdn + 32044;
    final b = (4 * a + 3) ~/ 146097;
    var c = a - (146097 * b) ~/ 4;
    final d = (4 * c + 3) ~/ 1461;
    c -= (1461 * d) ~/ 4;
    final m = (5 * c + 2) ~/ 153;
    final day = c - (153 * m + 2) ~/ 5 + 1;
    final month = m + 3 - 12 * (m ~/ 10);
    final year = 100 * b + d - 4800 + (m ~/ 10);
    return DateTime(year, month, day);
  }

  static int _gregorianToJdn(int year, int month, int day) {
    final a = (14 - month) ~/ 12;
    final y = year + 4800 - a;
    final m = month + 12 * a - 3;
    return day +
        ((153 * m + 2) ~/ 5) +
        (365 * y) +
        (y ~/ 4) -
        (y ~/ 100) +
        (y ~/ 400) -
        32045;
  }

  static EthiopianDate _jdnToEthiopic(int jdn) {
    const epoch = 1724221; // Corrected epoch to match conversion
    var remainder = jdn - epoch;
    var year = (4 * remainder) ~/ 1461;
    remainder = remainder % 1461;

    if (remainder < 0) {
      remainder += 1461;
      year--;
    }

    final month = (remainder ~/ 30) + 1;
    final day = (remainder % 30) + 1;

    // Handle Pagume (month 13)
    if (month > 13) {
      return EthiopianDate(year + 1, 1, day);
    }
    return EthiopianDate(year, month, day);
  }
}

class EthiopianDate {
  final int year;
  final int month;
  final int day;

  EthiopianDate(this.year, this.month, this.day);
}
