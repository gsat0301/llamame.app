import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../ads/ad_models.dart';
import '../ads/ads_repository.dart';
import '../profile/profile_providers.dart';
import 'admin_models.dart';
import 'admin_providers.dart';
import 'admin_repository.dart';

class AdminScreen extends ConsumerWidget {
  const AdminScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(myProfileProvider);
    final requestsAsync = ref.watch(providerRequestsProvider);
    final ratingsAsync = ref.watch(allRatingsProvider);
    final adsAsync = ref.watch(allAdsProvider);

    return profileAsync.when(
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (e, _) => Scaffold(
        appBar: AppBar(title: const Text('Admin')),
        body: Center(child: Text('Failed to load profile: $e')),
      ),
      data: (profile) {
        if (!profile.isAdmin) {
          return Scaffold(
            appBar: AppBar(title: const Text('Admin')),
            body: const Center(child: Text('Access denied. Admin only.')),
          );
        }

        return requestsAsync.when(
          loading: () =>
              const Scaffold(body: Center(child: CircularProgressIndicator())),
          error: (e, _) => Scaffold(
            appBar: AppBar(title: const Text('Admin')),
            body: Center(child: Text('Failed to load requests: $e')),
          ),
          data: (requests) {
            final pending = requests.where((r) => r.isPending).toList();

            return DefaultTabController(
              length: 4,
              child: Scaffold(
                appBar: AppBar(
                  title: const Text('Admin panel'),
                  leading: IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: () => context.pop(),
                  ),
                  bottom: TabBar(
                    isScrollable: true,
                    tabs: [
                      Tab(text: 'Pending (${pending.length})'),
                      const Tab(text: 'All requests'),
                      const Tab(text: 'Ratings'),
                      const Tab(text: 'Ads'),
                    ],
                  ),
                ),
                body: TabBarView(
                  children: [
                    _RequestList(
                      requests: pending,
                      onResolved: () =>
                          ref.invalidate(providerRequestsProvider),
                    ),
                    _RequestList(
                      requests: requests,
                      onResolved: () =>
                          ref.invalidate(providerRequestsProvider),
                    ),
                    ratingsAsync.when(
                      loading: () =>
                          const Center(child: CircularProgressIndicator()),
                      error: (e, _) =>
                          Center(child: Text('Failed to load ratings: $e')),
                      data: (ratings) => _RatingsList(ratings: ratings),
                    ),
                    adsAsync.when(
                      loading: () =>
                          const Center(child: CircularProgressIndicator()),
                      error: (e, _) =>
                          Center(child: Text('Failed to load ads: $e')),
                      data: (ads) => _AdsManagement(
                        ads: ads,
                        onChanged: () => ref.invalidate(allAdsProvider),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}

// ---------------------------------------------------------------------------
// Provider requests list
// ---------------------------------------------------------------------------

class _RequestList extends ConsumerWidget {
  const _RequestList({required this.requests, required this.onResolved});

  final List<AdminProviderRequest> requests;
  final VoidCallback onResolved;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (requests.isEmpty) {
      return const Center(child: Text('No requests in this list.'));
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: requests.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final r = requests[index];
        return _RequestCard(request: r, onResolved: onResolved);
      },
    );
  }
}

class _RequestCard extends ConsumerStatefulWidget {
  const _RequestCard({required this.request, required this.onResolved});

  final AdminProviderRequest request;
  final VoidCallback onResolved;

  @override
  ConsumerState<_RequestCard> createState() => _RequestCardState();
}

class _RequestCardState extends ConsumerState<_RequestCard> {
  bool _loading = false;

  Future<void> _resolve(bool approve) async {
    final repo = ref.read(adminRepositoryProvider);
    if (repo == null) return;

    setState(() => _loading = true);
    try {
      await repo.resolveProviderRequest(widget.request.id, approve);
      widget.onResolved();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(approve ? 'Request approved' : 'Request rejected')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final r = widget.request;
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    r.applicantName?.trim().isNotEmpty == true
                        ? r.applicantName!
                        : 'Unknown',
                    style: theme.textTheme.titleMedium,
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: r.status == 'pending'
                        ? theme.colorScheme.primaryContainer
                        : r.status == 'approved'
                            ? theme.colorScheme.tertiaryContainer
                            : theme.colorScheme.errorContainer,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    r.status,
                    style: theme.textTheme.labelSmall,
                  ),
                ),
              ],
            ),
            if (r.applicantPhone != null && r.applicantPhone!.trim().isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child:
                    Text(r.applicantPhone!, style: theme.textTheme.bodySmall),
              ),
            if (r.motivation != null && r.motivation!.trim().isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(r.motivation!,
                  style: theme.textTheme.bodyMedium,
                  maxLines: 4,
                  overflow: TextOverflow.ellipsis),
            ],
            const SizedBox(height: 8),
            Text(
              'Submitted ${r.createdAt.toLocal().toString().split('.')[0]}',
              style: theme.textTheme.bodySmall,
            ),
            if (r.isPending) ...[
              const SizedBox(height: 12),
              Wrap(
                alignment: WrapAlignment.end,
                spacing: 8,
                runSpacing: 8,
                children: [
                  TextButton(
                    onPressed: _loading ? null : () => _resolve(false),
                    child: const Text('Reject'),
                  ),
                  FilledButton(
                    onPressed: _loading ? null : () => _resolve(true),
                    child: const Text('Approve'),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Ratings list (admin only — shows comments)
// ---------------------------------------------------------------------------

class _RatingsList extends StatelessWidget {
  const _RatingsList({required this.ratings});

  final List<AdminRating> ratings;

  @override
  Widget build(BuildContext context) {
    if (ratings.isEmpty) {
      return const Center(child: Text('No ratings yet.'));
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: ratings.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final r = ratings[index];
        return _RatingCard(rating: r);
      },
    );
  }
}

class _RatingCard extends StatelessWidget {
  const _RatingCard({required this.rating});

  final AdminRating rating;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final stars = rating.stars;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Provider: ${rating.providerName ?? 'Unknown'}',
                        style: theme.textTheme.titleSmall,
                      ),
                      Text(
                        'Customer: ${rating.customerName ?? 'Unknown'}',
                        style: theme.textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
                // Star display
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: List.generate(5, (i) {
                    return Icon(
                      i < stars ? Icons.star : Icons.star_border,
                      color: Colors.amber,
                      size: 18,
                    );
                  }),
                ),
              ],
            ),
            if (rating.comment != null &&
                rating.comment!.trim().isNotEmpty) ...[
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  rating.comment!,
                  style: theme.textTheme.bodyMedium,
                ),
              ),
            ] else ...[
              const SizedBox(height: 4),
              Text('No comment left.',
                  style: theme.textTheme.bodySmall
                      ?.copyWith(fontStyle: FontStyle.italic)),
            ],
            const SizedBox(height: 6),
            Text(
              rating.createdAt.toLocal().toString().split('.')[0],
              style: theme.textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Ads management (admin)
// ---------------------------------------------------------------------------

class _AdsManagement extends ConsumerWidget {
  const _AdsManagement({required this.ads, required this.onChanged});

  final List<Ad> ads;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      children: [
        // Create new ad button
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: () => _showAdDialog(context, ref, null),
              icon: const Icon(Icons.add),
              label: const Text('Create new ad'),
            ),
          ),
        ),
        if (ads.isEmpty)
          const Expanded(
              child: Center(child: Text('No ads yet. Create your first ad!')))
        else
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: ads.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final ad = ads[index];
                return _AdCard(
                  ad: ad,
                  onEdit: () => _showAdDialog(context, ref, ad),
                  onDelete: () => _confirmDelete(context, ref, ad),
                  onToggle: () => _toggleActive(ref, ad),
                );
              },
            ),
          ),
      ],
    );
  }

  void _showAdDialog(BuildContext context, WidgetRef ref, Ad? existing) {
    showDialog(
      context: context,
      builder: (ctx) => _AdFormDialog(
        existing: existing,
        onSaved: onChanged,
      ),
    );
  }

  Future<void> _confirmDelete(
      BuildContext context, WidgetRef ref, Ad ad) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete ad'),
        content: const Text('Are you sure you want to delete this ad?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancel')),
          FilledButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Delete')),
        ],
      ),
    );

    if (confirmed != true) return;

    final repo = ref.read(adminRepositoryProvider);
    if (repo == null) return;

    try {
      await repo.deleteAd(ad.id);
      onChanged();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Ad deleted')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Delete failed: $e')),
        );
      }
    }
  }

  Future<void> _toggleActive(WidgetRef ref, Ad ad) async {
    final repo = ref.read(adminRepositoryProvider);
    if (repo == null) return;
    try {
      await repo.updateAd(id: ad.id, isActive: !ad.isActive);
      onChanged();
    } catch (_) {}
  }
}

