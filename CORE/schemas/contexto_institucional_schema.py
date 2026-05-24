# app_jade / CORE / schemas / contexto_institucional_schema.py

from __future__ import annotations

from pydantic import BaseModel, field_validator

from CORE.schemas.base_schema import (
    UbicacionSchema,
    PATRON_TEXTO_PERSONA,
    PATRON_TEXTO_CON_NUMEROS,
    validar_texto_obligatorio,
    validar_patron,
    error_validacion,
)
from CORE.schemas.personas_schema import PersonalInstitucionalSchema


# ============================================================
# SCHEMA - CONTEXTO INSTITUCIONAL
# ============================================================

class ContextoInstitucionalSchema(BaseModel):
    origen: str
    nombre_sede: str
    ubicacion: UbicacionSchema
    coordinador: PersonalInstitucionalSchema
    profesionales: list[PersonalInstitucionalSchema]

    @field_validator("origen")
    @classmethod
    def validar_origen(cls, valor: str) -> str:
        valor = validar_texto_obligatorio(valor, "Origen")

        return validar_patron(
            valor=valor,
            patron=PATRON_TEXTO_PERSONA,
            mensaje_usuario="Origen: solo permite letras, acentos y espacios.",
            mensaje_tecnico=(
                f"ContextoInstitucionalSchema.origen recibió '{valor}'. "
                "Patrón esperado: letras, acentos y espacios."
            ),
        )

    @field_validator("nombre_sede")
    @classmethod
    def validar_nombre_sede(cls, valor: str) -> str:
        valor = validar_texto_obligatorio(valor, "Nombre de sede")

        return validar_patron(
            valor=valor,
            patron=PATRON_TEXTO_CON_NUMEROS,
            mensaje_usuario="Nombre de sede: solo permite letras, números, acentos y espacios.",
            mensaje_tecnico=(
                f"ContextoInstitucionalSchema.nombre_sede recibió '{valor}'. "
                "Patrón esperado: letras, números, acentos y espacios."
            ),
        )

    @field_validator("profesionales")
    @classmethod
    def validar_profesionales(cls, valor: list[PersonalInstitucionalSchema]) -> list[PersonalInstitucionalSchema]:
        if len(valor) == 0:
            error_validacion(
                mensaje_usuario="Profesionales: debe cargar al menos un profesional.",
                mensaje_tecnico=(
                    "ContextoInstitucionalSchema.profesionales recibió una lista vacía. "
                    "Se esperaba al menos un PersonalInstitucionalSchema."
                ),
            )

        return valor