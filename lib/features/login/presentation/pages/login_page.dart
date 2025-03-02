import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:plando/core/widgets/custom_button.dart';
import 'package:plando/core/widgets/custom_text_field.dart';
import 'package:plando/core/styles/constants.dart';
import 'package:plando/core/utils/validators.dart';
import 'package:plando/core/widgets/custom_snack_bar.dart';
import 'package:plando/features/login/presentation/providers/apple_auth_provider.dart';
import 'package:plando/features/login/presentation/providers/google_auth_provider.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:plando/core/providers/requests/auth/user.dart';
import 'dart:io' show Platform;
import 'package:plando/core/services/analytics_service.dart';
import 'package:plando/core/constants/analytics_events.dart';
import 'package:plando/core/constants/analytics_params.dart';
import 'package:plando/core/constants/analytics_values.dart';
import 'package:plando/core/services/analytics_tracker.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final _storage = const FlutterSecureStorage();
  String? _emailError;
  bool _wasValidated = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Отслеживаем показ экрана входа/регистрации
    AnalyticsTracker.trackAuthScreenView();
  }

  void _validateEmail(String value) {
    if (_wasValidated) {
      setState(() {
        _emailError = Validators.validateEmail(value);
      });
    }
  }

  Future<void> _handleContinue() async {
    setState(() {
      _wasValidated = true;
      _emailError = Validators.validateEmail(_emailController.text);
      _isLoading = true;
    });

    if (_emailError == null) {
      // Отслеживаем выбор метода авторизации через email
      AnalyticsTracker.trackAuthMethodSelected(AnalyticsValues.email);

      try {
        // Get the email verification service
        final userService = ref.read(requestCodeProvider);
        final email = _emailController.text;

        try {
          // Check if the email exists
          final emailExists = await userService.checkEmailExists(email);

          if (mounted) {
            setState(() {
              _isLoading = false;
            });

            // Отслеживаем ввод email
            AnalyticsTracker.trackEmailEntered(email, emailExists);

            // Navigate based on whether the email exists
            if (emailExists) {
              context.push('/known-login', extra: email);
            } else {
              // If email doesn't exist but no 404 was thrown, send OTP and navigate to code page
              final result = await userService.sendRegistrationOtp(email);

              // Отслеживаем отправку OTP
              AnalyticsTracker.trackRegistrationOtpSent(email);

              if (result['success'] == true) {
                context.push('/code', extra: email);
              } else {
                // Check if the error indicates that the user already exists
                if (result['userExists'] == true) {
                  // If user already exists, redirect to known login page
                  context.push('/known-login', extra: email);
                } else {
                  // For other errors, show the error message
                  CustomSnackBar.show(
                    context,
                    message:
                        result['message'] ?? 'Failed to send verification code',
                    type: SnackBarType.error,
                  );
                }
              }
            }
          }
        } on EmailNotFoundException catch (_) {
          // Handle the case where email doesn't exist (404 error)
          if (mounted) {
            // Send registration OTP
            final result = await userService.sendRegistrationOtp(email);

            setState(() {
              _isLoading = false;
            });

            // Отслеживаем ввод email нового пользователя
            AnalyticsTracker.trackEmailEntered(email, false);

            // Отслеживаем отправку OTP
            AnalyticsTracker.trackRegistrationOtpSent(email);

            if (result['success'] == true) {
              context.push('/code', extra: email);
            } else {
              // Check if the error indicates that the user already exists
              if (result['userExists'] == true) {
                // If user already exists, redirect to known login page
                context.push('/known-login', extra: email);
              } else {
                // For other errors, show the error message
                CustomSnackBar.show(
                  context,
                  message:
                      result['message'] ?? 'Failed to send verification code',
                  type: SnackBarType.error,
                );
              }
            }
          }
        }
      } catch (e) {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });

          CustomSnackBar.show(
            context,
            message: 'Failed to verify email: ${e.toString()}',
            type: SnackBarType.error,
          );
        }
      }
    } else {
      setState(() {
        _isLoading = false;
      });

      CustomSnackBar.show(
        context,
        message: _emailError!,
        type: SnackBarType.error,
      );
    }
  }

  Future<void> _handleSuccessfulAuth(
      String email, String provider, String? photoUrl,
      {String? accessToken}) async {
    try {
      // For Google authentication, we need to check if the email exists
      if (provider == 'Google' && accessToken != null) {
        // Get the user service
        final userService = ref.read(requestCodeProvider);

        try {
          // Check if the email exists
          final emailExists = await userService.checkEmailExists(email);

          if (mounted) {
            if (emailExists) {
              // If email exists, sign in with Google
              final result = await userService.signInWithGoogle(accessToken);

              if (result['success'] == true) {
                // Save authentication data
                await _storage.write(key: 'user_email', value: email);
                await _storage.write(key: 'auth_provider', value: provider);
                await _storage.write(key: 'is_authenticated', value: 'true');
                if (photoUrl != null) {
                  await _storage.write(key: 'user_photo', value: photoUrl);
                }

                // Отслеживаем успешный вход
                AnalyticsTracker.trackLoginSuccess(
                    email, provider.toLowerCase());

                CustomSnackBar.show(
                  context,
                  message: 'Successfully signed in with $provider',
                  type: SnackBarType.success,
                );
                context.go('/home');
              } else {
                CustomSnackBar.show(
                  context,
                  message: result['message'] ?? 'Failed to sign in with Google',
                  type: SnackBarType.error,
                );
              }
            } else {
              // If email doesn't exist, redirect to username page for registration
              context.push('/google-username', extra: {
                'email': email,
                'token': accessToken,
                'photoUrl': photoUrl,
                'displayName': null, // We don't have display name here
              });
            }
          }
        } on EmailNotFoundException catch (_) {
          // If email doesn't exist, redirect to username page for registration
          if (mounted) {
            context.push('/google-username', extra: {
              'email': email,
              'token': accessToken,
              'photoUrl': photoUrl,
              'displayName': null, // We don't have display name here
            });
          }
        } catch (e) {
          if (mounted) {
            CustomSnackBar.show(
              context,
              message: 'Failed to verify email: ${e.toString()}',
              type: SnackBarType.error,
            );
          }
        }
      } else {
        // For other providers (Apple), proceed with the original flow
        await _storage.write(key: 'user_email', value: email);
        await _storage.write(key: 'auth_provider', value: provider);
        await _storage.write(key: 'is_authenticated', value: 'true');
        if (photoUrl != null) {
          await _storage.write(key: 'user_photo', value: photoUrl);
        }

        // Отслеживаем успешный вход
        AnalyticsTracker.trackLoginSuccess(email, provider.toLowerCase());

        if (mounted) {
          CustomSnackBar.show(
            context,
            message: 'Successfully signed in with $provider',
            type: SnackBarType.success,
          );
          context.go('/home');
        }
      }
    } catch (e) {
      if (mounted) {
        CustomSnackBar.show(
          context,
          message: 'Failed to save authentication data: ${e.toString()}',
          type: SnackBarType.error,
        );
      }
    }
  }

  void _handleAuthError(String provider, dynamic error) {
    String errorMessage = 'Authentication failed';

    if (error.toString().contains('canceled')) {
      errorMessage = '$provider sign in was canceled';
    } else if (error.toString().contains('network')) {
      errorMessage = 'Network error occurred. Please check your connection';
    } else if (error.toString().contains('PlatformException')) {
      errorMessage = 'Configuration error. Please try again later';
    } else if (error.toString().contains('Email is required')) {
      errorMessage =
          'Email is required for authentication. Please ensure you share your email when signing in with Apple.';
    }

    CustomSnackBar.show(
      context,
      message: errorMessage,
      type: SnackBarType.error,
    );
  }

  Widget _buildSocialButton(String iconPath, VoidCallback onPressed) {
    return SizedBox(
      width: 70,
      height: 70,
      child: GestureDetector(
        onTap: onPressed,
        child: Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: Colors.black),
          ),
          child: Center(
            child: SizedBox(
              width: 34,
              height: 34,
              child: Image.asset(
                iconPath,
                fit: BoxFit.contain,
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(appleAuthProvider, (previous, next) {
      next.whenOrNull(
        data: (userData) {
          if (userData != null) {
            final email = userData['email'];
            final identityToken = userData['identityToken'];

            // Отслеживаем выбор метода авторизации через Apple
            AnalyticsTracker.trackAuthMethodSelected(AnalyticsValues.apple);

            // Проверяем наличие email
            if (email == null || email.isEmpty) {
              CustomSnackBar.show(
                context,
                message:
                    'Email is required for authentication. Please ensure you share your email when signing in with Apple.',
                type: SnackBarType.error,
              );
              return;
            }

            if (identityToken != null) {
              _handleAppleAuth(email, identityToken);
            } else {
              CustomSnackBar.show(
                context,
                message: 'Missing required authentication token from Apple',
                type: SnackBarType.error,
              );
            }
          }
        },
        error: (error, stackTrace) {
          _handleAuthError('Apple', error);
        },
      );
    });

    ref.listen(googleAuthProvider, (previous, next) {
      next.whenOrNull(
        data: (userData) {
          if (userData != null) {
            // Отслеживаем выбор метода авторизации через Google
            AnalyticsTracker.trackAuthMethodSelected(AnalyticsValues.google);

            _handleSuccessfulAuth(
              userData['email'] as String,
              'Google',
              userData['photoUrl'] as String?,
              accessToken: userData['accessToken'] as String?,
            );
          }
        },
        error: (error, stackTrace) {
          _handleAuthError('Google', error);
        },
      );
    });

    return Scaffold(
      backgroundColor: Colors.white,
      // appBar: const AuthAppBar(),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(
              left: AppLength.body, right: AppLength.body, top: 60),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: AppLength.xl),
              const CircleAvatar(
                radius: 30,
                backgroundColor: Colors.black,
              ),
              const SizedBox(height: AppLength.xl),
              const Text(
                'Sign in or create an account',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: AppLength.xs),
              const Text(
                'We\'ll send a verification code in email,\nWe\'ll use this email to sign you in or create an\naccount if you don\'t have one yet',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: AppColors.darkGrey,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: AppLength.xl),
              CustomTextField(
                controller: _emailController,
                hintText: 'Email',
                labelText: 'Email',
                errorText: _emailError,
                validationType: TextFieldValidationType.email,
                onChanged: _validateEmail,
              ),
              const SizedBox(height: AppLength.xl),
              CustomButton(
                label: _isLoading ? 'Checking...' : 'Continue',
                onPressed: _isLoading
                    ? () {} // Empty callback when loading
                    : () {
                        _handleContinue();
                      }, // Wrap in a VoidCallback
                type: ButtonType.normal,
                isFullWidth: true,
                isEnabled: !_isLoading,
                isLoading: _isLoading, // Add loading indicator
                color: ButtonColor.black,
              ),
              const SizedBox(height: AppLength.xl),
              // Используем разные подходы для разных платформ
              Platform.isIOS
                  ? Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildSocialButton(
                          'lib/core/assets/images/logos/apple.png',
                          () async {
                            final authNotifier =
                                ref.read(appleAuthProvider.notifier);
                            await authNotifier.signInWithApple();
                          },
                        ),
                        const SizedBox(width: AppLength.body),
                        _buildSocialButton(
                          'lib/core/assets/images/logos/google.png',
                          () async {
                            final authNotifier =
                                ref.read(googleAuthProvider.notifier);
                            await authNotifier.signInWithGoogle();
                          },
                        ),
                      ],
                    )
                  : Center(
                      // Для Android центрируем одну кнопку Google
                      child: _buildSocialButton(
                        'lib/core/assets/images/logos/google.png',
                        () async {
                          final authNotifier =
                              ref.read(googleAuthProvider.notifier);
                          await authNotifier.signInWithGoogle();
                        },
                      ),
                    ),
              const SizedBox(height: AppLength.xxxl),
              TextButton(
                onPressed: () {
                  // Отслеживаем выбор метода авторизации через гостевой вход
                  AnalyticsTracker.trackAuthMethodSelected(
                      AnalyticsValues.guest);

                  // Отслеживаем успешный гостевой вход
                  AnalyticsTracker.trackGuestSuccess();

                  context.push('/guest');
                },
                child: const Text(
                  'Continue as a guest',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
              const Spacer(),
              RichText(
                textAlign: TextAlign.start,
                text: TextSpan(
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.darkGrey,
                    fontWeight: FontWeight.w600,
                  ),
                  children: [
                    const TextSpan(
                        text:
                            'By proceeding, I confirm that I have read and agree to '),
                    TextSpan(
                      text: 'Terms & Privacy Policy',
                      recognizer: TapGestureRecognizer()
                        ..onTap = () {
                          // Отслеживаем просмотр Terms & Privacy Policy
                          AnalyticsTracker.trackTermsPrivacyViewed();

                          // Handle terms tap
                        },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppLength.body),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _handleAppleAuth(String email, String identityToken) async {
    // Проверяем наличие email
    if (email == null || email.isEmpty || email == 'No email provided') {
      CustomSnackBar.show(
        context,
        message:
            'Email is required for authentication. Please ensure you share your email when signing in with Apple.',
        type: SnackBarType.error,
      );
      return;
    }

    try {
      // Get the user service
      final userService = ref.read(requestCodeProvider);

      try {
        // Check if the email exists
        final emailExists = await userService.checkEmailExists(email);

        if (mounted) {
          if (emailExists) {
            // If email exists, sign in with Apple
            final result = await userService.signInWithApple(identityToken, "");

            if (result['success'] == true) {
              // Save authentication data
              await _storage.write(key: 'user_email', value: email);
              await _storage.write(key: 'auth_provider', value: 'Apple');
              await _storage.write(key: 'is_authenticated', value: 'true');

              // Отслеживаем успешный вход
              AnalyticsTracker.trackLoginSuccess(email, AnalyticsValues.apple);

              CustomSnackBar.show(
                context,
                message: 'Successfully signed in with Apple',
                type: SnackBarType.success,
              );
              context.go('/home');
            } else {
              CustomSnackBar.show(
                context,
                message: result['message'] ?? 'Failed to sign in with Apple',
                type: SnackBarType.error,
              );
            }
          } else {
            // If email doesn't exist, redirect to username page for registration
            context.push('/apple-username', extra: {
              'email': email,
              'identityToken': identityToken,
              'authorizationCode': "",
            });
          }
        }
      } on EmailNotFoundException catch (_) {
        // If email doesn't exist, redirect to username page for registration
        if (mounted) {
          context.push('/apple-username', extra: {
            'email': email,
            'identityToken': identityToken,
            'authorizationCode': "",
          });
        }
      } catch (e) {
        if (mounted) {
          CustomSnackBar.show(
            context,
            message: 'Failed to verify email: ${e.toString()}',
            type: SnackBarType.error,
          );
        }
      }
    } catch (e) {
      if (mounted) {
        CustomSnackBar.show(
          context,
          message: 'Failed to process Apple authentication: ${e.toString()}',
          type: SnackBarType.error,
        );
      }
    }
  }
}
