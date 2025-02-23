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

  void _validateEmail(String value) {
    if (_wasValidated) {
      setState(() {
        _emailError = Validators.validateEmail(value);
      });
    }
  }

  void _handleContinue() {
    setState(() {
      _wasValidated = true;
      _emailError = Validators.validateEmail(_emailController.text);
    });

    if (_emailError == null) {
      // Check if this is a known user
      if (_emailController.text.toLowerCase() == 'test@test.com') {
        context.push('/known-login', extra: _emailController.text);
      } else {
        context.push('/code', extra: _emailController.text);
      }
    } else {
      CustomSnackBar.show(
        context,
        message: _emailError!,
        type: SnackBarType.error,
      );
    }
  }

  Future<void> _handleSuccessfulAuth(
      String email, String provider, String? photoUrl) async {
    try {
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
    } catch (e) {
      if (mounted) {
        CustomSnackBar.show(
          context,
          message: 'Failed to save authentication data',
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
                label: 'Continue',
                onPressed: _handleContinue,
                type: ButtonType.normal,
                isFullWidth: true,
                isEnabled: true,
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
