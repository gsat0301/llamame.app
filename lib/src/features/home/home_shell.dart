import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:go_router/go_router.dart';

import '../../core/supabase_client.dart';
import '../ads/widgets/popup_ad.dart';
import '../profile/profile_providers.dart';
import '../profile/profile_screen.dart';
import '../provider/provider_dashboard_screen.dart';
import '../search/service_directory_screen.dart';

class HomeShell extends ConsumerStatefulWidget {
  const HomeShell({super.key});

  @override
  ConsumerState<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends ConsumerState<HomeShell> {
  bool _popupAttempted = false;

  @override
  Widget build(BuildContext context) {
    final client = ref.watch(supabaseClientProvider);
    if (client == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('LlamaMe')),
        body: const SafeArea(
          minimum: EdgeInsets.all(16),
          child: Text(
              'Missing Supabase config. Create a .env file based on .env.example.'),
        ),
      );
    }

    final profileAsync = ref.watch(myProfileProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('LlamaMe'),
        actions: [
          profileAsync.maybeWhen(
            data: (profile) {
              final mode = ref.watch(appModeProvider);
              final canBeProvider = profile.isProvider;
              return SegmentedButton<AppMode>(
                style: ButtonStyle(
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  visualDensity: VisualDensity.compact,
                  padding: WidgetStateProperty.all(
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
                  ),
                ),
                segments: const [
                  ButtonSegment(
                      value: AppMode.customer, label: Text('Cliente')),
                  ButtonSegment(
                      value: AppMode.provider, label: Text('Proveedor')),
                ],
                selected: {mode},
                onSelectionChanged: (selection) {
                  final selected = selection.first;
                  if (selected == AppMode.provider && !canBeProvider) return;
                  ref.read(appModeProvider.notifier).state = selected;
                },
                showSelectedIcon: false,
              );
            },
            orElse: () => const SizedBox.shrink(),
          ),
          IconButton(
            tooltip: 'Salir',
            onPressed: () async => client.auth.signOut(),
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: profileAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error al cargar el perfil: $e')),
        data: (profile) {
          // Trigger popup ad once per session after profile loads
          if (!_popupAttempted) {
            _popupAttempted = true;
            WidgetsBinding.instance.addPostFrameCallback((_) {
              maybeShowPopupAd(context, ref);
            });
          }

          final mode = ref.watch(appModeProvider);
          if (!profile.isProvider && mode == AppMode.provider) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              ref.read(appModeProvider.notifier).state = AppMode.customer;
            });
          }
          final tabs = <Widget>[
            const ServiceDirectoryScreen(),
            const ProfileScreen(),
          ];
          final tabLabels = <NavigationDestination>[
            const NavigationDestination(
                icon: Icon(Icons.search), label: 'Directorio'),
            const NavigationDestination(
                icon: Icon(Icons.person), label: 'Perfil'),
          ];

          // Provider dashboard is visible only in provider mode and if admin approved.
          if (mode == AppMode.provider && profile.isProvider) {
            tabs.insert(1, const ProviderDashboardScreen());
            tabLabels.insert(
                1,
                const NavigationDestination(
                    icon: Icon(Icons.handyman), label: 'Proveedor'));
          }

          final index = ref.watch(_homeTabIndexProvider);
          final safeIndex = index.clamp(0, tabs.length - 1);
          return Column(
            children: [
              Expanded(child: IndexedStack(index: safeIndex, children: tabs)),
              NavigationBar(
                selectedIndex: safeIndex,
                onDestinationSelected: (i) =>
                    ref.read(_homeTabIndexProvider.notifier).state = i,
                destinations: tabLabels,
              ),
              if (!profile.isProvider)
                Material(
                  color: Theme.of(context).colorScheme.surfaceContainerHigh,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
                    child: Row(
                      children: [
                        const Expanded(
                            child: Text(
                                'El modo proveedor está bloqueado. Solicita acceso para cambiar.')),
                        const SizedBox(width: 12),
                        FilledButton(
                          onPressed: () => context.push('/provider-apply'),
                          child: const Text('Solicitar'),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

final _homeTabIndexProvider = StateProvider<int>((ref) => 0);
