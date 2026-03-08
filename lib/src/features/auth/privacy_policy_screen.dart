import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Política de Privacidad'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/welcome');
            }
          },
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Política de Privacidad',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            Text(
              'Última actualización: ${DateTime.now().year}-${DateTime.now().month.toString().padLeft(2, '0')}-${DateTime.now().day.toString().padLeft(2, '0')}\n\n'
              'Respetamos su privacidad y estamos comprometidos a protegerla mediante nuestro cumplimiento de esta política.\n\n'
              '1. Recopilación de Información\n'
              'Recopilamos la información que nos proporciona directamente al crear una cuenta, actualizar su perfil y utilizar nuestros servicios.\n\n'
              '2. Cómo Usamos la Información\n'
              'Usamos la información que recopilamos para proporcionar, mantener y mejorar nuestros servicios.\n\n'
              '3. Divulgación de Información\n'
              'No vendemos, intercambiamos ni transferimos a terceros su información de identificación personal a menos que notifiquemos a los usuarios con anticipación.\n\n'
              '4. Cambios a Nuestra Política de Privacidad\n'
              'Es nuestra política publicar cualquier cambio que hagamos a nuestra política de privacidad en esta página.',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ],
        ),
      ),
    );
  }
}
