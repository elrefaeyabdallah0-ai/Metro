import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';

/// A friendly error raised when the device location cannot be determined.
class LocationException implements Exception {
  const LocationException(this.message);

  final String message;

  @override
  String toString() => message;
}

class MapOpenResult {
  const MapOpenResult({
    required this.usedFallback,
    this.message,
  });

  final bool usedFallback;
  final String? message;
}

class LocationService {
  const LocationService();

  static const double _cairoLatitude = 30.0444;
  static const double _cairoLongitude = 31.2357;

  /// Opens Google Maps at the user's current position.
  ///
  /// If the position cannot be determined (permission denied, location
  /// services off, emulator without GPS...) the map opens on Cairo instead and
  /// [MapOpenResult.usedFallback] is true.
  Future<MapOpenResult> openCurrentLocationInMaps() async {
    Position? position;
    String? message;

    try {
      position = await _determinePosition();
    } on LocationException catch (error) {
      message = error.message;
    } on TimeoutException {
      message = 'Getting your location took too long.';
    } catch (_) {
      message = 'Could not determine your current location.';
    }

    final latitude = position?.latitude ?? _cairoLatitude;
    final longitude = position?.longitude ?? _cairoLongitude;
    await _launchCoordinates(
      latitude,
      longitude,
      position == null ? 'Cairo' : 'My location',
    );

    return MapOpenResult(
      usedFallback: position == null,
      message: message,
    );
  }

  /// Opens Google Maps searching for a specific metro station.
  Future<void> openStationInMaps(String station) async {
    final query = Uri.encodeComponent('$station metro station Cairo');
    final uri = Uri.parse('https://www.google.com/maps/search/?api=1&query=$query');
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      throw const LocationException('Could not open Google Maps.');
    }
  }

  Future<Position> _determinePosition() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw const LocationException('Location services are disabled.');
    }

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.denied) {
      throw const LocationException('Location permission was denied.');
    }
    if (permission == LocationPermission.deniedForever) {
      throw const LocationException(
        'Location permission is permanently denied. Enable it in your device settings.',
      );
    }

    try {
      return await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 20),
        ),
      );
    } on TimeoutException {
      final lastKnown = await Geolocator.getLastKnownPosition();
      if (lastKnown != null) return lastKnown;
      rethrow;
    }
  }

  Future<void> _launchCoordinates(
    double latitude,
    double longitude,
    String label,
  ) async {
    if (!kIsWeb) {
      final geoUri = Uri.parse(
        'geo:$latitude,$longitude?q=$latitude,$longitude(${Uri.encodeComponent(label)})',
      );
      if (await canLaunchUrl(geoUri)) {
        final opened = await launchUrl(geoUri, mode: LaunchMode.externalApplication);
        if (opened) return;
      }
    }

    final webUri = Uri.parse(
      'https://www.google.com/maps/search/?api=1&query=$latitude,$longitude',
    );
    final opened = await launchUrl(
      webUri,
      mode: kIsWeb ? LaunchMode.platformDefault : LaunchMode.externalApplication,
    );
    if (!opened) {
      throw const LocationException('Could not open Google Maps.');
    }
  }
}
