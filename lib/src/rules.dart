/// Rules for dealing with Fajr and Isha at places with high latitudes
enum HighLatitudeRule {
  /// Fajr will never be earlier than the middle of the night, and Isha will never be later than
  /// the middle of the night.
  middleOfTheNight,

  /// Fajr will never be earlier than the beginning of the last seventh of the night, and Isha will
  /// never be later than the end of hte first seventh of the night.
  seventhOfTheNight,

  quarterOfTheNight,

  /// Similar to [HighLatitudeRule.seventhOfTheNight], but instead of 1/7th, the faction
  /// of the night used is fajrAngle / 60 and ishaAngle/60.
  twilightAngle,
}