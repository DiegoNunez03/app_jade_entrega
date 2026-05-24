# app_jade / CORE / dominio / reglas.py

from __future__ import annotations

from CORE.dominio.catalogos import TipoSolicitudAlta
from CORE.dominio.entidades import (
    ContextoInstitucional,
    Destinatario,
    PersonalInstitucional,
    SolicitudAlta,
    SolicitudBaja,
    Tutor,
)
from CORE.dominio.errores import (
    CampoErrorDominio,
    ErrorDominio,
    agregar_error,
)


# ============================================================
# HELPERS INTERNOS
# ============================================================

def _clave_personal(persona: PersonalInstitucional) -> str:
    return f"{persona.nombre.strip().lower()}|{persona.apellido.strip().lower()}|{persona.rol.nombre.strip().lower()}"


def _hay_personas_repetidas(personas: list[PersonalInstitucional]) -> bool:
    claves = [_clave_personal(persona) for persona in personas]
    return len(claves) != len(set(claves))


def _pertenece_a_profesionales_configurados(
    profesional: PersonalInstitucional,
    contexto: ContextoInstitucional,
) -> bool:
    profesionales_configurados = {
        _clave_personal(profesional_configurado)
        for profesional_configurado in contexto.profesionales
    }

    return _clave_personal(profesional) in profesionales_configurados


# ============================================================
# REGLAS - CONTEXTO INSTITUCIONAL
# ============================================================

def validar_reglas_contexto_institucional(
    contexto: ContextoInstitucional,
) -> list[ErrorDominio]:
    errores: list[ErrorDominio] = []

    if len(contexto.profesionales) == 0:
        agregar_error(
            errores,
            CampoErrorDominio.PROFESIONALES,
            "El contexto institucional debe tener al menos un profesional configurado.",
        )

    if _hay_personas_repetidas(contexto.profesionales):
        agregar_error(
            errores,
            CampoErrorDominio.PROFESIONALES,
            "El contexto institucional no puede tener profesionales repetidos.",
        )

    return errores


# ============================================================
# REGLAS - SOLICITUD DE ALTA
# ============================================================

def validar_reglas_solicitud_alta(
    solicitud: SolicitudAlta,
) -> list[ErrorDominio]:
    errores: list[ErrorDominio] = []

    if solicitud.tipo_solicitud == TipoSolicitudAlta.DESTINATARIO:
        if not isinstance(solicitud.beneficiario, Destinatario):
            agregar_error(
                errores,
                CampoErrorDominio.BENEFICIARIO,
                "La solicitud de alta de destinatario debe tener un beneficiario de tipo Destinatario.",
            )

        if solicitud.responsable_adulto is None:
            agregar_error(
                errores,
                CampoErrorDominio.RESPONSABLE_ADULTO,
                "La solicitud de alta de destinatario debe tener responsable adulto.",
            )

    elif solicitud.tipo_solicitud == TipoSolicitudAlta.TUTOR:
        if not isinstance(solicitud.beneficiario, Tutor):
            agregar_error(
                errores,
                CampoErrorDominio.BENEFICIARIO,
                "La solicitud de alta de tutor debe tener un beneficiario de tipo Tutor.",
            )

    return errores


# ============================================================
# REGLAS - SOLICITUD DE BAJA
# ============================================================

def validar_reglas_solicitud_baja(
    solicitud: SolicitudBaja,
) -> list[ErrorDominio]:
    errores: list[ErrorDominio] = []

    if len(solicitud.profesionales_intervinientes) == 0:
        agregar_error(
            errores,
            CampoErrorDominio.PROFESIONALES_INTERVINIENTES,
            "La solicitud de baja debe tener al menos un profesional interviniente.",
        )

    if _hay_personas_repetidas(solicitud.profesionales_intervinientes):
        agregar_error(
            errores,
            CampoErrorDominio.PROFESIONALES_INTERVINIENTES,
            "La solicitud de baja no puede tener profesionales intervinientes repetidos.",
        )

    for profesional in solicitud.profesionales_intervinientes:
        if not _pertenece_a_profesionales_configurados(
            profesional,
            solicitud.contexto_institucional,
        ):
            agregar_error(
                errores,
                CampoErrorDominio.PROFESIONALES_INTERVINIENTES,
                f"El profesional interviniente {profesional.nombre_completo} no pertenece al contexto institucional configurado.",
            )

    return errores