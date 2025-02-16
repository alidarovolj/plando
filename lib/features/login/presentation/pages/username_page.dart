import 'package:flutter/material.dart';
import 'package:plando/core/styles/constants.dart';
import 'package:plando/core/widgets/custom_button.dart';
import 'package:plando/core/widgets/custom_text_field.dart';

class UsernamePage extends StatefulWidget {
  final String email;
  final String password;

  const UsernamePage({
    super.key,
    required this.email,
    required this.password,
  });

  @override
  State<UsernamePage> createState() => _UsernamePageState();
}

class _UsernamePageState extends State<UsernamePage> {
  final TextEditingController _usernameController = TextEditingController();
  String? _usernameError;
  bool _isUsernameValid = false;
  String? _successMessage;

  void _validateUsername(String value) {
    setState(() {
      if (value.isEmpty) {
        _usernameError = null;
        _successMessage = null;
        _isUsernameValid = false;
      } else if (value.length <= 3) {
        _usernameError = 'Username must be longer than 3 characters';
        _successMessage = null;
        _isUsernameValid = false;
      } else if (value == 'alidarovolj') {
        _usernameError =
            'This username is already taken.\nPlease choose another one.';
        _successMessage = null;
        _isUsernameValid = false;
      } else {
        _usernameError = null;
        _successMessage = 'Unique username';
        _isUsernameValid = true;
      }
    });
  }

  void _handleContinue() {
    if (_isUsernameValid) {
      print(
          'Registering with username: ${_usernameController.text}, email: ${widget.email}, password: ${widget.password}');
    }
  }

  @override
  void dispose() {
    _usernameController.dispose();
    super.dispose();
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 70),
              const Center(
                child: Text(
                  'One last step! Set up your\nusername to get started',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(height: AppLength.body),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CustomTextField(
                    controller: _usernameController,
                    hintText: 'Unique username',
                    errorText: _usernameError,
                    validationType: TextFieldValidationType.name,
                    onChanged: _validateUsername,
                  ),
                  if (_successMessage != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.check_circle,
                            color: Colors.green,
                            size: 16,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            _successMessage!,
                            style: const TextStyle(
                              color: Colors.green,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
              const Spacer(),
              CustomButton(
                label: 'Continue',
                onPressed: _handleContinue,
                type: ButtonType.normal,
                isFullWidth: true,
                isEnabled: _isUsernameValid,
                color: ButtonColor.black,
              ),
              const SizedBox(height: AppLength.xl),
            ],
          ),
        ),
      ),
    );
  }
}
