import 'package:flutter/material.dart';
import 'package:plando/core/styles/constants.dart';
import 'package:plando/core/widgets/auth_app_bar.dart';
import 'package:plando/core/widgets/custom_button.dart';
import 'package:plando/core/widgets/custom_text_field.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:go_router/go_router.dart';
import 'package:plando/core/widgets/custom_snack_bar.dart';
import 'package:plando/core/utils/validators.dart';

class KnownLoginPage extends StatefulWidget {
  final String email;

  const KnownLoginPage({
    super.key,
    required this.email,
  });

  @override
  State<KnownLoginPage> createState() => _KnownLoginPageState();
}

class _KnownLoginPageState extends State<KnownLoginPage> {
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  bool _isPasswordVisible = false;
  bool _isPasswordValid = false;
  String? _emailError;
  bool _wasValidated = false;

  @override
  void initState() {
    super.initState();
    _emailController.text = widget.email;
    _passwordController.addListener(_validatePassword);
  }

  void _validatePassword() {
    setState(() {
      _isPasswordValid = _passwordController.text.isNotEmpty;
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
    });

    if (!_isPasswordValid || _emailError != null) {
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
      const storage = FlutterSecureStorage();

      // Here you would typically validate the password against your backend
      // For now, we'll just simulate a successful login
      await storage.write(key: 'user_email', value: _emailController.text);
      await storage.write(key: 'is_authenticated', value: 'true');

      if (mounted) {
        CustomSnackBar.show(
          context,
          message: 'Successfully signed in',
          type: SnackBarType.success,
        );
        context.go('/home');
      }
    } catch (e) {
      if (mounted) {
        CustomSnackBar.show(
          context,
          message: 'Failed to sign in',
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
                'Welcome back',
                style: TextStyle(
                  fontSize: 20,
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
                    ),
                  ),
                ),
              ),
              const SizedBox(height: AppLength.xl),
              CustomButton(
                label: 'Sign in',
                onPressed: _handleSignIn,
                type: ButtonType.normal,
                isFullWidth: true,
                isEnabled: _isPasswordValid,
                color: ButtonColor.black,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
