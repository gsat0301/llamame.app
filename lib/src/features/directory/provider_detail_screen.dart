import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../provider/provider_providers.dart';
import '../provider/provider_repository.dart';
import 'directory_providers.dart';

class ProviderDetailScreen extends ConsumerWidget {
  const ProviderDetailScreen({super.key, required this.providerId});

  final String providerId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final providerAsync = ref.watch(providerByIdProvider(providerId));
    final galleryAsync = ref.watch(galleryProvider(providerId));
    final ratingsAsync = ref.watch(ratingsProvider(providerId));

    return Scaffold(
      appBar: AppBar(title: const Text('Proveedor')),
      body: providerAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error al cargar proveedor: $e')),
        data: (p) {
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Header
              Row(
                children: [
                  CircleAvatar(
                    radius: 34,
                    child: Text((p.fullName.isEmpty ? '?' : p.fullName[0])
                        .toUpperCase()),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(p.fullName,
                            style: Theme.of(context).textTheme.titleLarge),
                        if (p.headline != null && p.headline!.trim().isNotEmpty)
                          Text(p.headline!,
                              style: Theme.of(context).textTheme.bodyMedium),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 10,
                          runSpacing: 6,
                          children: [
                            if (p.averageRating != null)
                              Chip(
                                  label: Text(
                                      '⭐ ${p.averageRating!.toStringAsFixed(1)}')),
                            if (p.jobsCompleted != null)
                              Chip(label: Text('${p.jobsCompleted} trabajos')),
                            if (p.city != null) Chip(label: Text(p.city!)),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),

              // About
              if (p.yearsExperience != null ||
                  (p.bio != null && p.bio!.trim().isNotEmpty)) ...[
                Text('Acerca de',
                    style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 8),
                if (p.yearsExperience != null)
                  Text('Experiencia: ${p.yearsExperience} años'),
                if (p.bio != null && p.bio!.trim().isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Text(p.bio!),
                ],
                const SizedBox(height: 18),
              ],

              // Gallery
              galleryAsync.when(
                loading: () => const SizedBox.shrink(),
                error: (_, __) => const SizedBox.shrink(),
                data: (images) {
                  if (images.isEmpty) return const SizedBox.shrink();
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Galería de trabajos',
                          style: Theme.of(context).textTheme.titleMedium),
                      const SizedBox(height: 10),
                      GridView.count(
                        crossAxisCount: 2,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        crossAxisSpacing: 8,
                        mainAxisSpacing: 8,
                        children: images.map((img) {
                          return ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Image.network(
                              img.imageUrl,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => Container(
                                color: Theme.of(context)
                                    .colorScheme
                                    .surfaceContainerHighest,
                                child: const Icon(Icons.broken_image, size: 40),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 18),
                    ],
                  );
                },
              ),

              // Ratings summary
              ratingsAsync.when(
                loading: () => const SizedBox.shrink(),
                error: (_, __) => const SizedBox.shrink(),
                data: (ratings) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Calificaciones',
                          style: Theme.of(context).textTheme.titleMedium),
                      const SizedBox(height: 8),
                      if (ratings.isEmpty)
                        Text(
                          'Aún no hay calificaciones. ¡Sé el primero en calificar!',
                          style: Theme.of(context).textTheme.bodySmall,
                        )
                      else
                        _RatingSummary(
                            ratings: ratings.map((r) => r.stars).toList()),
                      const SizedBox(height: 12),
                      FilledButton.icon(
                        onPressed: () => _showRatingSheet(context, ref),
                        icon: const Icon(Icons.star_outline),
                        label: const Text('Calificar a este proveedor'),
                      ),
                      const SizedBox(height: 18),
                    ],
                  );
                },
              ),

              // Contact
              Text('Contacto', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 10),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  FilledButton.icon(
                    onPressed:
                        p.phone == null ? null : () => _launchTel(p.phone!),
                    icon: const Icon(Icons.call),
                    label: const Text('Llamar'),
                  ),
                  FilledButton.icon(
                    onPressed: p.phone == null
                        ? null
                        : () => _launchWhatsApp(p.phone!),
                    icon: const Icon(Icons.chat),
                    label: const Text('WhatsApp'),
                  ),
                ],
              ),
              const SizedBox(height: 18),

