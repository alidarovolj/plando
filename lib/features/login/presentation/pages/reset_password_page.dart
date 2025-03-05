import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:plando/core/styles/constants.dart';
import 'package:plando/core/widgets/auth_app_bar.dart';
import 'package:plando/core/widgets/custom_button.dart';
import 'package:plando/core/widgets/custom_text_field.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:plando/core/providers/requests/auth/user.dart';
import 'package:plando/core/widgets/custom_snack_bar.dart';
import 'package:flutter_svg/flutter_svg.dart';

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
  bool _passwordsMatch = false;
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _emailController.text = widget.email;
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _validatePassword(String value) {
    setState(() {
      _hasMinLength = value.length >= 8;
      _passwordsMatch =
          value == _confirmPasswordController.text && value.isNotEmpty;
    });
  }

  void _validateConfirmPassword(String value) {
    setState(() {
      _passwordsMatch = value == _passwordController.text && value.isNotEmpty;
    });
  }

  Future<void> _handleResetPassword() async {
    if (_hasMinLength && _passwordsMatch) {
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
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppLength.body),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const AuthAppBar(),
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
                  hintText: 'Email',
                  labelText: 'Email',
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
                  onChanged: _validatePassword,
                  obscureText: !_isPasswordVisible,
                  suffix: IconButton(
                    icon: SvgPicture.asset(
                      'lib/core/assets/icons/eye.svg',
                      colorFilter: ColorFilter.mode(
                        _isPasswordVisible ? AppColors.darkGrey : Colors.black,
                        BlendMode.srcIn,
                      ),
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
                  onChanged: _validateConfirmPassword,
                  obscureText: !_isConfirmPasswordVisible,
                  suffix: IconButton(
                    icon: SvgPicture.asset(
                      'lib/core/assets/icons/eye.svg',
                      colorFilter: ColorFilter.mode(
                        _isConfirmPasswordVisible
                            ? AppColors.darkGrey
                            : Colors.black,
                        BlendMode.srcIn,
                      ),
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
                  ],
                ),
                const SizedBox(height: AppLength.xl),
                CustomButton(
                  label:
                      _isLoading ? 'Resetting Password...' : 'Reset Password',
                  onPressed: _isLoading ? () {} : _handleResetPassword,
                  type: ButtonType.normal,
                  isFullWidth: true,
                  isEnabled: _hasMinLength && _passwordsMatch && !_isLoading,
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
