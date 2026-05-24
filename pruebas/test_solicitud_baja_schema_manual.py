# pruebas/test_solicitud_baja_schema_manual.py

from __future__ import annotations

import sys
from pathlib import Path
from datetime import date, timedelta

from pydantic import ValidationError

RUTA_RAIZ_PROYECTO = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(RUTA_RAIZ_PROYECTO))

from CORE.schemas.solicitud_baja_schema import SolicitudBajaSchema


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
    campo = " → ".join(str(parte) for parte in detalle_error.get("loc", []))

    if campo == "":
        return "solicitud_baja"

    return campo


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
        objeto = SolicitudBajaSchema(**datos)
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
        "nombre": "Trabajadora social",
        "siglas": "TS",
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


def beneficiario_valido() -> dict:
    return {
        "nombre": "Juan",
        "apellido": "López",
        "tipo_dni": "DNI",
        "dni": "12345678",
        "fecha_ingreso": "10/05/2024",
    }


def responsable_baja_valido() -> dict:
    return {
        "nombre": "María",
        "apellido": "López",
        "relacion": "Madre",
        "informado": "Sí",
    }


def solicitud_baja_valida() -> dict:
    contexto = contexto_valido()

    return {
        "fecha_emision": date.today(),
        "profesionales_intervinientes": contexto["profesionales"],
        "tipo_beneficiario": "destinatario",
        "motivo": "Trabajo Formal",
        "beneficiario": beneficiario_valido(),
        "responsable_adulto": responsable_baja_valido(),
        "contexto_institucional": contexto,
    }


# ============================================================
# PRUEBAS - SOLICITUD DE BAJA
# ============================================================

def prueba_baja_valida() -> None:
    probar_schema(
        "PRUEBA 1 - Solicitud de baja válida",
        solicitud_baja_valida(),
    )


def prueba_baja_fecha_emision_futura() -> None:
    datos = solicitud_baja_valida()
    datos["fecha_emision"] = date.today() + timedelta(days=1)

    probar_schema(
        "PRUEBA 2 - Solicitud de baja con fecha de emisión futura",
        datos,
    )


def prueba_baja_sin_profesionales_intervinientes() -> None:
    datos = solicitud_baja_valida()
    datos["profesionales_intervinientes"] = []

    probar_schema(
        "PRUEBA 3 - Solicitud de baja sin profesionales intervinientes",
        datos,
    )


def prueba_baja_profesional_interviniente_invalido() -> None:
    datos = solicitud_baja_valida()
    datos["profesionales_intervinientes"] = [
        {
            "nombre": "Laura123",
            "apellido": "Gómez",
            "rol": rol_profesional_valido(),
        }
    ]

    probar_schema(
        "PRUEBA 4 - Solicitud de baja con profesional interviniente inválido",
        datos,
    )


def prueba_baja_tipo_beneficiario_invalido() -> None:
    datos = solicitud_baja_valida()
    datos["tipo_beneficiario"] = "beneficiario"

    probar_schema(
        "PRUEBA 5 - Solicitud de baja con tipo de beneficiario inválido",
        datos,
    )


def prueba_baja_motivo_invalido() -> None:
    datos = solicitud_baja_valida()
    datos["motivo"] = "Motivo inventado"

    probar_schema(
        "PRUEBA 6 - Solicitud de baja con motivo inválido",
        datos,
    )


def prueba_baja_beneficiario_nombre_invalido() -> None:
    datos = solicitud_baja_valida()
    datos["beneficiario"] = {
        "nombre": "Juan123",
        "apellido": "López",
        "tipo_dni": "DNI",
        "dni": "12345678",
        "fecha_ingreso": "10/05/2024",
    }

    probar_schema(
        "PRUEBA 7 - Solicitud de baja con nombre de beneficiario inválido",
        datos,
    )


def prueba_baja_beneficiario_dni_invalido() -> None:
    datos = solicitud_baja_valida()
    datos["beneficiario"]["dni"] = "1234567"

    probar_schema(
        "PRUEBA 8 - Solicitud de baja con DNI de beneficiario inválido",
        datos,
    )


