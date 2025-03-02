import 'package:amplitude_flutter/amplitude.dart';
import 'package:flutter/foundation.dart';
import 'package:plando/core/constants/analytics_params.dart';
import 'package:plando/core/services/device_info_service.dart';
import 'package:geolocator/geolocator.dart';

class AnalyticsService {
  static final Amplitude _amplitude = Amplitude.getInstance();
  static bool _isInitialized = false;

  static Future<void> init(String apiKey) async {
    if (_isInitialized) return;

    try {
      await _amplitude.init(apiKey);
      await _amplitude.enableCoppaControl();
      await _amplitude.setUserId(null);
      await _amplitude.trackingSessionEvents(true);
      _isInitialized = true;
      debugPrint('Amplitude initialized successfully');
    } catch (e) {
      debugPrint('Error initializing Amplitude: $e');
    }
  }

  static Future<void> setUserId(String userId) async {
    try {
      await _amplitude.setUserId(userId);
      debugPrint('Amplitude user ID set: $userId');
    } catch (e) {
      debugPrint('Error setting Amplitude user ID: $e');
    }
  }

  static Future<void> logEvent(String eventName,
      {Map<String, dynamic>? properties}) async {
    try {
      await _amplitude.logEvent(
        eventName,
        eventProperties: properties,
      );
      debugPrint(
          'Amplitude event logged: $eventName with properties: $properties');
    } catch (e) {
      debugPrint('Error logging Amplitude event: $e');
    }
  }

  static Future<void> setUserProperties(Map<String, dynamic> properties) async {
    try {
      await _amplitude.setUserProperties(properties);
      debugPrint('Amplitude user properties set: $properties');
    } catch (e) {
      debugPrint('Error setting Amplitude user properties: $e');
    }
  }

  /// Обновляет информацию о местоположении пользователя в Amplitude
  static Future<void> updateLocationInfo() async {
    try {
      // Проверяем, включены ли службы геолокации
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        debugPrint('Службы геолокации отключены');
        return;
      }

      // Проверяем разрешения
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          debugPrint('Разрешения на геолокацию отклонены');
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        debugPrint('Разрешения на геолокацию отклонены навсегда');
        return;
      }

      // Получаем текущую позицию
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      // Создаем свойства с информацией о местоположении
      final locationProperties = {
        'latitude': position.latitude,
        'longitude': position.longitude,
        'accuracy': position.accuracy,
        'altitude': position.altitude,
        'speed': position.speed,
        'timestamp': position.timestamp?.millisecondsSinceEpoch,
      };

      // Обновляем свойства пользователя
      await setUserProperties(locationProperties);

      // Логируем событие обновления местоположения
      await logEvent('location_updated', properties: locationProperties);

      debugPrint('Location info updated: $locationProperties');
    } catch (e) {
      debugPrint('Error updating location info: $e');
    }
  }

  // Метод для обработки UTM-меток из ссылки
  static Future<void> trackAppSource(Uri uri) async {
    final Map<String, dynamic> sourceProperties = {};

    try {
      // Получаем информацию об устройстве
      final deviceInfo = await DeviceInfoService.getDeviceInfo();

      // Добавляем информацию об устройстве в свойства
      if (deviceInfo.containsKey('country') && deviceInfo['country'] != null) {
        sourceProperties['country'] = deviceInfo['country'];
      }

      if (deviceInfo.containsKey('carrier') && deviceInfo['carrier'] != null) {
        sourceProperties['carrier'] = deviceInfo['carrier'];
      }

      // Добавляем информацию о местоположении, если она доступна
      if (deviceInfo.containsKey('latitude') &&
          deviceInfo.containsKey('longitude')) {
        sourceProperties['latitude'] = deviceInfo['latitude'];
        sourceProperties['longitude'] = deviceInfo['longitude'];
        sourceProperties['location_accuracy'] = deviceInfo['location_accuracy'];
      }

      // Извлекаем UTM-метки из параметров URL
      if (uri.queryParameters.isNotEmpty) {
        if (uri.queryParameters.containsKey('utm_source')) {
          sourceProperties[AnalyticsParams.utmSource] =
              uri.queryParameters['utm_source'];
        }

        if (uri.queryParameters.containsKey('utm_medium')) {
          sourceProperties[AnalyticsParams.utmMedium] =
              uri.queryParameters['utm_medium'];
        }

        if (uri.queryParameters.containsKey('utm_campaign')) {
          sourceProperties[AnalyticsParams.utmCampaign] =
              uri.queryParameters['utm_campaign'];
        }
      }

      // Если есть хотя бы одно свойство, логируем событие
      if (sourceProperties.isNotEmpty) {
        await logEvent('app_source', properties: sourceProperties);

        // Также сохраняем свойства как свойства пользователя для дальнейшего анализа
        await setUserProperties(sourceProperties);

        debugPrint('Tracked app source: $sourceProperties');
      }
    } catch (e) {
      debugPrint('Error tracking app source: $e');
    }
  }
}
