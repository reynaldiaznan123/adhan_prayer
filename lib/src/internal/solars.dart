import 'dart:math';

import 'package:adhan_prayer/src/coordinates.dart';
import 'package:adhan_prayer/src/internal/astronomical.dart';
import 'package:adhan_prayer/src/utils/calendrical.dart';
import 'package:adhan_prayer/src/utils/math.dart';

class SolarTime {
  late final LocationCoordinates observer;
  late final SolarCoordinates current;
  late final SolarCoordinates prev;
  late final SolarCoordinates next;

  late final double? approximateTransit;
  late final double transit;
  late final double sunrise;
  late final double sunset;

  SolarTime(DateTime date, LocationCoordinates coordinates) {
    final today = date;
    final tomorrow = today.add(const Duration(days: 1));
    final yesterday = today.subtract(const Duration(days: 1));

    observer = coordinates;

    current = SolarCoordinates(CalendricalUtil.julianDayByDate(today));
    prev = SolarCoordinates(CalendricalUtil.julianDayByDate(yesterday));
    next = SolarCoordinates(CalendricalUtil.julianDayByDate(tomorrow));

    approximateTransit = Astronomical.approximateTransit(
      coordinates.longitude,
      current.apparentSiderealTime,
      current.rightAscension,
    );
    const altitude = -50.0 / 60.0;

    transit = Astronomical.correctedTransit(
      approximateTransit!,
      coordinates.longitude,
      current.apparentSiderealTime,
      current.rightAscension,
      prev.rightAscension,
      next.rightAscension,
    );

    sunrise = Astronomical.correctedHourAngle(
      approximateTransit!,
      altitude,
      coordinates,
      false,
      current.apparentSiderealTime,
      current.rightAscension,
      prev.rightAscension,
      next.rightAscension,
      current.declination,
      prev.declination,
      next.declination,
    );

    sunset = Astronomical.correctedHourAngle(
      approximateTransit!,
      altitude,
      coordinates,
      true,
      current.apparentSiderealTime,
      current.rightAscension,
      prev.rightAscension,
      next.rightAscension,
      current.declination,
      prev.declination,
      next.declination,
    );
  }

  double hourAngle(double angle, bool afterTransit) {
    return Astronomical.correctedHourAngle(
      approximateTransit ?? 0.0,
      angle,
      observer,
      afterTransit,
      current.apparentSiderealTime,
      current.rightAscension,
      prev.rightAscension,
      next.rightAscension,
      current.declination,
      prev.declination,
      next.declination,
    );
  }

  // hours from transit
  double afternoon(double shadowLength) {
    // TODO (from Swift version) source shadow angle calculation
    final tangent = (observer.latitude - current.declination).abs();
    final inverse = shadowLength + tan(MathUtil.radians(tangent));
    final angle = MathUtil.degrees(atan(1.0 / inverse));

    return hourAngle(angle, true);
  }
}

class SolarCoordinates {
  /// The declination of the sun, the angle between
  /// the rays of the Sun and the plane of the Earth's
  /// equator, in degrees.
  late final double _declination;
  double get declination => _declination;

  ///  Right ascension of the Sun, the angular distance on the
  /// celestial equator from the vernal equinox to the hour circle,
  /// in degrees.
  late final double _rightAscension;
  double get rightAscension => _rightAscension;

  ///  Apparent sidereal time, the hour angle of the vernal
  /// equinox, in degrees.
  late final double _apparentSiderealTime;
  double get apparentSiderealTime => _apparentSiderealTime;

  SolarCoordinates(double julianDay) {
    final T = CalendricalUtil.julianCentury(julianDay);
    final L0 = Astronomical.meanSolarLongitude(T);
    final Lp = Astronomical.meanLunarLongitude(T);
    final omega = Astronomical.ascendingLunarNodeLongitude(T);
    final lambda = MathUtil.radians(Astronomical.apparentSolarLongitude(T, L0));

    final theta0 = Astronomical.meanSiderealTime(T);
    final deltaPsi = Astronomical.nutationInLongitude(T, L0, Lp, omega);
    final deltaEpsilon = Astronomical.nutationInObliquity(T, L0, Lp, omega);

    final epsilon0 = Astronomical.meanObliquityOfTheEcliptic(T);
    final epsilonApparent = MathUtil.radians(Astronomical.apparentObliquityOfTheEcliptic(T, epsilon0));

    /* Equation from Astronomical Algorithms page 165 */
    _declination = MathUtil.degrees(asin(sin(epsilonApparent) * sin(lambda)));

    /* Equation from Astronomical Algorithms page 165 */
    _rightAscension = MathUtil.unwindAngle(
      MathUtil.degrees(atan2(cos(epsilonApparent) * sin(lambda), cos(lambda))),
    );

    /* Equation from Astronomical Algorithms page 88 */
    _apparentSiderealTime = theta0 + (((deltaPsi * 3600) * cos(MathUtil.radians(epsilon0 + deltaEpsilon))) / 3600);
  }
}
