import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../ads/widgets/ad_banner.dart';
import '../ads/widgets/ad_interstitial.dart';
import 'directory_providers.dart';

class ProvidersListScreen extends ConsumerStatefulWidget {
  const ProvidersListScreen({super.key, required this.categoryId});

  final int categoryId;

  @override
  ConsumerState<ProvidersListScreen> createState() =>
      _ProvidersListScreenState();
}

class _ProvidersListScreenState extends ConsumerState<ProvidersListScreen> {
  bool _attemptedInterstitial = false;

  @override
  Widget build(BuildContext context) {
    final providersAsync =
        ref.watch(providersForCategoryProvider(widget.categoryId));

    // Attempt one interstitial per app session (MVP).
    if (!_attemptedInterstitial) {
      _attemptedInterstitial = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        maybeShowInterstitialAd(context, ref, categoryId: widget.categoryId);
      });
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Profesionales')),
      body: providersAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) =>
            Center(child: Text('Error al cargar profesionales: $e')),
        data: (providers) {
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: providers.isEmpty ? 2 : providers.length + 1,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              if (index == 0) {
                return AdBanner(categoryId: widget.categoryId);
              }

              if (providers.isEmpty && index == 1) {
                return const Padding(
                  padding: EdgeInsets.symmetric(vertical: 40),
                  child:
                      Center(child: Text('No se encontraron profesionales.')),
                );
              }

              final p = providers[index - 1];
              return InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: () => context.push('/provider/${p.id}'),
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 24,
                          child: Text((p.fullName.isEmpty ? '?' : p.fullName[0])
                              .toUpperCase()),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(p.fullName,
                                  style:
                                      Theme.of(context).textTheme.titleMedium),
                              if (p.headline != null &&
                                  p.headline!.trim().isNotEmpty) ...[
                                const SizedBox(height: 2),
                                Text(p.headline!,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis),
                              ],
                              const SizedBox(height: 6),
                              Wrap(
                                spacing: 10,
                                runSpacing: 6,
                                children: [
                                  if (p.averageRating != null)
                                    _chip(
                                        '⭐ ${p.averageRating!.toStringAsFixed(1)}'),
                                  if (p.jobsCompleted != null)
                                    _chip('${p.jobsCompleted} trabajos'),
                                  if (p.city != null) _chip(p.city!),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const Icon(Icons.chevron_right),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _chip(String text) => Chip(label: Text(text));
}
