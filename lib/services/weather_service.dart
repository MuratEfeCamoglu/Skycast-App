import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/weather_models.dart';

class WeatherService {
  static const String _apiKey = '04f61c82fc9711bf0d60b6dd4e05a80c'; // OpenWeatherMap API key buraya
  static const String _baseUrl = 'https://api.openweathermap.org/data/2.5';

  // Hava durumu ikonunu Türkçe durum stringine çevir
  static String _conditionFromIcon(String icon, String description) {
    if (icon.startsWith('01')) return 'Güneşli';
    if (icon.startsWith('02') || icon.startsWith('03')) return 'Parçalı Bulutlu';
    if (icon.startsWith('04')) return 'Bulutlu';
    if (icon.startsWith('09') || icon.startsWith('10')) return 'Yağmurlu';
    if (icon.startsWith('11')) return 'Fırtınalı';
    if (icon.startsWith('13')) return 'Karlı';
    if (icon.startsWith('50')) return 'Sisli';
    return description;
  }

  // Gün adını döndür (Türkçe)
  static String _dayName(int weekday) {
    const days = ['Pzt', 'Sal', 'Çar', 'Per', 'Cum', 'Cmt', 'Paz'];
    return days[(weekday - 1) % 7];
  }

  // Şehir adına göre güncel hava durumu ve tahmin verisi çek
  static Future<WeatherData> fetchWeather(String city) async {
    // 1. Güncel Hava Durumu
    final currentUrl = Uri.parse(
      '$_baseUrl/weather?q=${Uri.encodeComponent(city)}&appid=$_apiKey&units=metric&lang=tr',
    );

    final currentResponse = await http.get(currentUrl);
    if (currentResponse.statusCode == 401) {
      throw Exception('401 Unauthorized: API key geçersiz veya henüz aktif değil.');
    }
    if (currentResponse.statusCode == 404) {
      throw Exception('404 bulunamadı: $city');
    }
    if (currentResponse.statusCode != 200) {
      throw Exception('HTTP ${currentResponse.statusCode}: ${currentResponse.body}');
    }

    final currentJson = jsonDecode(currentResponse.body) as Map<String, dynamic>;

    // 2. 5 Günlük Tahmin (3 saatlik)
    final forecastUrl = Uri.parse(
      '$_baseUrl/forecast?q=${Uri.encodeComponent(city)}&appid=$_apiKey&units=metric&lang=tr&cnt=40',
    );

    final forecastResponse = await http.get(forecastUrl);
    if (forecastResponse.statusCode != 200) {
      throw Exception('Tahmin verisi alınamadı');
    }

    final forecastJson = jsonDecode(forecastResponse.body) as Map<String, dynamic>;
    final forecastList = forecastJson['list'] as List<dynamic>;

    // Saatlik tahmin (ilk 8 kayıt = 24 saat)
    final hourlyList = <HourlyForecast>[];
    for (int i = 0; i < forecastList.length && i < 8; i++) {
      final item = forecastList[i] as Map<String, dynamic>;
      final dt = DateTime.fromMillisecondsSinceEpoch(
        (item['dt'] as int) * 1000,
        isUtc: true,
      ).toLocal();
      final weather = (item['weather'] as List).first as Map<String, dynamic>;
      final main = item['main'] as Map<String, dynamic>;

      hourlyList.add(HourlyForecast(
        time: i == 0 ? 'Şimdi' : '${dt.hour.toString().padLeft(2, '0')}:00',
        temp: (main['temp'] as num).round(),
        condition: weather['description'] as String,
        rainChance: item['pop'] != null ? ((item['pop'] as num) * 100).round() : 0,
        feelsLike: (main['feels_like'] as num).round(),
      ));
    }

    // Günlük tahmin (her günün öğle saati baz alınır)
    final Map<String, Map<String, dynamic>> dailyMap = {};
    for (final item in forecastList) {
      final itemMap = item as Map<String, dynamic>;
      final dt = DateTime.fromMillisecondsSinceEpoch(
        (itemMap['dt'] as int) * 1000,
        isUtc: true,
      ).toLocal();
      final dateKey = '${dt.year}-${dt.month}-${dt.day}';
      final main = itemMap['main'] as Map<String, dynamic>;
      final weather = (itemMap['weather'] as List).first as Map<String, dynamic>;

      if (!dailyMap.containsKey(dateKey)) {
        dailyMap[dateKey] = {
          'dt': dt,
          'high': (main['temp_max'] as num).round(),
          'low': (main['temp_min'] as num).round(),
          'icon': weather['icon'] as String,
          'description': weather['description'] as String,
        };
      } else {
        final existing = dailyMap[dateKey]!;
        if ((main['temp_max'] as num) > (existing['high'] as int)) {
          existing['high'] = (main['temp_max'] as num).round();
        }
        if ((main['temp_min'] as num) < (existing['low'] as int)) {
          existing['low'] = (main['temp_min'] as num).round();
        }
      }
    }

    final dailyList = <DailyForecast>[];
    int dayCount = 0;
    for (final entry in dailyMap.entries) {
      if (dayCount >= 7) break;
      final dt = entry.value['dt'] as DateTime;
      dailyList.add(DailyForecast(
        day: dayCount == 0 ? 'Bugün' : _dayName(dt.weekday),
        date: '${dt.day} ${_monthName(dt.month)}',
        high: entry.value['high'] as int,
        low: entry.value['low'] as int,
        condition: _conditionFromIcon(
          entry.value['icon'] as String,
          entry.value['description'] as String,
        ),
      ));
      dayCount++;
    }

    // Ana veriye dönüştür
    final mainData = currentJson['main'] as Map<String, dynamic>;
    final windData = currentJson['wind'] as Map<String, dynamic>;
    final weatherInfo = (currentJson['weather'] as List).first as Map<String, dynamic>;
    final coordData = currentJson['coord'] as Map<String, dynamic>;

    final double windMs = (windData['speed'] as num).toDouble();
    final double windKmh = windMs * 3.6;
    final int windDeg = (windData['deg'] as num?)?.toInt() ?? 0;

    final condition = _conditionFromIcon(
      weatherInfo['icon'] as String,
      weatherInfo['description'] as String,
    );

    return WeatherData(
      city: currentJson['name'] as String,
      temp: (mainData['temp'] as num).round(),
      condition: condition,
      humidity: (mainData['humidity'] as num).toInt(),
      feelsLike: (mainData['feels_like'] as num).round(),
      windSpeed: '${windKmh.round()} km/s',
      uvIndex: 3, // UV index ayrı endpoint gerektirir, varsayılan
      pressure: '${mainData['pressure']} hPa',
      visibility: currentJson['visibility'] != null
          ? '${((currentJson['visibility'] as num) / 1000).round()} km'
          : 'N/A',
      lat: (coordData['lat'] as num).toDouble(),
      lon: (coordData['lon'] as num).toDouble(),
      rainProbability: hourlyList.isNotEmpty ? hourlyList.first.rainChance : 0,
      high: dailyList.isNotEmpty ? dailyList.first.high : (mainData['temp_max'] as num? ?? mainData['temp'] as num).round(),
      low: dailyList.isNotEmpty ? dailyList.first.low : (mainData['temp_min'] as num? ?? mainData['temp'] as num).round(),
      windDirection: _windDirection(windDeg),
      hourly: hourlyList,
      daily: dailyList,
    );
  }

