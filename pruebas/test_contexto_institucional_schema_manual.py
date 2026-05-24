# pruebas/test_contexto_institucional_schema_manual.py

from __future__ import annotations

import sys
from pathlib import Path

from pydantic import ValidationError

RUTA_RAIZ_PROYECTO = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(RUTA_RAIZ_PROYECTO))

from CORE.schemas.contexto_institucional_schema import ContextoInstitucionalSchema


# ============================================================
# HELPERS DE PRUEBA
# ============================================================

def imprimir_titulo(nombre_prueba: str) -> None:
    print("\n" + "=" * 70)
    print(nombre_prueba)
    print("=" * 70)


def imprimir_resultado_exitoso(objeto) -> None:
    print("Operación exitosa.")
    print(objeto)


def obtener_mensaje_usuario(detalle_error: dict) -> str:
    return detalle_error.get("msg", "")


def obtener_mensaje_tecnico(detalle_error: dict) -> str:
    contexto = detalle_error.get("ctx") or {}
    return contexto.get("mensaje_tecnico", "")


def obtener_campo(detalle_error: dict) -> str:
    return " → ".join(str(parte) for parte in detalle_error.get("loc", []))


def imprimir_error(error: ValidationError) -> None:
    for detalle in error.errors():
        campo = obtener_campo(detalle)
        mensaje_usuario = obtener_mensaje_usuario(detalle)
        mensaje_tecnico = obtener_mensaje_tecnico(detalle)

        print(f"{campo}: {mensaje_usuario}")

        if mensaje_tecnico:
            print(f"DETALLE TÉCNICO: {mensaje_tecnico}")


def probar_schema(nombre_prueba: str, datos: dict) -> None:
    imprimir_titulo(nombre_prueba)

    try:
        objeto = ContextoInstitucionalSchema(**datos)
        imprimir_resultado_exitoso(objeto)
    except ValidationError as error:
        imprimir_error(error)


# ============================================================
# DATOS BASE
# ============================================================

def ubicacion_valida() -> dict:
    return {
        "municipio": "Coronel Rosales",
        "localidad": "Punta Alta",
        "barrio": "",
    }


def rol_coordinadora_valido() -> dict:
    return {
        "nombre": "Coordinadora",
        "siglas": "COORD",
    }


def rol_profesional_valido() -> dict:
    return {
        "nombre": "Trabajadora social",
        "siglas": "TS",
    }


def coordinador_valido() -> dict:
    return {
        "nombre": "Ana",
        "apellido": "Pérez",
        "rol": rol_coordinadora_valido(),
    }


def profesional_valido() -> dict:
    return {
        "nombre": "Laura",
        "apellido": "Gómez",
        "rol": rol_profesional_valido(),
    }


def contexto_valido() -> dict:
    return {
        "origen": "Envión",
        "nombre_sede": "Sede Centro",
        "ubicacion": ubicacion_valida(),
        "coordinador": coordinador_valido(),
        "profesionales": [
            profesional_valido(),
        ],
    }


# ============================================================
# PRUEBAS - CONTEXTO INSTITUCIONAL
# ============================================================

def prueba_contexto_valido() -> None:
    probar_schema(
        "PRUEBA 1 - Contexto institucional válido",
        contexto_valido(),
    )


def prueba_contexto_origen_invalido() -> None:
    datos = contexto_valido()
    datos["origen"] = "Envión 123"

    probar_schema(
        "PRUEBA 2 - Contexto institucional con origen inválido",
        datos,
    )


def prueba_contexto_origen_vacio() -> None:
    datos = contexto_valido()
    datos["origen"] = ""

    probar_schema(
        "PRUEBA 3 - Contexto institucional con origen vacío",
        datos,
    )


def prueba_contexto_nombre_sede_invalido() -> None:
    datos = contexto_valido()
    datos["nombre_sede"] = "Sede Centro Nº"

    probar_schema(
        "PRUEBA 4 - Contexto institucional con nombre de sede inválido",
        datos,
    )


def prueba_contexto_ubicacion_invalida() -> None:
    datos = contexto_valido()
    datos["ubicacion"] = {
        "municipio": "Coronel Rosales 123",
        "localidad": "Punta Alta",
        "barrio": "",
    }

    probar_schema(
        "PRUEBA 5 - Contexto institucional con ubicación inválida",
        datos,
    )


def prueba_contexto_coordinador_invalido() -> None:
    datos = contexto_valido()
    datos["coordinador"] = {
        "nombre": "Ana123",
        "apellido": "Pérez",
        "rol": rol_coordinadora_valido(),
    }

    probar_schema(
        "PRUEBA 6 - Contexto institucional con coordinador inválido",
        datos,
    )


def prueba_contexto_coordinador_rol_invalido() -> None:
    datos = contexto_valido()
    datos["coordinador"] = {
        "nombre": "Ana",
        "apellido": "Pérez",
        "rol": {
            "nombre": "Coordinadora 123",
            "siglas": "COORD",
        },
    }

    probar_schema(
        "PRUEBA 7 - Contexto institucional con rol de coordinador inválido",
        datos,
    )


def prueba_contexto_sin_profesionales() -> None:
    datos = contexto_valido()
    datos["profesionales"] = []

    probar_schema(
        "PRUEBA 8 - Contexto institucional sin profesionales",
        datos,
    )


def prueba_contexto_profesional_invalido() -> None:
    datos = contexto_valido()
    datos["profesionales"] = [
        {
            "nombre": "Laura",
            "apellido": "Gómez123",
            "rol": rol_profesional_valido(),
        }
    ]

    probar_schema(
        "PRUEBA 9 - Contexto institucional con profesional inválido",
        datos,
    )


def prueba_contexto_profesional_rol_invalido() -> None:
    datos = contexto_valido()
    datos["profesionales"] = [
        {
            "nombre": "Laura",
            "apellido": "Gómez",
            "rol": {
                "nombre": "Trabajadora social",
                "siglas": "TS123",
            },
        }
    ]

    probar_schema(
        "PRUEBA 10 - Contexto institucional con rol de profesional inválido",
        datos,
    )


# ============================================================
# EJECUCIÓN MANUAL
# ============================================================

if __name__ == "__main__":
    prueba_contexto_valido()
    prueba_contexto_origen_invalido()
    prueba_contexto_origen_vacio()
    prueba_contexto_nombre_sede_invalido()
    prueba_contexto_ubicacion_invalida()
    prueba_contexto_coordinador_invalido()
    prueba_contexto_coordinador_rol_invalido()
    prueba_contexto_sin_profesionales()
    prueba_contexto_profesional_invalido()
    prueba_contexto_profesional_rol_invalido()