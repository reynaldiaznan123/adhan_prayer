import 'dart:math';

import 'package:adhan_prayer/src/coordinates.dart';
import 'package:adhan_prayer/src/utils/calendar.dart';
import 'package:adhan_prayer/src/utils/math.dart';

class Astronomical {
  /// The geometric mean longitude of the sun in degrees.
  /// @param T the julian century
  /// @return the geometric longitude of the sun in degrees
  static double meanSolarLongitude(double T) {
    /* Equation from Astronomical Algorithms page 163 */
    const term1 = 280.4664567;
    final term2 = 36000.76983 * T;
    final term3 = 0.0003032 * pow(T, 2);
    final L0 = term1 + term2 + term3;
    return MathUtil.unwindAngle(L0);
  }

  /// The geometric mean longitude of the moon in degrees
  /// @param T the julian century
  /// @return the geometric mean longitude of the moon in degrees
  static double meanLunarLongitude(double julianCentury) {
    final T = julianCentury;

    /* Equation from Astronomical Algorithms page 144 */
    const term1 = 218.3165;
    final term2 = 481267.8813 * T;
    final Lp = term1 + term2;
    return MathUtil.unwindAngle(Lp);
  }

  /// The ascending lunar node longitude
  /// @param T the julian century
  /// @return the ascending lunar node longitude
  static double ascendingLunarNodeLongitude(double julianCentury) {
    final T = julianCentury;

    /* Equation from Astronomical Algorithms page 144 */
    const term1 = 125.04452;
    final term2 = 1934.136261 * T;
    final term3 = 0.0020708 * pow(T, 2);
    final term4 = pow(T, 3) / 450000;
    final omega = term1 - term2 + term3 + term4;
    return MathUtil.unwindAngle(omega);
  }

  /// The mean anomaly of the sun
  /// @param T the julian century
  /// @return the mean solar anomaly
  static double meanSolarAnomaly(double julianCentury) {
    final T = julianCentury;

    /* Equation from Astronomical Algorithms page 163 */
    const term1 = 357.52911;
    final term2 = 35999.05029 * T;
    final term3 = 0.0001537 * pow(T, 2);
    final M = term1 + term2 - term3;
    return MathUtil.unwindAngle(M);
  }

  /// The Sun's equation of the center in degrees.
  /// @param T the julian century
  /// @param M the mean anomaly
  /// @return the sun's equation of the center in degrees
  static double solarEquationOfTheCenter(double julianCentury, double meanAnomaly) {
    final T = julianCentury;
    final M = meanAnomaly;

    /* Equation from Astronomical Algorithms page 164 */
    final Mrad = MathUtil.radians(M);
    final term1 = (1.914602 - (0.004817 * T) - (0.000014 * pow(T, 2))) * sin(Mrad);
    final term2 = (0.019993 - (0.000101 * T)) * sin(2 * Mrad);
    final term3 = 0.000289 * sin(3 * Mrad);
    return term1 + term2 + term3;
  }

  /// The apparent longitude of the Sun, referred to the true equinox of the date.
  /// @param T the julian century
  /// @param L0 the mean longitude
  /// @return the true equinox of the date
  static double apparentSolarLongitude(double julianCentury, double meanLongitude) {
    final T = julianCentury;
    final L0 = meanLongitude;

    /* Equation from Astronomical Algorithms page 164 */
    final longitude = L0 + solarEquationOfTheCenter(T, meanSolarAnomaly(T));
    final omega = 125.04 - (1934.136 * T);
    final lambda = longitude - 0.00569 - (0.00478 * sin(MathUtil.radians(omega)));
    return MathUtil.unwindAngle(lambda);
  }

  /// The mean obliquity of the ecliptic in degrees
  /// formula adopted by the International Astronomical Union.
  /// @param T the julian century
  /// @return the mean obliquity of the ecliptic in degrees
  static double meanObliquityOfTheEcliptic(double julianCentury) {
    final T = julianCentury;

    /* Equation from Astronomical Algorithms page 147 */
    const term1 = 23.439291;
    final term2 = 0.013004167 * T;
    final term3 = 0.0000001639 * pow(T, 2);
    final term4 = 0.0000005036 * pow(T, 3);
    return term1 - term2 - term3 + term4;
  }

