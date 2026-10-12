import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/weather_entry.dart';
import '../models/current_weather.dart';

class City {
  final String name;
  final double lat;
  final double lon;
  const City(this.name, this.lat, this.lon);
}

const cities = [
  City('Legazpi', 13.14, 123.74),
  City('Manila', 14.5995, 120.9842),
  City('Cebu', 10.3157, 123.8854),
  City('Davao', 7.1907, 125.4553),
  City('Tokyo', 35.6762, 139.6503),
];

class WeatherService {
  Future<Map<String, dynamic>> _get(double lat, double lon) async {
    // 1. build the Uri for the MET Norway compact URL
    final uri = Uri.https(
      'api.met.no',
      '/weatherapi/locationforecast/2.0/compact',
      {'lat': lat.toString(), 'lon': lon.toString()},
    );

    // 2 & 3. http.get with a User-Agent header and a 10 second timeout
    final response = await http.get(
      uri,
      headers: {'User-Agent': 'api_midterm/1.0 (student project)'},
    ).timeout(const Duration(seconds: 10));

    // 4. non-200 -> throw
    if (response.statusCode != 200) {
      throw Exception('Request failed with status ${response.statusCode}');
    }

    // 5. decode and return
    return jsonDecode(response.body) as Map<String, dynamic>;
  }

  Future<List<WeatherEntry>> fetchForecast() async {
    // Legazpi is the first city in the list
    final legazpi = cities.first;
    final data = await _get(legazpi.lat, legazpi.lon);

    final timeseries = data['properties']['timeseries'] as List<dynamic>;
    return timeseries
        .take(24)
        .map((e) => WeatherEntry.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<CurrentWeather> fetchCurrent(City city) async {
    final data = await _get(city.lat, city.lon);
    return CurrentWeather.fromJson(city.name, data);
  }
}