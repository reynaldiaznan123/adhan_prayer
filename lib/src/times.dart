import 'package:adhan_prayer/src/coordinates.dart';
import 'package:adhan_prayer/src/extensions/datetime.dart';
import 'package:adhan_prayer/src/internal/astronomical.dart';
import 'package:adhan_prayer/src/internal/solars.dart';
import 'package:adhan_prayer/src/madhab.dart';
import 'package:adhan_prayer/src/method.dart';
import 'package:adhan_prayer/src/parameters.dart';
import 'package:adhan_prayer/src/utils/calendar.dart';

enum Prayer {
  none,
  fajr,
  sunrise,
  dhuha,
  dhuhr,
  asr,
  sunset,
  maghrib,
  isha,
  midnight,
  thirdnight,
}

class PrayerTimes {
  late DateTime? _fajr;
  DateTime? get fajr => _fajr;

  late DateTime? _sunrise;
  DateTime? get sunrise => _sunrise;

  late DateTime? _dhuha;
  DateTime? get dhuha => _dhuha;

  late DateTime? _dhuhr;
  DateTime? get dhuhr => _dhuhr;

  late DateTime? _asr;
  DateTime? get asr => _asr;

  late DateTime? _sunset;
  DateTime? get sunset => _sunset;

  late DateTime? _maghrib;
  DateTime? get maghrib => _maghrib;

  late DateTime? _isha;
  DateTime? get isha => _isha;

  late DateTime? _midNight;
  DateTime? get midNight => _midNight;

  late DateTime? _thirdNight;
  DateTime? get thirdNight => _thirdNight;

  factory PrayerTimes({
    required LocationCoordinates coordinates,
    required DateTime date,
    required CalculationParameters parameters,
    Duration? offset,
    bool precision = false,
  }) {
    return PrayerTimes._(
      coordinates,
      date,
      parameters,
      offset: offset,
      precision: precision,
    );
  }

  /// Calculate Today's PrayerTimes and Output Local Times By Default.
  /// If you provide utcOffset then it will Output UTC with Offset Applied Times.
  ///
  /// [coordinates] the coordinates of the location
  /// [calculationParameters] the parameters for the calculation
  factory PrayerTimes.today({
    required LocationCoordinates coordinates,
    required CalculationParameters parameters,
    Duration? offset,
    bool precision = false,
  }) {
    final now = DateTime.now();
    return PrayerTimes._(
      coordinates,
      DateTime(now.year, now.month, now.day),
      parameters,
      offset: offset,
      precision: precision,
    );
  }

  factory PrayerTimes.previous({
    required LocationCoordinates coordinates,
    required CalculationParameters parameters,
    Duration? offset,
    bool precision = false,
  }) {
    final now = DateTime.now().subtract(const Duration(
      days: 1,
    ));
    return PrayerTimes._(
      coordinates,
      DateTime(now.year, now.month, now.day),
      parameters,
      offset: offset,
      precision: precision,
    );
  }

  factory PrayerTimes.next({
    required LocationCoordinates coordinates,
    required CalculationParameters parameters,
    Duration? offset,
    bool precision = false,
  }) {
    final now = DateTime.now().add(const Duration(
      days: 1,
    ));
    return PrayerTimes._(
      coordinates,
      DateTime(now.year, now.month, now.day),
      parameters,
      offset: offset,
      precision: precision,
    );
  }

