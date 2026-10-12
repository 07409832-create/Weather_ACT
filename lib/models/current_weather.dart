class CurrentWeather {
  final String city;
  final double temperature; // °C
  final double humidity; // %
  final double windSpeed; // m/s
  final String symbol; // e.g. "partlycloudy_day"

  CurrentWeather({
    required this.city,
    required this.temperature,
    required this.humidity,
    required this.windSpeed,
    required this.symbol,
  });

  /// [json] is the whole response; the first item is
  /// json['properties']['timeseries'][0]
  factory CurrentWeather.fromJson(String city, Map<String, dynamic> json) {
    final first = json['properties']['timeseries'][0];
    final data = first['data'];
    final details = data['instant']['details'];

    // The symbol lives under next_1_hours, but fall back to next_6_hours
    // or next_12_hours if it's missing.
    final String symbol = (data['next_1_hours']?['summary']?['symbol_code'] ??
            data['next_6_hours']?['summary']?['symbol_code'] ??
            data['next_12_hours']?['summary']?['symbol_code'] ??
            'unknown')
        .toString();

    return CurrentWeather(
      city: city,
      temperature: (details['air_temperature'] as num).toDouble(),
      humidity: (details['relative_humidity'] as num).toDouble(),
      windSpeed: (details['wind_speed'] as num).toDouble(),
      symbol: symbol,
    );
  }
}