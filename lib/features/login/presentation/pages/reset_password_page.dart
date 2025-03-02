import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:plando/core/styles/constants.dart';
import 'package:plando/core/widgets/auth_app_bar.dart';
import 'package:plando/core/widgets/custom_button.dart';
import 'package:plando/core/widgets/custom_text_field.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:plando/core/providers/requests/auth/user.dart';
import 'package:plando/core/widgets/custom_snack_bar.dart';

class ResetPasswordPage extends ConsumerStatefulWidget {
  final String email;
  final String otpCode;

  const ResetPasswordPage({
    super.key,
    required this.email,
    required this.otpCode,
  });

  @override
  ConsumerState<ResetPasswordPage> createState() => _ResetPasswordPageState();
}

class _ResetPasswordPageState extends ConsumerState<ResetPasswordPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  bool _hasMinLength = false;
  bool _hasNumber = false;
  bool _hasSpecialChar = false;
  bool _passwordsMatch = false;
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _emailController.text = widget.email;
    _passwordController.addListener(_validatePassword);
    _confirmPasswordController.addListener(_validatePassword);
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _validatePassword() {
    final password = _passwordController.text;
    final confirmPassword = _confirmPasswordController.text;

    setState(() {
      _hasMinLength = password.length >= 8;
      _hasNumber = RegExp(r'[0-9]').hasMatch(password);
      _hasSpecialChar = RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(password);
      _passwordsMatch = password == confirmPassword && password.isNotEmpty;
    });
  }

  Future<void> _handleResetPassword() async {
    if (_hasMinLength && _hasNumber && _hasSpecialChar && _passwordsMatch) {
      setState(() {
        _isLoading = true;
      });

      try {
        // Get the user service
        final userService = ref.read(requestCodeProvider);

        // Reset password
        final result = await userService.resetPassword(
          widget.email,
          _passwordController.text,
          widget.otpCode,
        );

        if (mounted) {
          setState(() {
            _isLoading = false;
          });

          if (result['success'] == true) {
            // Show success message
            CustomSnackBar.show(
              context,
              message: result['message'] ?? 'Password reset successful',
              type: SnackBarType.success,
            );

            // Navigate to home page since we're already authenticated
            context.go('/home');
          } else {
            // Show error message
            CustomSnackBar.show(
              context,
              message: result['message'] ?? 'Failed to reset password',
              type: SnackBarType.error,
            );
          }
        }
      } catch (e) {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });

          // Show error message
          CustomSnackBar.show(
            context,
            message: 'Error resetting password: ${e.toString()}',
            type: SnackBarType.error,
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const AuthAppBar(),
      body: SafeArea(
        child: SingleChildScrollView(
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
                  'Reset Your Password',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 50),
                CustomTextField(
                  controller: _emailController,
                  hintText: 'Email address',
                  labelText: 'Email address',
                  validationType: TextFieldValidationType.email,
                  onChanged: (_) {},
                  enabled: false,
                ),
                const SizedBox(height: AppLength.sm),
                CustomTextField(
                  controller: _passwordController,
                  hintText: 'New Password',
                  labelText: 'New Password',
                  validationType: TextFieldValidationType.password,
                  onChanged: (_) => _validatePassword(),
                  obscureText: !_isPasswordVisible,
                  suffix: IconButton(
                    icon: Icon(
                      _isPasswordVisible
                          ? Icons.visibility
                          : Icons.visibility_off,
                      color: Colors.black,
                    ),
                    onPressed: () {
                      setState(() {
                        _isPasswordVisible = !_isPasswordVisible;
                      });
                    },
                  ),
                ),
                const SizedBox(height: AppLength.sm),
                CustomTextField(
                  controller: _confirmPasswordController,
                  hintText: 'Confirm Password',
                  labelText: 'Confirm Password',
                  validationType: TextFieldValidationType.password,
                  onChanged: (_) => _validatePassword(),
                  obscureText: !_isConfirmPasswordVisible,
                  suffix: IconButton(
                    icon: Icon(
                      _isConfirmPasswordVisible
                          ? Icons.visibility
                          : Icons.visibility_off,
                      color: Colors.black,
                    ),
                    onPressed: () {
                      setState(() {
                        _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
                      });
                    },
                  ),
                ),
                const SizedBox(height: AppLength.xs),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          _hasMinLength ? Icons.check : Icons.close,
                          color: _hasMinLength ? Colors.green : Colors.red,
                          size: 16,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Minimum of 8 characters',
                          style: TextStyle(
                            fontSize: 13,
                            color: _hasMinLength ? Colors.grey : Colors.red,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          _hasNumber ? Icons.check : Icons.close,
                          color: _hasNumber ? Colors.green : Colors.red,
                          size: 16,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'At least one number',
                          style: TextStyle(
                            fontSize: 13,
                            color: _hasNumber ? Colors.grey : Colors.red,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          _hasSpecialChar ? Icons.check : Icons.close,
                          color: _hasSpecialChar ? Colors.green : Colors.red,
                          size: 16,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'At least one special character (!, @, #, etc.)',
                          style: TextStyle(
                            fontSize: 13,
                            color: _hasSpecialChar ? Colors.grey : Colors.red,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          _passwordsMatch ? Icons.check : Icons.close,
                          color: _passwordsMatch ? Colors.green : Colors.red,
                          size: 16,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Passwords match',
                          style: TextStyle(
                            fontSize: 13,
                            color: _passwordsMatch ? Colors.grey : Colors.red,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'We recommend using uppercase, lowercase, numbers, and symbols for a stronger password',
                      style: TextStyle(
                        fontSize: 13,
                        color: AppColors.darkGrey,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppLength.xl),
                CustomButton(
                  label:
                      _isLoading ? 'Resetting Password...' : 'Reset Password',
                  onPressed: _isLoading ? () {} : _handleResetPassword,
                  type: ButtonType.normal,
                  isFullWidth: true,
                  isEnabled: _hasMinLength &&
                      _hasNumber &&
                      _hasSpecialChar &&
                      _passwordsMatch &&
                      !_isLoading,
                  isLoading: _isLoading,
                  color: ButtonColor.black,
                ),
                const SizedBox(height: AppLength.xl),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
