import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../ads/widgets/ad_banner.dart';
import '../ads/widgets/hero_banner.dart';
import '../directory/directory_providers.dart';

class ServiceDirectoryScreen extends ConsumerWidget {
  const ServiceDirectoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoriesAsync = ref.watch(categoriesProvider);

    return categoriesAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Error al cargar categorías: $e')),
      data: (categories) {
        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const HeroBanner(),
            Text('Encuentra un proveedor',
                style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 12),
            const AdBanner(),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: categories.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 1.6,
              ),
              itemBuilder: (context, index) {
                final c = categories[index];
                return InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: () => context.push('/category/${c.id}'),
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(14),
                      child: Row(
                        children: [
                          const Icon(Icons.miscellaneous_services),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              c.name,
                              style: Theme.of(context).textTheme.titleMedium,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        );
      },
    );
  }
}
