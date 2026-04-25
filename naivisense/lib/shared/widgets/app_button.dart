import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

enum AppButtonVariant { primary, secondary, success, danger }

class AppButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final AppButtonVariant variant;
  final IconData? icon;
  final bool fullWidth;
  final bool loading;

  const AppButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.variant = AppButtonVariant.primary,
    this.icon,
    this.fullWidth = true,
    this.loading = false,
  });

  @override
  Widget build(BuildContext context) {
    final isSecondary = variant == AppButtonVariant.secondary;

    Color bg;
    Color fg;
    BorderSide? border;
    switch (variant) {
      case AppButtonVariant.primary:
        bg = AppColors.primaryBlue;
        fg = Colors.white;
        break;
      case AppButtonVariant.success:
        bg = AppColors.mintGreen;
        fg = Colors.white;
        break;
      case AppButtonVariant.danger:
        bg = AppColors.softCoral;
        fg = Colors.white;
        break;
      case AppButtonVariant.secondary:
        bg = Colors.transparent;
        fg = AppColors.primaryBlue;
        border = const BorderSide(color: AppColors.primaryBlue, width: 1.2);
        break;
    }

    final button = ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: bg,
        foregroundColor: fg,
        elevation: 0,
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: border ?? BorderSide.none,
        ),
      ),
      onPressed: loading ? null : onPressed,
      child: loading
          ? const SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
            )
          : Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (icon != null) ...[
                  Icon(icon, size: 18),
                  const SizedBox(width: 8),
                ],
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: isSecondary ? AppColors.primaryBlue : fg,
                  ),
                ),
              ],
            ),
    );

    return fullWidth ? SizedBox(width: double.infinity, child: button) : button;
  }
}
