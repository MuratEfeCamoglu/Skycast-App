import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../models/weather_models.dart';

// ==========================================
// 1. FORECAST SCREEN WIDGET
// ==========================================

class ForecastScreen extends StatelessWidget {
  final WeatherData data;
  final bool isLoading;

  const ForecastScreen({super.key, required this.data, this.isLoading = false});

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
            const SizedBox(height: 20),

            // Bugün Özeti Hero Kartı
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: _TodayHeroCard(data: data),
            ),
            const SizedBox(height: 20),

            // 7-Günlük Tahmin Başlığı ve Listesi
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '7-Günlük Tahmin',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF111827),
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 14),
                  data.daily.isEmpty
                      ? const Center(
                          child: Padding(
                            padding: EdgeInsets.all(32),
                            child: Text('Tahmin verisi yok', style: TextStyle(color: Colors.grey)),
                          ),
                        )
                      : ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: data.daily.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 10),
                          itemBuilder: (context, idx) {
                            return ForecastItem(
                              data: data.daily[idx],
                              isActive: idx == 0,
                            )
                                .animate()
                                .fadeIn(duration: 250.ms, delay: (idx * 50).ms)
                                .moveY(begin: 10, end: 0, duration: 250.ms, delay: (idx * 50).ms);
                          },
                        ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Alt Detay Kartları
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Row(
                children: [
                  Expanded(
                    child: DetailCard(
                      label: 'Yağış İhtimali',
                      value: '%${data.rainProbability}',
                      subtext: '',
                      icon: LucideIcons.cloudRain,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: DetailCard(
                      label: 'Rüzgar Hızı',
                      value: data.windSpeed,
                      subtext: 'Yön: ${data.windDirection}',
                      icon: LucideIcons.wind,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ==========================================
// Bugün Hero Kartı
// ==========================================
class _TodayHeroCard extends StatelessWidget {
  final WeatherData data;
  const _TodayHeroCard({required this.data});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue.shade700, Colors.blue.shade400],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withOpacity(0.25),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Sıcaklık ve Durum
          Text(
            _todayLabel(),
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 13,
              fontWeight: FontWeight.w500,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${data.temp}°',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 64,
              fontWeight: FontWeight.w900,
              letterSpacing: -2,
              height: 1.1,
            ),
          ),
          Text(
            data.condition,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 16),
          // En Yüksek / En Düşük
          Container(
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              border: Border(top: BorderSide(color: Colors.white.withOpacity(0.2))),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _StatChip(icon: LucideIcons.arrowUp, label: 'En Y.', value: '${data.high}°'),
                const SizedBox(width: 32),
                _StatChip(icon: LucideIcons.arrowDown, label: 'En D.', value: '${data.low}°'),
                const SizedBox(width: 32),
                _StatChip(icon: LucideIcons.droplets, label: 'Nem', value: '%${data.humidity}'),
              ],
            ),
          ),
        ],
      ),
    ).animate().scale(
          duration: 300.ms,
          begin: const Offset(0.95, 0.95),
          curve: Curves.easeOut,
        ).fadeIn();
  }

  String _todayLabel() {
    final now = DateTime.now();
    const months = ['OCA', 'ŞUB', 'MAR', 'NİS', 'MAY', 'HAZ', 'TEM', 'AĞU', 'EYL', 'EKİ', 'KAS', 'ARA'];
    return 'BUGÜN • ${now.day} ${months[now.month - 1]}';
  }
}

class _StatChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _StatChip({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Icon(icon, size: 12, color: Colors.white60),
            const SizedBox(width: 4),
            Text(label, style: const TextStyle(color: Colors.white60, fontSize: 11)),
          ],
        ),
        const SizedBox(height: 2),
        Text(value, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
      ],
    );
  }
}

// ==========================================
// 2. SUB-COMPONENT: FORECAST ITEM WIDGET
// ==========================================

class ForecastItem extends StatelessWidget {
  final DailyForecast data;
  final bool isActive;

  const ForecastItem({
    super.key,
    required this.data,
    this.isActive = false,
  });

  IconData _getIcon(String condition) {
    final c = condition.toLowerCase();
    if (c.contains('güneş') || c.contains('açık') || c.contains('clear') || c.contains('sunny')) return LucideIcons.sun;
    if (c.contains('yağmur') || c.contains('rain')) return LucideIcons.cloudRain;
    if (c.contains('fırtına') || c.contains('storm')) return LucideIcons.cloudLightning;
    if (c.contains('kar') || c.contains('snow')) return LucideIcons.snowflake;
    return LucideIcons.cloud;
  }

  Color _getIconColor(String condition) {
    final c = condition.toLowerCase();
    if (c.contains('güneş') || c.contains('açık') || c.contains('sunny')) return Colors.orange.shade400;
    if (c.contains('yağmur') || c.contains('rain')) return Colors.blue.shade400;
    if (c.contains('fırtına') || c.contains('storm')) return Colors.purple.shade400;
    if (c.contains('kar') || c.contains('snow')) return Colors.lightBlue.shade300;
    return Colors.grey.shade400;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: BoxDecoration(
        color: isActive ? const Color(0xFFEFF6FF) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isActive ? const Color(0xFFDBEAFE) : const Color(0xFFF3F4F6),
        ),
        boxShadow: isActive
            ? null
            : [
                BoxShadow(
                  color: Colors.black.withOpacity(0.02),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                )
              ],
      ),
      child: Row(
        children: [
          // Gün ve Tarih
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  data.day,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: isActive ? const Color(0xFF2563EB) : const Color(0xFF111827),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  data.date,
                  style: const TextStyle(fontSize: 11, color: Colors.grey, fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),
          // İkon
          Icon(
            _getIcon(data.condition),
            color: _getIconColor(data.condition),
            size: 22,
          ),
          const SizedBox(width: 8),
          // Durum metni
          Expanded(
            flex: 3,
            child: Text(
              data.condition,
              style: const TextStyle(fontSize: 12, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
          ),
          // Sıcaklıklar
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                '${data.high}°',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF111827),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '${data.low}°',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ==========================================
// 3. SUB-COMPONENT: REUSABLE DETAIL CARD
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
        borderRadius: BorderRadius.circular(20),
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
          const SizedBox(height: 8),
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
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ],
      ),
    );
  }
}