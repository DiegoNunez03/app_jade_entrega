# app_jade / CORE / schemas / base_schema.py

from __future__ import annotations

import re

from pydantic import BaseModel, field_validator
from pydantic_core import PydanticCustomError


# ============================================================
# PATRONES BASE
# ============================================================

PATRON_TEXTO_PERSONA = re.compile(
    r"^[A-Za-zÁÉÍÓÚÜÑáéíóúüñ\s]+$"
)

PATRON_TEXTO_CON_NUMEROS = re.compile(
    r"^[A-Za-zÁÉÍÓÚÜÑáéíóúüñ0-9\s]+$"
)

PATRON_NUMERO_DOMICILIO = re.compile(
    r"^[A-Za-z0-9/-]+$"
)

PATRON_SIGLAS = re.compile(
    r"^[A-ZÁÉÍÓÚÜÑ]{1,10}$"
)


# ============================================================
# HELPERS DE VALIDACIÓN
# ============================================================

def limpiar_texto(valor: str) -> str:
    return valor.strip()


def error_validacion(
    mensaje_usuario: str,
    mensaje_tecnico: str = "",
) -> None:
    """
    Lanza un error de Pydantic con dos niveles de mensaje:
    - mensaje_usuario: mensaje limpio para mostrar en QML.
    - mensaje_tecnico: detalle para consola/desarrollo.
    """

    raise PydanticCustomError(
        "jade_validacion",
        mensaje_usuario,
        {
            "mensaje_usuario": mensaje_usuario,
            "mensaje_tecnico": mensaje_tecnico,
        },
    )


def validar_texto_obligatorio(valor: str, campo: str) -> str:
    valor_limpio = limpiar_texto(valor)

    if valor_limpio == "":
        error_validacion(
            mensaje_usuario=f"{campo}: es obligatorio.",
            mensaje_tecnico=f"{campo} recibió un texto vacío o compuesto solo por espacios.",
        )

    return valor_limpio


def validar_patron(
    valor: str,
    patron: re.Pattern[str],
    mensaje_usuario: str,
    mensaje_tecnico: str = "",
) -> str:
    if not patron.fullmatch(valor):
        error_validacion(
            mensaje_usuario=mensaje_usuario,
            mensaje_tecnico=mensaje_tecnico,
        )

    return valor


def validar_entero_positivo_como_texto(
    valor: str,
    campo: str,
) -> str:
    valor_limpio = validar_texto_obligatorio(valor, campo)

    if not valor_limpio.isdigit():
        error_validacion(
            mensaje_usuario=f"{campo}: debe contener solo dígitos.",
            mensaje_tecnico=f"{campo} recibió '{valor_limpio}'. Se esperaban solo dígitos.",
        )

    if int(valor_limpio) <= 0:
        error_validacion(
            mensaje_usuario=f"{campo}: debe ser mayor a cero.",
            mensaje_tecnico=f"{campo} recibió '{valor_limpio}'. El valor numérico debe ser mayor a cero.",
        )

    return valor_limpio


def validar_longitud_texto(
    valor: str,
    campo: str,
    minimo: int,
    maximo: int,
) -> str:
    cantidad = len(valor)

    if cantidad < minimo or cantidad > maximo:
        error_validacion(
            mensaje_usuario=f"{campo}: debe tener entre {minimo} y {maximo} dígitos.",
            mensaje_tecnico=f"{campo} recibió '{valor}'. Longitud recibida: {cantidad}. Longitud esperada: entre {minimo} y {maximo}.",
        )

    return valor


# ============================================================
# SCHEMAS BASE
# ============================================================

