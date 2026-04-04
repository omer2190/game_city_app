import 'package:flutter/material.dart';

enum ButtonType { primary, secondary, outline, text }

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final ButtonType type;
  final bool isLoading;
  final Widget? icon;
  final double? width;
  final double height;
  final Color? backgroundColor;
  final Color? textColor;
  final double borderRadius;

  const CustomButton({
    super.key,
    required this.text,
    this.onPressed,
    this.type = ButtonType.primary,
    this.isLoading = false,
    this.icon,
    this.width,
    this.height = 50,
    this.backgroundColor,
    this.textColor,
    this.borderRadius = 12,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    Color backgroundColor = this.backgroundColor ?? colorScheme.primary;
    Color foregroundColor = this.textColor ?? colorScheme.onPrimary;
    BorderSide? borderSide;

    switch (type) {
      case ButtonType.primary:
        backgroundColor = this.backgroundColor ?? colorScheme.primary;
        foregroundColor = this.textColor ?? colorScheme.onPrimary;
        borderSide = null;
        break;
      case ButtonType.secondary:
        backgroundColor = this.backgroundColor ?? colorScheme.secondary;
        foregroundColor = this.textColor ?? colorScheme.onSecondary;
        borderSide = null;
        break;
      case ButtonType.outline:
        backgroundColor = Colors.transparent;
        foregroundColor = this.textColor ?? colorScheme.primary;
        borderSide = BorderSide(color: colorScheme.primary, width: 2);
        break;
      case ButtonType.text:
        backgroundColor = Colors.transparent;
        foregroundColor = this.textColor ?? colorScheme.primary;
        borderSide = null;
        break;
    }

    return SizedBox(
      width: width,
      height: height,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
          foregroundColor: foregroundColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius),
            side: borderSide ?? BorderSide.none,
          ),
          elevation: type == ButtonType.primary || type == ButtonType.secondary
              ? 2
              : 0,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
        ),
        child: isLoading
            ? SizedBox(
                // height: 20,
                // width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(foregroundColor),
                ),
              )
            : Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (icon != null) ...[icon!, const SizedBox(width: 8)],
                  Flexible(
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        text,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: foregroundColor,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
