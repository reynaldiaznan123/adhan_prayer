class PrayerAdjustments {
  final int fajr;

  /// Sunrise offset in minutes
  final int sunrise;

  final int dhuha;

  /// Dhuhr offset in minutes
  final int dhuhr;

  /// Asr offset in minutes
  final int asr;

  /// Sunset offset in minutes
  final int sunset;

  /// Maghrib offset in minutes
  final int maghrib;

  /// Isha offset in minutes
  final int isha;

  /// Mid of night offset in minutes
  final int midNight;

  /// Third of night offset in minutes
  final int thirdNight;

  const PrayerAdjustments({
    this.fajr = 0,
    this.sunrise = 0,
    this.dhuha = 0,
    this.dhuhr = 0,
    this.asr = 0,
    this.sunset = 0,
    this.maghrib = 0,
    this.isha = 0,
    this.midNight = 0,
    this.thirdNight = 0,
  });

  PrayerAdjustments copyWith({
    int? fajr,
    int? sunrise,
    int? dhuha,
    int? dhuhr,
    int? asr,
    int? sunset,
    int? maghrib,
    int? isha,
    int? midNight,
    int? thirdNight,
  }) {
    return PrayerAdjustments(
      fajr: fajr ?? this.fajr,
      sunrise: sunrise ?? this.sunrise,
      dhuha: dhuha ?? this.dhuha,
      dhuhr: dhuhr ?? this.dhuhr,
      asr: asr ?? this.asr,
      sunset: sunset ?? this.sunset,
      maghrib: maghrib ?? this.maghrib,
      isha: isha ?? this.isha,
      midNight: midNight ?? this.midNight,
      thirdNight: thirdNight ?? this.thirdNight,
    );
  }
}