def prueba_baja_beneficiario_tipo_dni_invalido() -> None:
    datos = solicitud_baja_valida()
    datos["beneficiario"]["tipo_dni"] = "LC"

    probar_schema(
        "PRUEBA 9 - Solicitud de baja con tipo de documento inválido",
        datos,
    )


def prueba_baja_beneficiario_fecha_ingreso_invalida() -> None:
    datos = solicitud_baja_valida()
    datos["beneficiario"]["fecha_ingreso"] = "2024-05-10"

    probar_schema(
        "PRUEBA 10 - Solicitud de baja con fecha de ingreso inválida",
        datos,
    )


def prueba_baja_beneficiario_fecha_ingreso_futura() -> None:
    datos = solicitud_baja_valida()
    datos["beneficiario"]["fecha_ingreso"] = "10/05/2099"

    probar_schema(
        "PRUEBA 11 - Solicitud de baja con fecha de ingreso futura",
        datos,
    )


def prueba_baja_responsable_nombre_invalido() -> None:
    datos = solicitud_baja_valida()
    datos["responsable_adulto"] = {
        "nombre": "María123",
        "apellido": "López",
        "relacion": "Madre",
        "informado": "Sí",
    }

    probar_schema(
        "PRUEBA 12 - Solicitud de baja con nombre de responsable inválido",
        datos,
    )


def prueba_baja_responsable_apellido_invalido() -> None:
    datos = solicitud_baja_valida()
    datos["responsable_adulto"] = {
        "nombre": "María",
        "apellido": "López123",
        "relacion": "Madre",
        "informado": "Sí",
    }

    probar_schema(
        "PRUEBA 13 - Solicitud de baja con apellido de responsable inválido",
        datos,
    )


def prueba_baja_responsable_relacion_invalida() -> None:
    datos = solicitud_baja_valida()
    datos["responsable_adulto"]["relacion"] = "Vecina"

    probar_schema(
        "PRUEBA 14 - Solicitud de baja con relación de responsable inválida",
        datos,
    )


def prueba_baja_responsable_informado_sin_seleccionar() -> None:
    datos = solicitud_baja_valida()
    datos["responsable_adulto"]["informado"] = "Sin seleccionar"

    probar_schema(
        "PRUEBA 15 - Solicitud de baja con responsable informado sin seleccionar",
        datos,
    )


def prueba_baja_responsable_informado_si_sin_acento() -> None:
    datos = solicitud_baja_valida()
    datos["responsable_adulto"]["informado"] = "Si"

    probar_schema(
        "PRUEBA 16 - Solicitud de baja con responsable informado Si sin acento",
        datos,
    )


def prueba_baja_contexto_institucional_invalido() -> None:
    datos = solicitud_baja_valida()
    datos["contexto_institucional"]["origen"] = "Envión 123"

    probar_schema(
        "PRUEBA 17 - Solicitud de baja con contexto institucional inválido",
        datos,
    )


def prueba_baja_contexto_sin_profesionales() -> None:
    datos = solicitud_baja_valida()
    datos["contexto_institucional"]["profesionales"] = []

    probar_schema(
        "PRUEBA 18 - Solicitud de baja con contexto institucional sin profesionales",
        datos,
    )


# ============================================================
# EJECUCIÓN MANUAL
# ============================================================

if __name__ == "__main__":
    prueba_baja_valida()
    prueba_baja_fecha_emision_futura()
    prueba_baja_sin_profesionales_intervinientes()
    prueba_baja_profesional_interviniente_invalido()
    prueba_baja_tipo_beneficiario_invalido()
    prueba_baja_motivo_invalido()
    prueba_baja_beneficiario_nombre_invalido()
    prueba_baja_beneficiario_dni_invalido()
    prueba_baja_beneficiario_tipo_dni_invalido()
    prueba_baja_beneficiario_fecha_ingreso_invalida()
    prueba_baja_beneficiario_fecha_ingreso_futura()
    prueba_baja_responsable_nombre_invalido()
    prueba_baja_responsable_apellido_invalido()
    prueba_baja_responsable_relacion_invalida()
    prueba_baja_responsable_informado_sin_seleccionar()
    prueba_baja_responsable_informado_si_sin_acento()
    prueba_baja_contexto_institucional_invalido()
    prueba_baja_contexto_sin_profesionales()
