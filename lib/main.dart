import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:plando/core/api/firebase_setup.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:plando/app.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:plando/core/services/analytics_service.dart';
import 'package:plando/core/providers/auth/auth_state.dart';
import 'package:amplitude_flutter/amplitude.dart';
import 'package:plando/core/services/device_info_service.dart';

void main() async {
  // Ensure Flutter bindings are initialized
  WidgetsFlutterBinding.ensureInitialized();

  try {
    // Load environment variables
    await dotenv.load();

    // Initialize Firebase first
    await initializeFirebase();

    // Initialize other services
    await Future.wait([
      // Initialize Amplitude with API key
      _initializeAmplitude(),
      // Initialize date formatting
      initializeDateFormatting('ru', null),
    ]);

    // Check if user has seen onboarding
    final hasSeenOnboarding = await StorageService.hasSeenOnboarding();

    // Run the app
    runApp(
      ProviderScope(
        child: Consumer(
          builder: (context, ref, child) {
            // Initialize auth state
            ref.read(authProvider.notifier).initializeAuth();

            // If user hasn't seen onboarding, redirect to it
            if (!hasSeenOnboarding) {
              Future.microtask(() => StorageService.setHasSeenOnboarding());
              return const MyApp(initialRoute: '/onboarding');
            }

            return const MyApp(initialRoute: '/');
          },
        ),
      ),
    );
  } catch (e, stackTrace) {
    print('Error during initialization: $e');
    print('Stack trace: $stackTrace');
    rethrow;
  }
}

Future<void> _initializeAmplitude() async {
  try {
    // Используем предоставленный ключ API Amplitude
    const amplitudeApiKey = '5fcdaba4df8a3325295b865cbf1441a2';
    await AnalyticsService.init(amplitudeApiKey);

    // Включаем автоматический сбор данных о сессии
    final Amplitude amplitude = Amplitude.getInstance();
    await amplitude.trackingSessionEvents(true);

    // Включаем отслеживание дополнительных автоматических параметров
    await amplitude.enableCoppaControl();
    // Используем динамическую конфигурацию
    await amplitude.setUseDynamicConfig(true);

    // Получаем информацию об устройстве с помощью нашего сервиса
    final deviceInfo = await DeviceInfoService.getDeviceInfo();

    // Устанавливаем свойства пользователя
    await AnalyticsService.setUserProperties(deviceInfo);

    // Логируем событие запуска приложения с информацией об устройстве и местоположении
    await AnalyticsService.logEvent('app_started', properties: deviceInfo);

    // Логируем дополнительную информацию о местоположении, если она доступна
    if (deviceInfo.containsKey('latitude') &&
        deviceInfo.containsKey('longitude')) {
      debugPrint(
          'Location data collected: Lat: ${deviceInfo['latitude']}, Lng: ${deviceInfo['longitude']}');

      // Можно также отправить отдельное событие о местоположении
      await AnalyticsService.logEvent('location_detected', properties: {
        'latitude': deviceInfo['latitude'],
        'longitude': deviceInfo['longitude'],
        'accuracy': deviceInfo['location_accuracy'],
      });
    }

    debugPrint('Amplitude initialized with API key: $amplitudeApiKey');
    debugPrint('Device info collected: $deviceInfo');
  } catch (e) {
    debugPrint('Error initializing Amplitude: $e');
  }
}

class StorageService {
  static const _storage = FlutterSecureStorage();

  static Future<void> saveToken(String token) async {
    await _storage.write(key: 'token', value: token);
  }

  static Future<String?> getToken() async {
    return await _storage.read(key: 'token');
  }

  static const String _hasSeenOnboardingKey = 'hasSeenOnboarding';

  static Future<bool> hasSeenOnboarding() async {
    return _storage
        .read(key: _hasSeenOnboardingKey)
        .then((value) => value != null);
  }

  static Future<void> setHasSeenOnboarding() async {
    await _storage.write(key: _hasSeenOnboardingKey, value: 'true');
  }
}
