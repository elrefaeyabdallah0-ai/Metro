# Cairo Metro App

A Flutter application for planning trips on the Cairo Metro. It was built from
the metro data and UI ideas covered in the course video, including the features
shown from **72:00 to the end**.

## Features

- Searchable **From / To** station fields with area-name support.
- Shortest-route calculation with transfers and directions.
- Stops, estimated time and ticket-price summary.
- Coloured route timeline and a detailed **More info** page.
- **Nearest station** finder for districts, landmarks and Arabic area names.
- **My location on map** using `geolocator` and Google Maps via `url_launcher`.
- Responsive Material 3 UI for mobile, web and desktop.

See **[FEATURES.md](FEATURES.md)** for a full explanation of every feature,
the routing algorithm, platform permissions and examples.

### Documentation

| File | Language | Contents |
| --- | --- | --- |
| [FEATURES.md](FEATURES.md) | English | Full feature guide and implementation details. |
| [FEATURES_AR.md](FEATURES_AR.md) | العربية | الترجمة العربية الكاملة لدليل المميزات. |
| [QUESTIONS_AR.md](QUESTIONS_AR.md) | العربية | بنك أسئلة وأجوبة متوقعة للمناقشة. |

## Run

```bash
flutter pub get
flutter run -d chrome
```

For Windows desktop builds, enable Windows **Developer Mode** first so Flutter
can create plugin symlinks.

## Test

```bash
flutter analyze
flutter test
```

## Project layout

```text
lib/
├── main.dart
├── data/metro_data.dart
├── services/metro_service.dart
├── services/location_service.dart
├── screens/home_page.dart
├── screens/route_details_page.dart
├── screens/nearest_station_page.dart
└── widgets/
```