  /// The mean obliquity of the ecliptic, corrected for calculating the
  /// apparent position of the sun, in degrees.
  /// @param T the julian century
  /// @param epsilonOf0 the mean obliquity of the ecliptic
  /// @return the corrected mean obliquity of the ecliptic in degrees
  static double apparentObliquityOfTheEcliptic(double julianCentury, double meanObliquityOfTheEcliptic) {
    final T = julianCentury;
    final epsilonOf0 = meanObliquityOfTheEcliptic;

    /* Equation from Astronomical Algorithms page 165 */
    final O = 125.04 - (1934.136 * T);
    return epsilonOf0 + (0.00256 * cos(MathUtil.radians(O)));
  }

  /// Mean sidereal time, the hour angle of the vernal equinox, in degrees.
  /// @param T the julian century
  /// @return the mean sidereal time in degrees
  static double meanSiderealTime(double julianCentury) {
    final T = julianCentury;

    /* Equation from Astronomical Algorithms page 165 */
    final JD = (T * 36525) + 2451545.0;
    const term1 = 280.46061837;
    final term2 = 360.98564736629 * (JD - 2451545);
    final term3 = 0.000387933 * pow(T, 2);
    final term4 = pow(T, 3) / 38710000;
    final theta = term1 + term2 + term3 - term4;
    return MathUtil.unwindAngle(theta);
  }

  /// Get the nutation in longitude
  /// @param T the julian century
  /// @param L0 the solar longitude
  /// @param Lp the lunar longitude
  /// @param Ω the ascending node
  /// @return the nutation in longitude
  static double nutationInLongitude(
    double julianCentury,
    double solarLongitude,
    double lunarLongitude,
    double ascendingNode,
  ) {
    // final T = julianCentury;
    final L0 = solarLongitude;
    final Lp = lunarLongitude;
    final omega = ascendingNode;

    /* Equation from Astronomical Algorithms page 144 */
    final term1 = (-17.2 / 3600) * sin(MathUtil.radians(omega));
    final term2 = (1.32 / 3600) * sin(2 * MathUtil.radians(L0));
    final term3 = (0.23 / 3600) * sin(2 * MathUtil.radians(Lp));
    final term4 = (0.21 / 3600) * sin(2 * MathUtil.radians(omega));
    return term1 - term2 - term3 + term4;
  }

  /// Get the nutation in obliquity
  /// @param T the julian century
  /// @param L0 the solar longitude
  /// @param Lp the lunar longitude
  /// @param Ω the ascending node
  /// @return the nutation in obliquity
  static double nutationInObliquity(
    double julianCentury,
    double solarLongitude,
    double lunarLongitude,
    double ascendingNode,
  ) {
    // final T = julianCentury;
    final L0 = solarLongitude;
    final Lp = lunarLongitude;
    final omega = ascendingNode;

    /* Equation from Astronomical Algorithms page 144 */
    final term1 = (9.2 / 3600) * cos(MathUtil.radians(omega));
    final term2 = (0.57 / 3600) * cos(2 * MathUtil.radians(L0));
    final term3 = (0.10 / 3600) * cos(2 * MathUtil.radians(Lp));
    final term4 = (0.09 / 3600) * cos(2 * MathUtil.radians(omega));
    return term1 + term2 + term3 - term4;
  }

  /// Return the altitude of the celestial body
  /// @param φ the observer latitude
  /// @param δ the declination
  /// @param H the local hour angle
  /// @return the altitude of the celestial body
  static double altitudeOfCelestialBody(
    double observerLatitude,
    double declination,
    double localHourAngle,
  ) {
    final phi = observerLatitude;
    final delta = declination;
    final H = localHourAngle;

    /* Equation from Astronomical Algorithms page 93 */
    final term1 = sin(MathUtil.radians(phi)) * sin(MathUtil.radians(delta));
    final term2 = cos(MathUtil.radians(phi)) * cos(MathUtil.radians(delta)) * cos(MathUtil.radians(H));
    return MathUtil.degrees(asin(term1 + term2));
  }

  /// Return the approximate transite
  /// @param L the longitude
  /// @param Θ0 the sidereal time
  /// @param α2 the right ascension
  /// @return the approximate transite
  static double approximateTransit(
    double longitude,
    double siderealTime, 
    double rightAscension,
  ) {
    final L = longitude;
    final theta0 = siderealTime;
    final alpha2 = rightAscension;

    /* Equation from page Astronomical Algorithms 102 */
    final Lw = L * -1;
    return MathUtil.normalizeWithBound((alpha2 + Lw - theta0) / 360, 1);
  }

