Veteriner Kliniği Randevu Uygulaması

Evcil hayvan sahiplerinin veteriner kliniklerinden çevrimiçi randevu almasını sağlayan mobil uygulama.
Haliç Üniversitesi Bilgisayar Programcılığı bitirme projesi olarak geliştirilmiş ve akademik tez ile belgelenmiştir.

## Hakkında

Veteriner kliniklerinde randevu süreçleri çoğunlukla telefonla ve manuel olarak yürütülüyor; bu da yoğun saatlerde hem klinik hem de hayvan sahibi için zaman kaybına yol açıyor. Bu proje, randevu alma sürecini dijitalleştirerek kullanıcının kendi telefonundan uygun saati seçip randevu oluşturabilmesini amaçlıyor.

## Özellikler

- **Kullanıcı kaydı ve girişi** — Firebase üzerinden kimlik doğrulama
- **Randevu oluşturma** — tarih ve saat seçerek yeni randevu alma
- **Randevularım** — mevcut randevuları listeleme
- **Randevu iptali** — alınan randevuyu iptal etme
- **Evcil hayvanın özellikleri** — Sahip olunan evcil hayvanın yaşını, ırkını, türünü görebilme
- **Yaklaşan Aşı** — Evcil hayvanınıza bir aşı alındığınızda bunun tarihini görebilme
- **Veteriner Hekim Slot Sistemi** — Slot sistemi sayesinde hekim kendine uygun saatleri açarak evcil hayvan sahiplerinni randevu almasını sağlar.
- **Çoklu platform** — Flutter'ın tek kod tabanı sayesinde Android, iOS ve web desteği

## Kullanılan Teknolojiler

| Katman | Teknoloji |
|---|---|
| Arayüz / Uygulama | Flutter, Dart |
| Veri ve kimlik doğrulama | Firebase |
| Geliştirme ortamı | Visual Studio Code |

## Kurulum

Projeyi kendi bilgisayarınızda çalıştırmak için:

```bash
# Depoyu klonlayın
git clone https://github.com/Fiikss/veteriner-app.git
cd veteriner-app

# Bağımlılıkları yükleyin
flutter pub get

# Uygulamayı çalıştırın
flutter run
```

> **Not:** Uygulamanın çalışabilmesi için kendi Firebase projenizi oluşturup
> `google-services.json` (Android) ve `GoogleService-Info.plist` (iOS) dosyalarını
> ilgili klasörlere eklemeniz gerekir.

## Ekran Görüntüleri

<!-- Uygulamayı çalıştırıp 3-4 ekranın görüntüsünü alın, repoya bir screenshots/ klasörü açıp yükleyin
     ve aşağıdaki satırları düzenleyin. Bu bölüm, projeye bakan kişinin ilk dikkatini çeken yerdir. -->

<p align="center">
  <img src="screenshots/giris.png" width="230">
  <img src="screenshots/randevu.png" width="230">
  <img src="screenshots/randevularim.png" width="230">
</p>

## Proje Yapısı

```
lib/          # Uygulama kodları (ekranlar, modeller, servisler)
android/      # Android platform dosyaları
ios/          # iOS platform dosyaları
web/          # Web platform dosyaları
test/         # Test dosyaları
```

## Geliştirici

**Melikegül Keser**
Bilgisayar Programcılığı — Haliç Üniversitesi
[LinkedIn](https://www.linkedin.com/in/melikeg%C3%BCl-keser-94aa87330/) · melikeglkeser@gmail.com

