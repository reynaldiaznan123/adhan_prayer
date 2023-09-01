import 'dart:async';

import 'package:adhan_prayer/adhan_prayer.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final StreamController<LocationCoordinates> _controller = StreamController();

  final DateFormat _formatter = DateFormat('H:m');

  Future<void> _initialize() async {
    bool enabled = await Geolocator.isLocationServiceEnabled();

    if (enabled) {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if ([LocationPermission.always, LocationPermission.whileInUse].contains(permission)) {
        final position = await Geolocator.getCurrentPosition();
        _controller.add(LocationCoordinates(
          latitude: position.latitude,
          longitude: position.longitude,
        ));
      }
    }
  }

  @override
  void initState() {
    _initialize();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        // body: Center(
        //   child: Text('Running on: $_platformVersion\n'),
        // ),
        body: StreamBuilder(
          stream: _controller.stream,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }

            if (snapshot.data != null) {
              final data = snapshot.data!;

              return Row(
                children: [
                  PrayerNowSchedule(
                    coordinates: data,
                    builder: (prayer, current, previous) {
                      if (previous != null && current != null && prayer != null) {
                        DateTime time = DateTime.now();
                        if (previous.nextPrayer() == prayer && prayer != Prayer.none) {
                          time = previous.timeForPrayer(prayer)!;
                        } else if (current.nextPrayer() == prayer && prayer != Prayer.none) {
                          time = current.timeForPrayer(prayer)!;
                        }

                        String name = 'Unknown';
                        if (prayer == Prayer.fajr) {
                          name = 'Subuh';
                        } else if (prayer == Prayer.sunrise) {
                          name = 'Terbit';
                        } else if (prayer == Prayer.dhuhr) {
                          name = 'Dzuhur';
                        } else if (prayer == Prayer.asr) {
                          name = 'Ashar';
                        } else if (prayer == Prayer.sunset) {
                          name = 'Terbenam';
                        } else if (prayer == Prayer.maghrib) {
                          name = 'Maghrib';
                        } else if (prayer == Prayer.isha) {
                          name = 'Isya';
                        } else if (prayer == Prayer.midnight) {
                          name = 'Pertengahan Malam';
                        } else if (prayer == Prayer.thirdnight) {
                          name = 'Sepertiga Malam';
                        }

                        return Text('$name ${_formatter.format(time)}');
                      }

                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    },
                  ),
                  const SizedBox(
                    width: 8.0,
                  ),
                  PrayerTimeCountDown(
                    coordinates: data,
                    builder: (current) {
                      if (current != null) {
                        final hours = current.inHours.remainder(60);
                        final minutes = current.inMinutes.remainder(60);
                        final seconds = current.inSeconds.remainder(60);

                        return Text('$hours:$minutes:$seconds');
                      }

                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    },
                  ),
                ],
              );
            }

            return Container();
          },
        ),
      ),
    );
  }
}
