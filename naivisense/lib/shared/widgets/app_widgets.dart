import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

class StatusChip extends StatelessWidget {
  final String label;
  final Color? color;
  final Color? backgroundColor;
  final bool selected;
  final VoidCallback? onTap;
  final IconData? icon;

  const StatusChip({
    super.key,
    required this.label,
    this.color,
    this.backgroundColor,
    this.selected = false,
    this.onTap,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final effColor = color ?? AppColors.primaryBlue;
    final effBg = backgroundColor ?? (selected ? effColor.withValues(alpha: 0.12) : AppColors.cardSurface);

    return Material(
      color: effBg,
      borderRadius: BorderRadius.circular(999),
      child: InkWell(
        borderRadius: BorderRadius.circular(999),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(999),
            border: Border.all(
              color: selected ? effColor : AppColors.borderLight,
              width: selected ? 1.2 : 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                Icon(icon, size: 14, color: selected ? effColor : AppColors.textSecondary),
                const SizedBox(width: 4),
              ],
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: selected ? effColor : AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class AppProgressBar extends StatelessWidget {
  final double value;
  final Color color;
  final double height;

  const AppProgressBar({
    super.key,
    required this.value,
    this.color = AppColors.primaryBlue,
    this.height = 8,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(999),
      child: LinearProgressIndicator(
        value: value.clamp(0, 1),
        minHeight: height,
        backgroundColor: color.withValues(alpha: 0.15),
        valueColor: AlwaysStoppedAnimation<Color>(color),
      ),
    );
  }
}

class RatingStars extends StatelessWidget {
  final int value;
  final int max;
  final void Function(int)? onChanged;
  final double size;

  const RatingStars({
    super.key,
    required this.value,
    this.max = 5,
    this.onChanged,
    this.size = 28,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(max, (i) {
        final filled = i < value;
        return GestureDetector(
          onTap: onChanged == null ? null : () => onChanged!(i + 1),
          child: Padding(
            padding: const EdgeInsets.only(right: 4),
            child: Icon(
              filled ? Icons.star_rounded : Icons.star_outline_rounded,
              size: size,
              color: filled ? AppColors.warmYellow : AppColors.borderLight,
            ),
          ),
        );
      }),
    );
  }
}

class SectionHeader extends StatelessWidget {
  final String title;
  final String? action;
  final VoidCallback? onAction;

  const SectionHeader({super.key, required this.title, this.action, this.onAction});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
        ),
        if (action != null)
          TextButton(
            onPressed: onAction,
            child: Text(
              action!,
              style: const TextStyle(fontSize: 13, color: AppColors.primaryBlue, fontWeight: FontWeight.w600),
            ),
          ),
      ],
    );
  }
}

class StatTile extends StatelessWidget {
  final String value;
  final String label;
  final Color color;
  final Color tint;
  final IconData icon;

  const StatTile({
    super.key,
    required this.value,
    required this.label,
    required this.color,
    required this.tint,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: tint,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                value,
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: color),
              ),
              Icon(icon, color: color, size: 20),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(fontSize: 12, color: AppColors.textSecondary, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}

class AvatarCircle extends StatelessWidget {
  final String? emoji;
  final String? initials;
  final double size;
  final Color backgroundColor;

  const AvatarCircle({
    super.key,
    this.emoji,
    this.initials,
    this.size = 44,
    this.backgroundColor = AppColors.blueTint,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(color: backgroundColor, shape: BoxShape.circle),
      alignment: Alignment.center,
      child: Text(
        emoji ?? initials ?? '🙂',
        style: TextStyle(fontSize: size * 0.5, fontWeight: FontWeight.w600),
      ),
    );
  }
}