              // Location
              Text('Ubicación', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              Text([
                if (p.city != null) p.city,
                if (p.region != null) p.region,
                if (p.country != null) p.country,
              ].whereType<String>().join(', ').ifEmpty('No proporcionada')),
            ],
          );
        },
      ),
    );
  }

  void _showRatingSheet(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => _RatingSheet(
        providerId: providerId,
        onSubmitted: () {
          ref.invalidate(ratingsProvider(providerId));
          ref.invalidate(providerByIdProvider(providerId));
        },
      ),
    );
  }

  Future<void> _launchTel(String phone) async {
    final cleaned = phone.trim();
    final uri = Uri(scheme: 'tel', path: cleaned);
    await launchUrl(uri);
  }

  Future<void> _launchWhatsApp(String phone) async {
    final digits = phone.replaceAll(RegExp(r'[^0-9]'), '');
    final uri = Uri.parse('https://wa.me/$digits');
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }
}

// ---------------------------------------------------------------------------
// Rating summary (star bar)
// ---------------------------------------------------------------------------

class _RatingSummary extends StatelessWidget {
  const _RatingSummary({required this.ratings});

  final List<int> ratings;

  @override
  Widget build(BuildContext context) {
    final avg = ratings.isEmpty
        ? 0.0
        : ratings.reduce((a, b) => a + b) / ratings.length;
    final fullStars = avg.floor();
    final hasHalf = (avg - fullStars) >= 0.5;

    return Row(
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(5, (i) {
            if (i < fullStars) {
              return const Icon(Icons.star, color: Colors.amber, size: 22);
            } else if (i == fullStars && hasHalf) {
              return const Icon(Icons.star_half, color: Colors.amber, size: 22);
            } else {
              return const Icon(Icons.star_border,
                  color: Colors.amber, size: 22);
            }
          }),
        ),
        const SizedBox(width: 8),
        Text(
          '${avg.toStringAsFixed(1)} (${ratings.length} ${ratings.length == 1 ? 'reseña' : 'reseñas'})',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Rating bottom sheet
// ---------------------------------------------------------------------------

class _RatingSheet extends ConsumerStatefulWidget {
  const _RatingSheet({required this.providerId, required this.onSubmitted});

  final String providerId;
  final VoidCallback onSubmitted;

  @override
  ConsumerState<_RatingSheet> createState() => _RatingSheetState();
}

class _RatingSheetState extends ConsumerState<_RatingSheet> {
  int _selectedStars = 0;
  final _commentController = TextEditingController();
  bool _submitting = false;

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_selectedStars == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content:
                Text('Por favor selecciona una calificación de estrellas.')),
      );
      return;
    }

    final repo = ref.read(providerRepositoryProvider);
    if (repo == null) return;

    setState(() => _submitting = true);
    try {
      await repo.submitRating(
        providerId: widget.providerId,
        stars: _selectedStars,
        comment: _commentController.text.trim().isEmpty
            ? null
            : _commentController.text.trim(),
      );
      widget.onSubmitted();
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('¡Gracias por tu calificación!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al enviar la calificación: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Calificar a este proveedor',
              style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 4),
          Text(
            'Tu comentario permanecerá privado.',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 20),
          // Star picker
          Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(5, (i) {
                final star = i + 1;
                return GestureDetector(
                  onTap: () => setState(() => _selectedStars = star),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Icon(
                      star <= _selectedStars ? Icons.star : Icons.star_border,
                      color: Colors.amber,
                      size: 40,
                    ),
                  ),
                );
              }),
            ),
          ),
          const SizedBox(height: 8),
          Center(
            child: Text(
              _selectedStars == 0
                  ? 'Toca una estrella para calificar'
                  : [
                      '',
                      'Malo',
                      'Regular',
                      'Bueno',
                      'Muy bueno',
                      'Excelente'
                    ][_selectedStars],
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ),
          const SizedBox(height: 20),
          TextField(
            controller: _commentController,
            minLines: 3,
            maxLines: 5,
            decoration: const InputDecoration(
              labelText: 'Comentario (opcional)',
              hintText: 'Comparte tu experiencia…',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: _submitting ? null : _submit,
              child: Text(_submitting ? 'Enviando…' : 'Enviar calificación'),
            ),
          ),
        ],
      ),
    );
  }
}

extension _StringX on String {
  String ifEmpty(String fallback) => trim().isEmpty ? fallback : this;
}
