import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../ads_providers.dart';
import '../ads_repository.dart';

/// A tall, full-width hero banner that displays the active "hero" ad.
/// Shows a styled placeholder if no hero ad is available yet.
class HeroBanner extends ConsumerStatefulWidget {
  const HeroBanner({super.key});

  @override
  ConsumerState<HeroBanner> createState() => _HeroBannerState();
}

class _HeroBannerState extends ConsumerState<HeroBanner> {
  String? _recordedAdId;

  @override
  Widget build(BuildContext context) {
    final adAsync = ref.watch(heroAdProvider);
    final repo = ref.watch(adsRepositoryProvider);
    final theme = Theme.of(context);

    return adAsync.when(
      loading: () => _buildPlaceholder(theme),
      error: (_, __) => _buildPlaceholder(theme),
      data: (ad) {
        if (ad == null || repo == null) return _buildPlaceholder(theme);

        // Record impression once
        if (_recordedAdId != ad.id) {
          _recordedAdId = ad.id;
          repo.recordImpression(adId: ad.id).ignore();
        }

        final imageUrl = repo.resolveImageUrl(ad);

        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: ad.redirectUrl == null ? null : () => repo.handleAdClick(ad),
            child: Container(
              height: 200,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.network(
                  imageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => _buildPlaceholderContent(theme),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildPlaceholder(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Container(
        height: 200,
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              theme.colorScheme.primary,
              theme.colorScheme.primary.withValues(alpha: 0.7),
            ],
          ),
        ),
        child: _buildPlaceholderContent(theme),
      ),
    );
  }

  Widget _buildPlaceholderContent(ThemeData theme) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            theme.colorScheme.primary,
            theme.colorScheme.primary.withValues(alpha: 0.7),
          ],
        ),
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.handyman,
            size: 36,
            color: theme.colorScheme.secondary,
          ),
          const SizedBox(height: 12),
          Text(
            'Servicios profesionales',
            style: theme.textTheme.headlineSmall?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Encuentra profesionales de confianza cerca de ti',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: Colors.white70,
            ),
          ),
        ],
      ),
    );
  }
}

extension on Future<void> {
  void ignore() {}
}
