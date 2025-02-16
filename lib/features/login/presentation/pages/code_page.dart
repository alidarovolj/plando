import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:plando/core/providers/auth/auth_state.dart';
import 'package:plando/core/services/storage_service.dart';
import 'package:plando/core/styles/constants.dart';
import 'package:go_router/go_router.dart';
import 'package:plando/core/providers/requests/auth/user.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:async';

class CodeInputScreen extends StatefulWidget {
  final String email;

  const CodeInputScreen({
    super.key,
    required this.email,
  });

  @override
  State<CodeInputScreen> createState() => _CodeInputScreenState();
}

class _CodeInputScreenState extends State<CodeInputScreen> {
  final TextEditingController _codeController = TextEditingController();
  List<String> _codeDigits = ['', '', '', ''];
  bool _isExpired = false;
  Timer? _timer;
  int _timeLeft = 300; // 5 minutes in seconds
  bool _canResend = false;

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
    if (!_canResend) return;

    // Clear the input
    _codeController.clear();
    setState(() {
      _codeDigits = ['', '', '', ''];
      _isExpired = false;
    });

    // TODO: Implement code resend logic
    _startTimer();
  }

  void _handleCodeComplete() {
    final code = _codeController.text;
    if (code.length == 4) {
      // TODO: Add actual code verification
      // For now, just navigate to registration
      context.push('/registration', extra: widget.email);
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
              const Text(
                'Enter verification code',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: AppLength.sm),
              RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
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
              Text(
                'The code is valid for 5 minutes.',
                style: TextStyle(
                  fontSize: 13,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: AppLength.xxl),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Stack(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(4, (index) {
                        return Container(
                          margin: EdgeInsets.only(left: index > 0 ? 15 : 0),
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            border: Border.all(
                              color: _codeDigits[index].isNotEmpty
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
                                fontWeight: FontWeight.w500,
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
                          if (value.length == 4) {
                            _handleCodeComplete();
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppLength.sm),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                    onPressed: _canResend ? _resendCode : null,
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.zero,
                    ),
                    child: Text(
                      _isExpired
                          ? 'Code expired. Request a new one'
                          : 'Resend code',
                      style: TextStyle(
                        color: _canResend ? Colors.black : Colors.grey,
                        fontSize: 13,
                      ),
                    ),
                  ),
                  Text(
                    _formatTimeLeft(),
                    style: TextStyle(
                      color: _timeLeft == 0 ? Colors.red : Colors.black,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
