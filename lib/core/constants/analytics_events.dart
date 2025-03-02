// Константы для имен событий Amplitude
class AnalyticsEvents {
  // Регистрация/Авторизация
  static const String authScreenView = 'auth_screen_view';
  static const String authMethodSelected = 'auth_method_selected';
  static const String termsPrivacyViewed = 'terms_privacy_viewed';
  static const String emailEntered = 'email_entered';
  static const String registrationOtpSent = 'registration_otp_sent';
  static const String registrationOtpResendRequested =
      'registration_otp_resend_requested';
  static const String registrationOtpEntered = 'registration_otp_entered';
  static const String signupSuccess = 'signup_success';
  static const String registrationComplete = 'registration_complete';

  // Авторизация
  static const String loginSuccess = 'login_success';
  static const String forgotPassword = 'forgot_password';

  // Восстановление пароля
  static const String newPasswordOtpSent = 'new_password_otp_sent';
  static const String newPasswordOtpResendRequested =
      'new_password_otp_resend_requested';
  static const String newPasswordOtpEntered = 'new_password_otp_entered';

  // Гостевой вход
  static const String guestSuccess = 'guest_success';
  static const String guestCreateAccount = 'guest_create_account';
}
