import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../directory/directory_providers.dart';
import '../profile/profile_providers.dart';
import 'provider_models.dart';
import 'provider_providers.dart';
import 'provider_repository.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProviderDashboardScreen extends ConsumerStatefulWidget {
  const ProviderDashboardScreen({super.key});

  @override
  ConsumerState<ProviderDashboardScreen> createState() =>
      _ProviderDashboardScreenState();
}

class _ProviderDashboardScreenState
    extends ConsumerState<ProviderDashboardScreen> {
  final _headlineController = TextEditingController();
  final _bioController = TextEditingController();
  final _yearsController = TextEditingController();
  bool _saving = false;
  Set<int> _selectedCategoryIds = <int>{};
  bool _detailsHydrated = false;
  bool _servicesHydrated = false;

  @override
  void dispose() {
    _headlineController.dispose();
    _bioController.dispose();
    _yearsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final profileAsync = ref.watch(myProfileProvider);
    final categoriesAsync = ref.watch(categoriesProvider);
    final detailsAsync = ref.watch(myProviderDetailsProvider);
    final myServicesAsync = ref.watch(myServiceCategoryIdsProvider);

    return profileAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Failed: $e')),
      data: (profile) {
        if (!profile.isProvider) {
          return const Center(
              child: Text('Acceso como proveedor no aprobado aún.'));
        }

        // Hydrate form fields once to avoid wiping user input on rebuild.
        detailsAsync.whenData((details) {
          if (_detailsHydrated) return;
          _detailsHydrated = true;
          _headlineController.text = details?.headline ?? '';
          _bioController.text = details?.bio ?? '';
          _yearsController.text = details?.yearsExperience?.toString() ?? '';
        });

        myServicesAsync.whenData((ids) {
          if (_servicesHydrated) return;
          _servicesHydrated = true;
          _selectedCategoryIds = {...ids};
        });

        final galleryAsync = ref.watch(galleryProvider(profile.id));

        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text('Panel de proveedor',
                style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 12),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text('Perfil público',
                        style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _headlineController,
                      decoration: const InputDecoration(labelText: 'Titular'),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _yearsController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                          labelText: 'Años de experiencia'),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _bioController,
                      minLines: 4,
                      maxLines: 8,
                      decoration: const InputDecoration(labelText: 'Bio'),
                    ),
                    const SizedBox(height: 16),
                    FilledButton(
                      onPressed: _saving
                          ? null
                          : () async {
                              final repo = ref.read(providerRepositoryProvider);
                              if (repo == null) return;

                              final years =
                                  int.tryParse(_yearsController.text.trim());
                              setState(() => _saving = true);
                              try {
                                await repo.upsertMyProviderDetails(
                                  headline: _headlineController.text.trim(),
                                  bio: _bioController.text.trim(),
                                  yearsExperience: years,
                                );
                                await repo
                                    .replaceMyServices(_selectedCategoryIds);

                                ref.invalidate(myProviderDetailsProvider);
                                ref.invalidate(myServiceCategoryIdsProvider);
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                        content: Text(
                                            'Perfil de proveedor guardado')),
                                  );
                                }
                              } catch (e) {
                                if (!context.mounted) return;
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                      content: Text('Error al guardar: $e')),
                                );
                              } finally {
                                if (mounted) setState(() => _saving = false);
                              }
                            },
                      child: Text(_saving ? 'Guardando…' : 'Guardar cambios'),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text('Servicios ofrecidos',
                        style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 8),
                    categoriesAsync.when(
                      loading: () => const Padding(
                        padding: EdgeInsets.symmetric(vertical: 12),
                        child: LinearProgressIndicator(),
                      ),
                      error: (e, _) => Text('Error al cargar categorías: $e'),
                      data: (categories) {
                        return Column(
                          children: [
                            for (final c in categories)
                              CheckboxListTile(
                                value: _selectedCategoryIds.contains(c.id),
                                onChanged: (checked) {
                                  setState(() {
                                    if (checked == true) {
                                      _selectedCategoryIds.add(c.id);
                                    } else {
                                      _selectedCategoryIds.remove(c.id);
                                    }
                                  });
                                },
                                title: Text(c.name),
                                controlAffinity:
                                    ListTileControlAffinity.leading,
                                dense: true,
                              ),
                          ],
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Gallery section
            Card(
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Galería de trabajos',
                        style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 4),
                    Text(
                      'Agrega hasta 4 imágenes para mostrar tu trabajo.',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    const SizedBox(height: 12),
                    galleryAsync.when(
                      loading: () =>
                          const Center(child: LinearProgressIndicator()),
                      error: (e, _) => Text('Error al cargar galería: $e'),
                      data: (images) => _GalleryEditor(
                        providerId: profile.id,
                        images: images,
                        onChanged: () =>
                            ref.invalidate(galleryProvider(profile.id)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

// ---------------------------------------------------------------------------
// Gallery editor widget (provider dashboard)
// ---------------------------------------------------------------------------

class _GalleryEditor extends ConsumerWidget {
  const _GalleryEditor({
    required this.providerId,
    required this.images,
    required this.onChanged,
  });

  final String providerId;
  final List<ProviderGalleryImage> images;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Build a map of position → image for easy lookup
    final byPosition = {for (final img in images) img.position: img};

    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 10,
      mainAxisSpacing: 10,
      children: List.generate(4, (position) {
        final img = byPosition[position];
        if (img != null) {
          return _GallerySlotFilled(
            image: img,
            onDelete: () async {
              final repo = ref.read(providerRepositoryProvider);
              if (repo == null) return;
              try {
                await repo.deleteGalleryImage(img.id);
                onChanged();
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error al eliminar: $e')),
                  );
                }
              }
            },
          );
        } else {
          return _GallerySlotEmpty(
            position: position,
            providerId: providerId,
            onAdded: onChanged,
          );
        }
      }),
    );
  }
}

class _GallerySlotFilled extends StatelessWidget {
  const _GallerySlotFilled({required this.image, required this.onDelete});

  final ProviderGalleryImage image;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: Image.network(
            image.imageUrl,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => Container(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              child: const Icon(Icons.broken_image, size: 40),
            ),
          ),
        ),
        Positioned(
          top: 4,
          right: 4,
          child: GestureDetector(
            onTap: () async {
              final confirmed = await showDialog<bool>(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text('Eliminar imagen'),
                  content: const Text('¿Eliminar esta imagen de tu galería?'),
                  actions: [
                    TextButton(
                        onPressed: () => Navigator.pop(ctx, false),
                        child: const Text('Cancelar')),
                    FilledButton(
                        onPressed: () => Navigator.pop(ctx, true),
                        child: const Text('Eliminar')),
                  ],
                ),
              );
              if (confirmed == true) onDelete();
            },
            child: Container(
              decoration: BoxDecoration(
                color: Colors.black54,
                borderRadius: BorderRadius.circular(20),
              ),
              padding: const EdgeInsets.all(4),
              child: const Icon(Icons.close, color: Colors.white, size: 16),
            ),
          ),
        ),
      ],
    );
  }
}

