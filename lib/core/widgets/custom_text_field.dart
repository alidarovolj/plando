import 'package:flutter/material.dart';
import 'package:plando/core/styles/constants.dart';

enum TextFieldValidationType {
  email,
  password,
  phone,
  name,
  none,
}

class CustomTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final String? errorText;
  final TextFieldValidationType validationType;
  final Function(String) onChanged;
  final bool obscureText;
  final TextInputType? keyboardType;
  final String? labelText;
  final Widget? suffix;
  final bool enabled;

  const CustomTextField({
    super.key,
    required this.controller,
    required this.hintText,
    this.errorText,
    this.validationType = TextFieldValidationType.none,
    required this.onChanged,
    this.obscureText = false,
    this.keyboardType,
    this.labelText,
    this.suffix,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (labelText != null) ...[
          Text(
            labelText!,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: AppLength.xs),
        ],
        TextField(
          controller: controller,
          obscureText: obscureText,
          enabled: enabled,
          keyboardType: keyboardType ?? _getKeyboardType(),
          onChanged: onChanged,
          decoration: InputDecoration(
            hintText: hintText,
            errorText: errorText,
            suffixIcon: suffix,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.grey),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.grey),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.black),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.red),
            ),
          ),
        ),
      ],
    );
  }

  TextInputType _getKeyboardType() {
    switch (validationType) {
      case TextFieldValidationType.email:
        return TextInputType.emailAddress;
      case TextFieldValidationType.password:
        return TextInputType.visiblePassword;
      case TextFieldValidationType.phone:
        return TextInputType.phone;
      case TextFieldValidationType.name:
        return TextInputType.name;
      case TextFieldValidationType.none:
        return TextInputType.text;
    }
  }
}