  PrayerTimes._(
    this.coordinates,
    DateTime _date,
    this.parameters, {
    Duration? offset,
    bool precision = false,
  }) {
    final DateTime date = _date;
    final DateTime dateBefore = date.subtract(const Duration(
      days: 1,
    ));
    final DateTime dateAfter = date.add(const Duration(
      days: 1,
    ));

    DateTime? fajr;
    DateTime? fajrAfter;
    DateTime? dhuhr;
    DateTime? asr;
    DateTime? maghrib;
    DateTime? isha;
    DateTime? ishaBefore;
    DateTime? midNight;
    DateTime? thirdNight;

    final year = date.year;
    final dayOfYear = date.dayOfYear;

    final solarTime = SolarTime(date, coordinates);
    final solarTimeBefore = SolarTime(dateBefore, coordinates);
    final solarTimeAfter = SolarTime(dateAfter, coordinates);

    final transit = date.fromDouble(solarTime.transit)?.utc();
    final sunrise = date.fromDouble(solarTime.sunrise)?.utc();
    final dhuha = date.fromDouble(solarTime.hourAngle(parameters.dhuhaAngle ?? 15.0, false))?.utc();
    final sunset = date.fromDouble(solarTime.sunset)?.utc();

    final sunriseAfter = dateAfter.fromDouble(solarTimeAfter.sunrise)?.utc();
    final sunsetBefore = dateBefore.fromDouble(solarTimeBefore.sunset)?.utc();

    final afternoon = solarTime.afternoon(parameters.madhab.getShadowLength());

    final tomorrow = date.add(const Duration(days: 1));
    final tomorrowSolarTime = SolarTime(tomorrow, coordinates);
    final tomorrowSunrise = tomorrow.fromDouble(tomorrowSolarTime.sunrise)?.utc();
    final tomorrowFajr = tomorrow.fromDouble(tomorrowSolarTime.hourAngle(-1 * parameters.fajrAngle, false))?.utc();

    fajr = date.fromDouble(solarTime.hourAngle(-1 * parameters.fajrAngle, false))?.utc();
    fajrAfter = dateAfter.fromDouble(solarTimeAfter.hourAngle(-1 * parameters.fajrAngle, false))?.utc();

    final error = transit == null || sunrise == null || sunset == null || tomorrowSunrise == null;
    if (!error) {
      dhuhr = transit;
      asr = date.fromDouble(afternoon)?.utc();

      final night = tomorrowSunrise.difference(sunset).inSeconds;
      final nightPortions = parameters.getNightPortions();
      double nightFraction = 0;

      if (parameters.method == CalcMethodType.moonSightingCommittee && coordinates.longitude >= 55.0) {
        nightFraction = night / 7;
        fajr = sunrise.add(Duration(
          seconds: -1 * nightFraction.round(),
        ));
        fajrAfter = sunriseAfter?.add(Duration(
          seconds: -1 * nightFraction.round(),
        ));
      }

      DateTime safeFajr() {
        if (parameters.method == CalcMethodType.moonSightingCommittee) {
          return _seasonAdjustedMorningTwilight(
            coordinates.latitude,
            dayOfYear,
            year,
            sunrise,
          );
        } else {
          nightFraction = nightPortions.fajr * night;
          return sunrise.add(Duration(
            seconds: -1 * nightFraction.round(),
          ));
        }
      }

      DateTime safeFajrAfter() {
        if (parameters.method == CalcMethodType.moonSightingCommittee) {
          return _seasonAdjustedMorningTwilight(
            coordinates.latitude,
            dayOfYear,
            year,
            sunrise,
          );
        } else {
          nightFraction = nightPortions.fajr * night;
          return sunrise.add(Duration(
            seconds: -1 * nightFraction.round(),
          ));
        }
      }

      if (fajr == null || fajr.millisecondsSinceEpoch.isNaN || safeFajr().isAfter(fajr)) {
        fajr = safeFajr();
      }

      if (fajrAfter == null || fajrAfter.millisecondsSinceEpoch.isNaN || safeFajrAfter().isAfter(fajrAfter)) {
        fajrAfter = safeFajrAfter();
      }

      if (parameters.ishaInterval != null && parameters.ishaInterval! > 0) {
        isha = sunset.add(Duration(
          minutes: parameters.ishaInterval!,
        ));
        ishaBefore = sunsetBefore?.add(Duration(
          minutes: parameters.ishaInterval!,
        ));
      } else {
        isha = date
            .fromDouble(solarTime.hourAngle(
              -1 * parameters.ishaAngle,
              true,
            ))
            ?.utc();
        ishaBefore = dateBefore
            .fromDouble(solarTimeBefore.hourAngle(
              -1 * parameters.ishaAngle,
              true,
            ))
            ?.utc();

        if (parameters.method == CalcMethodType.moonSightingCommittee && coordinates.latitude >= 55.0) {
          nightFraction = night / 7;
          isha = sunset.add(Duration(
            seconds: nightFraction.round(),
          ));
          ishaBefore = sunsetBefore?.add(Duration(
            seconds: nightFraction.round(),
          ));
        }

        DateTime safeIsha() {
          if (parameters.method == CalcMethodType.moonSightingCommittee) {
            return _seasonAdjustedEveningTwilight(
              coordinates.latitude,
              dayOfYear,
              year,
              sunset,
            );
          } else {
            nightFraction = nightPortions.isha * night;
            return sunset.add(Duration(
              seconds: nightFraction.round(),
            ));
          }
        }

        DateTime safeIshaBefore() {
          if (parameters.method == CalcMethodType.moonSightingCommittee) {
            return _seasonAdjustedEveningTwilight(
              coordinates.latitude,
              dayOfYear,
              year,
              sunset,
            );
          } else {
            nightFraction = nightPortions.isha * night;
            return sunset.add(Duration(
              seconds: nightFraction.round(),
            ));
          }
        }

        if (isha == null || isha.millisecondsSinceEpoch.isNaN || safeIsha().isBefore(isha)) {
          isha = safeIsha();
        }

        if (ishaBefore == null || ishaBefore.millisecondsSinceEpoch.isNaN || safeIshaBefore().isBefore(ishaBefore)) {
          ishaBefore = safeIshaBefore();
        }
      }

      maghrib = sunset;
      if (parameters.maghribAngle != null) {
        final angleBasedMaghrib = date
            .fromDouble(solarTime.hourAngle(
              -1 * parameters.maghribAngle!,
              true,
            ))
            ?.utc();
        if (angleBasedMaghrib != null && sunset.isBefore(angleBasedMaghrib) && isha.isAfter(angleBasedMaghrib)) {
          maghrib = angleBasedMaghrib;
        }
      }

      _fajr = CalendarUtil.roundedMinute(fajr, precision: precision);
      _fajr = _fajr?.add(Duration(
        minutes: parameters.adjustments.fajr,
      ));
      _fajr = _fajr?.add(Duration(
        minutes: parameters.methodAdjustments.fajr,
      ));
      _fajr = _fajr?.toLocal();

      _sunrise = CalendarUtil.roundedMinute(sunrise, precision: precision);
      _sunrise = _sunrise?.add(Duration(
        minutes: parameters.adjustments.sunrise,
      ));
      _sunrise = _sunrise?.add(Duration(
        minutes: parameters.methodAdjustments.sunrise,
      ));
      _sunrise = _sunrise?.toLocal();

      if (dhuha != null) {
        _dhuha = CalendarUtil.roundedMinute(dhuha, precision: precision);
        _dhuha = _dhuha?.add(Duration(
          minutes: parameters.adjustments.dhuha,
        ));
        _dhuha = _dhuha?.add(Duration(
          minutes: parameters.methodAdjustments.dhuha,
        ));
        _dhuha = _dhuha?.toLocal();
      }

      _dhuhr = CalendarUtil.roundedMinute(dhuhr, precision: precision);
      _dhuhr = _dhuhr?.add(Duration(
        minutes: parameters.adjustments.dhuhr,
      ));
      _dhuhr = _dhuhr?.add(Duration(
        minutes: parameters.methodAdjustments.dhuhr,
      ));
      _dhuhr = _dhuhr?.toLocal();

      if (asr != null) {
        _asr = CalendarUtil.roundedMinute(asr, precision: precision);
        _asr = _asr?.add(Duration(
          minutes: parameters.adjustments.asr,
        ));
        _asr = _asr?.add(Duration(
          minutes: parameters.methodAdjustments.asr,
        ));
        _asr = _asr?.toLocal();
      }

      _sunset = CalendarUtil.roundedMinute(sunset, precision: precision);
      _sunset = _sunset?.add(Duration(
        minutes: parameters.adjustments.sunset,
      ));
      _sunset = _sunset?.add(Duration(
        minutes: parameters.methodAdjustments.sunset,
      ));
      _sunset = _sunset?.toLocal();

      _maghrib = CalendarUtil.roundedMinute(maghrib, precision: precision);
      _maghrib = _maghrib?.add(Duration(
        minutes: parameters.adjustments.maghrib,
      ));
      _maghrib = _maghrib?.add(Duration(
        minutes: parameters.methodAdjustments.maghrib,
      ));
      _maghrib = _maghrib?.toLocal();

      _isha = CalendarUtil.roundedMinute(isha, precision: precision);
      _isha = _isha?.add(Duration(
        minutes: parameters.adjustments.isha,
      ));
      _isha = _isha?.add(Duration(
        minutes: parameters.methodAdjustments.isha,
      ));
      _isha = _isha?.toLocal();

      if (tomorrowFajr != null) {
        midNight = maghrib
            .add(Duration(
              seconds: tomorrowFajr.difference(maghrib).inSeconds ~/ 2,
            ))
            .utc();

        _midNight = CalendarUtil.roundedMinute(midNight, precision: precision);
        _midNight = _midNight?.add(Duration(
          minutes: parameters.adjustments.midNight,
        ));
        _midNight = _midNight?.add(Duration(
          minutes: parameters.methodAdjustments.midNight,
        ));
        _midNight = _midNight?.toLocal();

        thirdNight = maghrib.add(Duration(
          seconds: tomorrowFajr.difference(maghrib).inSeconds ~/ 3 * 2,
        ));

        _thirdNight = CalendarUtil.roundedMinute(thirdNight, precision: precision);
        _thirdNight = _thirdNight?.add(Duration(
          minutes: parameters.adjustments.thirdNight,
        ));
        _thirdNight = _thirdNight?.add(Duration(
          minutes: parameters.methodAdjustments.thirdNight,
        ));
        _thirdNight = _thirdNight?.toLocal();
      }

      if (offset != null) {
        _fajr = fajr.add(offset);
        _sunrise = sunrise.add(offset);
        _dhuhr = dhuhr.add(offset);
        _asr = asr?.add(offset);
        _maghrib = maghrib.add(offset);
        _isha = isha.add(offset);
        _midNight = midNight?.add(offset);
        _thirdNight = thirdNight?.add(offset);
      }
    }
  }

