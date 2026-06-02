import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/weather_models.dart';

// ==========================================
// DETAILS SCREEN
// ==========================================

class DetailsScreen extends StatelessWidget {
  final WeatherData data;
  final bool isLoading;

  const DetailsScreen({super.key, required this.data, this.isLoading = false});

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
        padding: const EdgeInsets.only(bottom: 28.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 20),

            // Ana Sıcaklık Göstergesi
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: _TemperatureHeader(data: data),
            ),
            const SizedBox(height: 20),

            // 2 Kolonlu Metrik Izgarası
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: _buildMetricGrid(data),
            ),
            const SizedBox(height: 20),

            // Harita Kartı
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: _MapDetailCard(data: data),
            ),
            const SizedBox(height: 20),

            // 3 Günlük Tahmin
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Yakın Tahmin',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF111827),
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: data.daily.length > 3 ? 3 : data.daily.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (context, idx) {
                      final day = data.daily[idx];
                      return _DayForecastRow(day: day, idx: idx);
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricGrid(WeatherData data) {
    final metrics = [
      _MetricItem('NEM', '%${data.humidity}', 'Çiğ noktası ${data.feelsLike - 12}°C.', LucideIcons.droplets),
      _MetricItem('RÜZGAR', data.windSpeed, '${data.windDirection} yönünden.', LucideIcons.wind),
      _MetricItem('UV İNDEKSİ', '${data.uvIndex} - ${_uvLabel(data.uvIndex)}', 'Bugün normal seviyede.', LucideIcons.sun),
      _MetricItem('BASINÇ', data.pressure, 'İstikrarlı koşullar.', LucideIcons.compass),
      _MetricItem('GÖRÜŞ', data.visibility, 'Mükemmel görünürlük.', LucideIcons.eye),
      _MetricItem('HİSSEDİLEN', '${data.feelsLike}°', 'Nem nedeniyle daha sıcak.', LucideIcons.thermometer),
    ];

    return Column(
      children: [
        for (int i = 0; i < metrics.length; i += 2)
          Padding(
            padding: EdgeInsets.only(bottom: i + 2 < metrics.length ? 12 : 0),
            child: Row(
              children: [
                Expanded(child: DetailCard(item: metrics[i])),
                const SizedBox(width: 12),
                if (i + 1 < metrics.length)
                  Expanded(child: DetailCard(item: metrics[i + 1]))
                else
                  const Expanded(child: SizedBox.shrink()),
              ],
            ),
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

class _MetricItem {
  final String label;
  final String value;
  final String subtext;
  final IconData icon;
  const _MetricItem(this.label, this.value, this.subtext, this.icon);
}

// ==========================================
// Sıcaklık Başlığı
// ==========================================
class _TemperatureHeader extends StatelessWidget {
  final WeatherData data;
  const _TemperatureHeader({required this.data});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFF3F4F6)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            _todayLabel(),
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${data.temp}',
                style: TextStyle(
                  fontSize: 80,
                  fontWeight: FontWeight.w900,
                  color: Colors.blue.shade600,
                  letterSpacing: -4,
                  height: 1,
                ),
              ),
              Text(
                '°',
                style: TextStyle(
                  fontSize: 50,
                  fontWeight: FontWeight.w300,
                  color: Colors.blue.shade300,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            data.condition,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w900,
              color: Color(0xFF111827),
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _Badge(label: 'En Y: ${data.high}°', color: Colors.orange.shade100, textColor: Colors.orange.shade800),
              const SizedBox(width: 12),
              _Badge(label: 'En D: ${data.low}°', color: Colors.blue.shade50, textColor: Colors.blue.shade700),
            ],
          ),
        ],
      ),
    ).animate().fadeIn(duration: 350.ms).moveY(begin: 15, end: 0, duration: 350.ms);
  }

  String _todayLabel() {
    final now = DateTime.now();
    const months = ['OCA', 'ŞUB', 'MAR', 'NİS', 'MAY', 'HAZ', 'TEM', 'AĞU', 'EYL', 'EKİ', 'KAS', 'ARA'];
    return 'BUGÜN, ${now.day} ${months[now.month - 1]}';
  }
}

