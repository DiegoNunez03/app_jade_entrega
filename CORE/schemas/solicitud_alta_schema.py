# app_jade / CORE / schemas / solicitud_alta_schema.py

from __future__ import annotations

from datetime import date
from typing import Any

from pydantic import BaseModel, field_validator, model_validator

from CORE.dominio.catalogos import TipoSolicitudAlta
from CORE.schemas.base_schema import error_validacion
from CORE.schemas.contexto_institucional_schema import ContextoInstitucionalSchema
from CORE.schemas.personas_schema import (
    BeneficiarioAltaSchema,
    ResponsableAdultoSchema,
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
                f"SolicitudAltaSchema.fecha_emision recibió '{valor}'. "
                f"Fecha actual usada para comparación: '{hoy}'."
            ),
        )

    return valor


def validar_tipo_solicitud_alta(valor: Any) -> TipoSolicitudAlta:
    if isinstance(valor, TipoSolicitudAlta):
        return valor

    valor_normalizado = str(valor).strip().lower()

    try:
        return TipoSolicitudAlta(valor_normalizado)
    except ValueError:
        opciones_validas = ", ".join(tipo.value for tipo in TipoSolicitudAlta)

        error_validacion(
            mensaje_usuario="Tipo de solicitud: debe seleccionar una opción válida.",
            mensaje_tecnico=(
                f"SolicitudAltaSchema.tipo_solicitud recibió '{valor}'. "
                f"Opciones válidas: {opciones_validas}."
            ),
        )


# ============================================================
# SCHEMA - SOLICITUD DE ALTA
# ============================================================

class SolicitudAltaSchema(BaseModel):
    fecha_emision: date
    tipo_solicitud: TipoSolicitudAlta
    beneficiario: BeneficiarioAltaSchema
    contexto_institucional: ContextoInstitucionalSchema
    responsable_adulto: ResponsableAdultoSchema | None = None

    @field_validator("fecha_emision")
    @classmethod
    def validar_fecha_emision(cls, valor: date) -> date:
        return validar_fecha_emision_no_futura(valor)

    @field_validator("tipo_solicitud", mode="before")
    @classmethod
    def validar_tipo_solicitud(cls, valor: Any) -> TipoSolicitudAlta:
        return validar_tipo_solicitud_alta(valor)

    @model_validator(mode="after")
    def validar_reglas_de_entrada(self) -> "SolicitudAltaSchema":
        if (
            self.tipo_solicitud == TipoSolicitudAlta.DESTINATARIO
            and self.responsable_adulto is None
        ):
            error_validacion(
                mensaje_usuario=(
                    "Responsable adulto: es obligatorio para una solicitud "
                    "de alta de destinatario."
                ),
                mensaje_tecnico=(
                    "SolicitudAltaSchema recibió tipo_solicitud='destinatario' "
                    "con responsable_adulto=None."
                ),
            )

        if (
            self.tipo_solicitud == TipoSolicitudAlta.TUTOR
            and self.responsable_adulto is not None
        ):
            error_validacion(
                mensaje_usuario=(
                    "Responsable adulto: no debe cargarse para una solicitud "
                    "de alta de tutor."
                ),
                mensaje_tecnico=(
                    "SolicitudAltaSchema recibió tipo_solicitud='tutor' "
                    "con responsable_adulto cargado."
                ),
            )

        return self