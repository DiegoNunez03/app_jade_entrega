# CORE/dominio/catalogos.py

from __future__ import annotations

from enum import Enum


# ============================================================
# TIPOS DE SOLICITUD
# ============================================================

class TipoSolicitudAlta(str, Enum):
    DESTINATARIO = "destinatario"
    TUTOR = "tutor"


class TipoBeneficiarioBaja(str, Enum):
    DESTINATARIO = "destinatario"
    TUTOR = "tutor"


# ============================================================
# MOTIVOS DE BAJA
# ============================================================

class MotivoBaja(str, Enum):
    PRIVADO_LIBERTAD = "Encontrarse privado de la libertad"
    FALLECIMIENTO = "Fallecimiento"
    CUMPLIMIENTO_ACUERDOS = "Haber cumplimentado con todos los acuerdos para su egreso"
    LIQUIDACIONES_IMPAGAS = "Liquidaciones consecutivas impagas"
    MUDANZA = "Mudanza a otro Municipio"
    NEGATIVA_ACUERDO = "Negativa a cumplir con su Acuerdo de Compromiso"
    NEGATIVA_JOVEN = "Negativa del Joven a participar"
    DIFICULTADES_SOCIALIZACION = "Negativa o dificultades al momento de la socialización"
    PASE_DESTINATARIO_TUTOR = "Pase de Destinatario a Tutor"
    PASE_TUTOR_DESTINATARIO = "Pase de Tutor a Destinatario"
    TRABAJO_FORMAL = "Trabajo Formal"
    OTROS = "Otros motivos"


# ============================================================
# PARENTESCOS
# ============================================================

class TipoParentesco(str, Enum):
    MADRE = "Madre"
    PADRE = "Padre"
    TUTOR = "Tutor"
    TUTORA = "Tutora"
    ABUELA = "Abuela"
    ABUELO = "Abuelo"
    TIA = "Tía"
    TIO = "Tío"
    HERMANA = "Hermana"
    HERMANO = "Hermano"
    OTRO = "Otro"


# ============================================================
# ROLES INSTITUCIONALES
# ============================================================

class RolInstitucional(str, Enum):
    PROFESOR_EDUCACION_FISICA = "Profesor de educación física"
    TRABAJADORA_SOCIAL = "Trabajadora social"
    PSICOLOGA = "Psicóloga"
    PSICOPEDAGOGA = "Psicopedagoga"


# ============================================================
# SIGLAS DE ROLES
# ============================================================

SIGLAS_ROLES_INSTITUCIONALES: dict[RolInstitucional, str] = {
    RolInstitucional.PROFESOR_EDUCACION_FISICA: "EFC",
    RolInstitucional.TRABAJADORA_SOCIAL: "TS",
    RolInstitucional.PSICOLOGA: "PSI",
    RolInstitucional.PSICOPEDAGOGA: "PSP",
}


# # ============================================================
# # HELPERS DE CATÁLOGO
# # ============================================================

# def obtener_siglas_rol(rol: RolInstitucional) -> str:
#     return SIGLAS_ROLES_INSTITUCIONALES[rol]


# def listar_roles_institucionales() -> list[str]:
#     return [rol.value for rol in RolInstitucional]


# def listar_parentescos() -> list[str]:
#     return [parentesco.value for parentesco in TipoParentesco]


# def listar_motivos_baja() -> list[str]:
#     return [motivo.value for motivo in MotivoBaja]