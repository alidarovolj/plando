import 'package:plando/core/constants/analytics_events.dart';
import 'package:plando/core/constants/analytics_params.dart';
import 'package:plando/core/constants/analytics_values.dart';
import 'package:plando/core/services/analytics_service.dart';

/// Класс для отслеживания событий в различных экранах приложения
class AnalyticsTracker {
  // Экран входа/регистрации
  static Future<void> trackAuthScreenView() async {
    await AnalyticsService.logEvent(AnalyticsEvents.authScreenView);
  }

  static Future<void> trackAuthMethodSelected(String method) async {
    await AnalyticsService.logEvent(
      AnalyticsEvents.authMethodSelected,
      properties: {AnalyticsParams.method: method},
    );
  }

  static Future<void> trackTermsPrivacyViewed() async {
    await AnalyticsService.logEvent(AnalyticsEvents.termsPrivacyViewed);
  }

  static Future<void> trackEmailEntered(String email, bool isExisting) async {
    await AnalyticsService.logEvent(
      AnalyticsEvents.emailEntered,
      properties: {
        AnalyticsParams.status:
            isExisting ? AnalyticsValues.existingUser : AnalyticsValues.newUser,
        'email': email,
      },
    );
  }

  // Экран ввода OTP
  static Future<void> trackRegistrationOtpSent(String email) async {
    await AnalyticsService.logEvent(
      AnalyticsEvents.registrationOtpSent,
      properties: {'email': email},
    );
  }

  static Future<void> trackRegistrationOtpResendRequested(String email) async {
    await AnalyticsService.logEvent(
      AnalyticsEvents.registrationOtpResendRequested,
      properties: {'email': email},
    );
  }

  static Future<void> trackRegistrationOtpEntered(
      String email, bool isCorrect) async {
    await AnalyticsService.logEvent(
      AnalyticsEvents.registrationOtpEntered,
      properties: {
        AnalyticsParams.status:
            isCorrect ? AnalyticsValues.correct : AnalyticsValues.incorrect,
        'email': email,
      },
    );
  }

  // Экран ввода пароля при регистрации
  static Future<void> trackSignupSuccess(String email) async {
    await AnalyticsService.logEvent(
      AnalyticsEvents.signupSuccess,
      properties: {'email': email},
    );
  }

  // Экран ввода уникального логина
  static Future<void> trackRegistrationComplete(
      String email, String username) async {
    await AnalyticsService.logEvent(
      AnalyticsEvents.registrationComplete,
      properties: {
        'email': email,
        'username': username,
      },
    );
  }

  // Экран авторизации
  static Future<void> trackLoginSuccess(String email, String method) async {
    await AnalyticsService.logEvent(
      AnalyticsEvents.loginSuccess,
      properties: {
        'email': email,
        AnalyticsParams.method: method,
      },
    );
  }

  static Future<void> trackForgotPassword(String email) async {
    await AnalyticsService.logEvent(
      AnalyticsEvents.forgotPassword,
      properties: {'email': email},
    );
  }

  // Восстановление пароля
  static Future<void> trackNewPasswordOtpSent(String email) async {
    await AnalyticsService.logEvent(
      AnalyticsEvents.newPasswordOtpSent,
      properties: {'email': email},
    );
  }

  static Future<void> trackNewPasswordOtpResendRequested(String email) async {
    await AnalyticsService.logEvent(
      AnalyticsEvents.newPasswordOtpResendRequested,
      properties: {'email': email},
    );
  }

  static Future<void> trackNewPasswordOtpEntered(
      String email, bool isCorrect) async {
    await AnalyticsService.logEvent(
      AnalyticsEvents.newPasswordOtpEntered,
      properties: {
        AnalyticsParams.status:
            isCorrect ? AnalyticsValues.correct : AnalyticsValues.incorrect,
        'email': email,
      },
    );
  }

  // Гостевой вход
  static Future<void> trackGuestSuccess() async {
    await AnalyticsService.logEvent(AnalyticsEvents.guestSuccess);
  }

  static Future<void> trackGuestCreateAccount() async {
    await AnalyticsService.logEvent(AnalyticsEvents.guestCreateAccount);
  }
}
