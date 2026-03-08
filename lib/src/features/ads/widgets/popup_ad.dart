import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../ad_models.dart';
import '../ads_providers.dart';
import '../ads_repository.dart';

/// Shows a popup ad after login/restart.
/// The HomeShell's _popupAttempted flag prevents duplicate triggers per screen lifecycle.
Future<void> maybeShowPopupAd(BuildContext context, WidgetRef ref) async {
  final repo = ref.read(adsRepositoryProvider);
  if (repo == null) return;

  final ad = await ref.read(popupAdProvider.future);
  if (ad == null) return;

  await repo.recordImpression(adId: ad.id);

  if (!context.mounted) return;
  await showDialog<void>(
    context: context,
    barrierDismissible: true,
    builder: (context) => _PopupAdDialog(ad: ad, repo: repo),
  );
}

class _PopupAdDialog extends StatelessWidget {
  const _PopupAdDialog({required this.ad, required this.repo});

  final Ad ad;
  final AdsRepository repo;

  @override
  Widget build(BuildContext context) {
    final imageUrl = repo.resolveImageUrl(ad);
    final theme = Theme.of(context);

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      clipBehavior: Clip.antiAlias,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Close button row
          Container(
            color: theme.colorScheme.primary,
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: Row(
              children: [
                const SizedBox(width: 8),
                Text(
                  '✨ Oferta Especial',
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close, color: Colors.white, size: 20),
                  visualDensity: VisualDensity.compact,
                ),
              ],
            ),
          ),
          // Image
          AspectRatio(
            aspectRatio: 4 / 3,
            child: Image.network(
              imageUrl,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                color: theme.colorScheme.surfaceContainerHighest,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.campaign,
                          size: 48, color: theme.colorScheme.primary),
                      const SizedBox(height: 8),
                      Text('Oferta Especial', style: theme.textTheme.bodyLarge),
                    ],
                  ),
                ),
              ),
            ),
          ),
          // Action buttons
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Cerrar'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: FilledButton(
                    onPressed: ad.redirectUrl == null
                        ? null
                        : () async {
                            await repo.handleAdClick(ad);
                            if (context.mounted) Navigator.of(context).pop();
                          },
                    child: const Text('Más información'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
