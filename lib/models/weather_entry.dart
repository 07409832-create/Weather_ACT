class WeatherEntry {
  final DateTime time;
  final double temperature;
  final double humidity;
  final double windSpeed;
  final String? symbol;

  WeatherEntry({
    required this.time,
    required this.temperature,
    required this.humidity,
    required this.windSpeed,
    required this.symbol,
  });

  factory WeatherEntry.fromJson(Map<String, dynamic> json) {
    // 1. details map
    final details = json['data']['instant']['details'] as Map<String, dynamic>;

    // 2. numeric values
    final temperature = (details['air_temperature'] as num).toDouble();
    final humidity = (details['relative_humidity'] as num).toDouble();
    final windSpeed = (details['wind_speed'] as num).toDouble();

    // 3. symbol: next_1_hours, fall back to next_6_hours if null
    final String? symbol = json['data']['next_1_hours']?['summary']?['symbol_code'] ??
        json['data']['next_6_hours']?['summary']?['symbol_code'];

    // 4. time
    final time = DateTime.parse(json['time'] as String).toLocal();

    // 5. return the entry
    return WeatherEntry(
      time: time,
      temperature: temperature,
      humidity: humidity,
      windSpeed: windSpeed,
      symbol: symbol,
    );
  }
}