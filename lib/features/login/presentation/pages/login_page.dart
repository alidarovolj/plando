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

            // Navigate based on whether the email exists
            if (emailExists) {
              context.push('/known-login', extra: email);
            } else {
              // If email doesn't exist but no 404 was thrown, send OTP and navigate to code page
              final result = await userService.sendRegistrationOtp(email);
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
        data: (credential) {
          if (credential != null) {
            _handleSuccessfulAuth(
              credential.email ?? 'No email provided',
              'Apple',
              null, // Apple не предоставляет фото
            );
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
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildSocialButton(
                    'lib/core/assets/images/logos/apple.png',
                    () async {
                      final authNotifier = ref.read(appleAuthProvider.notifier);
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
              ),
              const SizedBox(height: AppLength.xxxl),
              TextButton(
                onPressed: () {
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
}