  /// The time at which the sun is at its highest point in the sky (in universal time)
  /// @param m0 approximate transit
  /// @param L the longitude
  /// @param Θ0 the sidereal time
  /// @param α2 the right ascension
  /// @param α1 the previous right ascension
  /// @param α3 the next right ascension
  /// @return the time (in universal time) when the sun is at its highest point in the sky
  static double correctedTransit(
    double approximateTransit,
    double longitude,
    double siderealTime,
    double rightAscension,
    double previousRightAscension,
    double nextRightAscension,
  ) {
    double m0 = approximateTransit;
    double L = longitude;
    double theta0 = siderealTime;
    double alpha2 = rightAscension;
    double? alpha1 = previousRightAscension;
    double alpha3 = nextRightAscension;

    /* Equation from page Astronomical Algorithms 102 */
    final Lw = L * -1;
    final theta = MathUtil.unwindAngle(theta0 + (360.985647 * m0));
    final alpha = MathUtil.unwindAngle(interpolateAngles(
        /* value */ alpha2,
        /* previousValue */ alpha1,
        /* nextValue */ alpha3,
        /* factor */ m0));
    final H = MathUtil.closestAngle(theta - Lw - alpha);
    final deltaM = H / -360;
    return (m0 + deltaM) * 24;
  }

  /// Get the corrected hour angle
  /// @param m0 the approximate transit
  /// @param h0 the angle
  /// @param coordinates the coordinates
  /// @param afterTransit whether it's after transit
  /// @param Θ0 the sidereal time
  /// @param α2 the right ascension
  /// @param α1 the previous right ascension
  /// @param α3 the next right ascension
  /// @param δ2 the declination
  /// @param δ1 the previous declination
  /// @param δ3 the next declination
  /// @return the corrected hour angle
  static double correctedHourAngle(
    double approximateTransit,
    double angle,
    LocationCoordinates coordinates,
    bool afterTransit,
    double siderealTime,
    double rightAscension,
    double previousRightAscension,
    double nextRightAscension,
    double declination,
    double previousDeclination,
    double nextDeclination,
  ) {

    final m0 = approximateTransit;
    final h0 = angle;
    final theta0 = siderealTime;
    final alpha2 = rightAscension;
    final alpha1 = previousRightAscension;
    final alpha3 = nextRightAscension;
    final delta2 = declination;
    final delta1 = previousDeclination;
    final delta3 = nextDeclination;

    /* Equation from page Astronomical Algorithms 102 */
    final Lw = coordinates.longitude * -1;
    final term1 = sin(MathUtil.radians(h0)) - (
      sin(MathUtil.radians(coordinates.latitude)) * 
      sin(MathUtil.radians(delta2))
    );
    final term2 = cos(MathUtil.radians(coordinates.latitude)) * cos(MathUtil.radians(delta2));
    final H0 = MathUtil.degrees(acos(term1 / term2));
    final m = afterTransit ? m0 + (H0 / 360) : m0 - (H0 / 360);
    final theta = MathUtil.unwindAngle(theta0 + (360.985647 * m));
    final alpha = MathUtil.unwindAngle(interpolateAngles(
        /* value */ alpha2,
        /* previousValue */ alpha1,
        /* nextValue */ alpha3,
        /* factor */ m));
    final delta = interpolate(
        /* value */ delta2,
        /* previousValue */ delta1,
        /* nextValue */ delta3,
        /* factor */ m);
    final H = (theta - Lw - alpha);
    final h = altitudeOfCelestialBody(
        /* observerLatitude */ coordinates.latitude,
        /* declination */ delta,
        /* localHourAngle */ H);
    final term3 = h - h0;
    final term4 = 360 * cos(MathUtil.radians(delta)) * cos(MathUtil.radians(coordinates.latitude)) * sin(MathUtil.radians(H));
    final deltaM = term3 / term4;
    return (m + deltaM) * 24;
  }

  /* Interpolation of a value given equidistant
  previous and next values and a factor
  equal to the fraction of the interpolated
  point's time over the time between values. */

  ///
  /// @param y2 the value
  /// @param y1 the previous value
  /// @param y3 the next value
  /// @param n the factor
  /// @return the interpolated value
  static double interpolate(double y2, double y1, double y3, double n) {
    /* Equation from Astronomical Algorithms page 24 */
    final a = y2 - y1;
    final b = y3 - y2;
    final c = b - a;
    return y2 + ((n / 2) * (a + b + (n * c)));
  }

