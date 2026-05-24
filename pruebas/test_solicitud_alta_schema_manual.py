# pruebas/test_solicitud_alta_schema_manual.py

from __future__ import annotations

import sys
from pathlib import Path
from datetime import date, timedelta

from pydantic import ValidationError

RUTA_RAIZ_PROYECTO = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(RUTA_RAIZ_PROYECTO))

from CORE.schemas.solicitud_alta_schema import SolicitudAltaSchema


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
        return "solicitud_alta"

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
        objeto = SolicitudAltaSchema(**datos)
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


def beneficiario_valido() -> dict:
    return {
        "nombre": "Juan",
        "apellido": "López",
        "dni": "12345678",
        "direccion": direccion_valida(),
        "fecha_nacimiento": date(2010, 5, 10),
        "escolarizado": True,
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


def solicitud_alta_destinatario_valida() -> dict:
    return {
        "fecha_emision": date.today(),
        "tipo_solicitud": "destinatario",
        "beneficiario": beneficiario_valido(),
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


# ============================================================
# PRUEBAS - SOLICITUD DE ALTA
# ============================================================

def prueba_alta_destinatario_valida() -> None:
    probar_schema(
        "PRUEBA 1 - Alta de destinatario válida",
        solicitud_alta_destinatario_valida(),
    )


def prueba_alta_destinatario_sin_responsable() -> None:
    datos = solicitud_alta_destinatario_valida()
    datos["responsable_adulto"] = None

    probar_schema(
        "PRUEBA 2 - Alta de destinatario sin responsable adulto",
        datos,
    )


def prueba_alta_tutor_valida() -> None:
    probar_schema(
        "PRUEBA 3 - Alta de tutor válida",
        solicitud_alta_tutor_valida(),
    )


def prueba_alta_tutor_con_responsable() -> None:
    datos = solicitud_alta_tutor_valida()
    datos["responsable_adulto"] = responsable_adulto_valido()

    probar_schema(
        "PRUEBA 4 - Alta de tutor con responsable adulto",
        datos,
    )


def prueba_alta_tipo_solicitud_invalido() -> None:
    datos = solicitud_alta_destinatario_valida()
    datos["tipo_solicitud"] = "beneficiario"

    probar_schema(
        "PRUEBA 5 - Alta con tipo de solicitud inválido",
        datos,
    )


def prueba_alta_fecha_emision_futura() -> None:
    datos = solicitud_alta_destinatario_valida()
    datos["fecha_emision"] = date.today() + timedelta(days=1)

    probar_schema(
        "PRUEBA 6 - Alta con fecha de emisión futura",
        datos,
    )


def prueba_alta_beneficiario_invalido() -> None:
    datos = solicitud_alta_destinatario_valida()
    datos["beneficiario"] = {
        "nombre": "Juan123",
        "apellido": "López",
        "dni": "12345678",
        "direccion": direccion_valida(),
        "fecha_nacimiento": date(2010, 5, 10),
        "escolarizado": True,
    }

    probar_schema(
        "PRUEBA 7 - Alta con beneficiario inválido",
        datos,
    )


def prueba_alta_beneficiario_dni_invalido() -> None:
    datos = solicitud_alta_destinatario_valida()
    datos["beneficiario"]["dni"] = "1234567"

    probar_schema(
        "PRUEBA 8 - Alta con DNI de beneficiario inválido",
        datos,
    )


def prueba_alta_responsable_invalido() -> None:
    datos = solicitud_alta_destinatario_valida()
    datos["responsable_adulto"] = {
        "nombre": "María",
        "apellido": "López123",
        "dni": "87654321",
        "direccion": direccion_valida(),
        "fecha_nacimiento": date(1980, 3, 20),
        "parentesco": "Madre",
        "telefono": telefono_valido(),
    }

    probar_schema(
        "PRUEBA 9 - Alta con responsable adulto inválido",
        datos,
    )


def prueba_alta_responsable_parentesco_invalido() -> None:
    datos = solicitud_alta_destinatario_valida()
    datos["responsable_adulto"]["parentesco"] = "Vecina"

    probar_schema(
        "PRUEBA 10 - Alta con parentesco inválido",
        datos,
    )


def prueba_alta_contexto_institucional_invalido() -> None:
    datos = solicitud_alta_destinatario_valida()
    datos["contexto_institucional"]["origen"] = "Envión 123"

    probar_schema(
        "PRUEBA 11 - Alta con contexto institucional inválido",
        datos,
    )


def prueba_alta_contexto_sin_profesionales() -> None:
    datos = solicitud_alta_destinatario_valida()
    datos["contexto_institucional"]["profesionales"] = []

    probar_schema(
        "PRUEBA 12 - Alta con contexto institucional sin profesionales",
        datos,
    )


# ============================================================
# EJECUCIÓN MANUAL
# ============================================================

if __name__ == "__main__":
    prueba_alta_destinatario_valida()
    prueba_alta_destinatario_sin_responsable()
    prueba_alta_tutor_valida()
    prueba_alta_tutor_con_responsable()
    prueba_alta_tipo_solicitud_invalido()
    prueba_alta_fecha_emision_futura()
    prueba_alta_beneficiario_invalido()
    prueba_alta_beneficiario_dni_invalido()
    prueba_alta_responsable_invalido()
    prueba_alta_responsable_parentesco_invalido()
    prueba_alta_contexto_institucional_invalido()
    prueba_alta_contexto_sin_profesionales()