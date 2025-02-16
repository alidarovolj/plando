import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:plando/core/styles/constants.dart';
import 'package:plando/core/widgets/custom_button.dart';
import 'package:plando/core/widgets/custom_text_field.dart';
import 'package:plando/core/utils/validators.dart';

class RegistrationPage extends StatefulWidget {
  final String email;

  const RegistrationPage({
    super.key,
    required this.email,
  });

  @override
  State<RegistrationPage> createState() => _RegistrationPageState();
}

class _RegistrationPageState extends State<RegistrationPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _hasMinLength = false;
  bool _hasNumber = false;
  bool _hasSpecialChar = false;
  bool _isPasswordVisible = false;

  @override
  void initState() {
    super.initState();
    _emailController.text = widget.email;
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _validatePassword(String value) {
    setState(() {
      _hasMinLength = value.length >= 8;
      _hasNumber = RegExp(r'[0-9]').hasMatch(value);
      _hasSpecialChar = RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(value);
    });
  }

  void _handleSignUp() {
    if (_hasMinLength && _hasNumber && _hasSpecialChar) {
      context.push('/username', extra: {
        'email': widget.email,
        'password': _passwordController.text,
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
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
                hintText: 'Password',
                labelText: 'Password',
                validationType: TextFieldValidationType.password,
                onChanged: _validatePassword,
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
                  const Text(
                    'We recommend using uppercase, lowercase, numbers, and symbols for a stronger password',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppLength.xl),
              CustomButton(
                label: 'Sign up',
                onPressed: _handleSignUp,
                type: ButtonType.normal,
                isFullWidth: true,
                isEnabled: _hasMinLength && _hasNumber && _hasSpecialChar,
                color: ButtonColor.black,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
