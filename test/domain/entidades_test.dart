import 'package:flutter_test/flutter_test.dart';
import 'package:manos_seguras/domain/entidades/auditoria.dart';
import 'package:manos_seguras/domain/entidades/catalogos.dart';
import 'package:manos_seguras/domain/entidades/indicador_higiene.dart';
import 'package:manos_seguras/domain/entidades/oportunidad_registro.dart';
import 'package:manos_seguras/domain/entidades/personal.dart';
import 'package:manos_seguras/domain/servicios/calculadora_adherencia.dart';

/// **Pruebas de la capa de dominio.**
///
/// Ninguna de estas pruebas abre una base de datos, hace una petición HTTP ni
/// construye un widget: el dominio es Dart puro, y esa pureza es exactamente
/// lo que la arquitectura por capas de la Semana 8 busca (y lo que hace que la
/// suite corra en milisegundos).
void main() {
  group('Catálogos (Momento, Acción)', () {
    test('los 5 Momentos tienen clave y etiqueta no vacías', () {
      expect(Momento.values, hasLength(5));
      for (final Momento momento in Momento.values) {
        expect(momento.clave, isNotEmpty);
        expect(momento.etiqueta, isNotEmpty);
      }
    });

    test('las claves de los Momentos son únicas', () {
      final Set<String> claves =
          Momento.values.map((Momento m) => m.clave).toSet();
      expect(claves, hasLength(Momento.values.length));
    });

    test('la omisión es la única acción que no es cumplimiento', () {
      final Iterable<Accion> cumplen =
          Accion.values.where((Accion a) => a.esCumplimiento);
      expect(cumplen, isNot(contains(Accion.omision)));
      expect(cumplen, hasLength(3));
    });

    test('desdeClave degrada a un valor seguro ante una clave desconocida', () {
      expect(Momento.desdeClave('clave_inexistente'),
          Momento.antesDeTocarPaciente);
      expect(Accion.desdeClave(null), Accion.omision);
    });
  });

  group('Auditoria: indicadores derivados', () {
    test('sin oportunidades la adherencia es 0 y tieneDatos es false', () {
      final Auditoria auditoria = _auditoria(<OportunidadRegistro>[]);
      expect(auditoria.totalOportunidades, 0);
      expect(auditoria.porcentajeAdherencia, 0);
      expect(auditoria.tieneDatos, isFalse);
    });

    test('3 de 5 cumplidas → 60 % de adherencia y 2 omisiones', () {
      final Auditoria auditoria = _auditoria(<OportunidadRegistro>[
        _oportunidad(1, Accion.lavadoDeManos),
        _oportunidad(2, Accion.friccionDeManos),
        _oportunidad(3, Accion.guantes),
        _oportunidad(4, Accion.omision),
        _oportunidad(5, Accion.omision),
      ]);

      expect(auditoria.oportunidadesCumplidas, 3);
      expect(auditoria.omisiones, 2);
      expect(auditoria.porcentajeAdherencia, 60.0);
      expect(auditoria.tieneDatos, isTrue);
    });

    test('copyWith conserva los campos no indicados', () {
      final Auditoria original = _auditoria(<OportunidadRegistro>[]);
      final Auditoria copia = original.copyWith(
        estado: EstadoAuditoria.finalizada,
      );

      expect(copia.estado, EstadoAuditoria.finalizada);
      expect(copia.id, original.id);
      expect(copia.establecimientoNombre, original.establecimientoNombre);
    });
  });

  group('OportunidadRegistro', () {
    test('el código visible va con dos dígitos', () {
      expect(_oportunidad(3, Accion.omision).codigo, 'O-03');
      expect(_oportunidad(12, Accion.omision).codigo, 'O-12');
    });

    test('cumplio delega en el catálogo de acciones', () {
      expect(_oportunidad(1, Accion.guantes).cumplio, isTrue);
      expect(_oportunidad(2, Accion.omision).cumplio, isFalse);
    });
  });

  group('CalculadoraAdherencia', () {
    const CalculadoraAdherencia calculadora = CalculadoraAdherencia();

    test('sin auditorías devuelve el resumen vacío', () {
      final ResumenAdherencia resumen =
          calculadora.resumir(<Auditoria>[]);
      expect(resumen.totalAuditorias, 0);
      expect(resumen.totalOportunidades, 0);
      expect(resumen.porcentajeGlobal, 0);
    });

    test('ignora las auditorías eliminadas lógicamente', () {
      final List<Auditoria> auditorias = <Auditoria>[
        _auditoria(<OportunidadRegistro>[
          _oportunidad(1, Accion.lavadoDeManos),
        ]),
        _auditoria(<OportunidadRegistro>[
          _oportunidad(1, Accion.omision),
        ], eliminada: true),
      ];

      final ResumenAdherencia resumen = calculadora.resumir(auditorias);
      expect(resumen.totalAuditorias, 1);
      expect(resumen.totalOportunidades, 1);
      expect(resumen.totalCumplidas, 1);
      expect(resumen.porcentajeGlobal, 100);
    });

    test('el promedio se calcula solo sobre auditorías con datos', () {
      final List<Auditoria> auditorias = <Auditoria>[
        _auditoria(<OportunidadRegistro>[
          _oportunidad(1, Accion.lavadoDeManos),
          _oportunidad(2, Accion.lavadoDeManos),
        ]), // 100 %
        _auditoria(<OportunidadRegistro>[]), // sin datos: no debe contar
      ];

      final ResumenAdherencia resumen = calculadora.resumir(auditorias);
      expect(resumen.totalAuditorias, 2);
      expect(resumen.promedioAdherencia, 100);
    });

    test('agrupa por Momento para el tablero', () {
      final Map<String, ({int total, int cumplidas})> porMomento =
          calculadora.porMomento(<Auditoria>[
        _auditoria(<OportunidadRegistro>[
          _oportunidad(1, Accion.lavadoDeManos,
              momento: Momento.antesDeTocarPaciente),
          _oportunidad(2, Accion.omision,
              momento: Momento.antesDeTocarPaciente),
          _oportunidad(3, Accion.guantes,
              momento: Momento.despuesDeTocarPaciente),
        ]),
      ]);

      expect(porMomento[Momento.antesDeTocarPaciente.clave]!.total, 2);
      expect(porMomento[Momento.antesDeTocarPaciente.clave]!.cumplidas, 1);
      expect(porMomento[Momento.despuesDeTocarPaciente.clave]!.total, 1);
    });
  });

  group('Personal', () {
    test('las iniciales del observado usan nombre y apellido', () {
      const Observado observado = Observado(
        dni: '45678912',
        nombresApellidos: 'Carlos Huamán Ttito',
        categoriaProfesional: 'Enfermero(a)',
      );
      expect(observado.iniciales, 'CT');
      expect(observado.rol, 'observado');
    });

    test('un observador no expone categoría profesional', () {
      const Observador observador = Observador(
        dni: '23456789',
        nombresApellidos: 'Ana Quispe',
      );
      expect(observador.iniciales, 'AQ');
      expect(observador.rol, 'observador');
    });
  });

  group('IndicadorHigiene', () {
    test('la clave de caché combina país, año y ámbito', () {
      const IndicadorHigiene indicador = IndicadorHigiene(
        codigoIndicador: 'WSH_HYGIENE_BASIC',
        pais: 'PER',
        anio: 2024,
        ambito: 'Rural',
        valor: 72.27,
      );
      expect(indicador.clave, 'PER|2024|Rural');
      expect(indicador.valorTexto, '72.3 %');
      expect(indicador.fraccion, closeTo(0.7227, 0.001));
    });

    test('un valor nulo se muestra como "Sin dato" y fracción 0', () {
      const IndicadorHigiene indicador = IndicadorHigiene(
        codigoIndicador: 'WSH_HYGIENE_BASIC',
        pais: 'PER',
        anio: 2025,
        ambito: 'Rural',
      );
      expect(indicador.tieneValor, isFalse);
      expect(indicador.valorTexto, 'Sin dato');
      expect(indicador.fraccion, 0);
    });
  });
}

// ---------------------------------------------------------------------
// Constructores auxiliares de las pruebas
// ---------------------------------------------------------------------

Auditoria _auditoria(
  List<OportunidadRegistro> oportunidades, {
  bool eliminada = false,
}) {
  return Auditoria(
    id: 'aud-1',
    establecimientoId: '00006405',
    establecimientoNombre: 'Hospital Regional del Cusco',
    observadorDni: '23456789',
    observadorNombre: 'Ana Quispe Mamani',
    observadoDni: '45678912',
    observadoNombre: 'Carlos Huamán Ttito',
    fecha: DateTime(2026, 10, 20, 9, 30),
    eliminada: eliminada,
    oportunidades: oportunidades,
  );
}

OportunidadRegistro _oportunidad(
  int numero,
  Accion accion, {
  Momento momento = Momento.antesDeTocarPaciente,
}) {
  return OportunidadRegistro(
    auditoriaId: 'aud-1',
    numero: numero,
    momento: momento,
    accion: accion,
  );
}
