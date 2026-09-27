import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/weather_models.dart';

// ==========================================
// 1. WEATHER SCREEN WIDGET (ANA EKRAN)
// ==========================================
class WeatherScreen extends StatelessWidget {
  final WeatherData data;
  final bool isLoading;

  const WeatherScreen({super.key, required this.data, this.isLoading = false});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: Row(
          children: [
            Text(
              data.city,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Color(0xFF111827),
                letterSpacing: -0.5,
              ),
            ),
            if (isLoading) ...[
              const SizedBox(width: 10),
              const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.blue),
              ),
            ],
          ],
        ),
        backgroundColor: Colors.white.withOpacity(0.9),
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 16),

            // 1. WeatherHero Alanı
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: WeatherHero(data: data),
            ),
            const SizedBox(height: 20),

            // 2. Saatlik Tahmin Listesi
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Saatlik Tahmin',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF111827),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 120,
                    child: data.hourly.isEmpty
                        ? const Center(child: Text('Veri yok', style: TextStyle(color: Colors.grey)))
                        : ListView.separated(
                            scrollDirection: Axis.horizontal,
                            itemCount: data.hourly.length,
                            separatorBuilder: (_, __) => const SizedBox(width: 12),
                            itemBuilder: (context, idx) {
                              final hour = data.hourly[idx];
                              // İlk item (Şimdi) vurgulansın
                              final isHighlighted = idx == 0;
                              return _HourlyCard(
                                hour: hour,
                                isHighlighted: isHighlighted,
                                animDelay: idx * 50,
                              );
                            },
                          ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // 3. Sıcaklık Grafiği
            if (data.hourly.isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: TemperatureChart(hourlyData: data.hourly),
              ),
            const SizedBox(height: 20),

            // 4. Detay Kartları Izgarası
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: _buildDetailGrid(data),
            ),
            const SizedBox(height: 20),

            // 5. Harita Önizleme Kartı
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: _MapCard(data: data),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailGrid(WeatherData data) {
    final items = [
      {'label': 'RÜZGAR', 'value': data.windSpeed, 'sub': data.windDirection, 'icon': LucideIcons.wind},
      {'label': 'NEM', 'value': '%${data.humidity}', 'sub': 'Çiğ noktası ${(data.feelsLike - 12)}°', 'icon': LucideIcons.droplets},
      {'label': 'UV İNDEKSİ', 'value': '${data.uvIndex}', 'sub': _uvLabel(data.uvIndex), 'icon': LucideIcons.sun},
      {'label': 'GÖRÜŞ', 'value': data.visibility, 'sub': 'Net görüş', 'icon': LucideIcons.eye},
    ];

    return Column(
      children: [
        Row(
          children: [
            Expanded(child: DetailCard(label: items[0]['label'] as String, value: items[0]['value'] as String, subtext: items[0]['sub'] as String, icon: items[0]['icon'] as IconData)),
            const SizedBox(width: 12),
            Expanded(child: DetailCard(label: items[1]['label'] as String, value: items[1]['value'] as String, subtext: items[1]['sub'] as String, icon: items[1]['icon'] as IconData)),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(child: DetailCard(label: items[2]['label'] as String, value: items[2]['value'] as String, subtext: items[2]['sub'] as String, icon: items[2]['icon'] as IconData)),
            const SizedBox(width: 12),
            Expanded(child: DetailCard(label: items[3]['label'] as String, value: items[3]['value'] as String, subtext: items[3]['sub'] as String, icon: items[3]['icon'] as IconData)),
          ],
        ),
      ],
    );
  }

  String _uvLabel(int uv) {
    if (uv <= 2) return 'Düşük';
    if (uv <= 5) return 'Orta';
    if (uv <= 7) return 'Yüksek';
    if (uv <= 10) return 'Çok Yüksek';
    return 'Aşırı';
  }
}

// ==========================================
// Saatlik Kart Bileşeni
// ==========================================
class _HourlyCard extends StatelessWidget {
  final HourlyForecast hour;
  final bool isHighlighted;
  final int animDelay;