class RolSchema(BaseModel):
    nombre: str
    siglas: str

    @field_validator("nombre")
    @classmethod
    def validar_nombre(cls, valor: str) -> str:
        valor = validar_texto_obligatorio(valor, "Rol")

        return validar_patron(
            valor=valor,
            patron=PATRON_TEXTO_PERSONA,
            mensaje_usuario="Rol: solo permite letras, acentos y espacios.",
            mensaje_tecnico=f"RolSchema.nombre recibió '{valor}'. Patrón esperado: letras, acentos y espacios.",
        )

    @field_validator("siglas")
    @classmethod
    def validar_siglas(cls, valor: str) -> str:
        valor = validar_texto_obligatorio(valor, "Siglas del rol").upper()

        return validar_patron(
            valor=valor,
            patron=PATRON_SIGLAS,
            mensaje_usuario="Siglas del rol: solo permite letras mayúsculas.",
            mensaje_tecnico=f"RolSchema.siglas recibió '{valor}'. Patrón esperado: letras mayúsculas, entre 1 y 10 caracteres.",
        )


class UbicacionSchema(BaseModel):
    municipio: str
    localidad: str
    barrio: str = ""

    @field_validator("municipio")
    @classmethod
    def validar_municipio(cls, valor: str) -> str:
        valor = validar_texto_obligatorio(valor, "Municipio")

        return validar_patron(
            valor=valor,
            patron=PATRON_TEXTO_PERSONA,
            mensaje_usuario="Municipio: solo permite letras, acentos y espacios.",
            mensaje_tecnico=f"UbicacionSchema.municipio recibió '{valor}'. Patrón esperado: letras, acentos y espacios.",
        )

    @field_validator("localidad")
    @classmethod
    def validar_localidad(cls, valor: str) -> str:
        valor = validar_texto_obligatorio(valor, "Localidad")

        return validar_patron(
            valor=valor,
            patron=PATRON_TEXTO_PERSONA,
            mensaje_usuario="Localidad: solo permite letras, acentos y espacios.",
            mensaje_tecnico=f"UbicacionSchema.localidad recibió '{valor}'. Patrón esperado: letras, acentos y espacios.",
        )

    @field_validator("barrio")
    @classmethod
    def validar_barrio(cls, valor: str) -> str:
        valor = limpiar_texto(valor)

        if valor == "":
            return ""

        return validar_patron(
            valor=valor,
            patron=PATRON_TEXTO_CON_NUMEROS,
            mensaje_usuario="Barrio: solo permite letras, números, acentos y espacios.",
            mensaje_tecnico=f"UbicacionSchema.barrio recibió '{valor}'. Patrón esperado: letras, números, acentos y espacios.",
        )


class DireccionSchema(BaseModel):
    calle: str
    numero: str

    @field_validator("calle")
    @classmethod
    def validar_calle(cls, valor: str) -> str:
        valor = validar_texto_obligatorio(valor, "Calle")

        return validar_patron(
            valor=valor,
            patron=PATRON_TEXTO_CON_NUMEROS,
            mensaje_usuario="Calle: solo permite letras, números, acentos y espacios.",
            mensaje_tecnico=f"DireccionSchema.calle recibió '{valor}'. Patrón esperado: letras, números, acentos y espacios.",
        )

    @field_validator("numero")
    @classmethod
    def validar_numero(cls, valor: str) -> str:
        valor = validar_texto_obligatorio(valor, "Número de domicilio")

        return validar_patron(
            valor=valor,
            patron=PATRON_NUMERO_DOMICILIO,
            mensaje_usuario="Número de domicilio: solo permite números, letras, barra / y guion -, sin espacios.",
            mensaje_tecnico=f"DireccionSchema.numero recibió '{valor}'. Patrón esperado: letras, números, barra / y guion -, sin espacios.",
        )


class TelefonoSchema(BaseModel):
    codigo_area: str
    numero: str

    @field_validator("codigo_area")
    @classmethod
    def validar_codigo_area(cls, valor: str) -> str:
        valor = validar_entero_positivo_como_texto(
            valor=valor,
            campo="Código de área",
        )

        return validar_longitud_texto(
            valor=valor,
            campo="Código de área",
            minimo=4,
            maximo=5,
        )

    @field_validator("numero")
    @classmethod
    def validar_numero(cls, valor: str) -> str:
        return validar_entero_positivo_como_texto(
            valor=valor,
            campo="Número de teléfono",
        )

