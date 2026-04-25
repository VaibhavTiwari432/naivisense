import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

class AppCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final Color? backgroundColor;
  final VoidCallback? onTap;
  final BorderRadius? borderRadius;
  final Border? border;

  const AppCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.backgroundColor,
    this.onTap,
    this.borderRadius,
    this.border,
  });

  @override
  Widget build(BuildContext context) {
    final radius = borderRadius ?? BorderRadius.circular(16);
    return Material(
      color: backgroundColor ?? AppColors.cardSurface,
      borderRadius: radius,
      child: InkWell(
        borderRadius: radius,
        onTap: onTap,
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            borderRadius: radius,
            border: border ?? Border.all(color: AppColors.borderLight),
          ),
          child: child,
        ),
      ),
    );
  }
}
