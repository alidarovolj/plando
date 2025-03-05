import 'package:flutter/material.dart';
import 'package:plando/core/styles/constants.dart';
import 'package:plando/core/widgets/auth_app_bar.dart';
import 'package:plando/core/widgets/custom_button.dart';
import 'package:plando/core/widgets/custom_text_field.dart';
import 'package:go_router/go_router.dart';
import 'package:plando/core/widgets/custom_snack_bar.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:plando/core/providers/requests/auth/user.dart';
import 'dart:async';

class GoogleUsernamePage extends ConsumerStatefulWidget {
  final String email;
  final String token;
  final String? photoUrl;
  final String? displayName;

  const GoogleUsernamePage({
    super.key,
    required this.email,
    required this.token,
    this.photoUrl,
    this.displayName,
  });

  @override
  ConsumerState<GoogleUsernamePage> createState() => _GoogleUsernamePageState();
}

class _GoogleUsernamePageState extends ConsumerState<GoogleUsernamePage> {
  final TextEditingController _usernameController = TextEditingController();
  String? _usernameError;
  bool _isUsernameValid = false;
  String? _successMessage;
  bool _isLoading = false;
  bool _isCheckingUsername = false;
  // Debounce timer for username validation
  Timer? _debounceTimer;

  @override
  void initState() {
    super.initState();
    // If display name is available, suggest it as username
    if (widget.displayName != null && widget.displayName!.isNotEmpty) {
      // Remove spaces and special characters to create a valid username
      final suggestedUsername = widget.displayName!
          .toLowerCase()
          .replaceAll(RegExp(r'[^\w\s]+'), '')
          .replaceAll(' ', '');

      _usernameController.text = suggestedUsername;
      // Validate the suggested username
      _validateUsername(suggestedUsername);
    }
  }

  Future<void> _validateUsername(String value) async {
    // Cancel any previous debounce timer
    _debounceTimer?.cancel();

    setState(() {
      if (value.isEmpty) {
        _usernameError = null;
        _successMessage = null;
        _isUsernameValid = false;
      } else if (value.length <= 3) {
        _usernameError = 'Username must be longer than 3 characters';
        _successMessage = null;
        _isUsernameValid = false;
      } else {
        // Set initial state while we check
        _usernameError = null;
        _successMessage = null;
        _isUsernameValid = false;
        _isCheckingUsername = true;

        // Debounce the API call to avoid too many requests
        _debounceTimer = Timer(const Duration(milliseconds: 500), () async {
          try {
            // Get the user service
            final userService = ref.read(requestCodeProvider);

            // Check if username exists
            final result = await userService.checkUsernameExists(value);

            if (mounted) {
              setState(() {
                _isCheckingUsername = false;

                if (result['success'] == true) {
                  if (result['exists'] == true) {
                    _usernameError =
                        'This username is already taken.\nPlease choose another one.';
                    _successMessage = null;
                    _isUsernameValid = false;
                  } else {
                    _usernameError = null;
                    _successMessage = 'Username is available';
                    _isUsernameValid = true;
                  }
                } else {
                  // API call failed
                  _usernameError = 'Could not verify username';
                  _successMessage = null;
                  _isUsernameValid = false;
                }
              });
            }
          } catch (e) {
            if (mounted) {
              setState(() {
                _isCheckingUsername = false;
                _usernameError = 'Error checking username';
                _successMessage = null;
                _isUsernameValid = false;
              });
            }
          }
        });
      }
    });
  }

  Future<void> _handleContinue() async {
    if (!_isUsernameValid || _isLoading) return;

    setState(() {
      _isLoading = true;
    });

    try {
      // Get the user service
      final userService = ref.read(requestCodeProvider);

      // Print values for debugging
      print('Google Registration parameters:');
      print('Email: ${widget.email}');
      print('Token: ${widget.token}');
      print('Username: ${_usernameController.text}');

      // Register the user with Google
      final result = await userService.signUpWithGoogle(
        widget.token,
        _usernameController.text,
        widget.email,
      );

      if (mounted) {
        setState(() {
          _isLoading = false;
        });

        if (result['success'] == true) {
          // Show success message and navigate to home
          CustomSnackBar.show(
            context,
            message: result['message'] ?? 'Registration successful!',
            type: SnackBarType.success,
          );

          context.go('/home');
        } else {
          // Show error message
          CustomSnackBar.show(
            context,
            message: result['message'] ?? 'Registration failed',
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
          message: 'Failed to register: ${e.toString()}',
          type: SnackBarType.error,
        );
      }
    }
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _debounceTimer?.cancel();
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const AuthAppBar(),
              const SizedBox(height: 60),
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
              const SizedBox(height: AppLength.xl),
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
                  if (_isCheckingUsername)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Row(
                        children: [
                          SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Theme.of(context).primaryColor,
                            ),
                          ),
                          const SizedBox(width: 4),
                          const Text(
                            'Checking username...',
                            style: TextStyle(
                              color: Colors.grey,
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
                label: _isLoading ? 'Registering...' : 'Continue',
                onPressed: _isLoading ? () {} : _handleContinue,
                type: ButtonType.normal,
                isFullWidth: true,
                isEnabled:
                    _isUsernameValid && !_isLoading && !_isCheckingUsername,
                isLoading: _isLoading,
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
