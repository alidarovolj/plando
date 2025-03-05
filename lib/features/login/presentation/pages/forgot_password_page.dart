import 'package:flutter/material.dart';
import 'package:plando/core/styles/constants.dart';
import 'package:plando/core/widgets/custom_button.dart';
import 'package:plando/core/widgets/custom_text_field.dart';
import 'package:plando/core/utils/validators.dart';
import 'package:plando/core/widgets/custom_snack_bar.dart';
import 'package:plando/core/widgets/auth_app_bar.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:plando/core/providers/requests/auth/user.dart';

class ForgotPasswordPage extends ConsumerStatefulWidget {
  final String? email;

  const ForgotPasswordPage({
    super.key,
    this.email,
  });

  @override
  ConsumerState<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends ConsumerState<ForgotPasswordPage> {
  final TextEditingController _emailController = TextEditingController();
  String? _emailError;
  bool _wasValidated = false;
  bool _isEmailValid = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.email != null) {
      _emailController.text = widget.email!;
      _validateEmail(widget.email!);
    }
    _emailController.addListener(() {
      _validateEmail(_emailController.text);
    });
  }

  void _validateEmail(String value) {
    setState(() {
      if (_wasValidated) {
        _emailError = Validators.validateEmail(value);
      }
      _isEmailValid = Validators.validateEmail(value) == null;
    });
  }

  Future<void> _handleSendEmail() async {
    setState(() {
      _wasValidated = true;
      _emailError = Validators.validateEmail(_emailController.text);
      _isEmailValid = _emailError == null;
      _isLoading = true;
    });

    if (_isEmailValid) {
      try {
        // Get the user service
        final userService = ref.read(requestCodeProvider);
        final email = _emailController.text;

        // Send password reset OTP
        final result = await userService.sendPasswordResetOtp(email);

        if (mounted) {
          setState(() {
            _isLoading = false;
          });

          if (result['success'] == true) {
            // Show success message
            CustomSnackBar.show(
              context,
              message:
                  result['message'] ?? 'Password reset code sent successfully',
              type: SnackBarType.success,
            );

            // Navigate to password reset code verification page
            context.push('/reset-code', extra: email);
          } else {
            // Show error message
            CustomSnackBar.show(
              context,
              message:
                  result['message'] ?? 'Failed to send password reset code',
              type: SnackBarType.error,
            );
          }
        }
      } catch (e) {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });

          CustomSnackBar.show(
            context,
            message: 'Failed to send password reset code: ${e.toString()}',
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

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppLength.body),
          child: Column(
            children: [
              const AuthAppBar(),
              const SizedBox(height: 60),
              const Text(
                'Enter your email, and we\'ll send you a reset code',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 50),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Email',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: AppLength.xs),
                  CustomTextField(
                    controller: _emailController,
                    hintText: 'Email',
                    errorText: _emailError,
                    validationType: TextFieldValidationType.email,
                    onChanged: _validateEmail,
                  ),
                ],
              ),
              const SizedBox(height: AppLength.xl),
              CustomButton(
                label: _isLoading ? 'Sending...' : 'Send an email',
                onPressed: _isLoading ? () {} : _handleSendEmail,
                type: ButtonType.normal,
                isFullWidth: true,
                isEnabled: _isEmailValid && !_isLoading,
                isLoading: _isLoading,
                color: ButtonColor.black,
              ),
              const SizedBox(height: AppLength.xl),
              const Text(
                'We will send the confirmation code to your email. Check your email address and enter the code listed below.',
                style: TextStyle(
                  fontSize: 16,
                  color: AppColors.darkGrey,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }
}
