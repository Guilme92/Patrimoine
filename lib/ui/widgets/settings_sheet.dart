import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../controllers/portfolio_controller.dart';
import '../../theme/app_theme.dart';

/// Ouvre la feuille « Réglages » depuis n'importe quel écran de l'app.
Future<void> showSettingsSheet(BuildContext context) {
  return showModalBottomSheet<void>(
    context: context,
    backgroundColor: Colors.transparent,
    builder: (_) => const SettingsSheet(),
  );
}

/// Réglages de l'interface : taille de police globale.
///
/// La feuille lit l'échelle courante sur le [PortfolioController] et la lui
/// transmet à chaque déplacement du curseur : la police de toute l'app est
/// ré-appliquée en direct, et le choix est persisté en base.
class SettingsSheet extends StatelessWidget {
  const SettingsSheet({super.key});

  static const String title = 'Réglages';

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<PortfolioController>();
    final scale = controller.fontScale;
    final percent = '${(scale * 100).round()} %';

    return SafeArea(
      top: false,
      child: Container(
        margin: const EdgeInsets.all(12),
        padding: const EdgeInsets.fromLTRB(20, 14, 20, 16),
        decoration: cardDecoration(),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.tune, size: 18, color: AppColors.primary),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  tooltip: 'Fermer',
                  icon: const Icon(Icons.close, size: 18),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(
                  Icons.text_fields,
                  size: 16,
                  color: AppColors.textSecondary,
                ),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text(
                    'Taille de police',
                    style: TextStyle(
                      fontSize: 13,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                Text(
                  percent,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
            Slider(
              value: scale,
              min: fontScaleMin,
              max: fontScaleMax,
              divisions: 13,
              label: percent,
              onChanged: controller.setFontScale,
            ),
            const Text(
              'Agrandit le texte de l’application, y compris les cellules '
              'compactes des onglets Immobilier et Bourse et Crypto.',
              style: TextStyle(
                fontSize: 11,
                height: 1.35,
                color: AppColors.textSecondary,
              ),
            ),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () => controller.setFontScale(1.0),
                child: const Text('Taille par défaut'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