class _GallerySlotEmpty extends ConsumerStatefulWidget {
  const _GallerySlotEmpty({
    required this.position,
    required this.providerId,
    required this.onAdded,
  });

  final int position;
  final String providerId;
  final VoidCallback onAdded;

  @override
  ConsumerState<_GallerySlotEmpty> createState() => _GallerySlotEmptyState();
}

class _GallerySlotEmptyState extends ConsumerState<_GallerySlotEmpty> {
  bool _loading = false;

  Future<void> _addImage() async {
    final picker = ImagePicker();
    final supabase = Supabase.instance.client;

    // 1. Seleccionar la imagen del dispositivo
    final XFile? pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 70, // Optimiza el tamaño para tu MVP
    );

    if (pickedFile == null) return; // El usuario canceló

    final repo = ref.read(providerRepositoryProvider);
    if (repo == null) return;

    setState(() => _loading = true);

    try {
      final file = File(pickedFile.path);
      final fileExt = pickedFile.path.split('.').last;
      // Carpeta: userId, Nombre: timestamp + extensión
      final fileName = '${DateTime.now().millisecondsSinceEpoch}.$fileExt';
      final path = '${widget.providerId}/$fileName';

      // 2. Subir a Supabase Storage
      await supabase.storage.from('provider-gallery').upload(
            path,
            file,
            fileOptions: const FileOptions(upsert: true),
          );

      // 3. Obtener la URL pública generada
      final String publicUrl =
          supabase.storage.from('provider-gallery').getPublicUrl(path);

      // 4. Guardar esa URL en tu tabla de base de datos
      await repo.addGalleryImage(
        imageUrl: publicUrl,
        position: widget.position,
      );

      widget.onAdded(); // Refresca la galería en la UI
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al subir imagen: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _loading ? null : _addImage,
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(
            color: Theme.of(context).colorScheme.outlineVariant,
            width: 1.5,
          ),
          borderRadius: BorderRadius.circular(10),
          color: Theme.of(context).colorScheme.surfaceContainerLowest,
        ),
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.add_photo_alternate_outlined,
                    size: 36,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Agregar imagen',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.primary,
                        ),
                  ),
                ],
              ),
      ),
    );
  }
}
