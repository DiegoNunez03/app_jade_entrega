# pruebas/test_base_schema_manual.py

from __future__ import annotations

import sys
from pathlib import Path

from pydantic import ValidationError

RUTA_RAIZ_PROYECTO = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(RUTA_RAIZ_PROYECTO))

from CORE.schemas.base_schema import (
    RolSchema,
    UbicacionSchema,
    DireccionSchema,
    TelefonoSchema,
)


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


def probar_schema(nombre_prueba: str, schema, datos: dict) -> None:
    imprimir_titulo(nombre_prueba)

    try:
        objeto = schema(**datos)
        imprimir_resultado_exitoso(objeto)
    except ValidationError as error:
        imprimir_error(error)


# ============================================================
# PRUEBAS - ROL
# ============================================================

def prueba_rol_valido() -> None:
    probar_schema(
        "PRUEBA 1 - Rol válido",
        RolSchema,
        {
            "nombre": "Trabajadora social",
            "siglas": "TS",
        },
    )


def prueba_rol_nombre_invalido() -> None:
    probar_schema(
        "PRUEBA 2 - Rol con nombre inválido",
        RolSchema,
        {
            "nombre": "Trabajadora social 123",
            "siglas": "TS",
        },
    )


def prueba_rol_siglas_minusculas() -> None:
    probar_schema(
        "PRUEBA 3 - Rol con siglas en minúscula",
        RolSchema,
        {
            "nombre": "Psicóloga",
            "siglas": "psi",
        },
    )


def prueba_rol_siglas_invalidas() -> None:
    probar_schema(
        "PRUEBA 4 - Rol con siglas inválidas",
        RolSchema,
        {
            "nombre": "Psicóloga",
            "siglas": "PSI123",
        },
    )


# ============================================================
# PRUEBAS - UBICACIÓN
# ============================================================

def prueba_ubicacion_valida_con_barrio() -> None:
    probar_schema(
        "PRUEBA 5 - Ubicación válida con barrio",
        UbicacionSchema,
        {
            "municipio": "Coronel Rosales",
            "localidad": "Punta Alta",
            "barrio": "Barrio 27 de Septiembre",
        },
    )


def prueba_ubicacion_valida_sin_barrio() -> None:
    probar_schema(
        "PRUEBA 6 - Ubicación válida sin barrio",
        UbicacionSchema,
        {
            "municipio": "Coronel Rosales",
            "localidad": "Punta Alta",
            "barrio": "",
        },
    )


def prueba_ubicacion_municipio_invalido() -> None:
    probar_schema(
        "PRUEBA 7 - Ubicación con municipio inválido",
        UbicacionSchema,
        {
            "municipio": "Coronel Rosales 123",
            "localidad": "Punta Alta",
            "barrio": "",
        },
    )


def prueba_ubicacion_localidad_vacia() -> None:
    probar_schema(
        "PRUEBA 8 - Ubicación con localidad vacía",
        UbicacionSchema,
        {
            "municipio": "Coronel Rosales",
            "localidad": "",
            "barrio": "",
        },
    )


def prueba_ubicacion_barrio_invalido() -> None:
    probar_schema(
        "PRUEBA 9 - Ubicación con barrio inválido",
        UbicacionSchema,
        {
            "municipio": "Coronel Rosales",
            "localidad": "Punta Alta",
            "barrio": "Barrio Nº 1",
        },
    )


# ============================================================
# PRUEBAS - DIRECCIÓN
# ============================================================

def prueba_direccion_valida() -> None:
    probar_schema(
        "PRUEBA 10 - Dirección válida",
        DireccionSchema,
        {
            "calle": "25 de Mayo",
            "numero": "123",
        },
    )


def prueba_direccion_numero_con_barra_y_guion() -> None:
    probar_schema(
        "PRUEBA 11 - Dirección con número con barra y guion",
        DireccionSchema,
        {
            "calle": "Rivadavia",
            "numero": "123-A/2",
        },
    )


def prueba_direccion_calle_invalida() -> None:
    probar_schema(
        "PRUEBA 12 - Dirección con calle inválida",
        DireccionSchema,
        {
            "calle": "Rivadavia Nº",
            "numero": "123",
        },
    )


def prueba_direccion_numero_con_espacio() -> None:
    probar_schema(
        "PRUEBA 13 - Dirección con número con espacio",
        DireccionSchema,
        {
            "calle": "Rivadavia",
            "numero": "123 A",
        },
    )


# ============================================================
# PRUEBAS - TELÉFONO
# ============================================================

def prueba_telefono_valido() -> None:
    probar_schema(
        "PRUEBA 14 - Teléfono válido",
        TelefonoSchema,
        {
            "codigo_area": "2932",
            "numero": "123456",
        },
    )


def prueba_telefono_codigo_area_con_letras() -> None:
    probar_schema(
        "PRUEBA 15 - Teléfono con código de área inválido",
        TelefonoSchema,
        {
            "codigo_area": "29A2",
            "numero": "123456",
        },
    )


def prueba_telefono_numero_con_letras() -> None:
    probar_schema(
        "PRUEBA 16 - Teléfono con número inválido",
        TelefonoSchema,
        {
            "codigo_area": "2932",
            "numero": "123ABC",
        },
    )


def prueba_telefono_codigo_area_cero() -> None:
    probar_schema(
        "PRUEBA 17 - Teléfono con código de área cero",
        TelefonoSchema,
        {
            "codigo_area": "0",
            "numero": "123456",
        },
    )


def prueba_telefono_numero_cero() -> None:
    probar_schema(
        "PRUEBA 18 - Teléfono con número cero",
        TelefonoSchema,
        {
            "codigo_area": "2932",
            "numero": "0",
        },
    )


def prueba_telefono_codigo_area_tres_digitos() -> None:
    probar_schema(
        "PRUEBA 19 - Teléfono con código de área de 3 dígitos",
        TelefonoSchema,
        {
            "codigo_area": "293",
            "numero": "123456",
        },
    )


def prueba_telefono_codigo_area_cinco_digitos() -> None:
    probar_schema(
        "PRUEBA 20 - Teléfono con código de área de 5 dígitos",
        TelefonoSchema,
        {
            "codigo_area": "92932",
            "numero": "123456",
        },
    )


def prueba_telefono_numero_con_cero_intermedio() -> None:
    probar_schema(
        "PRUEBA 21 - Teléfono con número que contiene cero",
        TelefonoSchema,
        {
            "codigo_area": "2932",
            "numero": "120456",
        },
    )


# ============================================================
# EJECUCIÓN MANUAL
# ============================================================

if __name__ == "__main__":
    prueba_rol_valido()
    prueba_rol_nombre_invalido()
    prueba_rol_siglas_minusculas()
    prueba_rol_siglas_invalidas()

    prueba_ubicacion_valida_con_barrio()
    prueba_ubicacion_valida_sin_barrio()
    prueba_ubicacion_municipio_invalido()
    prueba_ubicacion_localidad_vacia()
    prueba_ubicacion_barrio_invalido()

    prueba_direccion_valida()
    prueba_direccion_numero_con_barra_y_guion()
    prueba_direccion_calle_invalida()
    prueba_direccion_numero_con_espacio()

    prueba_telefono_valido()
    prueba_telefono_codigo_area_con_letras()
    prueba_telefono_numero_con_letras()
    prueba_telefono_codigo_area_cero()
    prueba_telefono_numero_cero()
    prueba_telefono_codigo_area_tres_digitos()
    prueba_telefono_codigo_area_cinco_digitos()
    prueba_telefono_numero_con_cero_intermedio()