  const _HourlyCard({
    required this.hour,
    required this.isHighlighted,
    required this.animDelay,
  });

  String _getEmoji(String condition) {
    final c = condition.toLowerCase();
    if (c.contains('güneş') || c.contains('açık') || c.contains('clear') || c.contains('sunny')) return '☀️';
    if (c.contains('yağmur') || c.contains('rain')) return '🌧️';
    if (c.contains('fırtına') || c.contains('storm')) return '⛈️';
    if (c.contains('kar') || c.contains('snow')) return '❄️';
    if (c.contains('sis') || c.contains('fog') || c.contains('mist')) return '🌫️';
    if (c.contains('bulut') || c.contains('cloud')) return '⛅';
    return '🌤️';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 80,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 14),
      decoration: BoxDecoration(
        color: isHighlighted ? Colors.blue.shade600 : Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: isHighlighted ? Colors.blue.shade600 : const Color(0xFFF3F4F6),
        ),
        boxShadow: isHighlighted
            ? [
                BoxShadow(
                  color: Colors.blue.withOpacity(0.25),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                )
              ]
            : null,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            hour.time,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: isHighlighted ? Colors.white : Colors.grey,
            ),
          ),
          Text(
            _getEmoji(hour.condition),
            style: const TextStyle(fontSize: 20),
          ),
          Text(
            '${hour.temp}°',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isHighlighted ? Colors.white : const Color(0xFF111827),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(
          duration: 200.ms,
          delay: animDelay.ms,
        ).moveX(
          begin: 20,
          end: 0,
          duration: 200.ms,
          delay: animDelay.ms,
        );
  }
}

// ==========================================
// Harita Kartı
// ==========================================
class _MapCard extends StatelessWidget {
  final WeatherData data;
  const _MapCard({required this.data});