  /// Interpolation of three angles, accounting for angle unwinding
  /// @param y2 value
  /// @param y1 previousValue
  /// @param y3 nextValue
  /// @param n factor
  /// @return interpolated angle
  static double interpolateAngles(
    double y2,
    double y1,
    double y3,
    double n,
  ) {
    /* Equation from Astronomical Algorithms page 24 */
    final a = MathUtil.unwindAngle(y2 - y1);
    final b = MathUtil.unwindAngle(y3 - y2);
    final c = b - a;
    return y2 + ((n / 2) * (a + b + (n * c)));
  }

  static int daysSinceSolstice(int dayOfYear, int year, double latitude) {
    int daysSinceSolistice = 0;
    const northernOffset = 10;
    final isLeapYear = CalendarUtil.isLeapYear(year);
    final southernOffset = isLeapYear ? 173 : 172;
    final daysInYear = isLeapYear ? 366 : 365;

    if (latitude >= 0) {
      daysSinceSolistice = dayOfYear + northernOffset;
      if (daysSinceSolistice >= daysInYear) {
        daysSinceSolistice = daysSinceSolistice - daysInYear;
      }
    } else {
      daysSinceSolistice = dayOfYear - southernOffset;
      if (daysSinceSolistice < 0) {
        daysSinceSolistice = daysSinceSolistice + daysInYear;
      }
    }
    return daysSinceSolistice;
  }
}

// class Astronomical {
//   /* The geometric mean longitude of the sun in degrees. */
//   static double meanSolarLongitude(double julianCentury) {
//     double T = julianCentury;
//     /* Equation from Astronomical Algorithms page 163 */
//     const term1 = 280.4664567;
//     double term2 = 36000.76983 * T;
//     double term3 = 0.0003032 * pow(T, 2);
//     double L0 = term1 + term2 + term3;
//     return MathUtil.unwindAngle(L0);
//   }

//   /* The geometric mean longitude of the moon in degrees. */
//   static double meanLunarLongitude(double julianCentury) {
//     double T = julianCentury;
//     /* Equation from Astronomical Algorithms page 144 */
//     const term1 = 218.3165;
//     double term2 = 481267.8813 * T;
//     double Lp = term1 + term2;
//     return MathUtil.unwindAngle(Lp);
//   }

//   static double ascendingLunarNodeLongitude(double julianCentury) {
//     double T = julianCentury;
//     /* Equation from Astronomical Algorithms page 144 */
//     const term1 = 125.04452;
//     double term2 = 1934.136261 * T;
//     double term3 = 0.0020708 * pow(T, 2);
//     double term4 = pow(T, 3) / 450000;
//     double Omega = term1 - term2 + term3 + term4;
//     return MathUtil.unwindAngle(Omega);
//   }

//   /* The mean anomaly of the sun. */
//   static double meanSolarAnomaly(double julianCentury) {
//     double T = julianCentury;
//     /* Equation from Astronomical Algorithms page 163 */
//     const term1 = 357.52911;
//     double term2 = 35999.05029 * T;
//     double term3 = 0.0001537 * pow(T, 2);
//     double M = term1 + term2 - term3;
//     return MathUtil.unwindAngle(M);
//   }

//   /* The Sun's equation of the center in degrees. */
//   static double solarEquationOfTheCenter(julianCentury, meanAnomaly) {
//     double T = julianCentury;
//     /* Equation from Astronomical Algorithms page 164 */
//     double Mrad = MathUtil.degreesToRadians(meanAnomaly);
//     double term1 =
//         (1.914602 - (0.004817 * T) - (0.000014 * pow(T, 2))) * sin(Mrad);
//     double term2 = (0.019993 - (0.000101 * T)) * sin(2 * Mrad);
//     double term3 = 0.000289 * sin(3 * Mrad);
//     return term1 + term2 + term3;
//   }

//   /* The apparent longitude of the Sun, referred to the
//         true equinox of the date. */
//   static double apparentSolarLongitude(julianCentury, meanLongitude) {
//     double T = julianCentury;
//     double L0 = meanLongitude;
//     /* Equation from Astronomical Algorithms page 164 */
//     double longitude = L0 +
//         Astronomical.solarEquationOfTheCenter(
//             T, Astronomical.meanSolarAnomaly(T));
//     double Omega = 125.04 - (1934.136 * T);
//     double Lambda =
//         longitude - 0.00569 - (0.00478 * sin(MathUtil.degreesToRadians(Omega)));
//     return MathUtil.unwindAngle(Lambda);
//   }

