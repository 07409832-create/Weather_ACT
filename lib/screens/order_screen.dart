import 'package:flutter/material.dart';
import '../models/weather_entry.dart';
import '../services/weather_service.dart';

class OrderScreen extends StatefulWidget {
  const OrderScreen({super.key});
  @override
  State<OrderScreen> createState() => _OrderScreenState();
}

class _OrderScreenState extends State<OrderScreen> {
  final _service = WeatherService();
  late Future<List<WeatherEntry>> _future;

  @override
  void initState() {
    super.initState();
    // assign _future ONCE here
    _future = _service.fetchForecast();
  }

  void _retry() {
    setState(() {
      _future = _service.fetchForecast();
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<WeatherEntry>>(
      future: _future,
      builder: (context, snapshot) {
        // 1. waiting -> spinner
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        // 2. hasError -> message + Retry button
        if (snapshot.hasError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Something went wrong: ${snapshot.error}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.red),
                ),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: _retry,
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }

        // 3. empty data -> 'Nothing to show'
        final entries = snapshot.data ?? [];
        if (entries.isEmpty) {
          return const Center(child: Text('Nothing to show'));
        }

        // 4. otherwise -> ListView.builder of rows
        return ListView.builder(
          itemCount: entries.length,
          itemBuilder: (context, index) {
            final e = entries[index];
            final t = e.time;
            final hh = t.hour.toString().padLeft(2, '0');
            final mm = t.minute.toString().padLeft(2, '0');
            return ListTile(
              leading: const Icon(Icons.wb_sunny_outlined),
              title: Text('${t.month}/${t.day}  $hh:$mm'),
              subtitle: Text(
                '${e.temperature.toStringAsFixed(1)} °C  •  '
                '${e.humidity.toStringAsFixed(0)} %  •  '
                '${e.windSpeed.toStringAsFixed(1)} m/s',
              ),
              trailing: Text(e.symbol ?? '—'),
            );
          },
        );
      },
    );
  }
}