import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';

/// Estado de **carga**: se muestra mientras el `Future` de la consulta aún
/// no se completa. Es el mismo widget de la Sesión 16, con un mensaje por
/// omisión que ahora habla de la base local y del servicio remoto.
class EstadoCarga extends StatelessWidget {
  const EstadoCarga({super.key, this.mensaje = 'Consultando datos…'});

  final String mensaje;

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
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }
}

/// Estado de **error**: muestra el mensaje traducido por la capa de datos y
/// ofrece un botón para reintentar la operación.
class EstadoError extends StatelessWidget {
  const EstadoError({
    super.key,
    required this.mensaje,
    required this.alReintentar,
    this.titulo = 'No se pudieron obtener los datos',
  });

  final String mensaje;
  final String titulo;
  final VoidCallback alReintentar;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            const Icon(Icons.error_outline, size: 56, color: AppColors.alerta),
            const SizedBox(height: 16),
            Text(
              titulo,
              textAlign: TextAlign.center,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
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

/// Estado **vacío**: la consulta fue exitosa pero no hay registros. Es un
/// caso distinto del error y merece su propio mensaje y su propia acción.
class EstadoVacio extends StatelessWidget {
  const EstadoVacio({
    super.key,
    this.mensaje = 'Todavía no hay registros guardados en el dispositivo.',
    this.icono = Icons.inbox_outlined,
    this.accionEtiqueta,
    this.alAccionar,
  });

  final String mensaje;
  final IconData icono;
  final String? accionEtiqueta;
  final VoidCallback? alAccionar;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(icono, size: 56, color: AppColors.textSecondary),
            const SizedBox(height: 16),
            Text(
              mensaje,
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.textSecondary),
            ),
            if (accionEtiqueta != null && alAccionar != null) ...<Widget>[
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: alAccionar,
                icon: const Icon(Icons.add),
                label: Text(accionEtiqueta!),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Insignia que informa **de dónde salieron los datos** que se están
/// mostrando. Es la cara visible del patrón *offline-first*: el usuario
/// siempre sabe si lo que ve está recién descargado o viene del dispositivo.
class InsigniaOrigen extends StatelessWidget {
  const InsigniaOrigen({
    super.key,
    required this.etiqueta,
    required this.esRemoto,
    this.datosObsoletos = false,
    this.icono,
  });

  final String etiqueta;
  final bool esRemoto;
  final bool datosObsoletos;
  final IconData? icono;

  @override
  Widget build(BuildContext context) {
    final Color color = datosObsoletos
        ? const Color(0xFFB45309)
        : esRemoto
        ? AppColors.exito
        : AppColors.textSecondary;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(
            icono ??
                (datosObsoletos
                    ? Icons.warning_amber_rounded
                    : esRemoto
                    ? Icons.cloud_done
                    : Icons.sd_storage),
            size: 14,
            color: color,
          ),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              datosObsoletos ? 'Caché vencida · Datos obsoletos' : etiqueta,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
