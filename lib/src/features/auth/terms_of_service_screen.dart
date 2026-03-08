import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class TermsOfServiceScreen extends StatelessWidget {
  const TermsOfServiceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Términos de Servicio'),
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
              'Términos de Servicio',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            Text(
              'Última actualización: ${DateTime.now().year}-${DateTime.now().month.toString().padLeft(2, '0')}-${DateTime.now().day.toString().padLeft(2, '0')}\n\n'
              'Bienvenido a nuestra plataforma. Estos Términos de Servicio ("Términos") rigen su acceso y uso de nuestros servicios.\n\n'
              '1. Aceptación de los Términos\n'
              'Al acceder o utilizar nuestra aplicación, usted acepta estar sujeto a estos Términos.\n\n'
              '2. Responsabilidades del Usuario\n'
              'Usted es responsable de salvaguardar su contraseña y de todas las actividades que ocurran bajo su cuenta.\n\n'
              '3. Servicios\n'
              'Actuamos como intermediario para profesionales de servicios y clientes. No somos responsables por las acciones directas de ninguna de las partes.\n\n'
              '4. Modificaciones\n'
              'Nos reservamos el derecho, a nuestra entera discreción, de modificar o reemplazar estos Términos en cualquier momento.',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ],
        ),
      ),
    );
  }
}
