import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Shown when Supabase redirects the user back to the app after they click the
/// email-verification link.
///
/// Supabase default redirect URL is configured to `localhost:3000/#/email-verified`
/// (or the production equivalent). The Flutter web router picks up the
/// `#/email-verified` fragment and navigates here.
class EmailVerifiedScreen extends StatelessWidget {
  const EmailVerifiedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 48),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // ── Animated success badge ────────────────────────────────
                _SuccessIcon(colorScheme: colorScheme),

                const SizedBox(height: 32),

                // ── Headline ──────────────────────────────────────────────
                Text(
                  '¡Correo Verificado!',
                  textAlign: TextAlign.center,
                  style: textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface,
                  ),
                ),

                const SizedBox(height: 16),

                // ── Subtitle ──────────────────────────────────────────────
                Text(
                  'Tu dirección de correo electrónico ha sido confirmada exitosamente. '
                  'Ya puedes iniciar sesión y comenzar a usar LlamaMe.',
                  textAlign: TextAlign.center,
                  style: textTheme.bodyLarge?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    height: 1.5,
                  ),
                ),

                const SizedBox(height: 32),

                // ── Feature chips ─────────────────────────────────────────
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  alignment: WrapAlignment.center,
                  children: [
                    _InfoChip(
                      icon: Icons.search_rounded,
                      label: 'Busca servicios',
                      colorScheme: colorScheme,
                      textTheme: textTheme,
                    ),
                    _InfoChip(
                      icon: Icons.verified_user_rounded,
                      label: 'Proveedores verificados',
                      colorScheme: colorScheme,
                      textTheme: textTheme,
                    ),
                    _InfoChip(
                      icon: Icons.security_rounded,
                      label: 'Pagos seguros',
                      colorScheme: colorScheme,
                      textTheme: textTheme,
                    ),
                  ],
                ),

                const SizedBox(height: 40),

                // ── CTA button ────────────────────────────────────────────
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: () => context.go('/login'),
                    icon: const Icon(Icons.login_rounded),
                    label: const Text('Iniciar Sesión'),
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── Animated success icon ──────────────────────────────────────────────────

class _SuccessIcon extends StatefulWidget {
  const _SuccessIcon({required this.colorScheme});

  final ColorScheme colorScheme;

  @override
  State<_SuccessIcon> createState() => _SuccessIconState();
}

class _SuccessIconState extends State<_SuccessIcon>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _scaleAnim = CurvedAnimation(
      parent: _controller,
      curve: Curves.elasticOut,
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scaleAnim,
      child: Container(
        width: 120,
        height: 120,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: const Color(0xFF43A047).withValues(alpha: 0.12),
        ),
        child: const Icon(
          Icons.mark_email_read_rounded,
          size: 64,
          color: Color(0xFF43A047),
        ),
      ),
    );
  }
}

// ── Small feature chip ─────────────────────────────────────────────────────

class _InfoChip extends StatelessWidget {
  const _InfoChip({
    required this.icon,
    required this.label,
    required this.colorScheme,
    required this.textTheme,
  });

  final IconData icon;
  final String label;
  final ColorScheme colorScheme;
  final TextTheme textTheme;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: colorScheme.primaryContainer.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: colorScheme.primary.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: colorScheme.primary),
          const SizedBox(width: 6),
          Text(
            label,
            style: textTheme.labelMedium?.copyWith(
              color: colorScheme.onPrimaryContainer,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
