import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../ad_models.dart';
import '../ads_providers.dart';
import '../ads_repository.dart';

Future<void> maybeShowInterstitialAd(BuildContext context, WidgetRef ref, {int? categoryId}) async {
  final repo = ref.read(adsRepositoryProvider);
  if (repo == null) return;
  if (!ref.read(canShowInterstitialProvider)) return;

  final ad = await ref.read(interstitialAdProvider(categoryId).future);
  if (ad == null) return;

  markInterstitialShown(ref);
  await repo.recordImpression(adId: ad.id);

  if (!context.mounted) return;
  await showDialog<void>(
    context: context,
    barrierDismissible: true,
    builder: (context) => _InterstitialDialog(ad: ad, repo: repo),
  );
}

class _InterstitialDialog extends StatelessWidget {
  const _InterstitialDialog({required this.ad, required this.repo});

  final Ad ad;
  final AdsRepository repo;

  @override
  Widget build(BuildContext context) {
    final imageUrl = repo.resolveImageUrl(ad);

    return Dialog(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            child: AspectRatio(
              aspectRatio: 16 / 9,
              child: Image.network(
                imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => const Center(child: Text('Ad')),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Close'),
                  ),
                ),
                const SizedBox(width: 8),
                FilledButton(
                  onPressed: ad.redirectUrl == null
                      ? null
                      : () async {
                          await repo.handleAdClick(ad);
                          if (context.mounted) Navigator.of(context).pop();
                        },
                  child: const Text('Learn more'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

