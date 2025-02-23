import 'package:flutter/material.dart';
import 'package:plando/core/styles/constants.dart';

enum TextFieldValidationType {
  email,
  password,
  phone,
  name,
  none,
}

class CustomTextField extends StatefulWidget {
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
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  final _focusNode = FocusNode();
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() {
      setState(() {
        _isFocused = _focusNode.hasFocus;
      });
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: (_) {
        if (_focusNode.hasFocus) {
          _focusNode.unfocus();
        }
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (widget.labelText != null) ...[
            Text(
              widget.labelText!,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: AppLength.xs),
          ],
          ValueListenableBuilder<TextEditingValue>(
            valueListenable: widget.controller,
            builder: (context, value, child) {
              return AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                decoration: BoxDecoration(
                  color: AppColors.lightGrey,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: widget.errorText != null
                        ? Colors.red
                        : (_isFocused ? Colors.black : Colors.transparent),
                    width: 1,
                  ),
                ),
                child: SizedBox(
                  height: 50,
                  child: Center(
                    child: TextField(
                      controller: widget.controller,
                      obscureText: widget.obscureText,
                      enabled: widget.enabled,
                      focusNode: _focusNode,
                      keyboardType: widget.keyboardType ?? _getKeyboardType(),
                      onChanged: widget.onChanged,
                      textAlignVertical: TextAlignVertical.center,
                      style: const TextStyle(
                        fontSize: 16,
                      ),
                      decoration: InputDecoration(
                        isCollapsed: true,
                        hintText: widget.hintText,
                        hintStyle: const TextStyle(
                          fontSize: 16,
                          color: AppColors.darkGrey,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 0,
                        ),
                        suffixIcon: widget.enabled && value.text.isNotEmpty
                            ? widget.suffix ??
                                IconButton(
                                  icon: Container(
                                    width: 24,
                                    height: 24,
                                    decoration: const BoxDecoration(
                                      color: AppColors.grey,
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.close,
                                      size: 16,
                                      color: Colors.black,
                                    ),
                                  ),
                                  onPressed: () {
                                    widget.controller.clear();
                                    widget.onChanged('');
                                  },
                                )
                            : widget.suffix,
                        filled: true,
                        fillColor: Colors.transparent,
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        errorBorder: InputBorder.none,
                        focusedErrorBorder: InputBorder.none,
                        disabledBorder: InputBorder.none,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
          if (widget.errorText != null) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(
                  Icons.close,
                  size: 16,
                  color: Colors.red,
                ),
                const SizedBox(width: 4),
                Text(
                  widget.errorText!,
                  style: const TextStyle(
                    color: Colors.red,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  TextInputType _getKeyboardType() {
    switch (widget.validationType) {
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
