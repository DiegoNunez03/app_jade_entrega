# pruebas/test_personas_schema_manual.py

from __future__ import annotations

import sys
from pathlib import Path
from datetime import date, timedelta

from pydantic import ValidationError

RUTA_RAIZ_PROYECTO = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(RUTA_RAIZ_PROYECTO))

from CORE.schemas.personas_schema import (
    PersonaSchema,
    PersonalInstitucionalSchema,
    DestinatarioSchema,
    TutorSchema,
    ResponsableAdultoSchema,
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
# DATOS BASE
# ============================================================

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


def rol_valido() -> dict:
    return {
        "nombre": "Trabajadora social",
        "siglas": "TS",
    }


# ============================================================
# PRUEBAS - PERSONA
# ============================================================

def prueba_persona_valida() -> None:
    probar_schema(
        "PRUEBA 1 - Persona válida",
        PersonaSchema,
        {
            "nombre": "Juan",
            "apellido": "López",
        },
    )


def prueba_persona_nombre_vacio() -> None:
    probar_schema(
        "PRUEBA 2 - Persona con nombre vacío",
        PersonaSchema,
        {
            "nombre": "",
            "apellido": "López",
        },
    )


def prueba_persona_apellido_con_numeros() -> None:
    probar_schema(
        "PRUEBA 3 - Persona con apellido inválido",
        PersonaSchema,
        {
            "nombre": "Juan",
            "apellido": "López123",
        },
    )


# ============================================================
# PRUEBAS - PERSONAL INSTITUCIONAL
# ============================================================

def prueba_personal_institucional_valido() -> None:
    probar_schema(
        "PRUEBA 4 - Personal institucional válido",
        PersonalInstitucionalSchema,
        {
            "nombre": "Laura",
            "apellido": "Gómez",
            "rol": rol_valido(),
        },
    )


def prueba_personal_institucional_rol_invalido() -> None:
    probar_schema(
        "PRUEBA 5 - Personal institucional con rol inválido",
        PersonalInstitucionalSchema,
        {
            "nombre": "Laura",
            "apellido": "Gómez",
            "rol": {
                "nombre": "Trabajadora social 123",
                "siglas": "TS",
            },
        },
    )


# ============================================================
# PRUEBAS - DESTINATARIO
# ============================================================

def prueba_destinatario_valido() -> None:
    probar_schema(
        "PRUEBA 6 - Destinatario válido",
        DestinatarioSchema,
        {
            "nombre": "Juan",
            "apellido": "López",
            "dni": "12345678",
            "direccion": direccion_valida(),
            "fecha_nacimiento": date(2010, 5, 10),
            "escolarizado": True,
        },
    )


def prueba_destinatario_dni_con_letras() -> None:
    probar_schema(
        "PRUEBA 7 - Destinatario con DNI con letras",
        DestinatarioSchema,
        {
            "nombre": "Juan",
            "apellido": "López",
            "dni": "1234A678",
            "direccion": direccion_valida(),
            "fecha_nacimiento": date(2010, 5, 10),
            "escolarizado": True,
        },
    )


def prueba_destinatario_dni_menos_de_8_digitos() -> None:
    probar_schema(
        "PRUEBA 8 - Destinatario con DNI de menos de 8 dígitos",
        DestinatarioSchema,
        {
            "nombre": "Juan",
            "apellido": "López",
            "dni": "1234567",
            "direccion": direccion_valida(),
            "fecha_nacimiento": date(2010, 5, 10),
            "escolarizado": True,
        },
    )


def prueba_destinatario_dni_mas_de_8_digitos() -> None:
    probar_schema(
        "PRUEBA 9 - Destinatario con DNI de más de 8 dígitos",
        DestinatarioSchema,
        {
            "nombre": "Juan",
            "apellido": "López",
            "dni": "123456789",
            "direccion": direccion_valida(),
            "fecha_nacimiento": date(2010, 5, 10),
            "escolarizado": True,
        },
    )


def prueba_destinatario_fecha_futura() -> None:
    probar_schema(
        "PRUEBA 10 - Destinatario con fecha de nacimiento futura",
        DestinatarioSchema,
        {
            "nombre": "Juan",
            "apellido": "López",
            "dni": "12345678",
            "direccion": direccion_valida(),
            "fecha_nacimiento": date.today() + timedelta(days=1),
            "escolarizado": True,
        },
    )


def prueba_destinatario_direccion_invalida() -> None:
    probar_schema(
        "PRUEBA 11 - Destinatario con dirección inválida",
        DestinatarioSchema,
        {
            "nombre": "Juan",
            "apellido": "López",
            "dni": "12345678",
            "direccion": {
                "calle": "Rivadavia Nº",
                "numero": "123",
            },
            "fecha_nacimiento": date(2010, 5, 10),
            "escolarizado": True,
        },
    )


# ============================================================
# PRUEBAS - TUTOR
# ============================================================

def prueba_tutor_valido_sin_escolarizado() -> None:
    probar_schema(
        "PRUEBA 12 - Tutor válido sin escolarizado",
        TutorSchema,
        {
            "nombre": "Carlos",
            "apellido": "Martínez",
            "dni": "23456789",
            "direccion": {
                "calle": "Mitre",
                "numero": "456",
            },
            "fecha_nacimiento": date(1995, 8, 15),
            "escolarizado": None,
        },
    )


def prueba_tutor_valido_con_escolarizado() -> None:
    probar_schema(
        "PRUEBA 13 - Tutor válido con escolarizado",
        TutorSchema,
        {
            "nombre": "Carlos",
            "apellido": "Martínez",
            "dni": "23456789",
            "direccion": {
                "calle": "Mitre",
                "numero": "456",
            },
            "fecha_nacimiento": date(1995, 8, 15),
            "escolarizado": False,
        },
    )


# ============================================================
# PRUEBAS - RESPONSABLE ADULTO
# ============================================================

def prueba_responsable_adulto_valido() -> None:
    probar_schema(
        "PRUEBA 14 - Responsable adulto válido",
        ResponsableAdultoSchema,
        {
            "nombre": "María",
            "apellido": "López",
            "dni": "87654321",
            "direccion": direccion_valida(),
            "fecha_nacimiento": date(1980, 3, 20),
            "parentesco": "Madre",
            "telefono": telefono_valido(),
        },
    )


def prueba_responsable_adulto_parentesco_invalido() -> None:
    probar_schema(
        "PRUEBA 15 - Responsable adulto con parentesco inválido",
        ResponsableAdultoSchema,
        {
            "nombre": "María",
            "apellido": "López",
            "dni": "87654321",
            "direccion": direccion_valida(),
            "fecha_nacimiento": date(1980, 3, 20),
            "parentesco": "Vecina",
            "telefono": telefono_valido(),
        },
    )


def prueba_responsable_adulto_telefono_invalido() -> None:
    probar_schema(
        "PRUEBA 16 - Responsable adulto con teléfono inválido",
        ResponsableAdultoSchema,
        {
            "nombre": "María",
            "apellido": "López",
            "dni": "87654321",
            "direccion": direccion_valida(),
            "fecha_nacimiento": date(1980, 3, 20),
            "parentesco": "Madre",
            "telefono": {
                "codigo_area": "293",
                "numero": "123456",
            },
        },
    )


def prueba_responsable_adulto_fecha_futura() -> None:
    probar_schema(
        "PRUEBA 17 - Responsable adulto con fecha futura",
        ResponsableAdultoSchema,
        {
            "nombre": "María",
            "apellido": "López",
            "dni": "87654321",
            "direccion": direccion_valida(),
            "fecha_nacimiento": date.today() + timedelta(days=1),
            "parentesco": "Madre",
            "telefono": telefono_valido(),
        },
    )


# ============================================================
# EJECUCIÓN MANUAL
# ============================================================

if __name__ == "__main__":
    prueba_persona_valida()
    prueba_persona_nombre_vacio()
    prueba_persona_apellido_con_numeros()

    prueba_personal_institucional_valido()
    prueba_personal_institucional_rol_invalido()

    prueba_destinatario_valido()
    prueba_destinatario_dni_con_letras()
    prueba_destinatario_dni_menos_de_8_digitos()
    prueba_destinatario_dni_mas_de_8_digitos()
    prueba_destinatario_fecha_futura()
    prueba_destinatario_direccion_invalida()

    prueba_tutor_valido_sin_escolarizado()
    prueba_tutor_valido_con_escolarizado()

    prueba_responsable_adulto_valido()
    prueba_responsable_adulto_parentesco_invalido()
    prueba_responsable_adulto_telefono_invalido()
    prueba_responsable_adulto_fecha_futura()