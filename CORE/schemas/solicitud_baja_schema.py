# app_jade / CORE / schemas / solicitud_baja_schema.py

from __future__ import annotations

from datetime import date
from typing import Any

from pydantic import BaseModel, field_validator

from CORE.dominio.catalogos import (
    TipoBeneficiarioBaja,
    MotivoBaja,
)
from CORE.schemas.base_schema import error_validacion
from CORE.schemas.contexto_institucional_schema import ContextoInstitucionalSchema
from CORE.schemas.personas_schema import (
    PersonalInstitucionalSchema,
    BeneficiarioBajaSchema,
    ResponsableBajaSchema,
)


# ============================================================
# HELPERS DE VALIDACIÓN
# ============================================================

def validar_fecha_emision_no_futura(valor: date) -> date:
    hoy = date.today()

    if valor > hoy:
        error_validacion(
            mensaje_usuario="Fecha de emisión: no puede ser una fecha futura.",
            mensaje_tecnico=(
                f"SolicitudBajaSchema.fecha_emision recibió '{valor}'. "
                f"Fecha actual usada para comparación: '{hoy}'."
            ),
        )

    return valor


def validar_tipo_beneficiario_baja(valor: Any) -> TipoBeneficiarioBaja:
    if isinstance(valor, TipoBeneficiarioBaja):
        return valor

    valor_normalizado = str(valor).strip().lower()

    try:
        return TipoBeneficiarioBaja(valor_normalizado)

    except ValueError:
        opciones_validas = ", ".join(
            tipo.value for tipo in TipoBeneficiarioBaja
        )

        error_validacion(
            mensaje_usuario="Tipo de beneficiario: debe seleccionar una opción válida.",
            mensaje_tecnico=(
                f"SolicitudBajaSchema.tipo_beneficiario recibió '{valor}'. "
                f"Opciones válidas: {opciones_validas}."
            ),
        )


def validar_motivo_baja(valor: Any) -> MotivoBaja:
    if isinstance(valor, MotivoBaja):
        return valor

    valor_normalizado = str(valor).strip()

    try:
        return MotivoBaja(valor_normalizado)

    except ValueError:
        opciones_validas = ", ".join(
            motivo.value for motivo in MotivoBaja
        )

        error_validacion(
            mensaje_usuario="Motivo de baja: debe seleccionar una opción válida.",
            mensaje_tecnico=(
                f"SolicitudBajaSchema.motivo recibió '{valor}'. "
                f"Opciones válidas: {opciones_validas}."
            ),
        )


# ============================================================
# SCHEMA - SOLICITUD DE BAJA
# ============================================================

class SolicitudBajaSchema(BaseModel):
    fecha_emision: date
    profesionales_intervinientes: list[PersonalInstitucionalSchema]
    tipo_beneficiario: TipoBeneficiarioBaja
    motivo: MotivoBaja
    beneficiario: BeneficiarioBajaSchema
    responsable_adulto: ResponsableBajaSchema
    contexto_institucional: ContextoInstitucionalSchema

    @field_validator("fecha_emision")
    @classmethod
    def validar_fecha_emision(cls, valor: date) -> date:
        return validar_fecha_emision_no_futura(valor)

    @field_validator("tipo_beneficiario", mode="before")
    @classmethod
    def validar_tipo_beneficiario(cls, valor: Any) -> TipoBeneficiarioBaja:
        return validar_tipo_beneficiario_baja(valor)

    @field_validator("motivo", mode="before")
    @classmethod
    def validar_motivo(cls, valor: Any) -> MotivoBaja:
        return validar_motivo_baja(valor)

    @field_validator("profesionales_intervinientes")
    @classmethod
    def validar_profesionales_intervinientes(
        cls,
        valor: list[PersonalInstitucionalSchema],
    ) -> list[PersonalInstitucionalSchema]:
        if len(valor) == 0:
            error_validacion(
                mensaje_usuario=(
                    "Profesionales intervinientes: debe seleccionar al menos "
                    "un profesional."
                ),
                mensaje_tecnico=(
                    "SolicitudBajaSchema.profesionales_intervinientes recibió "
                    "una lista vacía. Se esperaba al menos un "
                    "PersonalInstitucionalSchema."
                ),
            )

        return valor
