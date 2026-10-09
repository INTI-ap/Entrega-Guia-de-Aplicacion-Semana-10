import 'package:flutter/material.dart';

import '../../core/id.dart';
import '../../core/theme/app_theme.dart';
import '../../domain/entidades/auditoria.dart';
import '../../domain/entidades/catalogos.dart';
import 'app_layout.dart';

/// Colores y etiquetas con los que la interfaz representa cada Momento y cada
/// Acción del catálogo oficial.
///
/// Vive en la capa de **presentación** y no en el dominio: un color no es una
/// regla de negocio (SRP, Semana 9). Si mañana cambia la identidad visual,
/// solo se toca este archivo.
class EstiloCatalogo {
  EstiloCatalogo._();

  static IconData iconoMomento(Momento momento) {
    switch (momento) {
      case Momento.antesDeTocarPaciente:
        return Icons.back_hand_outlined;
      case Momento.antesDeTareaAseptica:
        return Icons.clean_hands_outlined;
      case Momento.despuesRiesgoFluidos:
        return Icons.water_drop_outlined;
      case Momento.despuesDeTocarPaciente:
        return Icons.pan_tool_outlined;
      case Momento.despuesEntornoPaciente:
        return Icons.bed_outlined;
    }
  }

  static Color colorAccion(Accion accion) =>
      accion.esCumplimiento ? AppColors.exito : AppColors.alerta;

  static IconData iconoAccion(Accion accion) {
    switch (accion) {
      case Accion.guantes:
        return Icons.medical_services_outlined;
      case Accion.lavadoDeManos:
        return Icons.soap_outlined;
      case Accion.friccionDeManos:
        return Icons.sanitizer_outlined;
      case Accion.omision:
        return Icons.block_outlined;
    }
  }
}

/// Tarjeta que lista los 5 Momentos de la higiene de manos.
class TarjetaMomentos extends StatelessWidget {
  const TarjetaMomentos({super.key});

  @override
  Widget build(BuildContext context) {
    return TarjetaBase(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: const <Widget>[
              Icon(Icons.checklist_rtl, color: AppColors.navy),
              SizedBox(width: 8),
              Text(
                'Los 5 Momentos',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          const Text(
            'Instrumento oficial de la OMS para la higiene de manos en '
            'establecimientos de salud (RM N.° 255-2016/MINSA).',
            style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
          ),
          const SizedBox(height: 16),
          ...Momento.values.map(
            (Momento m) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Container(
                    margin: const EdgeInsets.only(top: 2),
                    width: 24,
                    height: 24,
                    alignment: Alignment.center,
                    decoration: const BoxDecoration(
                      color: AppColors.cyan,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      '${m.index + 1}',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: AppColors.navyDark,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      m.etiqueta,
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Tarjeta de una auditoría en el listado local.
///
/// **Reto 3:** agregue aquí los botones de editar, anular y duplicar; el
/// callback [alEditar] ya está previsto en el constructor.
class TarjetaAuditoria extends StatelessWidget {
  const TarjetaAuditoria({
    super.key,
    required this.auditoria,
    this.alTocar,
    this.alEditar,
    this.alAnular,
    this.alRestaurar,
    this.alDuplicar,
  });

  final Auditoria auditoria;
  final VoidCallback? alTocar;
  final VoidCallback? alEditar;
  final VoidCallback? alAnular;
  final VoidCallback? alRestaurar;
  final VoidCallback? alDuplicar;

  @override
  Widget build(BuildContext context) {
    final double adherencia = auditoria.porcentajeAdherencia;
    final Color color = adherencia >= 80
        ? AppColors.exito
        : (adherencia >= 60 ? AppColors.aviso : AppColors.alerta);

    return InkWell(
      onTap: alTocar,
      borderRadius: BorderRadius.circular(16),
      child: TarjetaBase(
        margin: const EdgeInsets.only(bottom: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        auditoria.establecimientoNombre,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${formatearFecha(auditoria.fecha)} · '
                        '${auditoria.observadoNombre}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    formatearPorcentaje(
                      auditoria.tieneDatos ? adherencia : null,
                    ),
                    style: TextStyle(fontWeight: FontWeight.bold, color: color),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 6,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: <Widget>[
                _Etiqueta(
                  texto: auditoria.estado.etiqueta,
                  color: AppColors.navy,
                  icono: Icons.sync,
                ),
                _Etiqueta(
                  texto: '${auditoria.totalOportunidades} oportunidades',
                  color: AppColors.textSecondary,
                  icono: Icons.list_alt,
                ),
                if (auditoria.eliminada)
                  const _Etiqueta(
                    texto: 'Anulada',
                    color: AppColors.alerta,
                    icono: Icons.delete_outline,
                  ),
              ],
            ),
            if (alEditar != null ||
                alAnular != null ||
                alRestaurar != null ||
                alDuplicar != null) ...<Widget>[
              const SizedBox(height: 8),
              const Divider(height: 1),
              Wrap(
                alignment: WrapAlignment.end,
                children: <Widget>[
                  if (alRestaurar != null)
                    TextButton.icon(
                      onPressed: alRestaurar,
                      icon: const Icon(Icons.restore, size: 18),
                      label: const Text('Restaurar'),
                    ),
                  if (alDuplicar != null)
                    TextButton.icon(
                      onPressed: alDuplicar,
                      icon: const Icon(Icons.copy, size: 18),
                      label: const Text('Duplicar'),
                    ),
                  if (alEditar != null)
                    TextButton.icon(
                      onPressed: alEditar,
                      icon: const Icon(Icons.edit_outlined, size: 18),
                      label: const Text('Editar'),
                    ),
                  if (alAnular != null)
                    TextButton.icon(
                      onPressed: alAnular,
                      icon: const Icon(Icons.delete_outline, size: 18),
                      label: const Text('Anular'),
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

/// Tarjeta de una oportunidad registrada dentro de una auditoría.
class TarjetaOportunidad extends StatelessWidget {
  const TarjetaOportunidad({
    super.key,
    required this.numero,
    required this.momento,
    required this.accion,
    this.observacion,
  });

  final int numero;
  final Momento momento;
  final Accion accion;
  final String? observacion;

  @override
  Widget build(BuildContext context) {
    final Color color = EstiloCatalogo.colorAccion(accion);

    return TarjetaBase(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            width: 40,
            height: 40,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.14),
              shape: BoxShape.circle,
            ),
            child: Icon(
              EstiloCatalogo.iconoAccion(accion),
              color: color,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'Oportunidad ${numero.toString().padLeft(2, '0')}',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  momento.etiqueta,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Acción: ${accion.etiqueta}',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: color,
                  ),
                ),
                if (observacion != null && observacion!.isNotEmpty) ...<Widget>[
                  const SizedBox(height: 4),
                  Text(
                    'Nota: $observacion',
                    style: const TextStyle(
                      fontSize: 11,
                      fontStyle: FontStyle.italic,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Etiqueta extends StatelessWidget {
  const _Etiqueta({
    required this.texto,
    required this.color,
    required this.icono,
  });

  final String texto;
  final Color color;
  final IconData icono;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(icono, size: 12, color: color),
          const SizedBox(width: 4),
          Text(
            texto,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
