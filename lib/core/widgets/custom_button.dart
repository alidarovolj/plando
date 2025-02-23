import 'package:flutter/material.dart';
import 'package:plando/core/styles/constants.dart';

enum ButtonType { small, normal, big } // Типы кнопок

enum ButtonColor { primary, black }

enum CustomButtonStyle { filled, outlined, text }

class CustomButton extends StatefulWidget {
  final String label; // Текст на кнопке
  final VoidCallback onPressed; // Действие при нажатии
  final ButtonType type; // Тип кнопки
  final bool isEnabled; // Определяет, включена ли кнопка
  final bool isFullWidth; // Растягивать ли кнопку на всю ширину
  final bool isLoading; // Add this line
  final ButtonColor color;
  final CustomButtonStyle style;

  const CustomButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.type = ButtonType.normal, // Тип по умолчанию
    this.isEnabled = true, // Кнопка включена по умолчанию
    this.isFullWidth = true, // По умолчанию на всю ширину
    this.isLoading = false, // Add this line
    this.color = ButtonColor.primary,
    this.style = CustomButtonStyle.filled,
  });

  @override
  _CustomButtonState createState() => _CustomButtonState();
}

class _CustomButtonState extends State<CustomButton> {
  late TextStyle _textStyle;
  late EdgeInsets _padding;

  @override
  void initState() {
    super.initState();
    _applyButtonStyle();
  }

  void _applyButtonStyle() {
    switch (widget.type) {
      case ButtonType.small:
        _textStyle = const TextStyle(
          fontSize: AppLength.xs,
          fontWeight: FontWeight.bold,
        );
        _padding = const EdgeInsets.symmetric(
            vertical: AppLength.tiny, horizontal: AppLength.xs);
        break;
      case ButtonType.normal:
        _textStyle = const TextStyle(
          fontSize: AppLength.sm,
          fontWeight: FontWeight.w600,
        );
        _padding =
            const EdgeInsets.symmetric(horizontal: AppLength.body, vertical: 0);
        break;
      case ButtonType.big:
        _textStyle = const TextStyle(
          fontSize: AppLength.body,
          fontWeight: FontWeight.w700,
        );
        _padding = const EdgeInsets.symmetric(
            horizontal: AppLength.body, vertical: AppLength.xl);
        break;
    }
  }

  Color _getButtonColor() {
    if (!widget.isEnabled) {
      return AppColors.buttonDisabled;
    }

    if (widget.style == CustomButtonStyle.outlined ||
        widget.style == CustomButtonStyle.text) {
      return Colors.transparent;
    }

    switch (widget.color) {
      case ButtonColor.primary:
        return AppColors.primary;
      case ButtonColor.black:
        return Colors.black;
    }
  }

  Color _getTextColor() {
    if (!widget.isEnabled) {
      return AppColors.textSecondary;
    }

    if (widget.style == CustomButtonStyle.filled) {
      return AppColors.white;
    }

    switch (widget.color) {
      case ButtonColor.primary:
        return AppColors.primary;
      case ButtonColor.black:
        return Colors.black;
    }
  }

  BoxDecoration _getButtonDecoration() {
    final borderRadius = BorderRadius.circular(100);

    if (widget.style == CustomButtonStyle.text) {
      return BoxDecoration(
        borderRadius: borderRadius,
      );
    }

    final border = widget.style == CustomButtonStyle.outlined
        ? Border.all(
            color: widget.isEnabled
                ? (widget.color == ButtonColor.black
                    ? Colors.black
                    : AppColors.primary)
                : AppColors.buttonDisabled,
          )
        : null;

    return BoxDecoration(
      color: _getButtonColor(),
      borderRadius: borderRadius,
      border: border,
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.isEnabled ? widget.onPressed : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        decoration: _getButtonDecoration(),
        child: SizedBox(
          width: widget.isFullWidth ? double.infinity : null,
          height: 60,
          child: Container(
            padding: _padding,
            child: Center(
              child: widget.isLoading
                  ? SizedBox(
                      height: widget.type == ButtonType.small ? 12 : 16,
                      width: widget.type == ButtonType.small ? 12 : 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          widget.isEnabled
                              ? _getTextColor()
                              : AppColors.textSecondary,
                        ),
                      ),
                    )
                  : AnimatedDefaultTextStyle(
                      duration: const Duration(milliseconds: 200),
                      style: _textStyle.copyWith(
                        color: _getTextColor(),
                      ),
                      child: Text(widget.label,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          )),
                    ),
            ),
          ),
        ),
      ),
    );
  }
}
