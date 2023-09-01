class DateComponents {

}

class TimeComponents {
  final int hours;
  final int minutes;
  final int seconds;

  TimeComponents(this.hours, this.minutes, this.seconds);

  static TimeComponents? fromDouble(double value) {
    if (value.isInfinite || value.isNaN) {
      return null;
    }

    final hours = value.floor();
    final minutes = ((value - hours) * 60.0).floor();
    final seconds = ((value - (hours + minutes / 60.0)) * 60 * 60).floor();
    return TimeComponents(hours, minutes, seconds);
  }

}