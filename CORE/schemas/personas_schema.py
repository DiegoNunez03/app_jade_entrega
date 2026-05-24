# app_jade / CORE / schemas / personas_schema.py

from __future__ import annotations

from datetime import date, datetime

from pydantic import BaseModel, field_validator

from CORE.dominio.catalogos import TipoParentesco
from CORE.schemas.base_schema import (
    DireccionSchema,
    RolSchema,
    TelefonoSchema,
    PATRON_TEXTO_PERSONA,
    validar_texto_obligatorio,
    validar_patron,
    validar_entero_positivo_como_texto,
    error_validacion,
)


# ============================================================
# HELPERS DE VALIDACIÓN
# ============================================================

def validar_nombre_persona(
    valor: str,
    campo: str,
    clase: str,
    atributo: str,
) -> str:
    valor = validar_texto_obligatorio(valor, campo)

    return validar_patron(
        valor=valor,
        patron=PATRON_TEXTO_PERSONA,
        mensaje_usuario=f"{campo}: solo permite letras, acentos y espacios.",
        mensaje_tecnico=(
            f"{clase}.{atributo} recibió '{valor}'. "
            "Patrón esperado: letras, acentos y espacios."
        ),
    )


def validar_dni_persona(
    valor: str,
    campo: str,
    clase: str,
    atributo: str,
) -> str:
    valor = validar_entero_positivo_como_texto(
        valor=valor,
        campo=campo,
    )

    if len(valor) != 8:
        error_validacion(
            mensaje_usuario=f"{campo}: debe tener exactamente 8 dígitos.",
            mensaje_tecnico=(
                f"{clase}.{atributo} recibió '{valor}'. "
                f"Longitud recibida: {len(valor)}. Longitud esperada: 8."
            ),
        )

    return valor


def validar_fecha_no_futura(
    valor: date,
    campo: str,
    clase: str,
    atributo: str,
) -> date:
    hoy = date.today()

    if valor > hoy:
        error_validacion(
            mensaje_usuario=f"{campo}: no puede ser una fecha futura.",
            mensaje_tecnico=(
                f"{clase}.{atributo} recibió '{valor}'. "
                f"Fecha actual usada para comparación: '{hoy}'."
            ),
        )

    return valor


def validar_fecha_texto_dd_mm_aaaa(
    valor: str,
    campo: str,
    clase: str,
    atributo: str,
) -> str:
    valor = validar_texto_obligatorio(valor, campo)

    try:
        fecha = datetime.strptime(valor, "%d/%m/%Y").date()

    except ValueError:
        error_validacion(
            mensaje_usuario=f"{campo}: debe tener formato dd/mm/aaaa.",
            mensaje_tecnico=(
                f"{clase}.{atributo} recibió '{valor}'. "
                "Formato esperado: dd/mm/aaaa."
            ),
        )

    validar_fecha_no_futura(
        valor=fecha,
        campo=campo,
        clase=clase,
        atributo=atributo,
    )

    return valor


# ============================================================
# SCHEMAS DE PERSONAS
# ============================================================

class PersonaSchema(BaseModel):
    nombre: str
    apellido: str

    @field_validator("nombre")
    @classmethod
    def validar_nombre(cls, valor: str) -> str:
        return validar_nombre_persona(
            valor=valor,
            campo="Nombre",
            clase="PersonaSchema",
            atributo="nombre",
        )

    @field_validator("apellido")
    @classmethod
    def validar_apellido(cls, valor: str) -> str:
        return validar_nombre_persona(
            valor=valor,
            campo="Apellido",
            clase="PersonaSchema",
            atributo="apellido",
        )


class PersonalInstitucionalSchema(PersonaSchema):
    rol: RolSchema


class BeneficiarioAltaSchema(PersonaSchema):
    dni: str
    direccion: DireccionSchema
    fecha_nacimiento: date
    escolarizado: bool | None = None

    @field_validator("dni")
    @classmethod
    def validar_dni(cls, valor: str) -> str:
        return validar_dni_persona(
            valor=valor,
            campo="DNI",
            clase="BeneficiarioAltaSchema",
            atributo="dni",
        )

    @field_validator("fecha_nacimiento")
    @classmethod
    def validar_fecha_nacimiento(cls, valor: date) -> date:
        return validar_fecha_no_futura(
            valor=valor,
            campo="Fecha de nacimiento",
            clase="BeneficiarioAltaSchema",
            atributo="fecha_nacimiento",
        )


