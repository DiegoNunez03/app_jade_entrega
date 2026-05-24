# app_jade / CORE / mapeadores / mapeador_dominio.py

from __future__ import annotations

from CORE.dominio.catalogos import (
    TipoBeneficiarioBaja,
    TipoSolicitudAlta,
)
from CORE.dominio.entidades import (
    Rol,
    Ubicacion,
    Direccion,
    Telefono,
    Persona,
    PersonalInstitucional,
    BeneficiarioAlta,
    BeneficiarioBaja,
    Destinatario,
    Tutor,
    ResponsableAdulto,
    ResponsableBaja,
    ContextoInstitucional,
    SolicitudAlta,
    SolicitudBaja,
)
from CORE.schemas.base_schema import (
    RolSchema,
    UbicacionSchema,
    DireccionSchema,
    TelefonoSchema,
)
from CORE.schemas.personas_schema import (
    PersonaSchema,
    PersonalInstitucionalSchema,
    BeneficiarioAltaSchema,
    BeneficiarioBajaSchema,
    ResponsableAdultoSchema,
    ResponsableBajaSchema,
)
from CORE.schemas.contexto_institucional_schema import (
    ContextoInstitucionalSchema,
)
from CORE.schemas.solicitud_alta_schema import SolicitudAltaSchema
from CORE.schemas.solicitud_baja_schema import SolicitudBajaSchema


# ============================================================
# VALUE OBJECTS
# ============================================================

def mapear_rol(schema: RolSchema) -> Rol:
    return Rol(
        nombre=schema.nombre,
        siglas=schema.siglas,
    )


def mapear_ubicacion(schema: UbicacionSchema) -> Ubicacion:
    return Ubicacion(
        municipio=schema.municipio,
        localidad=schema.localidad,
        barrio=schema.barrio,
    )


def mapear_direccion(schema: DireccionSchema) -> Direccion:
    return Direccion(
        calle=schema.calle,
        numero=schema.numero,
    )


def mapear_telefono(schema: TelefonoSchema) -> Telefono:
    return Telefono(
        codigo_area=schema.codigo_area,
        numero=schema.numero,
    )


# ============================================================
# PERSONAS
# ============================================================

def mapear_persona(schema: PersonaSchema) -> Persona:
    return Persona(
        nombre=schema.nombre,
        apellido=schema.apellido,
    )


def mapear_personal_institucional(
    schema: PersonalInstitucionalSchema,
) -> PersonalInstitucional:
    return PersonalInstitucional(
        nombre=schema.nombre,
        apellido=schema.apellido,
        rol=mapear_rol(schema.rol),
    )


def mapear_beneficiario_alta(
    schema: BeneficiarioAltaSchema,
) -> BeneficiarioAlta:
    return BeneficiarioAlta(
        nombre=schema.nombre,
        apellido=schema.apellido,
        dni=schema.dni,
        direccion=mapear_direccion(schema.direccion),
        fecha_nacimiento=schema.fecha_nacimiento,
        escolarizado=schema.escolarizado,
    )


def mapear_beneficiario_baja(
    schema: BeneficiarioBajaSchema,
) -> BeneficiarioBaja:
    return BeneficiarioBaja(
        nombre=schema.nombre,
        apellido=schema.apellido,
        tipo_dni=schema.tipo_dni,
        dni=schema.dni,
        fecha_ingreso=schema.fecha_ingreso,
    )


def mapear_destinatario(
    schema: BeneficiarioAltaSchema,
) -> Destinatario:
    return Destinatario(
        nombre=schema.nombre,
        apellido=schema.apellido,
        dni=schema.dni,
        direccion=mapear_direccion(schema.direccion),
        fecha_nacimiento=schema.fecha_nacimiento,
        escolarizado=schema.escolarizado,
    )


def mapear_tutor(
    schema: BeneficiarioAltaSchema,
) -> Tutor:
    return Tutor(
        nombre=schema.nombre,
        apellido=schema.apellido,
        dni=schema.dni,
        direccion=mapear_direccion(schema.direccion),
        fecha_nacimiento=schema.fecha_nacimiento,
        escolarizado=schema.escolarizado,
    )


def mapear_responsable_adulto(
    schema: ResponsableAdultoSchema,
) -> ResponsableAdulto:
    return ResponsableAdulto(
        nombre=schema.nombre,
        apellido=schema.apellido,
        dni=schema.dni,
        direccion=mapear_direccion(schema.direccion),
        fecha_nacimiento=schema.fecha_nacimiento,
        parentesco=schema.parentesco,
        telefono=mapear_telefono(schema.telefono),
    )


def mapear_responsable_baja(
    schema: ResponsableBajaSchema,
) -> ResponsableBaja:
    return ResponsableBaja(
        nombre=schema.nombre,
        apellido=schema.apellido,
        relacion=schema.relacion,
        informado=schema.informado,
    )


# ============================================================
# CONTEXTO INSTITUCIONAL
# ============================================================

def mapear_contexto_institucional(
    schema: ContextoInstitucionalSchema,
) -> ContextoInstitucional:
    return ContextoInstitucional(
        origen=schema.origen,
        nombre_sede=schema.nombre_sede,
        ubicacion=mapear_ubicacion(schema.ubicacion),
        coordinador=mapear_personal_institucional(schema.coordinador),
        profesionales=[
            mapear_personal_institucional(profesional)
            for profesional in schema.profesionales
        ],
    )


# ============================================================
# SOLICITUDES
# ============================================================

def mapear_solicitud_alta(
    schema: SolicitudAltaSchema,
) -> SolicitudAlta:
    if schema.tipo_solicitud == TipoSolicitudAlta.DESTINATARIO:
        beneficiario = mapear_destinatario(schema.beneficiario)
    else:
        beneficiario = mapear_tutor(schema.beneficiario)

    responsable_adulto = None

    if schema.responsable_adulto is not None:
        responsable_adulto = mapear_responsable_adulto(
            schema.responsable_adulto
        )

    return SolicitudAlta(
        fecha_emision=schema.fecha_emision,
        tipo_solicitud=schema.tipo_solicitud,
        beneficiario=beneficiario,
        contexto_institucional=mapear_contexto_institucional(
            schema.contexto_institucional
        ),
        responsable_adulto=responsable_adulto,
    )


def mapear_solicitud_baja(
    schema: SolicitudBajaSchema,
) -> SolicitudBaja:
    return SolicitudBaja(
        fecha_emision=schema.fecha_emision,
        profesionales_intervinientes=[
            mapear_personal_institucional(profesional)
            for profesional in schema.profesionales_intervinientes
        ],
        tipo_beneficiario=schema.tipo_beneficiario,
        motivo=schema.motivo,
        beneficiario=mapear_beneficiario_baja(schema.beneficiario),
        responsable_adulto=mapear_responsable_baja(
            schema.responsable_adulto
        ),
        contexto_institucional=mapear_contexto_institucional(
            schema.contexto_institucional
        ),
    )

