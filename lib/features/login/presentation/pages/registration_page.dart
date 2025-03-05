import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:plando/core/styles/constants.dart';
import 'package:plando/core/widgets/auth_app_bar.dart';
import 'package:plando/core/widgets/custom_button.dart';
import 'package:plando/core/widgets/custom_text_field.dart';
import 'package:flutter_svg/flutter_svg.dart';

class RegistrationPage extends StatefulWidget {
  final String email;
  final String otpCode;

  const RegistrationPage({
    super.key,
    required this.email,
    required this.otpCode,
  });

  @override
  State<RegistrationPage> createState() => _RegistrationPageState();
}

class _RegistrationPageState extends State<RegistrationPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _hasMinLength = false;
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
    });
  }

  void _handleSignUp() {
    if (_hasMinLength) {
      context.push('/username', extra: {
        'email': widget.email,
        'password': _passwordController.text,
        'otpCode': widget.otpCode,
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
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
                'Welcome!',
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
                hintText: 'Password',
                labelText: 'Password',
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
                ],
              ),
              const SizedBox(height: AppLength.xl),
              CustomButton(
                label: 'Sign up',
                onPressed: _handleSignUp,
                type: ButtonType.normal,
                isFullWidth: true,
                isEnabled: _hasMinLength,
                color: ButtonColor.black,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