  // Şehir koordinatlarıyla hava durumu getir
  static Future<WeatherData> fetchWeatherByCoords(double lat, double lon) async {
    final currentUrl = Uri.parse(
      '$_baseUrl/weather?lat=$lat&lon=$lon&appid=$_apiKey&units=metric&lang=tr',
    );
    final resp = await http.get(currentUrl);
    if (resp.statusCode != 200) throw Exception('Konum verisi alınamadı');
    final json = jsonDecode(resp.body) as Map<String, dynamic>;
    final cityName = json['name'] as String;
    return fetchWeather(cityName);
  }

  static String _windDirection(int deg) {
    if (deg >= 337 || deg < 22) return 'Kuzey';
    if (deg < 67) return 'Kuzeydoğu';
    if (deg < 112) return 'Doğu';
    if (deg < 157) return 'Güneydoğu';
    if (deg < 202) return 'Güney';
    if (deg < 247) return 'Güneybatı';
    if (deg < 292) return 'Batı';
    return 'Kuzeybatı';
  }

  static String _monthName(int month) {
    const months = ['Oca', 'Şub', 'Mar', 'Nis', 'May', 'Haz', 'Tem', 'Ağu', 'Eyl', 'Eki', 'Kas', 'Ara'];
    return months[month - 1];
  }
}
