# pruebas/test_mapeador_dominio_manual.py

from __future__ import annotations

import sys
from pathlib import Path
from datetime import date

from pydantic import ValidationError

RUTA_RAIZ_PROYECTO = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(RUTA_RAIZ_PROYECTO))

from CORE.schemas.solicitud_alta_schema import SolicitudAltaSchema
from CORE.schemas.solicitud_baja_schema import SolicitudBajaSchema

from CORE.mapeadores.mapeador_dominio import (
    mapear_solicitud_alta,
    mapear_solicitud_baja,
)

from CORE.dominio.reglas import (
    validar_reglas_solicitud_alta,
    validar_reglas_solicitud_baja,
)

from CORE.dominio.errores import mensaje_resultado


# ============================================================
# HELPERS DE PRUEBA
# ============================================================

def imprimir_titulo(nombre_prueba: str) -> None:
    print("\n" + "=" * 70)
    print(nombre_prueba)
    print("=" * 70)


def obtener_mensaje_usuario(detalle_error: dict) -> str:
    return detalle_error.get("msg", "")


def obtener_mensaje_tecnico(detalle_error: dict) -> str:
    contexto = detalle_error.get("ctx") or {}
    return contexto.get("mensaje_tecnico", "")


def obtener_campo(detalle_error: dict) -> str:
    campo = " → ".join(str(parte) for parte in detalle_error.get("loc", []))

    if campo == "":
        return "validacion"

    return campo


def imprimir_error_pydantic(error: ValidationError) -> None:
    for detalle in error.errors():
        campo = obtener_campo(detalle)
        mensaje_usuario = obtener_mensaje_usuario(detalle)
        mensaje_tecnico = obtener_mensaje_tecnico(detalle)

        print(f"{campo}: {mensaje_usuario}")

        if mensaje_tecnico:
            print(f"DETALLE TÉCNICO: {mensaje_tecnico}")


def imprimir_entidad(nombre: str, entidad) -> None:
    print(f"\nEntidad generada: {nombre}")
    print(entidad)


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