  late final LocationCoordinates coordinates;
  late final DateTime date;
  late final CalculationParameters parameters;

  static DateTime _seasonAdjustedMorningTwilight(
    double latitude,
    int day,
    int year,
    DateTime sunrise,
  ) {
    final a = 75 + ((28.65 / 55.0) * (latitude).abs());
    final b = 75 + ((19.44 / 55.0) * (latitude).abs());
    final c = 75 + ((32.74 / 55.0) * (latitude).abs());
    final d = 75 + ((48.10 / 55.0) * (latitude).abs());

    double adjustment;
    final dyy = Astronomical.daysSinceSolstice(day, year, latitude);
    if (dyy < 91) {
      adjustment = a + (b - a) / 91.0 * dyy;
    } else if (dyy < 137) {
      adjustment = b + (c - b) / 46.0 * (dyy - 91);
    } else if (dyy < 183) {
      adjustment = c + (d - c) / 46.0 * (dyy - 137);
    } else if (dyy < 229) {
      adjustment = d + (c - d) / 46.0 * (dyy - 183);
    } else if (dyy < 275) {
      adjustment = c + (b - c) / 46.0 * (dyy - 229);
    } else {
      adjustment = b + (a - b) / 91.0 * (dyy - 275);
    }

    return sunrise.add(Duration(seconds: -(adjustment * 60.0).round()));
  }