  @override
  Widget build(BuildContext context) {
    final hasCoords = data.lat != null && data.lon != null;
    final mapUrl = hasCoords
        ? 'https://static-maps.yandex.ru/1.x/?lang=tr_TR&ll=${data.lon},${data.lat}&z=11&l=map&size=450,250'
        : 'https://images.unsplash.com/photo-1548685913-fe657448d30a?q=80&w=2069&auto=format&fit=crop';

    return Container(
      height: 190,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: Stack(
          children: [
            Positioned.fill(
              child: Image.network(
                mapUrl,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  color: Colors.blue.shade50,
                  child: const Center(child: Icon(LucideIcons.map, size: 48, color: Colors.blue)),
                ),
              ),
            ),
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.transparent, Colors.black.withOpacity(0.4)],
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: 16,
              left: 0,
              right: 0,
              child: Center(
                child: ElevatedButton.icon(
                  onPressed: hasCoords
                      ? () async {
                          final url = Uri.parse(
                            'https://www.openstreetmap.org/#map=13/${data.lat}/${data.lon}',
                          );
                          try {
                            await launchUrl(url, mode: LaunchMode.externalApplication);
                          } catch (_) {
                            await launchUrl(url, mode: LaunchMode.platformDefault);
                          }
                        }
                      : null,
                  icon: const Icon(LucideIcons.externalLink, size: 16),
                  label: const Text(
                    'Yağış Haritasını Keşfet',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue.shade600,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                    elevation: 6,
                    shadowColor: Colors.blue.withOpacity(0.4),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ==========================================
// 2. SUB-COMPONENT: WEATHER HERO WIDGET
// ==========================================
class WeatherHero extends StatelessWidget {
  final WeatherData data;

  const WeatherHero({super.key, required this.data});

  String _getBgImage(String condition) {
    final c = condition.toLowerCase();
    if (c.contains('güneş') || c.contains('açık') || c.contains('clear') || c.contains('sunny')) {
      return 'https://images.unsplash.com/photo-1506466010722-395aa2bef877?q=80&w=2153&auto=format&fit=crop';
    }
    if (c.contains('yağmur') || c.contains('rain') || c.contains('fırtına') || c.contains('storm')) {
      return 'https://images.unsplash.com/photo-1534274988757-a28bf1f539cf?q=80&w=2030&auto=format&fit=crop';
    }
    if (c.contains('kar') || c.contains('snow')) {
      return 'https://images.unsplash.com/photo-1491002052546-bf38f186af56?q=80&w=2083&auto=format&fit=crop';
    }
    return 'https://images.unsplash.com/photo-1534088568595-a066f410bcda?q=80&w=2070&auto=format&fit=crop';
  }

  Widget _getAnimatedIcon(String condition) {
    final c = condition.toLowerCase();

    Widget baseIcon(IconData icon) => Icon(
          icon,
          size: 60,
          color: Colors.white,
          shadows: [Shadow(color: Colors.white.withOpacity(0.5), blurRadius: 15)],
        );

    if (c.contains('güneş') || c.contains('clear') || c.contains('sunny') || c.contains('açık')) {
      return baseIcon(LucideIcons.sun)
          .animate(onPlay: (ctrl) => ctrl.repeat())
          .rotate(duration: 4.seconds, curve: Curves.linear);
    }
    if (c.contains('yağmur') || c.contains('rain')) {
      return baseIcon(LucideIcons.cloudRain)
          .animate(onPlay: (ctrl) => ctrl.repeat(reverse: true))
          .moveY(begin: -3, end: 3, duration: 2.seconds, curve: Curves.easeInOut);
    }
    if (c.contains('fırtına') || c.contains('storm')) {
      return baseIcon(LucideIcons.cloudLightning)
          .animate(onPlay: (ctrl) => ctrl.repeat(reverse: true))
          .moveY(begin: -2, end: 2, duration: 1.seconds, curve: Curves.easeInOut);
    }
    if (c.contains('kar') || c.contains('snow')) {
      return baseIcon(LucideIcons.snowflake)
          .animate(onPlay: (ctrl) => ctrl.repeat())
          .rotate(duration: 6.seconds, curve: Curves.linear);
    }
    return baseIcon(LucideIcons.cloud)
        .animate(onPlay: (ctrl) => ctrl.repeat(reverse: true))
        .moveX(begin: -5, end: 5, duration: 3.seconds, curve: Curves.easeInOut);
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    // Ekran yüksekliğinin %42'si kadar hero, min 320, max 440
    final heroHeight = (screenHeight * 0.44).clamp(340.0, 460.0);

    return Container(
      height: heroHeight,
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
      decoration: BoxDecoration(
        color: Colors.blue.shade600,
        borderRadius: BorderRadius.circular(36),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withOpacity(0.3),
            blurRadius: 25,
            offset: const Offset(0, 12),
          )
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(36),
        child: Stack(
          children: [
            Positioned.fill(
              child: Image.network(
                _getBgImage(data.condition),
                fit: BoxFit.cover,
                color: Colors.black.withOpacity(0.35),
                colorBlendMode: BlendMode.darken,
                errorBuilder: (_, __, ___) => Container(color: Colors.blue.shade700),
              ),
            ),
            Column(
              children: [
                // Tarih ve Şehir
                Text(
                  _todayLabel(),
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 2,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  data.city,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.5,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                const Spacer(),

                // İkon ve Sıcaklık
                _getAnimatedIcon(data.condition),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${data.temp}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 76,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -4,
                        height: 1,
                      ),
                    ),
                    const Text(
                      '°',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 42,
                        fontWeight: FontWeight.w300,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  data.condition,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.white.withOpacity(0.15)),
                  ),
                  child: Text(
                    'Hissedilen ${data.feelsLike}°',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const Spacer(),

                // Alt satır: En Y / En D
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.only(top: 12),
                  decoration: BoxDecoration(
                    border: Border(
                      top: BorderSide(color: Colors.white.withOpacity(0.2)),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _HighLowItem(label: 'En Yüksek', value: '${data.high}°'),
                      const SizedBox(width: 40),
                      _HighLowItem(label: 'En Düşük', value: '${data.low}°'),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    ).animate().fadeIn(duration: 400.ms).moveY(begin: 20, end: 0, duration: 400.ms);
  }

  String _todayLabel() {
    final now = DateTime.now();
    const months = ['OCA', 'ŞUB', 'MAR', 'NİS', 'MAY', 'HAZ', 'TEM', 'AĞU', 'EYL', 'EKİ', 'KAS', 'ARA'];
    return 'BUGÜN • ${now.day} ${months[now.month - 1]}';
  }
}

class _HighLowItem extends StatelessWidget {
  final String label;
  final String value;
  const _HighLowItem({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(label, style: const TextStyle(color: Colors.white60, fontSize: 10, fontWeight: FontWeight.bold)),
        Text(value, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w900)),
      ],
    );
  }
}

// ==========================================
// 3. SUB-COMPONENT: TEMPERATURE CHART WIDGET
// ==========================================
class TemperatureChart extends StatelessWidget {
  final List<HourlyForecast> hourlyData;

  const TemperatureChart({super.key, required this.hourlyData});

  @override
  Widget build(BuildContext context) {
    final List<FlSpot> spots = [];
    double minTemp = 99;
    double maxTemp = -99;

    for (int i = 0; i < hourlyData.length; i++) {
      final t = hourlyData[i].temp.toDouble();
      spots.add(FlSpot(i.toDouble(), t));
      if (t < minTemp) minTemp = t;
      if (t > maxTemp) maxTemp = t;
    }

    return Container(
      height: 200,
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: const Color(0xFFF3F4F6)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'SICAKLIK GRAFIĞI',
                style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 1.1),
              ),
              Row(
                children: [
                  _buildLegendBadge(Colors.blue.shade600, 'Sıcaklık'),
                ],
              )
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: LineChart(
              LineChartData(
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  getDrawingHorizontalLine: (_) => FlLine(
                    color: const Color(0xFFF3F4F6),
                    strokeWidth: 1,
                  ),
                ),
                titlesData: FlTitlesData(
                  show: true,
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  bottomTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 30,
                      getTitlesWidget: (value, meta) => Text(
                        '${value.round()}°',
                        style: const TextStyle(fontSize: 9, color: Colors.grey, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ),
                borderData: FlBorderData(show: false),
                minX: 0,
                maxX: (hourlyData.length - 1).toDouble(),
                minY: minTemp - 2,
                maxY: maxTemp + 2,
                lineBarsData: [
                  LineChartBarData(
                    spots: spots,
                    isCurved: true,
                    color: Colors.blue.shade600,
                    barWidth: 3,
                    isStrokeCapRound: true,
                    dotData: FlDotData(
                      show: true,
                      getDotPainter: (spot, percent, bar, index) => FlDotCirclePainter(
                        radius: 3,
                        color: Colors.blue.shade600,
                        strokeWidth: 2,
                        strokeColor: Colors.white,
                      ),
                    ),
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.blue.shade600.withOpacity(0.25),
                          Colors.blue.shade600.withOpacity(0),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                hourlyData.first.time,
                style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.grey),
              ),
              Text(
                hourlyData.length > 4 ? hourlyData[hourlyData.length ~/ 2].time : '',
                style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.grey),
              ),
              Text(
                hourlyData.last.time,
                style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.grey),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLegendBadge(Color color, String text) {
    return Row(
      children: [
        Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 4),
        Text(text, style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.grey)),
      ],
    );
  }
}

// ==========================================
// 4. SUB-COMPONENT: DETAIL CARD WIDGET
// ==========================================
class DetailCard extends StatelessWidget {
  final String label;
  final String value;
  final String subtext;
  final IconData icon;

  const DetailCard({
    super.key,
    required this.label,
    required this.value,
    required this.subtext,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFF3F4F6)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: Colors.blue.shade400),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey,
                    letterSpacing: 1.0,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            value,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Color(0xFF111827),
            ),
            overflow: TextOverflow.ellipsis,
          ),
          if (subtext.isNotEmpty) ...[
            const SizedBox(height: 2),
            Text(
              subtext,
              style: const TextStyle(
                fontSize: 11,
                color: Colors.grey,
                height: 1.3,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ],
      ),
    );
  }
}