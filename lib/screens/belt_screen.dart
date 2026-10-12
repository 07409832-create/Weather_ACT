import 'package:flutter/material.dart';
import '../models/current_weather.dart';
import '../services/weather_service.dart';

class FetchResult {
  final CurrentWeather? data;
  final String? error;

  FetchResult.ok(CurrentWeather d)
      : data = d,
        error = null;

  FetchResult.fail(String e)
      : data = null,
        error = e;
}

class BeltScreen extends StatefulWidget {
  const BeltScreen({super.key});
  @override
  State<BeltScreen> createState() => _BeltScreenState();
}

class _BeltScreenState extends State<BeltScreen> {
  final _service = WeatherService();
  late Stream<FetchResult> _stream;

  Stream<FetchResult> _belt() async* {
    int i = 0;
    while (true) {
      final city = cities[i % cities.length]; // 1. pick a city
      try {
        // 2. fetch and emit the result
        yield FetchResult.ok(await _service.fetchCurrent(city));
      } catch (e) {
        yield FetchResult.fail(e.toString());
      }
      i++; // 3.
      await Future.delayed(const Duration(seconds: 5)); // 4.
    }
  }

  @override
  void initState() {
    super.initState();
    _stream = _belt();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<FetchResult>(
      stream: _stream,
      builder: (context, snapshot) {
        final result = snapshot.data;

        // 1. no data yet -> loading
        if (result == null) {
          return const Center(child: CircularProgressIndicator());
        }

        // 2. result has error -> error state
        if (result.error != null) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'Error: ${result.error}',
                style: const TextStyle(color: Colors.red),
                textAlign: TextAlign.center,
              ),
            ),
          );
        }

        // 3. otherwise -> show city, temp, humidity, wind
        final w = result.data!;
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                w.city,
                style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              Text('Temperature: ${w.temperature.toStringAsFixed(1)} °C'),
              Text('Humidity: ${w.humidity.toStringAsFixed(0)} %'),
              Text('Wind: ${w.windSpeed.toStringAsFixed(1)} m/s'),
              Text('Conditions: ${w.symbol}'),
            ],
          ),
        );
      },
    );
  }
}