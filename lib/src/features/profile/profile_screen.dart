import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'profile_providers.dart';
import 'profile_repository.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _cityController = TextEditingController();
  final _regionController = TextEditingController();
  final _countryController = TextEditingController();
  bool _saving = false;

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _cityController.dispose();
    _regionController.dispose();
    _countryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final profileAsync = ref.watch(myProfileProvider);
    final latestReqAsync = ref.watch(latestProviderRequestProvider);

    return profileAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Failed: $e')),
      data: (profile) {
        _nameController.text = profile.fullName ?? '';
        _phoneController.text = profile.phone ?? '';
        _cityController.text = profile.city ?? '';
        _regionController.text = profile.region ?? '';
        _countryController.text = profile.country ?? '';

        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text('Account', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 12),
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Nombre completo'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(labelText: 'Teléfono'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _cityController,
              decoration: const InputDecoration(labelText: 'Ciudad'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _regionController,
              decoration: const InputDecoration(labelText: 'Estado/Región'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _countryController,
              decoration: const InputDecoration(labelText: 'País'),
            ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: _saving
                  ? null
                  : () async {
                      final repo = ref.read(profileRepositoryProvider);
                      if (repo == null) return;
                      setState(() => _saving = true);
                      try {
                        await repo.updateMyProfile(
                          fullName: _nameController.text.trim(),
                          phone: _phoneController.text.trim(),
                          city: _cityController.text.trim(),
                          region: _regionController.text.trim(),
                          country: _countryController.text.trim(),
                        );
                        ref.invalidate(myProfileProvider);
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Perfil guardado')),
                          );
                        }
                      } catch (e) {
                        if (!context.mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Error al guardar: $e')),
                        );
                      } finally {
                        if (mounted) setState(() => _saving = false);
                      }
                    },
              child: Text(_saving ? 'Guardando…' : 'Guardar'),
            ),
            if (profile.isAdmin) ...[
              const SizedBox(height: 16),
              FilledButton.tonalIcon(
                onPressed: () => context.push('/admin'),
                icon: const Icon(Icons.admin_panel_settings),
                label: const Text('Gestionar solicitudes de proveedores'),
              ),
            ],
            const SizedBox(height: 24),
            Text('Rol', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            Text(
                'Acceso como proveedor: ${profile.isProvider ? 'Aprobado' : 'No aprobado'}'),
            const SizedBox(height: 8),
            latestReqAsync.when(
              loading: () =>
                  const Text('Consultando última solicitud de proveedor…'),
              error: (e, _) => Text('Error al consultar solicitud: $e'),
              data: (req) {
                if (req == null) {
                  return const Text('No se ha enviado solicitud de proveedor.');
                }
                return Text(
                    'Última solicitud: ${req.status} (enviada ${req.createdAt.toLocal()})');
              },
            ),
            const SizedBox(height: 24),
            //Text('Debug', style: Theme.of(context).textTheme.titleLarge),
            //const SizedBox(height: 8),
            //Text(
            //    'User id: ${ref.read(supabaseClientProvider)!.auth.currentUser?.id}'),
          ],
        );
      },
    );
  }
}
