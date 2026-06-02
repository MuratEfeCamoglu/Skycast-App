class HourlyForecast {
  final String time;
  final int temp;
  final String condition;
  final int rainChance;
  final int feelsLike;

  HourlyForecast({
    required this.time,
    required this.temp,
    required this.condition,
    this.rainChance = 0,
    this.feelsLike = 0,
  });
}

class DailyForecast {
  final String day;
  final String date;
  final int high;
  final int low;
  final String condition;

  DailyForecast({
    required this.day,
    required this.date,
    required this.high,
    required this.low,
    required this.condition,
  });
}

class WeatherData {
  final String city;
  final int temp;
  final String condition;
  final int humidity;
  final int feelsLike;
  final String windSpeed;
  final int uvIndex;
  final String pressure;
  final String visibility;
  final double? lat;
  final double? lon;
  final int rainProbability;
  final int high;
  final int low;
  final String windDirection;
  final List<HourlyForecast> hourly;
  final List<DailyForecast> daily;

  WeatherData({
    required this.city,
    required this.temp,
    required this.condition,
    required this.humidity,
    required this.feelsLike,
    required this.windSpeed,
    required this.uvIndex,
    required this.pressure,
    required this.visibility,
    this.lat,
    this.lon,
    required this.rainProbability,
    required this.high,
    required this.low,
    required this.windDirection,
    required this.hourly,
    required this.daily,
  });
}

class SavedLocation {
  final String city;
  final int temp;
  final String condition;

  SavedLocation({
    required this.city,
    required this.temp,
    required this.condition,
  });
}

// MOCK DATA
final WeatherData mockWeatherData = WeatherData(
  city: 'İstanbul',
  temp: 22,
  condition: 'Parçalı Bulutlu',
  humidity: 65,
  feelsLike: 24,
  windSpeed: '18 km/s',
  uvIndex: 4,
  pressure: '1012 hPa',
  visibility: '10 km',
  lat: 41.0082,
  lon: 28.9784,
  rainProbability: 20,
  high: 26,
  low: 18,
  windDirection: 'Kuzeybatı',
  hourly: [
    HourlyForecast(time: 'Şimdi', temp: 22, condition: 'parçalı bulutlu', rainChance: 0, feelsLike: 24),
    HourlyForecast(time: '12:00', temp: 24, condition: 'güneşli', rainChance: 0, feelsLike: 25),
    HourlyForecast(time: '13:00', temp: 25, condition: 'güneşli', rainChance: 10, feelsLike: 26),
    HourlyForecast(time: '14:00', temp: 26, condition: 'güneşli', rainChance: 10, feelsLike: 27),
    HourlyForecast(time: '15:00', temp: 25, condition: 'parçalı bulutlu', rainChance: 20, feelsLike: 26),
    HourlyForecast(time: '16:00', temp: 24, condition: 'bulutlu', rainChance: 30, feelsLike: 25),
    HourlyForecast(time: '17:00', temp: 22, condition: 'yağmurlu', rainChance: 80, feelsLike: 22),
    HourlyForecast(time: '18:00', temp: 20, condition: 'yağmurlu', rainChance: 90, feelsLike: 19),
  ],
  daily: [
    DailyForecast(day: 'Bugün', date: '24 Eki', high: 26, low: 18, condition: 'Parçalı Bulutlu'),
    DailyForecast(day: 'Cuma', date: '25 Eki', high: 24, low: 16, condition: 'Yağmurlu'),
    DailyForecast(day: 'Cmt', date: '26 Eki', high: 22, low: 15, condition: 'Bulutlu'),
    DailyForecast(day: 'Paz', date: '27 Eki', high: 25, low: 17, condition: 'Güneşli'),
    DailyForecast(day: 'Pzt', date: '28 Eki', high: 27, low: 18, condition: 'Güneşli'),
    DailyForecast(day: 'Sal', date: '29 Eki', high: 23, low: 14, condition: 'Yağmurlu'),
    DailyForecast(day: 'Çar', date: '30 Eki', high: 20, low: 12, condition: 'Bulutlu'),
  ],
);

final List<SavedLocation> mockSavedLocations = [
  SavedLocation(city: 'Ankara', temp: 18, condition: 'Açık'),
  SavedLocation(city: 'İzmir', temp: 28, condition: 'Güneşli'),
  SavedLocation(city: 'Antalya', temp: 30, condition: 'Güneşli'),
];
