import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// Estado de **carga**: se muestra mientras el `Future` de la petición
/// HTTP aún no se completa.
class EstadoCarga extends StatelessWidget {
  final String mensaje;

  const EstadoCarga({
    super.key,
    this.mensaje = 'Consultando el servicio de la OMS…',
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 48),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            const CircularProgressIndicator(),
            const SizedBox(height: 16),
            Text(
              mensaje,
              style: const TextStyle(color: AppColors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }
}

/// Estado de **error**: muestra el mensaje traducido por el servicio y
/// ofrece un botón para reintentar la operación.
class EstadoError extends StatelessWidget {
  final String mensaje;
  final VoidCallback alReintentar;

  const EstadoError({
    super.key,
    required this.mensaje,
    required this.alReintentar,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            const Icon(Icons.cloud_off, size: 56, color: AppColors.alerta),
            const SizedBox(height: 16),
            const Text(
              'No se pudieron obtener los datos',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 8),
            Text(
              mensaje,
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: alReintentar,
              icon: const Icon(Icons.refresh),
              label: const Text('Reintentar'),
            ),
          ],
        ),
      ),
    );
  }
}

/// Estado **vacío**: la petición fue exitosa, pero la lista llegó sin
/// elementos. Es un caso distinto del error y merece su propio mensaje.
class EstadoVacio extends StatelessWidget {
  final String mensaje;

  const EstadoVacio({
    super.key,
    this.mensaje = 'El servicio no devolvió registros para este indicador.',
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            const Icon(
              Icons.inbox_outlined,
              size: 56,
              color: AppColors.textSecondary,
            ),
            const SizedBox(height: 16),
            Text(
              mensaje,
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }
}