class BeneficiarioBajaSchema(PersonaSchema):
    tipo_dni: str
    dni: str
    fecha_ingreso: str

    @field_validator("tipo_dni")
    @classmethod
    def validar_tipo_dni(cls, valor: str) -> str:
        valor = validar_texto_obligatorio(valor, "Tipo de documento")
        valor_normalizado = valor.strip().upper()

        if valor_normalizado != "DNI":
            error_validacion(
                mensaje_usuario="Tipo de documento: por ahora debe ser DNI.",
                mensaje_tecnico=(
                    f"BeneficiarioBajaSchema.tipo_dni recibió '{valor}'. "
                    "Valor esperado: DNI."
                ),
            )

        return valor_normalizado

    @field_validator("dni")
    @classmethod
    def validar_dni(cls, valor: str) -> str:
        return validar_dni_persona(
            valor=valor,
            campo="DNI",
            clase="BeneficiarioBajaSchema",
            atributo="dni",
        )

    @field_validator("fecha_ingreso")
    @classmethod
    def validar_fecha_ingreso(cls, valor: str) -> str:
        return validar_fecha_texto_dd_mm_aaaa(
            valor=valor,
            campo="Fecha de ingreso",
            clase="BeneficiarioBajaSchema",
            atributo="fecha_ingreso",
        )


class DestinatarioSchema(BeneficiarioAltaSchema):
    pass


class TutorSchema(BeneficiarioAltaSchema):
    pass


class ResponsableAdultoSchema(PersonaSchema):
    dni: str
    direccion: DireccionSchema
    fecha_nacimiento: date
    parentesco: TipoParentesco
    telefono: TelefonoSchema

    @field_validator("dni")
    @classmethod
    def validar_dni(cls, valor: str) -> str:
        return validar_dni_persona(
            valor=valor,
            campo="Responsable adulto - DNI",
            clase="ResponsableAdultoSchema",
            atributo="dni",
        )

    @field_validator("fecha_nacimiento")
    @classmethod
    def validar_fecha_nacimiento(cls, valor: date) -> date:
        return validar_fecha_no_futura(
            valor=valor,
            campo="Responsable adulto - Fecha de nacimiento",
            clase="ResponsableAdultoSchema",
            atributo="fecha_nacimiento",
        )


class ResponsableBajaSchema(PersonaSchema):
    relacion: str
    informado: str

    @field_validator("relacion")
    @classmethod
    def validar_relacion(cls, valor: str) -> str:
        valor = validar_texto_obligatorio(valor, "Relación con el joven")

        relaciones_validas = {
            "Madre",
            "Padre",
            "Tutor Legal",
            "Abuela",
            "Abuelo",
            "Tía",
            "Tío",
            "Hermana",
            "Hermano",
            "Otro",
        }

        if valor not in relaciones_validas:
            error_validacion(
                mensaje_usuario="Relación con el joven: debe seleccionar una opción válida.",
                mensaje_tecnico=(
                    f"ResponsableBajaSchema.relacion recibió '{valor}'. "
                    f"Opciones válidas: {', '.join(relaciones_validas)}."
                ),
            )

        return valor

    @field_validator("informado")
    @classmethod
    def validar_informado(cls, valor: str) -> str:
        valor = validar_texto_obligatorio(
            valor,
            "Adulto responsable informado",
        )

        if valor not in {"Sí", "Si", "No"}:
            error_validacion(
                mensaje_usuario="Adulto responsable informado: debe seleccionar Sí o No.",
                mensaje_tecnico=(
                    f"ResponsableBajaSchema.informado recibió '{valor}'. "
                    "Opciones válidas: Sí, No."
                ),
            )

        if valor == "Si":
            return "Sí"

        return valor


