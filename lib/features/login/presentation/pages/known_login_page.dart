import 'package:flutter/material.dart';
import 'package:plando/core/styles/constants.dart';
import 'package:plando/core/widgets/auth_app_bar.dart';
import 'package:plando/core/widgets/custom_button.dart';
import 'package:plando/core/widgets/custom_text_field.dart';
import 'package:go_router/go_router.dart';
import 'package:plando/core/widgets/custom_snack_bar.dart';
import 'package:plando/core/utils/validators.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:plando/core/providers/requests/auth/user.dart';

class KnownLoginPage extends ConsumerStatefulWidget {
  final String email;

  const KnownLoginPage({
    super.key,
    required this.email,
  });

  @override
  ConsumerState<KnownLoginPage> createState() => _KnownLoginPageState();
}

class _KnownLoginPageState extends ConsumerState<KnownLoginPage> {
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  bool _isPasswordVisible = false;
  bool _isPasswordValid = false;
  String? _emailError;
  String? _passwordError;
  bool _wasValidated = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _emailController.text = widget.email;
    _passwordController.addListener(_validatePassword);
  }

  void _validatePassword() {
    setState(() {
      _isPasswordValid = _passwordController.text.isNotEmpty;
      if (_wasValidated && !_isPasswordValid) {
        _passwordError = 'Password is required';
      } else {
        _passwordError = null;
      }
    });
  }

  void _validateEmail(String value) {
    if (_wasValidated) {
      setState(() {
        _emailError = Validators.validateEmail(value);
      });
    }
  }

  void _handleSignIn() async {
    setState(() {
      _wasValidated = true;
      _emailError = Validators.validateEmail(_emailController.text);
      _passwordError =
          _passwordController.text.isEmpty ? 'Password is required' : null;
      _isLoading = true;
    });

    if (!_isPasswordValid || _emailError != null) {
      setState(() {
        _isLoading = false;
      });

      if (_emailError != null) {
        CustomSnackBar.show(
          context,
          message: _emailError!,
          type: SnackBarType.error,
        );
      }
      return;
    }

    try {
      // Get the user service
      final userService = ref.read(requestCodeProvider);

      // Login with email and password
      final result = await userService.login(
        _emailController.text,
        _passwordController.text,
      );

      if (mounted) {
        setState(() {
          _isLoading = false;
        });

        if (result['success'] == true) {
          // Show success message and navigate to home
          CustomSnackBar.show(
            context,
            message: result['message'] ?? 'Successfully signed in',
            type: SnackBarType.success,
          );

          // Navigate to home page
          context.go('/home');
        } else {
          // Check if this is an authentication error
          if (result['error_type'] == 'auth_error') {
            // Display error under password field
            setState(() {
              _passwordError = result['message'];
            });
          } else {
            // Show error message in snackbar
            CustomSnackBar.show(
              context,
              message: result['message'] ?? 'Failed to sign in',
              type: SnackBarType.error,
            );
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
          message: 'Failed to sign in: ${e.toString()}',
          type: SnackBarType.error,
        );
      }
    }
  }

  @override
  void dispose() {
    _passwordController.removeListener(_validatePassword);
    _passwordController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const AuthAppBar(),
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
                'Welcome!',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 50),
              CustomTextField(
                controller: _emailController,
                hintText: 'Email',
                labelText: 'Email',
                errorText: _emailError,
                validationType: TextFieldValidationType.email,
                onChanged: _validateEmail,
              ),
              const SizedBox(height: AppLength.body),
              CustomTextField(
                controller: _passwordController,
                hintText: 'Password',
                validationType: TextFieldValidationType.password,
                onChanged: (_) {},
                labelText: 'Password',
                errorText: _passwordError,
                obscureText: !_isPasswordVisible,
                suffix: IconButton(
                  icon: Icon(
                    _isPasswordVisible
                        ? Icons.visibility_off
                        : Icons.visibility,
                    color: Colors.grey,
                  ),
                  onPressed: () {
                    setState(() {
                      _isPasswordVisible = !_isPasswordVisible;
                    });
                  },
                ),
              ),
              const SizedBox(height: AppLength.xl),
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton(
                  onPressed: () {
                    context.push('/forgot-password',
                        extra: _emailController.text);
                  },
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.zero,
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: const Text(
                    'Forgot password?',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 14,
                      decoration: TextDecoration.underline,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 30),
              CustomButton(
                label: _isLoading ? 'Signing in...' : 'Sign in',
                onPressed: _isLoading ? () {} : _handleSignIn,
                type: ButtonType.normal,
                isFullWidth: true,
                isEnabled: _isPasswordValid && !_isLoading,
                isLoading: _isLoading,
                color: ButtonColor.black,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