def rol_psicologa_valido() -> dict:
    return {
        "nombre": "Psicóloga",
        "siglas": "PSI",
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


def profesional_no_configurado() -> dict:
    return {
        "nombre": "Sofía",
        "apellido": "Ramírez",
        "rol": rol_psicologa_valido(),
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


def direccion_valida() -> dict:
    return {
        "calle": "Rivadavia",
        "numero": "123",
    }


def telefono_valido() -> dict:
    return {
        "codigo_area": "2932",
        "numero": "123456",
    }


def beneficiario_alta_valido() -> dict:
    return {
        "nombre": "Juan",
        "apellido": "López",
        "dni": "12345678",
        "direccion": direccion_valida(),
        "fecha_nacimiento": date(2010, 5, 10),
        "escolarizado": True,
    }


def beneficiario_baja_valido() -> dict:
    return {
        "nombre": "Juan",
        "apellido": "López",
        "tipo_dni": "DNI",
        "dni": "12345678",
        "fecha_ingreso": "10/05/2024",
    }


def tutor_valido() -> dict:
    return {
        "nombre": "Carlos",
        "apellido": "Martínez",
        "dni": "23456789",
        "direccion": {
            "calle": "Mitre",
            "numero": "456",
        },
        "fecha_nacimiento": date(1995, 8, 15),
        "escolarizado": None,
    }


def responsable_adulto_valido() -> dict:
    return {
        "nombre": "María",
        "apellido": "López",
        "dni": "87654321",
        "direccion": direccion_valida(),
        "fecha_nacimiento": date(1980, 3, 20),
        "parentesco": "Madre",
        "telefono": telefono_valido(),
    }


def responsable_baja_valido() -> dict:
    return {
        "nombre": "María",
        "apellido": "López",
        "relacion": "Madre",
        "informado": "Sí",
    }


def solicitud_alta_destinatario_valida() -> dict:
    return {
        "fecha_emision": date.today(),
        "tipo_solicitud": "destinatario",
        "beneficiario": beneficiario_alta_valido(),
        "responsable_adulto": responsable_adulto_valido(),
        "contexto_institucional": contexto_valido(),
    }


def solicitud_alta_tutor_valida() -> dict:
    return {
        "fecha_emision": date.today(),
        "tipo_solicitud": "tutor",
        "beneficiario": tutor_valido(),
        "responsable_adulto": None,
        "contexto_institucional": contexto_valido(),
    }


def solicitud_baja_valida() -> dict:
    contexto = contexto_valido()

    return {
        "fecha_emision": date.today(),
        "profesionales_intervinientes": contexto["profesionales"],
        "tipo_beneficiario": "destinatario",
        "motivo": "Trabajo Formal",
        "beneficiario": beneficiario_baja_valido(),
        "responsable_adulto": responsable_baja_valido(),
        "contexto_institucional": contexto,
    }


def solicitud_baja_con_profesional_no_configurado() -> dict:
    datos = solicitud_baja_valida()
    datos["profesionales_intervinientes"] = [
        profesional_no_configurado(),
    ]
    return datos


def solicitud_baja_con_profesionales_repetidos() -> dict:
    datos = solicitud_baja_valida()
    profesional = profesional_valido()

    datos["profesionales_intervinientes"] = [
        profesional,
        profesional,
    ]

    return datos


# ============================================================
# FLUJOS COMPLETOS
# ============================================================

def probar_flujo_alta(nombre_prueba: str, datos: dict) -> None:
    imprimir_titulo(nombre_prueba)

    try:
        schema = SolicitudAltaSchema(**datos)
        solicitud = mapear_solicitud_alta(schema)
        errores = validar_reglas_solicitud_alta(solicitud)

        imprimir_entidad("SolicitudAlta", solicitud)
        print("\nResultado:")
        print(mensaje_resultado(errores))

    except ValidationError as error:
        imprimir_error_pydantic(error)


def probar_flujo_baja(nombre_prueba: str, datos: dict) -> None:
    imprimir_titulo(nombre_prueba)

    try:
        schema = SolicitudBajaSchema(**datos)
        solicitud = mapear_solicitud_baja(schema)
        errores = validar_reglas_solicitud_baja(solicitud)

        imprimir_entidad("SolicitudBaja", solicitud)
        print("\nResultado:")
        print(mensaje_resultado(errores))

    except ValidationError as error:
        imprimir_error_pydantic(error)


# ============================================================
# PRUEBAS - ALTA
# ============================================================

def prueba_flujo_alta_destinatario_valida() -> None:
    probar_flujo_alta(
        "PRUEBA 1 - Flujo completo alta de destinatario válida",
        solicitud_alta_destinatario_valida(),
    )


def prueba_flujo_alta_tutor_valida() -> None:
    probar_flujo_alta(
        "PRUEBA 2 - Flujo completo alta de tutor válida",
        solicitud_alta_tutor_valida(),
    )


def prueba_flujo_alta_destinatario_sin_responsable() -> None:
    datos = solicitud_alta_destinatario_valida()
    datos["responsable_adulto"] = None

    probar_flujo_alta(
        "PRUEBA 3 - Flujo completo alta de destinatario sin responsable",
        datos,
    )


def prueba_flujo_alta_con_dni_invalido() -> None:
    datos = solicitud_alta_destinatario_valida()
    datos["beneficiario"]["dni"] = "1234567"

    probar_flujo_alta(
        "PRUEBA 4 - Flujo completo alta con DNI inválido",
        datos,
    )


# ============================================================
# PRUEBAS - BAJA
# ============================================================

def prueba_flujo_baja_valida() -> None:
    probar_flujo_baja(
        "PRUEBA 5 - Flujo completo baja válida",
        solicitud_baja_valida(),
    )


def prueba_flujo_baja_con_profesional_no_configurado() -> None:
    probar_flujo_baja(
        "PRUEBA 6 - Flujo completo baja con profesional no configurado",
        solicitud_baja_con_profesional_no_configurado(),
    )


def prueba_flujo_baja_con_profesionales_repetidos() -> None:
    probar_flujo_baja(
        "PRUEBA 7 - Flujo completo baja con profesionales repetidos",
        solicitud_baja_con_profesionales_repetidos(),
    )


def prueba_flujo_baja_sin_profesionales_intervinientes() -> None:
    datos = solicitud_baja_valida()
    datos["profesionales_intervinientes"] = []

    probar_flujo_baja(
        "PRUEBA 8 - Flujo completo baja sin profesionales intervinientes",
        datos,
    )


def prueba_flujo_baja_con_motivo_invalido() -> None:
    datos = solicitud_baja_valida()
    datos["motivo"] = "Motivo inventado"

    probar_flujo_baja(
        "PRUEBA 9 - Flujo completo baja con motivo inválido",
        datos,
    )


def prueba_flujo_baja_con_responsable_invalido() -> None:
    datos = solicitud_baja_valida()
    datos["responsable_adulto"] = {
        "nombre": "María",
        "apellido": "López123",
        "relacion": "Madre",
        "informado": "Sí",
    }

    probar_flujo_baja(
        "PRUEBA 10 - Flujo completo baja con responsable inválido",
        datos,
    )


def prueba_flujo_baja_con_responsable_informado_sin_seleccionar() -> None:
    datos = solicitud_baja_valida()
    datos["responsable_adulto"] = {
        "nombre": "María",
        "apellido": "López",
        "relacion": "Madre",
        "informado": "Sin seleccionar",
    }

    probar_flujo_baja(
        "PRUEBA 11 - Flujo completo baja con responsable informado sin seleccionar",
        datos,
    )


def prueba_flujo_baja_con_beneficiario_invalido() -> None:
    datos = solicitud_baja_valida()
    datos["beneficiario"] = {
        "nombre": "Juan123",
        "apellido": "López",
        "tipo_dni": "DNI",
        "dni": "12345678",
        "fecha_ingreso": "10/05/2024",
    }

    probar_flujo_baja(
        "PRUEBA 12 - Flujo completo baja con beneficiario inválido",
        datos,
    )


def prueba_flujo_baja_con_fecha_ingreso_invalida() -> None:
    datos = solicitud_baja_valida()
    datos["beneficiario"]["fecha_ingreso"] = "2024-05-10"

    probar_flujo_baja(
        "PRUEBA 13 - Flujo completo baja con fecha de ingreso inválida",
        datos,
    )


# ============================================================
# EJECUCIÓN MANUAL
# ============================================================

if __name__ == "__main__":
    prueba_flujo_alta_destinatario_valida()
    prueba_flujo_alta_tutor_valida()
    prueba_flujo_alta_destinatario_sin_responsable()
    prueba_flujo_alta_con_dni_invalido()

    prueba_flujo_baja_valida()
    prueba_flujo_baja_con_profesional_no_configurado()
    prueba_flujo_baja_con_profesionales_repetidos()
    prueba_flujo_baja_sin_profesionales_intervinientes()
    prueba_flujo_baja_con_motivo_invalido()
    prueba_flujo_baja_con_responsable_invalido()
    prueba_flujo_baja_con_responsable_informado_sin_seleccionar()
    prueba_flujo_baja_con_beneficiario_invalido()
    prueba_flujo_baja_con_fecha_ingreso_invalida()