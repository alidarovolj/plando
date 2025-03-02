import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';

/// Сервис для сбора информации об устройстве пользователя
class DeviceInfoService {
  static final DeviceInfoPlugin _deviceInfoPlugin = DeviceInfoPlugin();

  /// Получает полную информацию об устройстве, включая:
  /// - Модель устройства
  /// - Версию ОС
  /// - Версию приложения
  /// - Язык системы
  /// - Страну (из локали)
  /// - Геолокацию (если доступна)
  static Future<Map<String, dynamic>> getDeviceInfo() async {
    final Map<String, dynamic> deviceData = <String, dynamic>{};

    try {
      // Получаем информацию о версии приложения
      final packageInfo = await PackageInfo.fromPlatform();
      deviceData['app_version'] =
          '${packageInfo.version}+${packageInfo.buildNumber}';

      // Получаем информацию о языке системы и стране
      final locale = Platform.localeName;
      deviceData['locale'] = locale;

      // Извлекаем код страны из локали
      if (locale.contains('_')) {
        final countryCode = locale.split('_').last;
        deviceData['country'] = countryCode;
      } else {
        deviceData['country'] = 'Unknown';
      }

      if (Platform.isAndroid) {
        await _getAndroidDeviceInfo(deviceData);
      } else if (Platform.isIOS) {
        await _getIosDeviceInfo(deviceData);
      }

      // Пытаемся получить информацию о местоположении
      await _getLocationInfo(deviceData);

      debugPrint('Collected device info: $deviceData');
    } catch (e) {
      debugPrint('Error collecting device info: $e');
    }

    return deviceData;
  }

  /// Получает информацию об Android-устройстве
  static Future<void> _getAndroidDeviceInfo(
      Map<String, dynamic> deviceData) async {
    final AndroidDeviceInfo androidInfo = await _deviceInfoPlugin.androidInfo;

    deviceData['os'] = 'Android';
    deviceData['os_version'] = androidInfo.version.release;
    deviceData['device_model'] =
        '${androidInfo.manufacturer} ${androidInfo.model}';
    deviceData['device_id'] = androidInfo.id;
    deviceData['android_sdk'] = androidInfo.version.sdkInt.toString();

    // Для Android можно попытаться получить информацию о мобильном операторе
    // через TelephonyManager, но это требует дополнительных разрешений
    deviceData['carrier'] = 'Unknown'; // По умолчанию
  }

  /// Получает информацию об iOS-устройстве
  static Future<void> _getIosDeviceInfo(Map<String, dynamic> deviceData) async {
    final IosDeviceInfo iosInfo = await _deviceInfoPlugin.iosInfo;

    deviceData['os'] = 'iOS';
    deviceData['os_version'] = iosInfo.systemVersion;
    deviceData['device_model'] = iosInfo.model;
    deviceData['device_name'] = iosInfo.name;
    deviceData['device_id'] = iosInfo.identifierForVendor;

    // Для iOS также устанавливаем неизвестного оператора по умолчанию
    deviceData['carrier'] = 'Unknown';
  }

  /// Получает информацию о местоположении пользователя
  static Future<void> _getLocationInfo(Map<String, dynamic> deviceData) async {
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
        // Не запрашиваем разрешение автоматически, чтобы не беспокоить пользователя
        debugPrint('Разрешения на геолокацию отклонены');
        return;
      }

      if (permission == LocationPermission.deniedForever) {
        debugPrint('Разрешения на геолокацию отклонены навсегда');
        return;
      }

      // Пытаемся получить последнюю известную позицию, чтобы не ждать долго
      Position? position = await Geolocator.getLastKnownPosition();

      // Если последняя известная позиция недоступна, пробуем получить текущую
      if (position == null) {
        // Устанавливаем таймаут в 5 секунд, чтобы не блокировать запуск приложения
        position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.low,
          timeLimit: const Duration(seconds: 5),
        ).catchError((e) {
          debugPrint('Ошибка при получении текущей позиции: $e');
          return null;
        });
      }

      if (position != null) {
        deviceData['latitude'] = position.latitude;
        deviceData['longitude'] = position.longitude;
        deviceData['location_accuracy'] = position.accuracy;

        // Можно добавить дополнительную информацию о местоположении
        // например, через обратное геокодирование получить город, страну и т.д.
        // Но это требует дополнительных API и может занять время
      }
    } catch (e) {
      debugPrint('Ошибка при получении информации о местоположении: $e');
    }
  }
}
