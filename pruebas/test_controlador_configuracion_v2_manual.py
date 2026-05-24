# pruebas/test_controlador_configuracion_v2_manual.py

from __future__ import annotations

import sys
from pathlib import Path

RUTA_RAIZ_PROYECTO = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(RUTA_RAIZ_PROYECTO))

from CORE.controladores.controlador_configuracion import ControladorConfiguracionV2


# ============================================================
# HELPERS DE PRUEBA
# ============================================================

def imprimir_titulo(nombre_prueba: str) -> None:
    print("\n" + "=" * 70)
    print(nombre_prueba)
    print("=" * 70)


def imprimir_resultado(resultado) -> None:
    print(resultado)


# ============================================================
# DATOS BASE
# ============================================================

def configuracion_valida() -> dict:
    return {
        "origen": "Envión",
        "nombre_sede": "Sede Centro",
        "ubicacion": {
            "municipio": "Coronel Rosales",
            "localidad": "Punta Alta",
            "barrio": "",
        },
        "coordinador": {
            "nombre": "Ana",
            "apellido": "Pérez",
            "rol": {
                "nombre": "Coordinadora",
                "siglas": "COORD",
            },
        },
        "profesionales": [
            {
                "nombre": "Laura",
                "apellido": "Gómez",
                "rol": {
                    "nombre": "Trabajadora social",
                    "siglas": "TS",
                },
            },
            {
                "nombre": "Sofía",
                "apellido": "Ramírez",
                "rol": {
                    "nombre": "Psicóloga",
                    "siglas": "PSI",
                },
            },
        ],
    }


def configuracion_origen_invalido() -> dict:
    datos = configuracion_valida()
    datos["origen"] = "Envión 123"
    return datos


def configuracion_sin_profesionales() -> dict:
    datos = configuracion_valida()
    datos["profesionales"] = []
    return datos


def configuracion_profesional_invalido() -> dict:
    datos = configuracion_valida()
    datos["profesionales"] = [
        {
            "nombre": "Laura123",
            "apellido": "Gómez",
            "rol": {
                "nombre": "Trabajadora social",
                "siglas": "TS",
            },
        }
    ]
    return datos


def configuracion_rol_invalido() -> dict:
    datos = configuracion_valida()
    datos["profesionales"] = [
        {
            "nombre": "Laura",
            "apellido": "Gómez",
            "rol": {
                "nombre": "Trabajadora social 123",
                "siglas": "TS",
            },
        }
    ]
    return datos


def configuracion_profesionales_repetidos() -> dict:
    datos = configuracion_valida()
    profesional = {
        "nombre": "Laura",
        "apellido": "Gómez",
        "rol": {
            "nombre": "Trabajadora social",
            "siglas": "TS",
        },
    }

    datos["profesionales"] = [
        profesional,
        profesional,
    ]

    return datos


# ============================================================
# PRUEBAS
# ============================================================

def prueba_guardar_configuracion_valida(
    controlador: ControladorConfiguracionV2,
) -> None:
    imprimir_titulo("PRUEBA 1 - Guardar configuración válida")
    resultado = controlador.guardarConfiguracionSede(configuracion_valida())
    imprimir_resultado(resultado)


def prueba_cargar_configuracion_guardada(
    controlador: ControladorConfiguracionV2,
) -> None:
    imprimir_titulo("PRUEBA 2 - Cargar configuración guardada")
    resultado = controlador.cargarConfiguracionSede()
    imprimir_resultado(resultado)


def prueba_guardar_configuracion_origen_invalido(
    controlador: ControladorConfiguracionV2,
) -> None:
    imprimir_titulo("PRUEBA 3 - Guardar configuración con origen inválido")
    resultado = controlador.guardarConfiguracionSede(configuracion_origen_invalido())
    imprimir_resultado(resultado)


def prueba_guardar_configuracion_sin_profesionales(
    controlador: ControladorConfiguracionV2,
) -> None:
    imprimir_titulo("PRUEBA 4 - Guardar configuración sin profesionales")
    resultado = controlador.guardarConfiguracionSede(configuracion_sin_profesionales())
    imprimir_resultado(resultado)


def prueba_guardar_configuracion_profesional_invalido(
    controlador: ControladorConfiguracionV2,
) -> None:
    imprimir_titulo("PRUEBA 5 - Guardar configuración con profesional inválido")
    resultado = controlador.guardarConfiguracionSede(configuracion_profesional_invalido())
    imprimir_resultado(resultado)


def prueba_guardar_configuracion_rol_invalido(
    controlador: ControladorConfiguracionV2,
) -> None:
    imprimir_titulo("PRUEBA 6 - Guardar configuración con rol inválido")
    resultado = controlador.guardarConfiguracionSede(configuracion_rol_invalido())
    imprimir_resultado(resultado)


def prueba_guardar_configuracion_profesionales_repetidos(
    controlador: ControladorConfiguracionV2,
) -> None:
    imprimir_titulo("PRUEBA 7 - Guardar configuración con profesionales repetidos")
    resultado = controlador.guardarConfiguracionSede(configuracion_profesionales_repetidos())
    imprimir_resultado(resultado)


def prueba_cargar_configuracion_final(
    controlador: ControladorConfiguracionV2,
) -> None:
    imprimir_titulo("PRUEBA 8 - Cargar configuración final")
    resultado = controlador.cargarConfiguracionSede()
    imprimir_resultado(resultado)


# ============================================================
# EJECUCIÓN MANUAL
# ============================================================

if __name__ == "__main__":
    controlador = ControladorConfiguracionV2()

    prueba_guardar_configuracion_valida(controlador)
    prueba_cargar_configuracion_guardada(controlador)

    prueba_guardar_configuracion_origen_invalido(controlador)
    prueba_guardar_configuracion_sin_profesionales(controlador)
    prueba_guardar_configuracion_profesional_invalido(controlador)
    prueba_guardar_configuracion_rol_invalido(controlador)
    prueba_guardar_configuracion_profesionales_repetidos(controlador)

    prueba_cargar_configuracion_final(controlador)