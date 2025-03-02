import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import '../services/location_service.dart';
import '../services/analytics_service.dart';

/// Состояние провайдера геолокации
class LocationState {
  final Position? position;
  final bool isLoading;
  final String? error;
  final bool permissionGranted;

  LocationState({
    this.position,
    this.isLoading = false,
    this.error,
    this.permissionGranted = false,
  });

  LocationState copyWith({
    Position? position,
    bool? isLoading,
    String? error,
    bool? permissionGranted,
  }) {
    return LocationState(
      position: position ?? this.position,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      permissionGranted: permissionGranted ?? this.permissionGranted,
    );
  }
}

/// Нотифаер для провайдера геолокации
class LocationNotifier extends StateNotifier<LocationState> {
  final LocationService _locationService;

  LocationNotifier(this._locationService) : super(LocationState()) {
    // При инициализации проверяем разрешения
    _checkPermission();
  }

  /// Проверяет разрешения на доступ к геолокации
  Future<void> _checkPermission() async {
    final permission = await _locationService.checkPermission();
    state = state.copyWith(
      permissionGranted: permission == LocationPermission.whileInUse ||
          permission == LocationPermission.always,
    );
  }

  /// Запрашивает разрешение на доступ к геолокации
  Future<void> requestPermission() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final permission = await _locationService.requestPermission();
      state = state.copyWith(
        permissionGranted: permission == LocationPermission.whileInUse ||
            permission == LocationPermission.always,
        isLoading: false,
      );

      // Если разрешение получено, отправляем событие в Amplitude
      if (permission == LocationPermission.whileInUse ||
          permission == LocationPermission.always) {
        AnalyticsService.logEvent('location_permission_granted', properties: {
          'permission_type': permission == LocationPermission.whileInUse
              ? 'while_in_use'
              : 'always',
        });
      } else {
        // Если разрешение не получено, также отправляем событие
        AnalyticsService.logEvent('location_permission_denied', properties: {
          'permission_type': permission.toString(),
        });
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Не удалось запросить разрешение: $e',
      );

      // Логируем ошибку в Amplitude
      AnalyticsService.logEvent('location_permission_error', properties: {
        'error': e.toString(),
      });
    }
  }

  /// Получает текущую позицию пользователя
  Future<void> getCurrentPosition({
    LocationAccuracy accuracy = LocationAccuracy.high,
  }) async {
    if (!state.permissionGranted) {
      await requestPermission();
      if (!state.permissionGranted) {
        return;
      }
    }

    state = state.copyWith(isLoading: true, error: null);

    try {
      final position = await _locationService.getCurrentPosition(
        accuracy: accuracy,
        requestPermission: false,
      );

      state = state.copyWith(
        position: position,
        isLoading: false,
        error: position == null ? 'Не удалось получить местоположение' : null,
      );

      // Если позиция получена, отправляем информацию в Amplitude
      if (position != null) {
        // Создаем свойства с информацией о местоположении
        final locationProperties = {
          'latitude': position.latitude,
          'longitude': position.longitude,
          'accuracy': position.accuracy,
          'altitude': position.altitude,
          'speed': position.speed,
          'timestamp': position.timestamp?.millisecondsSinceEpoch,
        };

        // Обновляем свойства пользователя в Amplitude
        AnalyticsService.setUserProperties(locationProperties);

        // Логируем событие получения местоположения
        AnalyticsService.logEvent('location_received',
            properties: locationProperties);
      } else {
        // Если позиция не получена, логируем событие ошибки
        AnalyticsService.logEvent('location_retrieval_failed');
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Ошибка при получении местоположения: $e',
      );

      // Логируем ошибку в Amplitude
      AnalyticsService.logEvent('location_error', properties: {
        'error': e.toString(),
      });
    }
  }

  /// Открывает настройки приложения для изменения разрешений
  Future<void> openAppSettings() async {
    await _locationService.openAppSettings();
    AnalyticsService.logEvent('location_settings_opened', properties: {
      'type': 'app_settings',
    });
  }

  /// Открывает настройки местоположения устройства
  Future<void> openLocationSettings() async {
    await _locationService.openLocationSettings();
    AnalyticsService.logEvent('location_settings_opened', properties: {
      'type': 'device_settings',
    });
  }
}

/// Провайдер для состояния геолокации
final locationProvider =
    StateNotifierProvider<LocationNotifier, LocationState>((ref) {
  final locationService = ref.watch(locationServiceProvider);
  return LocationNotifier(locationService);
});