//   /* The mean obliquity of the ecliptic, formula
//         adopted by the International Astronomical Union.
//         Represented in degrees. */
//   static double meanObliquityOfTheEcliptic(double julianCentury) {
//     double T = julianCentury;
//     /* Equation from Astronomical Algorithms page 147 */
//     const term1 = 23.439291;
//     double term2 = 0.013004167 * T;
//     double term3 = 0.0000001639 * pow(T, 2);
//     double term4 = 0.0000005036 * pow(T, 3);
//     return term1 - term2 - term3 + term4;
//   }

//   /* The mean obliquity of the ecliptic, corrected for
//         calculating the apparent position of the sun, in degrees. */
//   static double apparentObliquityOfTheEcliptic(
//       julianCentury, meanObliquityOfTheEcliptic) {
//     double T = julianCentury;
//     double Epsilon0 = meanObliquityOfTheEcliptic;
//     /* Equation from Astronomical Algorithms page 165 */
//     double O = 125.04 - (1934.136 * T);
//     return Epsilon0 + (0.00256 * cos(MathUtil.degreesToRadians(O)));
//   }

//   /* Mean sidereal time, the hour angle of the vernal equinox, in degrees. */
//   static double meanSiderealTime(double julianCentury) {
//     double T = julianCentury;
//     /* Equation from Astronomical Algorithms page 165 */
//     double JD = (T * 36525) + 2451545.0;
//     const term1 = 280.46061837;
//     double term2 = 360.98564736629 * (JD - 2451545);
//     double term3 = 0.000387933 * pow(T, 2);
//     double term4 = pow(T, 3) / 38710000;
//     double Theta = term1 + term2 + term3 - term4;
//     return MathUtil.unwindAngle(Theta);
//   }

//   static double nutationInLongitude(
//       julianCentury, solarLongitude, lunarLongitude, ascendingNode) {
//     double L0 = solarLongitude;
//     double Lp = lunarLongitude;
//     double Omega = ascendingNode;
//     /* Equation from Astronomical Algorithms page 144 */
//     double term1 = (-17.2 / 3600) * sin(MathUtil.degreesToRadians(Omega));
//     double term2 = (1.32 / 3600) * sin(2 * MathUtil.degreesToRadians(L0));
//     double term3 = (0.23 / 3600) * sin(2 * MathUtil.degreesToRadians(Lp));
//     double term4 = (0.21 / 3600) * sin(2 * MathUtil.degreesToRadians(Omega));
//     return term1 - term2 - term3 + term4;
//   }

//   static double nutationInObliquity(
//       julianCentury, solarLongitude, lunarLongitude, ascendingNode) {
//     double L0 = solarLongitude;
//     double Lp = lunarLongitude;
//     double Omega = ascendingNode;
//     /* Equation from Astronomical Algorithms page 144 */
//     double term1 = (9.2 / 3600) * cos(MathUtil.degreesToRadians(Omega));
//     double term2 = (0.57 / 3600) * cos(2 * MathUtil.degreesToRadians(L0));
//     double term3 = (0.10 / 3600) * cos(2 * MathUtil.degreesToRadians(Lp));
//     double term4 = (0.09 / 3600) * cos(2 * MathUtil.degreesToRadians(Omega));
//     return term1 + term2 + term3 - term4;
//   }

//   static double altitudeOfCelestialBody(
//       observerLatitude, declination, localHourAngle) {
//     double Phi = observerLatitude;
//     double delta = declination;
//     double H = localHourAngle;
//     /* Equation from Astronomical Algorithms page 93 */
//     double term1 = sin(MathUtil.degreesToRadians(Phi)) * sin(MathUtil.degreesToRadians(delta));
//     double term2 = cos(MathUtil.degreesToRadians(Phi)) *
//         cos(MathUtil.degreesToRadians(delta)) *
//         cos(MathUtil.degreesToRadians(H));
//     return MathUtil.radiansToDegrees(asin(term1 + term2));
//   }

//   static double approximateTransit(longitude, siderealTime, rightAscension) {
//     double L = longitude;
//     double Theta0 = siderealTime;
//     double a2 = rightAscension;
//     /* Equation from page Astronomical Algorithms 102 */
//     double Lw = L * -1;
//     return MathUtil.normalizeToScale((a2 + Lw - Theta0) / 360, 1);
//   }

