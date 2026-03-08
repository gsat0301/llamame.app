import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'profile_providers.dart';
import 'profile_repository.dart';

class ProviderApplicationScreen extends ConsumerStatefulWidget {
  const ProviderApplicationScreen({super.key});

  @override
  ConsumerState<ProviderApplicationScreen> createState() => _ProviderApplicationScreenState();
}

class _ProviderApplicationScreenState extends ConsumerState<ProviderApplicationScreen> {
  final _motivationController = TextEditingController();
  bool _submitting = false;

  @override
  void dispose() {
    _motivationController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final repo = ref.read(profileRepositoryProvider);
    if (repo == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Supabase is not configured.')),
      );
      return;
    }

    setState(() => _submitting = true);
    try {
      await repo.requestProviderRole(motivation: _motivationController.text.trim());
      ref.invalidate(latestProviderRequestProvider);
      if (mounted) context.pop();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Request submitted. Waiting for admin approval.')),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Request failed: $e')));
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Become a provider')),
      body: SafeArea(
        minimum: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Tell us briefly about your experience. An admin will review your request.',
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _motivationController,
              minLines: 4,
              maxLines: 8,
              decoration: const InputDecoration(
                labelText: 'Motivation',
                hintText: 'Example: Licensed electrician, 5 years experience, available in Bogotá.',
              ),
            ),
            const SizedBox(height: 20),
            FilledButton(
              onPressed: _submitting ? null : _submit,
              child: Text(_submitting ? 'Submitting…' : 'Submit request'),
            ),
          ],
        ),
      ),
    );
  }
}