class _Badge extends StatelessWidget {
  final String label;
  final Color color;
  final Color textColor;
  const _Badge({required this.label, required this.color, required this.textColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.bold,
          color: textColor,
        ),
      ),
    );
  }
}

// ==========================================
// Detay Kartı
// ==========================================
class DetailCard extends StatelessWidget {
  final _MetricItem item;

  const DetailCard({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFF3F4F6)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 6,
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
              Icon(item.icon, size: 16, color: Colors.blue.shade400),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  item.label,
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
            item.value,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF111827),
            ),
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 3),
          Text(
            item.subtext,
            style: const TextStyle(
              fontSize: 10,
              color: Colors.grey,
              height: 1.3,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

// ==========================================
// Harita Kartı
// ==========================================
class _MapDetailCard extends StatelessWidget {
  final WeatherData data;
  const _MapDetailCard({required this.data});

  @override
  Widget build(BuildContext context) {
    final hasCoords = data.lat != null && data.lon != null;
    final mapUrl = hasCoords
        ? 'https://static-maps.yandex.ru/1.x/?lang=tr_TR&ll=${data.lon},${data.lat}&z=10&l=map&size=450,250'
        : 'https://images.unsplash.com/photo-1526778548025-fa2f459cd5c1?q=80&w=2068&auto=format&fit=crop';

    return GestureDetector(
      onTap: hasCoords
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
      child: Container(
        height: 170,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 12,
              offset: const Offset(0, 4),
            )
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: Stack(
            children: [
              Positioned.fill(
                child: Image.network(
                  mapUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    color: Colors.blue.shade50,
                    child: const Center(
                      child: Icon(LucideIcons.map, size: 48, color: Colors.blue),
                    ),
                  ),
                ),
              ),
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      colors: [Colors.black.withOpacity(0.5), Colors.transparent],
                    ),
                  ),
                ),
              ),
              Positioned(
                bottom: 16,
                left: 20,
                right: 20,
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.25),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(LucideIcons.compass, color: Colors.white, size: 18),
                    ),
                    const SizedBox(width: 10),
                    const Expanded(
                      child: Text(
                        'Yerel Tahmin Haritası',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(LucideIcons.externalLink, color: Colors.white, size: 14),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ==========================================
// Günlük Tahmin Satırı
// ==========================================
class _DayForecastRow extends StatelessWidget {
  final DailyForecast day;
  final int idx;
  const _DayForecastRow({required this.day, required this.idx});

  IconData _getIcon(String condition) {
    final c = condition.toLowerCase();
    if (c.contains('güneş') || c.contains('açık') || c.contains('clear')) return LucideIcons.sun;
    if (c.contains('yağmur') || c.contains('rain')) return LucideIcons.cloudRain;
    if (c.contains('fırtına') || c.contains('storm')) return LucideIcons.cloudLightning;
    if (c.contains('kar') || c.contains('snow')) return LucideIcons.snowflake;
    return LucideIcons.cloud;
  }

  Color _getIconColor(String condition) {
    final c = condition.toLowerCase();
    if (c.contains('güneş') || c.contains('açık')) return Colors.orange.shade400;
    if (c.contains('yağmur') || c.contains('rain')) return Colors.blue.shade400;
    if (c.contains('kar') || c.contains('snow')) return Colors.lightBlue.shade300;
    return Colors.grey.shade400;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFF3F4F6)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              idx == 0 ? 'Yarın' : day.day,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 15,
                color: Color(0xFF111827),
              ),
            ),
          ),
          Icon(_getIcon(day.condition), color: _getIconColor(day.condition), size: 22),
          const SizedBox(width: 16),
          Text(
            '${day.high}°',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 15,
              color: Color(0xFF111827),
            ),
          ),
          const SizedBox(width: 12),
          Text(
            '${day.low}°',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    ).animate().scale(
          duration: 200.ms,
          delay: (idx * 80).ms,
          begin: const Offset(0.95, 0.95),
        );
  }
}