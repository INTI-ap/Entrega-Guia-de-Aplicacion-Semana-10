import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/fallos.dart';
import '../../core/id.dart';
import '../../core/theme/app_theme.dart';
import '../../data/local/infraestructura.dart';
import '../../data/local/manos_seguras_db.dart';
import '../../data/local/sembrador.dart';
import '../../domain/entidades/catalogos.dart';
import '../../domain/entidades/indicador_higiene.dart';
import '../../domain/entidades/oportunidad_registro.dart';
import '../../domain/repositorios/indicador_repository.dart';
import '../di.dart';
import '../widgets/app_layout.dart';
import '../widgets/estados_vista.dart';

/// **Pantalla de diagnóstico de la base local.**
///
/// Es la herramienta con la que el estudiante *ve* la persistencia: cuántas
/// filas hay en cada tabla, si las claves foráneas están activas, cuánto ocupa
/// el archivo y qué preferencias están guardadas. Se usa para tomar las
/// capturas de pantalla que exige el informe.
///
/// Además es el punto de entrada de tres pruebas manuales del laboratorio:
///
///  1. **Persistencia real:** guarde una auditoría, cierre la aplicación por
///     completo y vuelva a abrirla. El contador de `auditorias` debe seguir
///     igual.
///  2. **Claves foráneas (Reto 5):** pulse "Probar clave foránea" e intente
///     insertar una oportunidad con un `auditoriaId` inexistente. Debe fallar.
///  3. **Migración (Reto 4):** suba `schemaVersion` a 2 en
///     `manos_seguras_db.dart`, vuelva a ejecutar y observe el error
///     controlado de migración pendiente.
class PantallaDiagnostico extends StatefulWidget {
  const PantallaDiagnostico({super.key});

  @override
  State<PantallaDiagnostico> createState() => _PantallaDiagnosticoState();
}

class _PantallaDiagnosticoState extends State<PantallaDiagnostico> {
  late Future<_Diagnostico> _futuro;

  @override
  void initState() {
    super.initState();
    _futuro = _cargar();
  }

  Future<_Diagnostico> _cargar() async {
    final ManosSegurasDb base = getIt<ManosSegurasDb>();
    final Map<String, int> conteos = await base.contarFilas();
    final int clavesForaneas = await base.estadoClavesForaneas();
    final List<IndicadorHigiene> cache =
        await getIt<IndicadorRepository>().leerCache();
    final DateTime? ultima =
        await getIt<IndicadorRepository>().ultimaSincronizacion();
    final Map<String, String> preferencias =
        await getIt<PreferenciasRepository>().leerTodo();

    return _Diagnostico(
      conteos: conteos,
      clavesForaneasActivas: clavesForaneas == 1,
      registrosCache: cache.length,
      ultimaSincronizacion: ultima,
      preferencias: preferencias,
      versionEsquema: base.schemaVersion,
    );
  }

  void _recargar() {
    setState(() => _futuro = _cargar());
  }

