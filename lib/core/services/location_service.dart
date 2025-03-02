import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Провайдер для сервиса геолокации
final locationServiceProvider = Provider<LocationService>((ref) {
  return LocationService();
});

/// Сервис для работы с геолокацией
class LocationService {
  /// Проверяет, включены ли службы геолокации
  Future<bool> isLocationServiceEnabled() async {
    return await Geolocator.isLocationServiceEnabled();
  }

  /// Проверяет разрешения на доступ к геолокации
  Future<LocationPermission> checkPermission() async {
    return await Geolocator.checkPermission();
  }

  /// Запрашивает разрешение на доступ к геолокации
  Future<LocationPermission> requestPermission() async {
    return await Geolocator.requestPermission();
  }

  /// Получает текущую позицию пользователя
  Future<Position?> getCurrentPosition({
    LocationAccuracy accuracy = LocationAccuracy.high,
    bool requestPermission = true,
  }) async {
    try {
      // Проверяем, включены ли службы геолокации
      bool serviceEnabled = await isLocationServiceEnabled();
      if (!serviceEnabled) {
        debugPrint('Службы геолокации отключены');
        return null;
      }

      // Проверяем разрешения
      LocationPermission permission = await checkPermission();
      if (permission == LocationPermission.denied) {
        if (requestPermission) {
          permission = await this.requestPermission();
          if (permission == LocationPermission.denied) {
            debugPrint('Разрешения на геолокацию отклонены');
            return null;
          }
        } else {
          debugPrint('Разрешения на геолокацию отклонены');
          return null;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        debugPrint('Разрешения на геолокацию отклонены навсегда');
        return null;
      }

      // Получаем текущую позицию
      return await Geolocator.getCurrentPosition(
        desiredAccuracy: accuracy,
      );
    } catch (e) {
      debugPrint('Ошибка при получении геолокации: $e');
      return null;
    }
  }

  /// Получает последнюю известную позицию пользователя
  Future<Position?> getLastKnownPosition() async {
    try {
      return await Geolocator.getLastKnownPosition();
    } catch (e) {
      debugPrint('Ошибка при получении последней известной геолокации: $e');
      return null;
    }
  }

  /// Вычисляет расстояние между двумя точками в метрах
  double distanceBetween(
    double startLatitude,
    double startLongitude,
    double endLatitude,
    double endLongitude,
  ) {
    return Geolocator.distanceBetween(
      startLatitude,
      startLongitude,
      endLatitude,
      endLongitude,
    );
  }

  /// Открывает настройки приложения для изменения разрешений
  Future<bool> openAppSettings() async {
    return await Geolocator.openAppSettings();
  }

  /// Открывает настройки местоположения устройства
  Future<bool> openLocationSettings() async {
    return await Geolocator.openLocationSettings();
  }
}
