extension ConvertFromDouble on DateTime {
  DateTime? fromDouble(double value) {
    if (value.isInfinite || value.isNaN) {
      return null;
    }

    final hours = value.floor();
    final minutes = ((value - hours) * 60.0).floor();
    final seconds = ((value - (hours + minutes / 60.0)) * 60 * 60).floor();
    return add(Duration(
      hours: hours,
      minutes: minutes,
      seconds: seconds,
    ));
  }

  DateTime utc() {
    return DateTime.utc(year, month, day, hour, minute, second);
  }

  int get dayOfYear {
    final yearStartDate = DateTime(year);
    return difference(yearStartDate).inDays + 1;
  }
}