import 'package:adhan_prayer/src/adjustments.dart';
import 'package:adhan_prayer/src/parameters.dart';

enum CalcMethodType {
  /// Muslim World League
  /// Uses Fajr angle of 18 and an Isha angle of 17
  muslimWorldLeague,

  /// Egyptian General Authority of Survey
  /// Uses Fajr angle of 19.5 and an Isha angle of 17.5
  egyptian,

  /// University of Islamic Sciences, Karachi
  /// Uses Fajr angle of 18 and an Isha angle of 18
  karachi,

  /// Umm al-Qura University, Makkah
  /// Uses a Fajr angle of 18.5 and an Isha angle of 90. Note: You should add a +30 minute custom
  /// adjustment of Isha during Ramadan.
  ummAlQura,

  /// The Gulf Region
  /// Uses Fajr and Isha angles of 18.2 degrees.
  dubai,

  /// Moon Sighting Committee
  /// Uses a Fajr angle of 18 and an Isha angle of 18. Also uses seasonal adjustment values.
  moonSightingCommittee,

  /// Referred to as the ISNA method
  /// This method is included for completeness, but is not recommended.
  /// Uses a Fajr angle of 15 and an Isha angle of 15.
  northAmerica,

  /// Kuwait
  /// Uses a Fajr angle of 18 and an Isha angle of 17.5
  kuwait,

  /// Qatar
  /// Modified version of Umm al-Qura that uses a Fajr angle of 18.
  qatar,

  /// Singapore
  /// Uses a Fajr angle of 20 and an Isha angle of 18
  singapore,

  /// Dianet
  turkey,

  /// Institute of Geophysics, University of Tehran. Early Isha time with an angle of 14°. Slightly later Fajr time with an angle of 17.7°.
  /// Calculates Maghrib based on the sun reaching an angle of 4.5° below the horizon.
  tehran,

  marraco,

  // Kementrian agama
  kemanag,

  // Sihat Kemenag
  sihat,

  /// The default value for [CalculationParameters.method] when initializing a
  /// [CalculationParameters] object. Sets a Fajr angle of 0 and an Isha angle of 0.
  other,
}

class CalculationMethod {
  const CalculationMethod({
    required this.type,
  });

  final CalcMethodType type;

  CalculationParameters parameters() {
    switch (type) {
      case CalcMethodType.muslimWorldLeague:
        return CalculationParameters(
          method: type,
          fajrAngle: 17.0,
          ishaAngle: 18.0,
          methodAdjustments: const PrayerAdjustments(
            dhuhr: 1,
          ),
        );
      case CalcMethodType.egyptian:
        return CalculationParameters(
          method: type,
          fajrAngle: 19.5,
          ishaAngle: 17.5,
          methodAdjustments: const PrayerAdjustments(
            dhuhr: 1,
          ),
        );
      case CalcMethodType.karachi:
        return CalculationParameters(
          method: type,
          fajrAngle: 18.0,
          ishaAngle: 18.0,
          methodAdjustments: const PrayerAdjustments(
            dhuhr: 1,
          ),
        );
      case CalcMethodType.ummAlQura:
        return CalculationParameters(
          method: type,
          fajrAngle: 18.5,
          ishaAngle: 0.0,
          ishaInterval: 90,
        );
      case CalcMethodType.dubai:
        return CalculationParameters(
          method: type,
          fajrAngle: 18.2,
          ishaAngle: 18.2,
          methodAdjustments: const PrayerAdjustments(
            sunrise: -3,
            dhuhr: 3,
            asr: 3,
            maghrib: 3,
          ),
        );
      case CalcMethodType.moonSightingCommittee:
        return CalculationParameters(
          method: type,
          fajrAngle: 18.0,
          ishaAngle: 18.0,
          methodAdjustments: const PrayerAdjustments(
            dhuhr: 5,
            maghrib: 3,
          ),
        );
      case CalcMethodType.northAmerica:
        return CalculationParameters(
          method: type,
          fajrAngle: 15.0,
          ishaAngle: 15.0,
          methodAdjustments: const PrayerAdjustments(
            dhuhr: 1,
          ),
        );
      case CalcMethodType.kuwait:
        return CalculationParameters(
          method: type,
          fajrAngle: 18.0,
          ishaAngle: 17.5,
        );
      case CalcMethodType.qatar:
        return CalculationParameters(
          method: type,
          fajrAngle: 18.0,
          ishaAngle: 0.0,
          ishaInterval: 90,
        );
      case CalcMethodType.singapore:
        return CalculationParameters(
          method: type,
          fajrAngle: 20.0,
          ishaAngle: 18.0,
          methodAdjustments: const PrayerAdjustments(
            dhuhr: 1,
          ),
        );
      case CalcMethodType.turkey:
        return CalculationParameters(
          method: type,
          fajrAngle: 18.0,
          ishaAngle: 17.0,
          methodAdjustments: const PrayerAdjustments(
            sunrise: -7,
            dhuhr: 5,
            asr: 4,
            maghrib: 7,
          ),
        );
      case CalcMethodType.tehran:
        return CalculationParameters(
          method: type,
          fajrAngle: 17.7,
          ishaAngle: 14.0,
          maghribAngle: 4.5,
        );
      case CalcMethodType.marraco:
        return CalculationParameters(
          method: type,
          fajrAngle: 19.0,
          ishaAngle: 17.0,
          methodAdjustments: const PrayerAdjustments(
            sunrise: -3,
            dhuhr: 5,
            maghrib: 5,
          ),
        );
      case CalcMethodType.kemanag:
      case CalcMethodType.sihat:
        return CalculationParameters(
          method: type,
          fajrAngle: 20.0,
          ishaAngle: 18.0,
          methodAdjustments: const PrayerAdjustments(
            fajr: 2,
            dhuhr: 3,
            asr: 2,
            maghrib: 2,
            isha: 2,
          ),
        );
      case CalcMethodType.other:
        return CalculationParameters(
          method: type,
          fajrAngle: 0.0,
          ishaAngle: 0.0,
        );
      default:
        throw const FormatException('Invalid CalculationMethod');
    }
  }
}