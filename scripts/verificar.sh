#!/usr/bin/env bash
#
# Verificación completa del proyecto de la Semana 10.
#
#   ./scripts/verificar.sh
#
# El script reproduce exactamente lo que ejecuta el pipeline de GitHub Actions
# definido en ../.github/workflows/flutter-semana10.yml, para que el estudiante
# pueda comprobarlo antes de hacer commit.

set -euo pipefail

cd "$(dirname "$0")/.."

echo "==> 1/4  Versiones"
flutter --version

echo "==> 2/4  Dependencias"
flutter pub get

echo "==> 3/4  Código generado por drift"
dart run build_runner build

echo "==> 4/4  Análisis estático y pruebas"
flutter analyze --fatal-infos
flutter test --reporter expanded

echo
echo "Verificación completada sin errores."
