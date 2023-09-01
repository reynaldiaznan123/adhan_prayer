import 'package:adhan_prayer/src/coordinates.dart';
import 'package:adhan_prayer/src/madhab.dart';
import 'package:adhan_prayer/src/method.dart';
import 'package:adhan_prayer/src/times.dart';

void main() {
  Madhab.standard.getShadowLength();
  Madhab.hanafi.getShadowLength();

  const method = CalculationMethod(
    type: CalcMethodType.kemanag,
  );
  final times = PrayerTimes(
    coordinates: const LocationCoordinates(
      latitude: 0.4975853122625686,
      longitude: 101.37143544805068,

      // latitude: 17.3850,
      // longitude: 78.4867,
      
      // latitude: 55.898205,
      // longitude: 75.321398,
    ),
    date: DateTime(2023, 8, 31),
    parameters: method.parameters(),
  );

  // int timezoneAdj = (7.0 * 60).toInt();
  print(times.fajr);
  print(times.sunrise);
  print(times.dhuhr);
  print(times.asr);
  print(times.maghrib);
  print(times.isha);
  print(times.midNight);
  print(times.thirdNight);

  final prayer = times.nextPrayerByDateTime(
    // DateTime(2023, 9, 1, 22, 0, 0),
    DateTime.now(),
  );
  // final time = times.timeForPrayer(prayer);
  print(prayer);

  // final start = DateTime(2023, 9, 2, 4, 53);
  // final end = DateTime(2023, 9, 1, 18, 18);
  // final diff = start.difference(end);
  // print(end.add(Duration(
  //   seconds: diff.inSeconds ~/ 2,
  // )));
}