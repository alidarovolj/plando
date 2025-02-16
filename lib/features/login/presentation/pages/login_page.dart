import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:plando/core/widgets/custom_button.dart';
import 'package:plando/core/widgets/custom_text_field.dart';
import 'package:plando/core/styles/constants.dart';
import 'package:plando/core/utils/validators.dart';
import 'package:plando/features/login/presentation/providers/apple_auth_provider.dart';
import 'package:plando/features/login/presentation/providers/google_auth_provider.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final TextEditingController _emailController = TextEditingController();
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
      // Navigate to code input screen
      context.push('/code', extra: _emailController.text);
    }
  }

  Widget _buildSocialButton(String iconPath, VoidCallback onPressed) {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: Colors.black12),
      ),
      child: IconButton(
        icon: Image.asset(
          iconPath,
          height: 24,
          width: 24,
        ),
        onPressed: onPressed,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(backgroundColor: Colors.white, elevation: 0),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppLength.body),
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
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: AppLength.xs),
              const Text(
                'We\'ll send a verification code in email,\nWe\'ll use this email to sign you in or create an\naccount if you don\'t have one yet',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: AppLength.xl),
              CustomTextField(
                controller: _emailController,
                hintText: 'Email address',
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
                      final authState = ref.read(appleAuthProvider);
                      authState.whenData((credential) {
                        if (credential != null) {
                          // Handle successful auth
                        }
                      });
                    },
                  ),
                  const SizedBox(width: AppLength.body),
                  _buildSocialButton(
                    'lib/core/assets/images/logos/google.png',
                    () async {
                      final authNotifier =
                          ref.read(googleAuthProvider.notifier);
                      await authNotifier.signInWithGoogle();
                      final authState = ref.read(googleAuthProvider);
                      authState.whenData((userData) {
                        if (userData != null) {
                          // Handle successful Google auth
                          print('Signed in user: ${userData['email']}');
                        }
                      });
                    },
                  ),
                ],
              ),
              TextButton(
                onPressed: () {
                  context.push('/guest');
                },
                child: const Text(
                  'Continue as a guest',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 16,
                  ),
                ),
              ),
              const Spacer(),
              RichText(
                textAlign: TextAlign.start,
                text: TextSpan(
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                  children: [
                    const TextSpan(
                        text:
                            'By proceeding, I confirm that I have read and agree to '),
                    TextSpan(
                      text: 'Terms & Privacy Policy',
                      style: const TextStyle(
                        decoration: TextDecoration.underline,
                      ),
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
