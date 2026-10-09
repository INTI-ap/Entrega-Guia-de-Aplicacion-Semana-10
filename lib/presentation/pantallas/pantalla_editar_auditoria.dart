import 'package:flutter/material.dart';
import '../../core/fallos.dart';
import '../../domain/entidades/auditoria.dart';
import '../../domain/repositorios/auditoria_repository.dart';
import '../di.dart';

class PantallaEditarAuditoria extends StatefulWidget {
  const PantallaEditarAuditoria({super.key, required this.auditoria});
  final Auditoria auditoria;
  @override
  State<PantallaEditarAuditoria> createState() =>
      _PantallaEditarAuditoriaState();
}

class _PantallaEditarAuditoriaState extends State<PantallaEditarAuditoria> {
  final _formulario = GlobalKey<FormState>();
  late final TextEditingController _establecimiento;
  late final TextEditingController _observador;
  late final TextEditingController _observado;
  late final TextEditingController _observacion;
  late final TextEditingController _camas;
  late bool? _consentimiento;
  bool _guardando = false;

  @override
  void initState() {
    super.initState();
    final a = widget.auditoria;
    _establecimiento = TextEditingController(text: a.establecimientoNombre);
    _observador = TextEditingController(text: a.observadorNombre);
    _observado = TextEditingController(text: a.observadoNombre);
    _observacion = TextEditingController(text: a.observacionGeneral ?? '');
    _camas = TextEditingController(text: a.numeroCamas?.toString() ?? '');
    _consentimiento = a.consentimientoVerbal;
  }

  @override
  void dispose() {
    for (final c in [
      _establecimiento,
      _observador,
      _observado,
      _observacion,
      _camas,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _guardar() async {
    if (!_formulario.currentState!.validate() || _guardando) return;
    setState(() => _guardando = true);
    final a = widget.auditoria;
    try {
      // Conserva la fecha original y el detalle; solo cambia los campos del formulario.
      await getIt<AuditoriaRepository>().actualizar(
        Auditoria(
          id: a.id,
          establecimientoId: a.establecimientoId,
          establecimientoNombre: _establecimiento.text.trim(),
          observadorDni: a.observadorDni,
          observadorNombre: _observador.text.trim(),
          observadoDni: a.observadoDni,
          observadoNombre: _observado.text.trim(),
          fecha: a.fecha,
          estado: a.estado,
          eliminada: a.eliminada,
          sincronizadaEn: a.sincronizadaEn,
          fechaInicio: a.fechaInicio,
          fechaFin: a.fechaFin,
          numeroCamas: int.tryParse(_camas.text.trim()),
          consentimientoVerbal: _consentimiento,
          observacionGeneral: _observacion.text.trim().isEmpty
              ? null
              : _observacion.text.trim(),
          oportunidades: a.oportunidades,
        ),
      );
      if (!mounted) return;
      Navigator.of(context).pop(true);
    } on Fallo catch (fallo) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(fallo.mensaje)));
    } finally {
      if (mounted) setState(() => _guardando = false);
    }
  }

  Widget _nombre(String etiqueta, TextEditingController controlador) =>
      TextFormField(
        controller: controlador,
        enabled: !_guardando,
        decoration: InputDecoration(labelText: etiqueta),
        validator: (v) =>
            v == null || v.trim().isEmpty ? 'Complete este campo.' : null,
      );

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Editar auditoría')),
    body: Form(
      key: _formulario,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            'Se conservarán las ${widget.auditoria.totalOportunidades} oportunidades registradas.',
          ),
          const SizedBox(height: 12),
          _nombre('Establecimiento', _establecimiento),
          const SizedBox(height: 16),
          _nombre('Observador', _observador),
          const SizedBox(height: 16),
          _nombre('Personal observado', _observado),
          const SizedBox(height: 16),
          TextFormField(
            controller: _camas,
            enabled: !_guardando,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: 'Número de camas'),
            validator: (v) =>
                v != null &&
                    v.trim().isNotEmpty &&
                    (int.tryParse(v.trim()) == null || int.parse(v.trim()) < 0)
                ? 'Ingrese un entero mayor o igual a cero.'
                : null,
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<bool?>(
            initialValue: _consentimiento,
            decoration: const InputDecoration(
              labelText: 'Consentimiento verbal',
            ),
            items: const [
              DropdownMenuItem(value: null, child: Text('Sin registrar')),
              DropdownMenuItem(value: true, child: Text('Sí')),
              DropdownMenuItem(value: false, child: Text('No')),
            ],
            onChanged: _guardando
                ? null
                : (v) => setState(() => _consentimiento = v),
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _observacion,
            enabled: !_guardando,
            maxLines: 3,
            decoration: const InputDecoration(labelText: 'Observación general'),
          ),
          const SizedBox(height: 20),
          FilledButton(
            onPressed: _guardando ? null : _guardar,
            child: Text(_guardando ? 'Guardando…' : 'Guardar cambios'),
          ),
        ],
      ),
    ),
  );
}