  DateTime? timeForPrayer(Prayer prayer) {
    if (prayer == Prayer.fajr) {
      return fajr;
    } else if (prayer == Prayer.sunrise) {
      return sunrise;
    } else if (prayer == Prayer.dhuhr) {
      return dhuhr;
    } else if (prayer == Prayer.asr) {
      return asr;
    } else if (prayer == Prayer.sunset) {
      return sunset;
    } else if (prayer == Prayer.maghrib) {
      return maghrib;
    } else if (prayer == Prayer.isha) {
      return isha;
    } else if (prayer == Prayer.midnight) {
      return midNight;
    } else if (prayer == Prayer.thirdnight) {
      return thirdNight;
    }

    return null;
  }

  Prayer currentPrayer() {
    return currentPrayerByDateTime(DateTime.now());
  }

  Prayer currentPrayerByDateTime(DateTime time) {
    final when = time.millisecondsSinceEpoch;
    if (thirdNight != null && thirdNight!.millisecondsSinceEpoch - when <= 0) {
      return Prayer.thirdnight;
    } else if (midNight != null && midNight!.millisecondsSinceEpoch - when <= 0) {
      return Prayer.midnight;
    } else if (isha != null && isha!.millisecondsSinceEpoch - when <= 0) {
      return Prayer.isha;
    } else if (maghrib != null && maghrib!.millisecondsSinceEpoch - when <= 0) {
      return Prayer.maghrib;
    } else if (sunset != null && sunset!.millisecondsSinceEpoch - when <= 0) {
      return Prayer.sunset;
    } else if (asr != null && asr!.millisecondsSinceEpoch - when <= 0) {
      return Prayer.asr;
    } else if (dhuhr != null && dhuhr!.millisecondsSinceEpoch - when <= 0) {
      return Prayer.dhuhr;
    } else if (sunrise != null && sunrise!.millisecondsSinceEpoch - when <= 0) {
      return Prayer.sunrise;
    } else if (fajr != null && fajr!.millisecondsSinceEpoch - when <= 0) {
      return Prayer.fajr;
    }

    return Prayer.none;
  }

