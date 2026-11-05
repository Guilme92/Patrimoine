import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';

/// Petite icône « i » qui explique un chiffre calculé.
///
/// Le [Tooltip] s'ouvre au survol (Windows, desktop) et à l'appui long /
/// au tap (mobile).
class InfoHint extends StatelessWidget {
  final String message;
  final double size;

  const InfoHint(this.message, {super.key, this.size = 14});

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: message,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 3),
        child: Icon(
          Icons.info_outline,
          size: size,
          color: AppColors.textSecondary,
        ),
      ),
    );
  }
}

/// Libellé suivi d'une info-bulle explicative.
class LabelWithHint extends StatelessWidget {
  final String label;
  final String message;
  final TextStyle? style;
  final double size;

  const LabelWithHint(
    this.label, {
    super.key,
    required this.message,
    this.style,
    this.size = 14,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Flexible(
          child: Text(
            label,
            style: style ?? Theme.of(context).textTheme.bodySmall,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        InfoHint(message, size: size),
      ],
    );
  }
}
