import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'models/weather_models.dart';
import 'services/weather_service.dart';
import 'screens/weatherscreen.dart';
import 'screens/forecast.dart';
import 'screens/locatins.dart';
import 'screens/details.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Skycast Weather',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
        fontFamily: 'Inter',
      ),
      home: const MainShell(),
    );
  }
}

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _currentIndex = 0;

  // Veri yükleme durumu
  bool _isLoading = true;
  String? _errorMessage;

  // Veri state
  WeatherData? _currentData;
  List<SavedLocation> savedLocations = List.from(mockSavedLocations);

  @override
  void initState() {
    super.initState();
    _loadWeather('İstanbul');
  }

  Future<void> _loadWeather(String city) async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final data = await WeatherService.fetchWeather(city);
      setState(() {
        _currentData = data;
        _isLoading = false;
      });
    } catch (e) {
      final msg = e.toString();
      String userMsg;
      if (msg.contains('401') || msg.contains('Unauthorized') || msg.contains('Invalid API')) {
        userMsg = '⚠️ API key henüz aktif değil. Yeni key\'ler 1-2 saat içinde aktif olur.';
      } else if (msg.contains('404') || msg.contains('bulunamadı')) {
        userMsg = '❌ "$city" şehri bulunamadı. Şehir adını kontrol edin.';
      } else if (msg.contains('SocketException') || msg.contains('network') || msg.contains('Failed host')) {
        userMsg = '📡 İnternet bağlantısı yok. Örnek veri gösteriliyor.';
      } else {
        userMsg = '⚠️ Veri alınamadı: ${msg.length > 60 ? msg.substring(0, 60) : msg}';
      }
      setState(() {
        _currentData = _currentData ?? mockWeatherData;
        _isLoading = false;
        _errorMessage = userMsg;
      });
    }
  }

  Future<bool> _handleAddCity(String cityName) async {
    if (cityName.trim().isEmpty) return false;
    try {
      final data = await WeatherService.fetchWeather(cityName.trim());
      setState(() {
        // Zaten eklenmiş mi kontrol et
        final exists = savedLocations.any(
          (l) => l.city.toLowerCase() == data.city.toLowerCase(),
        );
        if (!exists) {
          savedLocations.add(SavedLocation(
            city: data.city,
            temp: data.temp,
            condition: data.condition,
          ));
        }
      });
      return true;
    } catch (_) {
      // API key yoksa mock ile fallback
      final trimmed = cityName.trim();
      final exists = savedLocations.any(
        (l) => l.city.toLowerCase() == trimmed.toLowerCase(),
      );
      if (!exists && trimmed.isNotEmpty) {
        setState(() {
          savedLocations.add(SavedLocation(
            city: trimmed,
            temp: 20,
            condition: 'Bilinmiyor',
          ));
        });
        return true;
      }
      return false;
    }
  }

  void _handleSelectCity(String cityName) {
    setState(() {
      _currentIndex = 0;
    });
    _loadWeather(cityName);
  }

  @override
  Widget build(BuildContext context) {
    final data = _currentData ?? mockWeatherData;

    final List<Widget> pages = [
      WeatherScreen(data: data, isLoading: _isLoading),
      ForecastScreen(data: data, isLoading: _isLoading),
      LocationsScreen(
        savedLocations: savedLocations,
        onAddCity: _handleAddCity,
        onSelectCity: _handleSelectCity,
      ),
      DetailsScreen(data: data, isLoading: _isLoading),
    ];

    return Scaffold(
      body: Stack(
        children: [
          pages[_currentIndex],
          // API uyarı mesajı
          if (_errorMessage != null)
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Material(
                    elevation: 4,
                    borderRadius: BorderRadius.circular(12),
                    color: Colors.orange.shade100,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      child: Row(
                        children: [
                          Icon(LucideIcons.alertTriangle, color: Colors.orange.shade700, size: 18),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              _errorMessage!,
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.orange.shade900,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          GestureDetector(
                            onTap: () => setState(() => _errorMessage = null),
                            child: Icon(LucideIcons.x, color: Colors.orange.shade700, size: 16),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 20,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: NavigationBarTheme(
          data: NavigationBarThemeData(
            indicatorColor: Colors.blue.shade100,
            labelTextStyle: WidgetStateProperty.all(
              const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
            ),
          ),
          child: NavigationBar(
            selectedIndex: _currentIndex,
            onDestinationSelected: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
            backgroundColor: Colors.white,
            elevation: 0,
            destinations: const [
              NavigationDestination(
                icon: Icon(LucideIcons.home),
                selectedIcon: Icon(LucideIcons.home, color: Colors.blue),
                label: 'Bugün',
              ),
              NavigationDestination(
                icon: Icon(LucideIcons.calendar),
                selectedIcon: Icon(LucideIcons.calendar, color: Colors.blue),
                label: 'Tahmin',
              ),
              NavigationDestination(
                icon: Icon(LucideIcons.mapPin),
                selectedIcon: Icon(LucideIcons.mapPin, color: Colors.blue),
                label: 'Konumlar',
              ),
              NavigationDestination(
                icon: Icon(LucideIcons.menu),
                selectedIcon: Icon(LucideIcons.menu, color: Colors.blue),
                label: 'Detaylar',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