  Prayer nextPrayer() {
    return nextPrayerByDateTime(DateTime.now());
  }

  Prayer nextPrayerByDateTime(DateTime time) {
    final when = time.millisecondsSinceEpoch;
    if (fajr != null && when <= fajr!.millisecondsSinceEpoch) {
      return Prayer.fajr;
    } else if (sunrise != null && when <= sunrise!.millisecondsSinceEpoch) {
      return Prayer.sunrise;
    } else if (dhuhr != null && when <= dhuhr!.millisecondsSinceEpoch) {
      return Prayer.dhuhr;
    } else if (asr != null && when <= asr!.millisecondsSinceEpoch) {
      return Prayer.asr;
    } else if (sunset != null && when <= sunset!.millisecondsSinceEpoch) {
      return Prayer.sunset;
    } else if (maghrib != null && when <= maghrib!.millisecondsSinceEpoch) {
      return Prayer.maghrib;
    } else if (isha != null && when <= isha!.millisecondsSinceEpoch) {
      return Prayer.isha;
    } else if (midNight != null && when <= midNight!.millisecondsSinceEpoch) {
      return Prayer.midnight;
    } else if (thirdNight != null && when <= thirdNight!.millisecondsSinceEpoch) {
      return Prayer.thirdnight;
    }

    return Prayer.none;
  }

  static DateTime _seasonAdjustedEveningTwilight(
    double latitude,
    int day,
    int year,
    DateTime sunset,
  ) {
    final a = 75 + ((25.60 / 55.0) * (latitude).abs());
    final b = 75 + ((2.050 / 55.0) * (latitude).abs());
    final c = 75 - ((9.210 / 55.0) * (latitude).abs());
    final d = 75 + ((6.140 / 55.0) * (latitude).abs());

    double adjustment;
    final dyy = Astronomical.daysSinceSolstice(day, year, latitude);
    if (dyy < 91) {
      adjustment = a + (b - a) / 91.0 * dyy;
    } else if (dyy < 137) {
      adjustment = b + (c - b) / 46.0 * (dyy - 91);
    } else if (dyy < 183) {
      adjustment = c + (d - c) / 46.0 * (dyy - 137);
    } else if (dyy < 229) {
      adjustment = d + (c - d) / 46.0 * (dyy - 183);
    } else if (dyy < 275) {
      adjustment = c + (b - c) / 46.0 * (dyy - 229);
    } else {
      adjustment = b + (a - b) / 91.0 * (dyy - 275);
    }

    return sunset.add(Duration(seconds: (adjustment * 60.0).round()));
  }
}