  Future<void> _sembrar() async {
    try {
      final SembradorDatos sembrador = getIt<SembradorDatos>();
      await sembrador.limpiar();
      final int creadas = await sembrador.sembrar(cantidad: 3);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Se sembraron $creadas auditorías de ejemplo.')),
      );
      _recargar();
    } on Fallo catch (fallo) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(fallo.mensaje)),
      );
    }
  }

  /// Oportunidad con un `auditoriaId` que no existe, para comprobar que la
  /// clave foránea se hace cumplir.
  OportunidadRegistro _oportunidadInvalida() {
    return const OportunidadRegistro(
      auditoriaId: 'auditoria-que-no-existe',
      numero: 99,
      momento: Momento.antesDeTocarPaciente,
      accion: Accion.omision,
    );
  }

  /// **Prueba de integridad referencial (Reto 5).**
  ///
  /// Intenta insertar una oportunidad cuyo `auditoriaId` no existe. Con
  /// `PRAGMA foreign_keys = ON` SQLite debe rechazarla. Si la inserción tiene
  /// éxito, la comprobación de integridad **no** está activa y hay que
  /// revisar `beforeOpen` en `manos_seguras_db.dart`.
  Future<void> _probarClaveForanea() async {
    final InfraestructuraLocal infra = InfraestructuraLocal(
      getIt<ManosSegurasDb>(),
    );
    String resultado;
    try {
      await infra.auditoriasDao.insertarOportunidad(
        _oportunidadInvalida(),
      );
      resultado = 'FALLO la prueba: SQLite aceptó una oportunidad huérfana. '
          'Revise el PRAGMA foreign_keys.';
    } catch (error) {
      resultado = 'Prueba correcta: SQLite rechazó la oportunidad huérfana '
          '(${error.runtimeType}).';
    }
    if (!mounted) return;
    showDialog<void>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: const Text('Integridad referencial'),
        content: Text(resultado),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Entendido'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Diagnóstico local'),
        actions: <Widget>[
          IconButton(
            tooltip: 'Recargar',
            onPressed: _recargar,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: FutureBuilder<_Diagnostico>(
        future: _futuro,
        builder: (
          BuildContext context,
          AsyncSnapshot<_Diagnostico> snapshot,
        ) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const EstadoCarga(mensaje: 'Inspeccionando la base…');
          }
          if (snapshot.hasError) {
            return EstadoError(
              mensaje: '${snapshot.error}',
              alReintentar: _recargar,
            );
          }

          final _Diagnostico? datos = snapshot.data;
          if (datos == null) {
            return const EstadoVacio(mensaje: 'Sin información.');
          }

          return SingleChildScrollView(
            child: AppLayout(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  TarjetaBase(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        const Text(
                          'Estado de la base de datos local',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                            color: AppColors.navy,
                          ),
                        ),
                        const SizedBox(height: 8),
                        _Dato('Motor', 'SQLite (drift)'),
                        _Dato('Versión del esquema',
                            '${datos.versionEsquema}'),
                        _Dato(
                          'Claves foráneas',
                          datos.clavesForaneasActivas
                              ? 'ACTIVAS (PRAGMA foreign_keys = 1)'
                              : 'INACTIVAS',
                          alerta: !datos.clavesForaneasActivas,
                        ),
                        _Dato(
                          'Caché del indicador',
                          '${datos.registrosCache} registros',
                        ),
                        _Dato(
                          'Última sincronización',
                          datos.ultimaSincronizacion == null
                              ? 'Nunca'
                              : formatearFechaHora(
                                  datos.ultimaSincronizacion!,
                                ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  const TituloSeccion('Filas por tabla', icono: Icons.table_chart),
                  TarjetaBase(
                    child: Column(
                      children: datos.conteos.entries
                          .map(
                            (MapEntry<String, int> e) => _Dato(
                              e.key,
                              '${e.value} fila(s)',
                            ),
                          )
                          .toList(),
                    ),
                  ),
                  const SizedBox(height: 8),
                  const TituloSeccion(
                    'Preferencias (clave-valor)',
                    icono: Icons.tune,
                  ),
                  TarjetaBase(
                    child: datos.preferencias.isEmpty
                        ? const Text(
                            'Sin preferencias guardadas todavía.',
                            style: TextStyle(color: AppColors.textSecondary),
                          )
                        : Column(
                            children: datos.preferencias.entries
                                .map(
                                  (MapEntry<String, String> e) =>
                                      _Dato(e.key, e.value),
                                )
                                .toList(),
                          ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 48,
                    child: ElevatedButton.icon(
                      onPressed: _sembrar,
                      icon: const Icon(Icons.auto_awesome),
                      label: const Text('Sembrar datos de ejemplo'),
                    ),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    height: 48,
                    child: OutlinedButton.icon(
                      onPressed: _probarClaveForanea,
                      icon: const Icon(Icons.link_off),
                      label: const Text('Probar clave foránea (Reto 5)'),
                    ),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    height: 48,
                    child: OutlinedButton.icon(
                      onPressed: () => context.go('/'),
                      icon: const Icon(Icons.home_outlined),
                      label: const Text('Volver al inicio'),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

/// Datos que muestra la pantalla. Es una clase privada de presentación: no
/// pertenece al dominio porque solo existe para dibujar esta vista.
class _Diagnostico {
  const _Diagnostico({
    required this.conteos,
    required this.clavesForaneasActivas,
    required this.registrosCache,
    required this.preferencias,
    required this.versionEsquema,
    this.ultimaSincronizacion,
  });

  final Map<String, int> conteos;
  final bool clavesForaneasActivas;
  final int registrosCache;
  final Map<String, String> preferencias;
  final int versionEsquema;
  final DateTime? ultimaSincronizacion;
}

class _Dato extends StatelessWidget {
  const _Dato(this.etiqueta, this.valor, {this.alerta = false});

  final String etiqueta;
  final String valor;
  final bool alerta;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Expanded(
            child: Text(
              etiqueta,
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          Expanded(
            child: Text(
              valor,
              textAlign: TextAlign.right,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: alerta ? AppColors.alerta : AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
