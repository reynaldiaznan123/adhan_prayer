import 'dart:math';

class MathUtil {
  // /// Constant factor to convert and angle from degrees to radians.
  // static double get degrees2Radians => pi / 180.0;

  // /// Constant factor to convert and angle from radians to degrees.
  // static double get radians2Degrees => 180.0 / pi;

  /// Convert [radians] to degrees.
  static double degrees(double radians) => (radians * 180.0) / pi;

  /// Convert [degrees] to radians.
  static double radians(double degrees) => (degrees * pi) / 180.0;

  static double normalizeWithBound(double value, double max) {
    return value - (max * (value / max).floorToDouble());
  }

  static double unwindAngle(double value) {
    return normalizeWithBound(value, 360);
  }

  static double closestAngle(double angle) {
    if (angle >= -180 && angle <= 180) {
      return angle;
    }
    return angle - (360 * (angle / 360).roundToDouble());
  }

  static double normalizeToScale(double number, double max) {
    return number - (max * ((number / max).floor()));
  }

  static double quadrantShiftAngle(double angle) {
    if (angle >= -180 && angle <= 180) {
      return angle;
    }

    return angle - (360 * (angle / 360).round());
  }
}
