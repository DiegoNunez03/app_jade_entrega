#  app_jade / core / dominio / entidades.py

from __future__ import annotations
from dataclasses import dataclass
from datetime import date

from CORE.dominio.catalogos import (
    TipoSolicitudAlta,
    TipoBeneficiarioBaja,
    MotivoBaja,
    TipoParentesco,
    # RolInstitucional,
)

# ============================================================
# VALUE OBJECTS
# ============================================================

@dataclass(frozen=True)
class Rol:
    nombre: str
    siglas: str


@dataclass(frozen=True)
class Ubicacion:
    municipio: str
    localidad: str
    barrio: str = ""


@dataclass(frozen=True)
class Direccion:
    calle: str
    numero: str


@dataclass(frozen=True)
class Telefono:
    codigo_area: str
    numero: str

    @property
    def completo(self) -> str:
        return f"{self.codigo_area} {self.numero}"


# ============================================================
# PERSONAS
# ============================================================

@dataclass(frozen=True)
class Persona:
    nombre: str
    apellido: str

    @property
    def nombre_completo(self) -> str:
        return f"{self.nombre} {self.apellido}"


@dataclass(frozen=True)
class PersonalInstitucional(Persona):
    rol: Rol


@dataclass(frozen=True)
class BeneficiarioAlta(Persona):
    dni: str
    direccion: Direccion
    fecha_nacimiento: date
    escolarizado: bool | None = None

@dataclass(frozen=True)
class BeneficiarioBaja(Persona):
    tipo_dni: str
    dni: str
    fecha_ingreso: str


@dataclass(frozen=True)
class Destinatario(BeneficiarioAlta):
    pass


@dataclass(frozen=True)
class Tutor(BeneficiarioAlta):
    pass


@dataclass(frozen=True)
class ResponsableAdulto(Persona):
    dni: str
    direccion: Direccion
    fecha_nacimiento: date
    parentesco: TipoParentesco
    telefono: Telefono


# ============================================================
# CONTEXTO INSTITUCIONAL
# ============================================================

@dataclass(frozen=True)
class ContextoInstitucional:
    origen: str
    nombre_sede: str
    ubicacion: Ubicacion
    coordinador: PersonalInstitucional
    profesionales: list[PersonalInstitucional]


# ============================================================
# SOLICITUDES
# ============================================================

@dataclass(frozen=True)
class SolicitudAlta:
    fecha_emision: date
    tipo_solicitud: TipoSolicitudAlta
    beneficiario: BeneficiarioAlta
    contexto_institucional: ContextoInstitucional
    responsable_adulto: ResponsableAdulto | None = None


@dataclass(frozen=True)
class SolicitudBaja:
    fecha_emision: date
    profesionales_intervinientes: list[PersonalInstitucional]
    tipo_beneficiario: TipoBeneficiarioBaja
    motivo: MotivoBaja
    beneficiario: BeneficiarioBaja
    responsable_adulto: ResponsableBaja
    contexto_institucional: ContextoInstitucional

@dataclass(frozen=True)
class ResponsableBaja(Persona):
    relacion: str
    informado: str