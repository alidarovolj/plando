import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:plando/core/styles/constants.dart';
import 'package:go_router/go_router.dart';
import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:plando/core/providers/requests/auth/user.dart';
import 'package:plando/core/widgets/custom_snack_bar.dart';

import 'package:plando/core/widgets/auth_app_bar.dart';

class CodeInputScreen extends ConsumerStatefulWidget {
  final String email;

  const CodeInputScreen({
    super.key,
    required this.email,
  });

  @override
  ConsumerState<CodeInputScreen> createState() => _CodeInputScreenState();
}

class _CodeInputScreenState extends ConsumerState<CodeInputScreen> {
  final TextEditingController _codeController = TextEditingController();
  List<String> _codeDigits = ['', '', '', ''];
  bool _isExpired = false;
  Timer? _timer;
  int _timeLeft = 300; // 5 minutes in seconds
  bool _canResend = false;
  bool _isResending = false;
  bool _isVerifying = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _codeController.dispose();
    super.dispose();
  }

  void _startTimer() {
    setState(() {
      _timeLeft = 300;
      _canResend = false;
      _isExpired = false;
      _errorMessage = null;
    });

    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_timeLeft > 0) {
        setState(() {
          _timeLeft--;
        });
      } else {
        timer.cancel();
        setState(() {
          _canResend = true;
          _isExpired = true;
          _errorMessage = 'Code expired. Request a new one.';
        });
      }
    });
  }

  String _formatTimeLeft() {
    final minutes = (_timeLeft / 60).floor();
    final seconds = _timeLeft % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  Future<void> _resendCode() async {
    if (!_canResend || _isResending) return;

    setState(() {
      _isResending = true;
      _errorMessage = null;
    });

    try {
      // Get the user service
      final userService = ref.read(requestCodeProvider);

      // Send registration OTP
      final result = await userService.sendRegistrationOtp(widget.email);

      if (mounted) {
        setState(() {
          _isResending = false;
        });

        if (result['success'] == true) {
          // Clear the input
          _codeController.clear();
          setState(() {
            _codeDigits = ['', '', '', ''];
            _isExpired = false;
            _errorMessage = null;
          });

          // Show success message
          CustomSnackBar.show(
            context,
            message: result['message'] ?? 'Verification code sent successfully',
            type: SnackBarType.success,
          );

          // Restart the timer
          _startTimer();
        } else {
          // Show error message
          CustomSnackBar.show(
            context,
            message: result['message'] ?? 'Failed to send verification code',
            type: SnackBarType.error,
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isResending = false;
        });

        // Show error message
        CustomSnackBar.show(
          context,
          message: 'Error sending verification code: ${e.toString()}',
          type: SnackBarType.error,
        );
      }
    }
  }

  Future<void> _handleCodeComplete() async {
    final code = _codeController.text;
    if (code.length == 4) {
      // Show loading indicator
      setState(() {
        _isVerifying = true;
        _errorMessage = null;
      });

      try {
        // Get the user service
        final userService = ref.read(requestCodeProvider);

        // Print the code for debugging
        print('Verifying OTP code: $code');
        print('Code type: ${code.runtimeType}');
        print('Code length: ${code.length}');

        // Verify the OTP code
        final result = await userService.verifyOtpCode(widget.email, code);

        if (mounted) {
          setState(() {
            _isVerifying = false;
          });

          if (result['success'] == true) {
            // Show success message
            CustomSnackBar.show(
              context,
              message: result['message'] ?? 'Code verified successfully',
              type: SnackBarType.success,
            );

            // Print the code being passed to the registration page
            print('Passing OTP code to registration page: $code');

            // Navigate to registration page with email and OTP code
            context.push('/registration', extra: {
              'email': widget.email,
              'otpCode': code,
            });
          } else {
            if (result['message']
                        ?.toString()
                        .toLowerCase()
                        .contains('too many') ==
                    true ||
                result['message']
                        ?.toString()
                        .toLowerCase()
                        .contains('attempts') ==
                    true) {
              setState(() {
                _errorMessage = 'Too many failed attempts. Try again later.';
              });
            } else if (result['message']
                    ?.toString()
                    .toLowerCase()
                    .contains('invalid') ==
                true) {
              setState(() {
                _errorMessage = 'Invalid verification code';
              });
            } else {
              setState(() {
                _errorMessage = result['message'] ?? 'Verification failed';
              });
            }

            // Show error message
            CustomSnackBar.show(
              context,
              message: result['message'] ??
                  'Invalid verification code. Please try again.',
              type: SnackBarType.error,
            );

            // Clear the input
            _codeController.clear();
            setState(() {
              _codeDigits = ['', '', '', ''];
            });
          }
        }
      } catch (e) {
        if (mounted) {
          setState(() {
            _isVerifying = false;
            // Check if the error contains "Invalid otp code"
            if (e.toString().contains('Invalid otp code')) {
              _errorMessage = 'Invalid verification code';
            } else {
              _errorMessage = 'Error verifying code';
            }
          });

          // Show error message
          CustomSnackBar.show(
            context,
            message: 'Error verifying code: ${e.toString()}',
            type: SnackBarType.error,
          );

          // Clear the input
          _codeController.clear();
          setState(() {
            _codeDigits = ['', '', '', ''];
          });
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
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppLength.body),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 60),
              const Text(
                'Enter verification code',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: AppLength.sm),
              RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: AppColors.darkGrey,
                  ),
                  children: [
                    const TextSpan(
                        text: 'We\'ve sent a verification code to\n'),
                    TextSpan(
                      text: widget.email,
                      style: const TextStyle(
                        color: AppColors.primary,
                      ),
                    ),
                    const TextSpan(
                      text:
                          '. Please check your\ninbox and enter the code below.',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppLength.xs),
              const Text(
                'The code is valid for 5 minutes.',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: AppColors.darkGrey,
                ),
              ),
              const SizedBox(height: AppLength.xxl),
              Stack(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: List.generate(4, (index) {
                      final containerWidth =
                          (MediaQuery.of(context).size.width -
                                  (16.0 * 2) -
                                  (14.5 * 3)) /
                              4;
                      return Container(
                        width: containerWidth,
                        height: 60,
                        margin: EdgeInsets.only(
                          left: index == 0 ? 0 : 7.25,
                          right: index == 3 ? 0 : 7.25,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(
                            color: (_errorMessage != null &&
                                    (_errorMessage!.contains(
                                            'Invalid verification code') ||
                                        _errorMessage!
                                            .contains('Code expired') ||
                                        _errorMessage!.contains(
                                            'Too many failed attempts')))
                                ? const Color(
                                    0xFFFF3B30) // Красный цвет для ошибки
                                : _codeDigits[index].isNotEmpty
                                    ? Colors.black
                                    : Colors.grey,
                            width: 1,
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Center(
                          child: Text(
                            _codeDigits[index],
                            style: const TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.w600,
                              color: Colors.black,
                            ),
                          ),
                        ),
                      );
                    }),
                  ),
                  Positioned.fill(
                    child: TextField(
                      controller: _codeController,
                      keyboardType: TextInputType.number,
                      autofillHints: const [AutofillHints.oneTimeCode],
                      maxLength: 4,
                      style: const TextStyle(
                        color: Colors.transparent,
                        fontSize: 1,
                      ),
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(4),
                      ],
                      decoration: const InputDecoration(
                        counterText: '',
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.zero,
                      ),
                      onChanged: (value) {
                        setState(() {
                          _codeDigits = List.filled(4, '');
                          final digits = value.split('');
                          for (var i = 0; i < digits.length && i < 4; i++) {
                            _codeDigits[i] = digits[i];
                          }
                        });
                        if (value.length == 4 && !_isVerifying) {
                          _handleCodeComplete();
                        }
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppLength.sm),
              if (_isVerifying)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 8.0),
                  child: Center(
                    child: SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
                      ),
                    ),
                  ),
                ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                    onPressed: (_canResend && !_isResending && !_isVerifying)
                        ? _resendCode
                        : null,
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.zero,
                    ),
                    child: Text(
                      _isResending ? 'Sending...' : 'Resend code',
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 14,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                  Text(
                    _formatTimeLeft(),
                    style: TextStyle(
                      color: _timeLeft == 0 ? Colors.red : Colors.black,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
              if (_errorMessage != null)
                Align(
                  alignment: Alignment.centerLeft,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 0),
                    child: Text(
                      _errorMessage!,
                      style: const TextStyle(
                        color: Color(0xFFFF3B30),
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