//   /* The time at which the sun is at its highest point in the sky (in universal time) */
//   static double correctedTransit(approximateTransit, longitude, siderealTime,
//       rightAscension, previousRightAscension, nextRightAscension) {
//     double m0 = approximateTransit;
//     double L = longitude;
//     double Theta0 = siderealTime;
//     double a2 = rightAscension;
//     double? a1 = previousRightAscension;
//     double a3 = nextRightAscension;
//     /* Equation from page Astronomical Algorithms 102 */
//     double Lw = L * -1;
//     double Theta = MathUtil.unwindAngle((Theta0 + (360.985647 * m0)));
//     double a = MathUtil.unwindAngle(Astronomical.interpolateAngles(a2, a1, a3, m0)!);
//     double H = MathUtil.quadrantShiftAngle(Theta - Lw - a);
//     double dm = H / -360;
//     return (m0 + dm) * 24;
//   }

//   static double correctedHourAngle(
//       approximateTransit,
//       angle,
//       coordinates,
//       afterTransit,
//       siderealTime,
//       rightAscension,
//       previousRightAscension,
//       nextRightAscension,
//       declination,
//       previousDeclination,
//       nextDeclination) {
//     double? m0 = approximateTransit;
//     double h0 = angle;
//     double Theta0 = siderealTime;
//     double a2 = rightAscension;
//     double? a1 = previousRightAscension;
//     double a3 = nextRightAscension;
//     double d2 = declination;
//     double? d1 = previousDeclination;
//     double d3 = nextDeclination;

//     /* Equation from page Astronomical Algorithms 102 */
//     double Lw = coordinates.longitude * -1;
//     double term1 = sin(MathUtil.degreesToRadians(h0)) -
//         (sin(MathUtil.degreesToRadians(coordinates.latitude)) *
//             sin(MathUtil.degreesToRadians(d2)));
//     double term2 =
//         cos(MathUtil.degreesToRadians(coordinates.latitude)) * cos(MathUtil.degreesToRadians(d2));

//     // TODO: acos with term1/term2 > 1 or < -1
//     double H0 =
//         (term1 / term2).abs() > 1 ? 1.0 : MathUtil.radiansToDegrees(acos(term1 / term2));

//     double m = afterTransit ? m0! + (H0 / 360) : m0! - (H0 / 360);
//     double Theta = MathUtil.unwindAngle((Theta0 + (360.985647 * m)));
//     double a = MathUtil.unwindAngle(Astronomical.interpolateAngles(a2, a1, a3, m)!);
//     double delta = Astronomical.interpolate(d2, d1, d3, m)!;
//     double H = (Theta - Lw - a);
//     double h =
//         Astronomical.altitudeOfCelestialBody(coordinates.latitude, delta, H);
//     double term3 = h - h0;
//     double term4 = 360 *
//         cos(MathUtil.degreesToRadians(delta)) *
//         cos(MathUtil.degreesToRadians(coordinates.latitude)) *
//         sin(MathUtil.degreesToRadians(H));
//     double dm = term3 / term4;
//     return (m + dm) * 24;
//   }

//   /* Interpolation of a value given equidistant
//         previous and next values and a factor
//         equal to the fraction of the interpolated
//         point's time over the time between values. */
//   static double? interpolate(y2, y1, y3, n) {
//     /* Equation from Astronomical Algorithms page 24 */
//     double a = y2 - y1;
//     double b = y3 - y2;
//     double c = b - a;
//     return y2 + ((n / 2) * (a + b + (n * c)));
//   }

//   /* Interpolation of three angles, accounting for
//         angle unwinding. */
//   static double? interpolateAngles(y2, y1, y3, n) {
//     /* Equation from Astronomical Algorithms page 24 */
//     double a = MathUtil.unwindAngle(y2 - y1);
//     double b = MathUtil.unwindAngle(y3 - y2);
//     double c = b - a;
//     return y2 + ((n / 2) * (a + b + (n * c)));
//   }

//   /* The Julian Day for the given Gregorian date components. */
//   static double julianDay(year, month, day, hours) {
//     /* Equation from Astronomical Algorithms page 60 */
//     if (hours == null) {
//       hours = 0;
//     }

