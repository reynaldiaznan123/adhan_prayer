import 'package:adhan_prayer/src/adjustments.dart';
import 'package:adhan_prayer/src/method.dart';
import 'package:adhan_prayer/src/madhab.dart';
import 'package:adhan_prayer/src/rules.dart';

class CalculationParameters {
  /// The method used to do the calculation
  final CalcMethodType method;

  /// The angle of the sun used to calculate fajr
  final double fajrAngle;

  final double? dhuhaAngle;

  /// The angle of the sun used to calculate Maghrib
  final double? maghribAngle;

  /// The angle of the sun used to calculate isha
  final double ishaAngle;

  /// Minutes after Maghrib (if set, the time for Isha will be Maghrib plus IshaInterval)
  final int? ishaInterval;

  /// The madhab used to calculate Asr
  final Madhab madhab;

  /// Rules for placing bounds on Fajr and Isha for high latitude areas
  final HighLatitudeRule? highLatitudeRule;

  /// Used to optionally add or subtract a set amount of time from each prayer time
  final PrayerAdjustments adjustments;

  /// Used for method adjustments
  final PrayerAdjustments methodAdjustments;

  const CalculationParameters({
    this.method = CalcMethodType.other,
    required this.fajrAngle,
    this.dhuhaAngle,
    this.maghribAngle,
    required this.ishaAngle,
    this.ishaInterval,
    this.madhab = Madhab.standard,
    this.highLatitudeRule = HighLatitudeRule.middleOfTheNight,
    this.adjustments = const PrayerAdjustments(),
    this.methodAdjustments = const PrayerAdjustments(),
  });

  NightPortions getNightPortions() {
    switch (highLatitudeRule) {
      case HighLatitudeRule.middleOfTheNight:
        return const NightPortions(1.0 / 2.0, 1.0 / 2.0);
      case HighLatitudeRule.seventhOfTheNight:
        return const NightPortions(1.0 / 7.0, 1.0 / 7.0);
      case HighLatitudeRule.quarterOfTheNight:
        return const NightPortions(1.0 / 3.0, 1.0 / 3.0);
      case HighLatitudeRule.twilightAngle:
        return NightPortions(fajrAngle / 60.0, ishaAngle / 60.0);
      default:
        throw FormatException(
          'Invalid high latitude rule found when attempting to compute night portions: $highLatitudeRule',
        );
    }
  }
}

class NightPortions {
  final double fajr;
  final double isha;

  const NightPortions(this.fajr, this.isha);
}
