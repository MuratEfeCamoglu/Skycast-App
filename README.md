# ☁️ Skycast Weather

Gerçek zamanlı hava durumu verilerini şık ve modern bir arayüzle sunan Flutter tabanlı mobil uygulama.

![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?style=for-the-badge&logo=flutter&logoColor=white)
![Dart](https://img.shields.io/badge/Dart-3.x-0175C2?style=for-the-badge&logo=dart&logoColor=white)
![OpenWeatherMap](https://img.shields.io/badge/OpenWeatherMap-API-EB6E4B?style=for-the-badge&logo=openweathermap&logoColor=white)
![Status](https://img.shields.io/badge/Durum-Geliştiriliyor-yellow?style=for-the-badge)

---

## 📱 Uygulama Hakkında

**Skycast Weather**, OpenWeatherMap API'sini kullanarak dünya genelindeki şehirler için anlık ve tahminli hava durumu verileri sunan bir Flutter uygulamasıdır. Kullanıcı dostu arayüzü, animasyonlu bileşenleri ve konum bazlı harita entegrasyonu ile premium bir deneyim hedefler.

---

## ✨ Özellikler

- 🌡️ **Anlık Hava Durumu** — Sıcaklık, hissedilen sıcaklık, nem, rüzgar hızı ve yönü
- 📅 **7 Günlük Tahmin** — Günlük en yüksek/en düşük sıcaklık ve hava durumu
- ⏱️ **Saatlik Tahmin** — 24 saatlik grafik ve kartlı gösterim
- 📊 **Sıcaklık Grafiği** — `fl_chart` ile çizgi grafik görselleştirme
- 📍 **Konum Yönetimi** — Birden fazla şehir ekleme, kaydetme ve kaldırma
- 🗺️ **Harita Entegrasyonu** — OpenStreetMap üzerinde konum görüntüleme
- 🎨 **Dinamik Arka Plan** — Hava durumuna göre değişen arkaplan görüntüleri
- 🌀 **Animasyonlu İkonlar** — `flutter_animate` ile hava durumu simgeleri
- ⚡ **Yedek Veri** — API erişimi yoksa örnek veri ile kesintisiz çalışma

---

## 🗂️ Ekranlar

| Ekran | Açıklama |
|-------|----------|
| **Bugün** | Ana ekran — anlık hava durumu, saatlik tahmin, sıcaklık grafiği ve detay kartları |
| **Tahmin** | 7 günlük tahmin listesi ve günlük özet kartı |
| **Konumlar** | Kaydedilen şehirler, şehir arama ve ekleme paneli |
| **Detaylar** | Nem, basınç, UV indeksi, görüş, rüzgar gibi meteorolojik detaylar |

---

## 🛠️ Kullanılan Teknolojiler

### Çerçeve & Dil
- [Flutter](https://flutter.dev/) `^3.x` — Cross-platform mobil uygulama çerçevesi
- [Dart](https://dart.dev/) `^3.x` — Programlama dili

### Paketler

| Paket | Versiyon | Kullanım Amacı |
|-------|----------|----------------|
| [`http`](https://pub.dev/packages/http) | `^1.2.0` | OpenWeatherMap REST API çağrıları |
| [`fl_chart`](https://pub.dev/packages/fl_chart) | `^1.2.0` | Sıcaklık çizgi grafiği |
| [`flutter_animate`](https://pub.dev/packages/flutter_animate) | `^4.5.2` | UI animasyonları ve geçiş efektleri |
| [`lucide_icons_flutter`](https://pub.dev/packages/lucide_icons_flutter) | `^3.1.20` | Modern vektör ikon seti |
| [`url_launcher`](https://pub.dev/packages/url_launcher) | `^6.3.2` | Harita linklerini tarayıcıda açma |

### Harici API
- [OpenWeatherMap API](https://openweathermap.org/api)
  - `GET /weather` — Anlık hava durumu
  - `GET /forecast` — 5 günlük / 3 saatlik tahmin

---

## 📁 Proje Yapısı

```
lib/
├── main.dart                  # Uygulama giriş noktası, alt navigasyon, state yönetimi
├── models/
│   └── weather_models.dart    # Veri modelleri (WeatherData, HourlyForecast, DailyForecast, SavedLocation)
├── services/
│   └── weather_service.dart   # OpenWeatherMap API entegrasyonu
└── screens/
    ├── weatherscreen.dart     # Ana ekran (Bugün)
    ├── forecast.dart          # 7 günlük tahmin ekranı
    ├── locatins.dart          # Konum yönetim ekranı
    └── details.dart           # Meteorolojik detay ekranı
```

---

## 🚀 Kurulum

### Gereksinimler
- Flutter SDK `3.x` veya üzeri
- Dart `3.x` veya üzeri
- Android Studio / VS Code
- OpenWeatherMap ücretsiz API key'i

### Adımlar

```bash
# 1. Repoyu klonla
git clone https://github.com/kullanici-adin/skycast-weather.git
cd skycast-weather

# 2. Bağımlılıkları yükle
flutter pub get

# 3. API key'ini ayarla (dart_defines.json git'e eklenmez)
cp dart_defines.example.json dart_defines.json
# dart_defines.json içindeki OWM_API_KEY değerini kendi key'inle değiştir

# 4. Uygulamayı çalıştır
flutter run --dart-define-from-file=dart_defines.json

# APK almak için
flutter build apk --release --dart-define-from-file=dart_defines.json
```

> API key verilmeden çalıştırılırsa uygulama örnek veriyle açılır.

### 🔑 API Key Alma

1. [openweathermap.org](https://openweathermap.org/) adresine git
2. Ücretsiz hesap oluştur
3. **API Keys** sekmesinden key'ini kopyala
4. `dart_defines.json` dosyasındaki `OWM_API_KEY` değerine yapıştır

> ⚠️ Yeni oluşturulan API key'lerin aktif olması **1-2 saat** sürebilir.

---

## 📸 Ekran Görüntüleri

> Ana ekran, tahmin ekranı ve konum yönetimi ekranları

| Bugün | Tahmin | Konumlar | Detaylar |
|-------|--------|----------|----------|
| Anlık sıcaklık ve hava durumu | 7 günlük liste | Şehir ekleme ve yönetim | Meteorolojik detaylar |

---

## 🔧 Yapılandırma

### Android İzinleri (`android/app/src/main/AndroidManifest.xml`)
```xml
<uses-permission android:name="android.permission.INTERNET"/>
```

URL Launcher için Android 11+ desteği:
```xml
<queries>
    <intent>
        <action android:name="android.intent.action.VIEW" />
        <data android:scheme="https" />
    </intent>
</queries>
```

---

## 📋 Bilinen Sınırlılıklar

- **UV İndeksi**: Şu an sabit değer gösterilmekte; OpenWeatherMap'in ayrı `/uvi` endpoint'i ile gerçek veriye bağlanabilir
- **Yandex Statik Harita**: Bölgeye göre yüklenemeyebilir, hata durumunda fallback görseli devreye girer
- **Offline Mod**: İnternet bağlantısı yokken örnek (mock) veri gösterilir

---

## 🤝 Katkı

Pull request'ler memnuniyetle karşılanır. Büyük değişiklikler için önce bir issue açarak ne değiştirmek istediğinizi tartışın.

---

## 📄 Lisans

Bu proje [MIT Lisansı](LICENSE) altında lisanslanmıştır.

---

<div align="center">
  <p>⭐ Bu projeyi beğendiysen yıldız vermeyi unutma!</p>
  <p>Made with ❤️ and Flutter</p>
</div>