//     // const trunc = Math.trunc || function (x) { return x < 0 ? Math.ceil(x) : Math.floor(x); };
//     trunc(val) => val.truncate();

//     int Y = trunc(month > 2 ? year : year - 1);
//     int M = trunc(month > 2 ? month : month + 12);
//     double D = day + (hours / 24);

//     int A = trunc(Y / 100);
//     int B = trunc(2 - A + trunc(A / 4));

//     int i0 = trunc(365.25 * (Y + 4716));
//     int i1 = trunc(30.6001 * (M + 1));

//     return i0 + i1 + D + B - 1524.5;
//   }

//   /* Julian century from the epoch. */
//   static double julianCentury(double julianDay) {
//     /* Equation from Astronomical Algorithms page 163 */
//     return (julianDay - 2451545.0) / 36525;
//   }

//   /* Whether or not a year is a leap year (has 366 days). */
//   static bool isLeapYear(year) {
//     if (year % 4 != 0) {
//       return false;
//     }

//     if (year % 100 == 0 && year % 400 != 0) {
//       return false;
//     }

//     return true;
//   }

//   static DateTime seasonAdjustedMorningTwilight(
//       double latitude, int dayOfYear, int year, DateTime sunrise) {
//     double a = 75 + ((28.65 / 55.0) * (latitude).abs());
//     double b = 75 + ((19.44 / 55.0) * (latitude).abs());
//     double c = 75 + ((32.74 / 55.0) * (latitude).abs());
//     double d = 75 + ((48.10 / 55.0) * (latitude).abs());

//     double adjustment() {
//       int dyy = Astronomical.daysSinceSolstice(dayOfYear, year, latitude);
//       if (dyy < 91) {
//         return a + (b - a) / 91.0 * dyy;
//       } else if (dyy < 137) {
//         return b + (c - b) / 46.0 * (dyy - 91);
//       } else if (dyy < 183) {
//         return c + (d - c) / 46.0 * (dyy - 137);
//       } else if (dyy < 229) {
//         return d + (c - d) / 46.0 * (dyy - 183);
//       } else if (dyy < 275) {
//         return c + (b - c) / 46.0 * (dyy - 229);
//       } else {
//         return b + (a - b) / 91.0 * (dyy - 275);
//       }
//     }

//     ;

//     return sunrise.add(Duration(days: (adjustment() * -60.0).round()));
//   }

//   static DateTime seasonAdjustedEveningTwilight(
//       double latitude, int dayOfYear, int year, DateTime sunset) {
//     double a = 75 + ((25.60 / 55.0) * (latitude).abs());
//     double b = 75 + ((2.050 / 55.0) * (latitude).abs());
//     double c = 75 - ((9.210 / 55.0) * (latitude).abs());
//     double d = 75 + ((6.140 / 55.0) * (latitude).abs());

//     double adjustment() {
//       int dyy = Astronomical.daysSinceSolstice(dayOfYear, year, latitude);
//       if (dyy < 91) {
//         return a + (b - a) / 91.0 * dyy;
//       } else if (dyy < 137) {
//         return b + (c - b) / 46.0 * (dyy - 91);
//       } else if (dyy < 183) {
//         return c + (d - c) / 46.0 * (dyy - 137);
//       } else if (dyy < 229) {
//         return d + (c - d) / 46.0 * (dyy - 183);
//       } else if (dyy < 275) {
//         return c + (b - c) / 46.0 * (dyy - 229);
//       } else {
//         return b + (a - b) / 91.0 * (dyy - 275);
//       }
//     }

//     ;

//     return sunset.add(Duration(days: (adjustment() * 60.0).round()));
//   }

//   static int daysSinceSolstice(int dayOfYear, int year, double latitude) {
//     int daysSinceSolstice = 0;
//     int northernOffset = 10;
//     int southernOffset = Astronomical.isLeapYear(year) ? 173 : 172;
//     int daysInYear = Astronomical.isLeapYear(year) ? 366 : 365;

//     if (latitude >= 0) {
//       daysSinceSolstice = dayOfYear + northernOffset;
//       if (daysSinceSolstice >= daysInYear) {
//         daysSinceSolstice = daysSinceSolstice - daysInYear;
//       }
//     } else {
//       daysSinceSolstice = dayOfYear - southernOffset;
//       if (daysSinceSolstice < 0) {
//         daysSinceSolstice = daysSinceSolstice + daysInYear;
//       }
//     }

//     return daysSinceSolstice;
//   }
// }