class _AdCard extends ConsumerWidget {
  const _AdCard({
    required this.ad,
    required this.onEdit,
    required this.onDelete,
    required this.onToggle,
  });

  final Ad ad;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onToggle;

  String _typeLabel(AdType type) {
    switch (type) {
      case AdType.banner:
        return 'Banner';
      case AdType.interstitial:
        return 'Interstitial';
      case AdType.hero:
        return 'Hero';
      case AdType.popup:
        return 'Pop-up';
    }
  }

  Color _typeBadgeColor(AdType type, ThemeData theme) {
    switch (type) {
      case AdType.hero:
        return theme.colorScheme.secondary;
      case AdType.popup:
        return theme.colorScheme.tertiary;
      case AdType.banner:
        return theme.colorScheme.primaryContainer;
      case AdType.interstitial:
        return theme.colorScheme.tertiaryContainer;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image thumbnail
            GestureDetector(
              onTap: ad.redirectUrl == null
                  ? null
                  : () => ref.read(adsRepositoryProvider)?.handleAdClick(ad),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: SizedBox(
                  width: 80,
                  height: 60,
                  child: Consumer(
                    builder: (context, ref, _) {
                      final repo = ref.watch(adsRepositoryProvider);
                      final url = repo != null ? repo.resolveImageUrl(ad) : '';
                      return Image.network(
                        url,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          color: theme.colorScheme.surfaceContainerHighest,
                          child: const Icon(Icons.image, size: 24),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: _typeBadgeColor(ad.type, theme),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          _typeLabel(ad.type),
                          style: theme.textTheme.labelSmall
                              ?.copyWith(fontWeight: FontWeight.w600),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: ad.isActive
                              ? Colors.green.shade100
                              : Colors.red.shade100,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          ad.isActive ? 'Active' : 'Inactive',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: ad.isActive
                                ? Colors.green.shade800
                                : Colors.red.shade800,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (ad.redirectUrl != null && ad.redirectUrl!.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      ad.redirectUrl!,
                      style: theme.textTheme.bodySmall,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
            // Actions
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  onPressed: onToggle,
                  icon: Icon(
                    ad.isActive ? Icons.visibility : Icons.visibility_off,
                    size: 20,
                  ),
                  tooltip: ad.isActive ? 'Deactivate' : 'Activate',
                  visualDensity: VisualDensity.compact,
                ),
                IconButton(
                  onPressed: onEdit,
                  icon: const Icon(Icons.edit, size: 20),
                  tooltip: 'Edit',
                  visualDensity: VisualDensity.compact,
                ),
                IconButton(
                  onPressed: onDelete,
                  icon: Icon(Icons.delete_outline,
                      size: 20, color: theme.colorScheme.error),
                  tooltip: 'Delete',
                  visualDensity: VisualDensity.compact,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Create / Edit ad dialog
// ---------------------------------------------------------------------------

class _AdFormDialog extends ConsumerStatefulWidget {
  const _AdFormDialog({this.existing, required this.onSaved});

  final Ad? existing;
  final VoidCallback onSaved;

  @override
  ConsumerState<_AdFormDialog> createState() => _AdFormDialogState();
}

class _AdFormDialogState extends ConsumerState<_AdFormDialog> {
  late AdType _selectedType;
  final _redirectUrlController = TextEditingController();
  bool _isActive = true;
  bool _saving = false;
  XFile? _pickedImage;
  String? _existingImageUrl;

  @override
  void initState() {
    super.initState();
    final existing = widget.existing;
    _selectedType = existing?.type ?? AdType.banner;
    _redirectUrlController.text = existing?.redirectUrl ?? '';
    _isActive = existing?.isActive ?? true;
    _existingImageUrl = existing?.imageUrl;
  }

  @override
  void dispose() {
    _redirectUrlController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final file =
        await picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
    if (file != null) {
      setState(() => _pickedImage = file);
    }
  }

  Future<void> _save() async {
    final repo = ref.read(adminRepositoryProvider);
    if (repo == null) return;

    // For new ads, image is required.
    if (widget.existing == null && _pickedImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select an image for the ad.')),
      );
      return;
    }

    setState(() => _saving = true);
    try {
      String imageUrl = _existingImageUrl ?? '';

      // Upload new image if picked
      if (_pickedImage != null) {
        final bytes = await _pickedImage!.readAsBytes();
        final name = _pickedImage!.name;
        imageUrl = await repo.uploadAdImage(bytes: bytes, fileName: name);
      }

      if (widget.existing != null) {
        // Update
        await repo.updateAd(
          id: widget.existing!.id,
          type: _selectedType,
          imageUrl: imageUrl,
          redirectUrl: _redirectUrlController.text.trim(),
          isActive: _isActive,
        );
      } else {
        // Create
        await repo.createAd(
          type: _selectedType,
          imageUrl: imageUrl,
          redirectUrl: _redirectUrlController.text.trim().isEmpty
              ? null
              : _redirectUrlController.text.trim(),
          isActive: _isActive,
        );
      }

      widget.onSaved();
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content:
                  Text(widget.existing != null ? 'Ad updated' : 'Ad created')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isEditing = widget.existing != null;

    return Dialog(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                isEditing ? 'Edit Ad' : 'Create New Ad',
                style: theme.textTheme.titleLarge,
              ),
              const SizedBox(height: 20),

              // Type selector
              Text('Ad Type', style: theme.textTheme.labelLarge),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 4,
                children: [
                  for (final entry in const [
                    (AdType.banner, 'Banner'),
                    (AdType.hero, 'Hero'),
                    (AdType.interstitial, 'Interstitial'),
                    (AdType.popup, 'Pop-up'),
                  ])
                    ChoiceChip(
                      label: Text(entry.$2),
                      selected: _selectedType == entry.$1,
                      onSelected: (_) =>
                          setState(() => _selectedType = entry.$1),
                      showCheckmark: false,
                    ),
                ],
              ),
              const SizedBox(height: 16),

              // Image picker
              Text('Image', style: theme.textTheme.labelLarge),
              const SizedBox(height: 8),
              InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: _pickImage,
                child: Container(
                  height: 140,
                  decoration: BoxDecoration(
                    border: Border.all(color: theme.colorScheme.outlineVariant),
                    borderRadius: BorderRadius.circular(12),
                    color: theme.colorScheme.surfaceContainerLowest,
                  ),
                  child: _pickedImage != null
                      ? FutureBuilder<List<int>>(
                          future: _pickedImage!.readAsBytes(),
                          builder: (ctx, snap) {
                            if (!snap.hasData) {
                              return const Center(
                                  child: CircularProgressIndicator());
                            }
                            return ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.memory(
                                snap.data! as dynamic,
                                fit: BoxFit.cover,
                                width: double.infinity,
                              ),
                            );
                          },
                        )
                      : _existingImageUrl != null &&
                              _existingImageUrl!.startsWith('http')
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.network(
                                _existingImageUrl!,
                                fit: BoxFit.cover,
                                width: double.infinity,
                                errorBuilder: (_, __, ___) =>
                                    _imagePlaceholder(theme),
                              ),
                            )
                          : _imagePlaceholder(theme),
                ),
              ),
              const SizedBox(height: 16),

              // Redirect URL
              TextField(
                controller: _redirectUrlController,
                decoration: const InputDecoration(
                  labelText: 'Redirect URL (optional)',
                  hintText: 'https://example.com',
                ),
              ),
              const SizedBox(height: 16),

              // Active toggle
              SwitchListTile(
                value: _isActive,
                onChanged: (v) => setState(() => _isActive = v),
                title: const Text('Active'),
                subtitle: const Text('Inactive ads won\'t be shown to users'),
                contentPadding: EdgeInsets.zero,
              ),
              const SizedBox(height: 20),

              // Action buttons
              Wrap(
                alignment: WrapAlignment.end,
                spacing: 8,
                runSpacing: 8,
                children: [
                  TextButton(
                    onPressed: _saving ? null : () => Navigator.pop(context),
                    child: const Text('Cancel'),
                  ),
                  FilledButton(
                    onPressed: _saving ? null : _save,
                    child: Text(_saving
                        ? 'Saving…'
                        : (isEditing ? 'Update' : 'Create')),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _imagePlaceholder(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.add_photo_alternate_outlined,
              size: 36, color: theme.colorScheme.primary),
          const SizedBox(height: 6),
          Text(
            'Tap to select image',
            style: theme.textTheme.bodySmall
                ?.copyWith(color: theme.colorScheme.primary),
          ),
        ],
      ),
    );
  }
}
