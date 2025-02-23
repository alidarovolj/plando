import 'package:flutter/material.dart';
import 'package:plando/core/styles/constants.dart';
import 'package:plando/core/widgets/custom_button.dart';
import 'package:plando/core/widgets/custom_text_field.dart';
import 'package:plando/core/utils/validators.dart';
import 'package:plando/core/widgets/custom_snack_bar.dart';
import 'package:plando/core/widgets/auth_app_bar.dart';
import 'package:go_router/go_router.dart';

class ForgotPasswordPage extends StatefulWidget {
  final String? email;

  const ForgotPasswordPage({
    super.key,
    this.email,
  });

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final TextEditingController _emailController = TextEditingController();
  String? _emailError;
  bool _wasValidated = false;
  bool _isEmailValid = false;

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

  void _handleSendEmail() {
    setState(() {
      _wasValidated = true;
      _emailError = Validators.validateEmail(_emailController.text);
      _isEmailValid = _emailError == null;
    });

    if (_isEmailValid) {
      // Here you would typically send the reset code to the email
      context.push('/code', extra: _emailController.text);
    } else {
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
      appBar: const AuthAppBar(),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppLength.body),
          child: Column(
            children: [
              const SizedBox(height: AppLength.xl),
              const Text(
                'Enter your email, and\nwe\'ll send you a reset code',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: AppLength.xl),
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
                label: 'Send an email',
                onPressed: _handleSendEmail,
                type: ButtonType.normal,
                isFullWidth: true,
                isEnabled: _isEmailValid,
                color: ButtonColor.black,
              ),
              const SizedBox(height: AppLength.xl),
              const Text(
                'We will send the confirmation code to your email. Check your email address and enter the code listed below.',
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.darkGrey,
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
