# app_jade / CORE / dominio / errores.py

from __future__ import annotations

from dataclasses import dataclass
from enum import Enum


# ============================================================
# CAMPOS DE ERROR DE DOMINIO
# ============================================================

class CampoErrorDominio(str, Enum):
    GENERAL = "general"

    # Contexto institucional
    CONTEXTO_INSTITUCIONAL = "contexto_institucional"
    COORDINADOR = "coordinador"
    PROFESIONALES = "profesionales"
    PROFESIONALES_INTERVINIENTES = "profesionales_intervinientes"

    # Alta
    SOLICITUD_ALTA = "solicitud_alta"
    TIPO_SOLICITUD = "tipo_solicitud"
    BENEFICIARIO = "beneficiario"
    RESPONSABLE_ADULTO = "responsable_adulto"

    # Baja
    SOLICITUD_BAJA = "solicitud_baja"
    TIPO_BENEFICIARIO = "tipo_beneficiario"
    MOTIVO_BAJA = "motivo_baja"


# ============================================================
# ERRORES DE DOMINIO
# ============================================================

@dataclass(frozen=True)
class ErrorDominio:
    campo: CampoErrorDominio
    mensaje_usuario: str
    mensaje_tecnico: str = ""


# ============================================================
# HELPERS
# ============================================================

# def agregar_error(
#     errores: list[ErrorDominio],
#     campo: CampoErrorDominio,
#     mensaje: str,
# ) -> None:
#     errores.append(
#         ErrorDominio(
#             campo=campo,
#             mensaje=mensaje,

#         )
#     )

def agregar_error(
    errores: list[ErrorDominio],
    campo: CampoErrorDominio,
    mensaje_usuario: str,
    mensaje_tecnico: str = "",
) -> None:
    errores.append(
        ErrorDominio(
            campo=campo,
            mensaje_usuario=mensaje_usuario,
            mensaje_tecnico=mensaje_tecnico,
        )
    )


# def errores_a_texto(errores: list[ErrorDominio]) -> str:
#     return "\n".join(error.mensaje for error in errores)
def errores_a_texto(errores: list[ErrorDominio]) -> str:
    return "\n".join(error.mensaje_usuario for error in errores)

def hay_errores(errores: list[ErrorDominio]) -> bool:
    return len(errores) > 0


MENSAJE_OPERACION_EXITOSA = "Operación exitosa."


def mensaje_resultado(errores: list[ErrorDominio]) -> str:
    if hay_errores(errores):
        return errores_a_texto(errores)

    return MENSAJE_OPERACION_EXITOSA