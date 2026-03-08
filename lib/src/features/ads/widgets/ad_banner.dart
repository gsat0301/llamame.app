import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../ads_providers.dart';
import '../ads_repository.dart';

class AdBanner extends ConsumerStatefulWidget {
  const AdBanner({super.key, this.categoryId});

  final int? categoryId;

  @override
  ConsumerState<AdBanner> createState() => _AdBannerState();
}

class _AdBannerState extends ConsumerState<AdBanner> {
  String? _recordedAdId;

  @override
  Widget build(BuildContext context) {
    final adAsync = ref.watch(bannerAdProvider(widget.categoryId));
    final repo = ref.watch(adsRepositoryProvider);

    return adAsync.when(
      loading: () => const SizedBox(height: 88),
      error: (_, __) => const SizedBox.shrink(),
      data: (ad) {
        if (ad == null || repo == null) return const SizedBox.shrink();

        if (_recordedAdId != ad.id) {
          _recordedAdId = ad.id;
          // Fire and forget.
          repo.recordImpression(adId: ad.id).ignore();
        }

        final imageUrl = repo.resolveImageUrl(ad);

        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: ad.redirectUrl == null ? null : () => repo.handleAdClick(ad),
            child: Card(
              child: SizedBox(
                height: 88,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Image.network(
                    imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => const Center(child: Text('Ad')),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

extension on Future<void> {
  void ignore() {}
}

