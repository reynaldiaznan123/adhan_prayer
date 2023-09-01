import 'dart:async';

import 'package:adhan_prayer/src/coordinates.dart';
import 'package:adhan_prayer/src/method.dart';
import 'package:adhan_prayer/src/times.dart';
import 'package:flutter/material.dart';

typedef PrayerDateWidgetBuilder = Widget Function(
  Prayer? prayer,
  PrayerTimes? current,
  PrayerTimes? previous,
);

typedef PrayerTimeWidgetBuilder = Widget Function(
  Duration? current,
);

class PrayerTimeCountDown extends StatefulWidget {
  const PrayerTimeCountDown({
    super.key,
    required this.coordinates,
    required this.builder,
  });

  final LocationCoordinates coordinates;

  final PrayerTimeWidgetBuilder builder;

  @override
  State<PrayerTimeCountDown> createState() => _PrayerTimeCountDownState();
}

class _PrayerTimeCountDownState extends State<PrayerTimeCountDown> {
  late final StreamController<Duration> _controller;
  late final Stream<Duration> _stream;

  Future<void> _initialize() async {
    _controller = StreamController<Duration>();
    _stream = _controller.stream.asBroadcastStream();

    try {
      final coordinates = widget.coordinates;
      final parameters = const CalculationMethod(
        type: CalcMethodType.kemanag,
      ).parameters();

      PrayerTimes previous = PrayerTimes.previous(
        coordinates: coordinates,
        parameters: parameters,
      );
      PrayerTimes current = PrayerTimes.today(
        coordinates: coordinates,
        parameters: parameters,
      );
      Timer.periodic(const Duration(seconds: 1), (timer) {
        DateTime? time = current.timeForPrayer(current.nextPrayer());
        if (previous.nextPrayer() != Prayer.none) {
          time = previous.timeForPrayer(previous.nextPrayer());
        } else {
          previous = PrayerTimes.previous(
            coordinates: coordinates,
            parameters: parameters,
          );

          final prayer = current.nextPrayer();
          if (prayer == Prayer.none) {
            PrayerTimes current = PrayerTimes.today(
              coordinates: coordinates,
              parameters: parameters,
            );

            time = current.timeForPrayer(current.nextPrayer());
          }
        }
        
        final start = DateTime.now();
        final end = time;
        if (end != null) {
          _controller.add(end.difference(start));
        }
      });
    } catch (_) {}
  }

  @override
  void initState() {
    _initialize();
    super.initState();
  }

  @override
  void dispose() {
    _controller.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: _stream,
      builder: (context, snapshot) {
        return widget.builder(snapshot.data);
      },
    );
  }
}

class PrayerNowSchedule extends StatefulWidget {
  const PrayerNowSchedule({
    super.key,
    required this.coordinates,
    required this.builder,
  });

  final LocationCoordinates coordinates;

  final PrayerDateWidgetBuilder builder;

  @override
  State<PrayerNowSchedule> createState() => _PrayerNowScheduleState();
}

class _PrayerNowScheduleState extends State<PrayerNowSchedule> {
  PrayerTimes? _prev;
  PrayerTimes? _current;

  Prayer? _cache;

  Future<void> _initialize() async {
    try {
      final coordinates = widget.coordinates;
      final parameters = const CalculationMethod(
        type: CalcMethodType.kemanag,
      ).parameters();

      _prev = PrayerTimes.previous(
        coordinates: coordinates,
        parameters: parameters,
      );
      _current = PrayerTimes.today(
        coordinates: coordinates,
        parameters: parameters,
      );
      Timer.periodic(const Duration(seconds: 1), (timer) {
        if (_prev!.nextPrayer() != Prayer.none) {
          setState(() {
            _cache = _prev!.nextPrayer();
          });
        } else {
          _prev = PrayerTimes.previous(
            coordinates: coordinates,
            parameters: parameters,
          );

          final prayer = _current!.nextPrayer();
          if (prayer == Prayer.none) {
            _current = PrayerTimes.today(
              coordinates: coordinates,
              parameters: parameters,
            );
            
            setState(() {
              _cache = _current!.nextPrayer();
            });
          } else if (_cache != prayer) {
            setState(() {
              _cache = prayer;
            });
          }
        }
      });
    } catch (_) {}
  }

  @override
  void initState() {
    _initialize();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return widget.builder(_cache, _current, _prev);
  }
}

