
# app_jade / CORE / validaciones.py

from __future__ import annotations

import re
from datetime import datetime
from typing import Any


# ============================================================
# PATRONES BASE
# ============================================================

PATRON_TEXTO_PERSONA = re.compile(r"^[A-Za-zÁÉÍÓÚÜÑáéíóúüñ\s]+$")
PATRON_TEXTO_CON_NUMEROS = re.compile(r"^[A-Za-zÁÉÍÓÚÜÑáéíóúüñ0-9\s]+$")
PATRON_DNI = re.compile(r"^[0-9]+$")
PATRON_NUMERO_DOMICILIO = re.compile(r"^[A-Za-z0-9/-]+$")
PATRON_FECHA = re.compile(r"^\d{2}/\d{2}/\d{4}$")
PATRON_TEXTO_LIBRE_BASICO = re.compile(r"^[A-Za-zÁÉÍÓÚÜÑáéíóúüñ0-9\s.,;:()/_-]+$")


# ============================================================
# CONSTANTES BAJA
# ============================================================

TIPOS_BENEFICIARIO_BAJA = {
    "Destinatario",
    "Tutor",
}

MOTIVOS_BAJA = {
    "Encontrarse privado de la libertad",
    "Fallecimiento",
    "Haber cumplimentado con todos los acuerdos para su egreso",
    "Liquidaciones consecutivas impagas",
    "Mudanza a otro Municipio",
    "Negativa a cumplir con su Acuerdo de Compromiso",
    "Negativa del Joven a participar",
    "Negativa o dificultades al momento de la socialización",
    "Pase de Destinatario a Tutor",
    "Pase de Tutor a Destinatario",
    "Trabajo Formal",
    "Otros motivos",
}

RESPUESTAS_SI_NO = {
    "Sí",
    "Si",
    "No",
}


# ============================================================
# HELPERS
# ============================================================

def _texto(valor: Any) -> str:
    if valor is None:
        return ""

    return str(valor).strip()


def _esta_vacio(valor: Any) -> bool:
    return _texto(valor) == ""


def _agregar_error(
    errores: list[dict[str, str]],
    campo_id: str,
    mensaje: str,
) -> None:
    errores.append({
        "campo": campo_id,
        "mensaje": mensaje,
    })


def _validar_obligatorio(
    errores: list[dict[str, str]],
    valor: Any,
    campo_id: str,
    campo_label: str,
) -> bool:
    if _esta_vacio(valor):
        _agregar_error(
            errores,
            campo_id,
            f"{campo_label}: es obligatorio.",
        )
        return False

    return True


def _validar_patron(
    errores: list[dict[str, str]],
    valor: Any,
    campo_id: str,
    campo_label: str,
    patron: re.Pattern[str],
    mensaje: str,
) -> bool:
    texto = _texto(valor)

    if not patron.fullmatch(texto):
        _agregar_error(
            errores,
            campo_id,
            f"{campo_label}: {mensaje}",
        )
        return False

    return True


def _resultado_validacion(errores: list[dict[str, str]]) -> dict[str, Any]:
    return {
        "valido": len(errores) == 0,
        "errores": errores,
        "mensaje": errores_a_texto(errores),
    }


# ============================================================
# VALIDACIONES ATÓMICAS
# ============================================================

def validar_nombre_persona(
    errores: list[dict[str, str]],
    valor: Any,
    campo_id: str,
    campo_label: str,
) -> None:
    if not _validar_obligatorio(errores, valor, campo_id, campo_label):
        return

    _validar_patron(
        errores=errores,
        valor=valor,
        campo_id=campo_id,
        campo_label=campo_label,
        patron=PATRON_TEXTO_PERSONA,
        mensaje="solo permite letras, acentos y espacios.",
    )


def validar_texto_con_numeros(
    errores: list[dict[str, str]],
    valor: Any,
    campo_id: str,
    campo_label: str,
    obligatorio: bool = True,
) -> None:
    if obligatorio and not _validar_obligatorio(
        errores,
        valor,
        campo_id,
        campo_label,
    ):
        return

    if not obligatorio and _esta_vacio(valor):
        return

    _validar_patron(
        errores=errores,
        valor=valor,
        campo_id=campo_id,
        campo_label=campo_label,
        patron=PATRON_TEXTO_CON_NUMEROS,
        mensaje="solo permite letras, números, acentos y espacios.",
    )


def validar_texto_libre_basico(
    errores: list[dict[str, str]],
    valor: Any,
    campo_id: str,
    campo_label: str,
    obligatorio: bool = True,
) -> None:
    if obligatorio and not _validar_obligatorio(
        errores,
        valor,
        campo_id,
        campo_label,
    ):
        return

    if not obligatorio and _esta_vacio(valor):
        return

    _validar_patron(
        errores=errores,
        valor=valor,
        campo_id=campo_id,
        campo_label=campo_label,
        patron=PATRON_TEXTO_LIBRE_BASICO,
        mensaje="contiene caracteres no permitidos.",
    )


def validar_dni(
    errores: list[dict[str, str]],
    valor: Any,
    campo_id: str,
    campo_label: str,
) -> None:
    if not _validar_obligatorio(errores, valor, campo_id, campo_label):
        return

    texto = _texto(valor)

    if not PATRON_DNI.fullmatch(texto):
        _agregar_error(
            errores,
            campo_id,
            f"{campo_label}: debe contener solo números, sin puntos ni espacios.",
        )
        return

    try:
        if int(texto) <= 0:
            _agregar_error(
                errores,
                campo_id,
                f"{campo_label}: debe ser un número positivo.",
            )
    except ValueError:
        _agregar_error(
            errores,
            campo_id,
            f"{campo_label}: debe ser un número válido.",
        )


def validar_entero_positivo(
    errores: list[dict[str, str]],
    valor: Any,
    campo_id: str,
    campo_label: str,
) -> None:
    if not _validar_obligatorio(errores, valor, campo_id, campo_label):
        return

    texto = _texto(valor)

    if not PATRON_DNI.fullmatch(texto):
        _agregar_error(
            errores,
            campo_id,
            f"{campo_label}: debe contener solo números, sin espacios.",
        )
        return

    try:
        if int(texto) <= 0:
            _agregar_error(
                errores,
                campo_id,
                f"{campo_label}: debe ser un número positivo.",
            )
    except ValueError:
        _agregar_error(
            errores,
            campo_id,
            f"{campo_label}: debe ser un número válido.",
        )


def validar_numero_domicilio(
    errores: list[dict[str, str]],
    valor: Any,
    campo_id: str,
    campo_label: str,
) -> None:
    if not _validar_obligatorio(errores, valor, campo_id, campo_label):
        return

    _validar_patron(
        errores=errores,
        valor=valor,
        campo_id=campo_id,
        campo_label=campo_label,
        patron=PATRON_NUMERO_DOMICILIO,
        mensaje="solo permite números, letras, barra / y guion -, sin espacios.",
    )


def validar_fecha_nacimiento(
    errores: list[dict[str, str]],
    valor: Any,
    campo_id: str,
    campo_label: str,
) -> None:
    validar_fecha_no_futura(
        errores=errores,
        valor=valor,
        campo_id=campo_id,
        campo_label=campo_label,
    )


def validar_fecha_no_futura(
    errores: list[dict[str, str]],
    valor: Any,
    campo_id: str,
    campo_label: str,
) -> None:
    if not _validar_obligatorio(errores, valor, campo_id, campo_label):
        return

    texto = _texto(valor)

    if not PATRON_FECHA.fullmatch(texto):
        _agregar_error(
            errores,
            campo_id,
            f"{campo_label}: debe tener formato DD/MM/AAAA.",
        )
        return

    try:
        fecha = datetime.strptime(texto, "%d/%m/%Y").date()
    except ValueError:
        _agregar_error(
            errores,
            campo_id,
            f"{campo_label}: no es una fecha válida.",
        )
        return

    hoy = datetime.today().date()

    if fecha > hoy:
        _agregar_error(
            errores,
            campo_id,
            f"{campo_label}: no puede ser una fecha futura.",
        )


def validar_escolarizado(
    errores: list[dict[str, str]],
    valor: Any,
) -> None:
    texto = _texto(valor)

    if texto not in {"Sí", "Si", "No"}:
        _agregar_error(
            errores,
            "escolarizado",
            "Escolarizado: debe seleccionar Sí o No.",
        )


def validar_parentesco(
    errores: list[dict[str, str]],
    valor: Any,
) -> None:
    if _esta_vacio(valor):
        _agregar_error(
            errores,
            "responsableParentesco",
            "Parentesco: debe seleccionar una opción.",
        )


def validar_opcion_en_conjunto(
    errores: list[dict[str, str]],
    valor: Any,
    campo_id: str,
    campo_label: str,
    opciones_validas: set[str],
) -> None:
    texto = _texto(valor)

    if texto not in opciones_validas:
        _agregar_error(
            errores,
            campo_id,
            f"{campo_label}: debe seleccionar una opción válida.",
        )


# ============================================================
# VALIDACIONES COMPUESTAS - ALTA
# ============================================================

def validar_destinatario_o_tutor(datos: dict[str, Any]) -> list[dict[str, str]]:
    errores: list[dict[str, str]] = []

    validar_nombre_persona(
        errores,
        datos.get("nombre", ""),
        "nombre",
        "Nombre",
    )

    validar_nombre_persona(
        errores,
        datos.get("apellido", ""),
        "apellido",
        "Apellido",
    )

    validar_dni(
        errores,
        datos.get("dni", ""),
        "dni",
        "DNI",
    )

    validar_escolarizado(
        errores,
        datos.get("escolarizado", ""),
    )

    validar_texto_con_numeros(
        errores,
        datos.get("calle", ""),
        "calle",
        "Calle",
        obligatorio=True,
    )

    validar_numero_domicilio(
        errores,
        datos.get("numero", ""),
        "numero",
        "Número de domicilio",
    )

    validar_fecha_nacimiento(
        errores,
        datos.get("fechaNacimiento", ""),
        "fechaNacimiento",
        "Fecha de nacimiento",
    )

    return errores


def validar_responsable(datos: dict[str, Any]) -> list[dict[str, str]]:
    errores: list[dict[str, str]] = []

    validar_nombre_persona(
        errores,
        datos.get("responsableNombre", ""),
        "responsableNombre",
        "Responsable - Nombre",
    )

    validar_nombre_persona(
        errores,
        datos.get("responsableApellido", ""),
        "responsableApellido",
        "Responsable - Apellido",
    )

    validar_dni(
        errores,
        datos.get("responsableDni", ""),
        "responsableDni",
        "Responsable - DNI",
    )

    validar_parentesco(
        errores,
        datos.get("responsableParentesco", ""),
    )

    validar_fecha_nacimiento(
        errores,
        datos.get("responsableFechaNacimiento", ""),
        "responsableFechaNacimiento",
        "Responsable - Fecha de nacimiento",
    )

    telefono = _texto(datos.get("responsableTelefono", ""))
    partes_telefono = [parte for parte in telefono.split(" ") if parte.strip()]

    if len(partes_telefono) != 2:
        _agregar_error(
            errores,
            "responsableTelefono",
            "Responsable - Teléfono: debe completar número de área y número de teléfono.",
        )
    else:
        validar_entero_positivo(
            errores,
            partes_telefono[0],
            "responsableCodigoArea",
            "Responsable - Número de área",
        )

        validar_entero_positivo(
            errores,
            partes_telefono[1],
            "responsableNumeroTelefono",
            "Responsable - Número de teléfono",
        )

    domicilio = _texto(datos.get("responsableDomicilio", ""))

    if domicilio == "":
        _agregar_error(
            errores,
            "responsableDomicilio",
            "Responsable - Domicilio: debe completar el domicilio manualmente o seleccionar 'Mismo domicilio que destinatario'.",
        )

    return errores


def validar_solicitud_alta(datos: dict[str, Any]) -> dict[str, Any]:
    """
    Validación de seguridad antes de generar Excel.

    La validación principal del usuario debe ejecutarse por paso:
    - validar_destinatario_o_tutor()
    - validar_responsable()

    tipoSolicitud:
    - "destinatario" o vacío: exige datos de responsable adulto.
    - "tutor": no exige responsable adulto.
    """

    errores: list[dict[str, str]] = []

    tipo_solicitud = _texto(datos.get("tipoSolicitud", "destinatario")).lower()

    errores.extend(validar_destinatario_o_tutor(datos))

    if tipo_solicitud != "tutor":
        errores.extend(validar_responsable(datos))

    return {
        "valido": len(errores) == 0,
        "errores": errores,
    }


def validar_configuracion_sede(datos: dict[str, Any]) -> dict[str, Any]:
    errores: list[dict[str, str]] = []

    validar_texto_con_numeros(
        errores,
        datos.get("nombreSede", ""),
        "nombreSede",
        "Nombre de sede",
        obligatorio=True,
    )

    validar_nombre_persona(
        errores,
        datos.get("origen", ""),
        "origen",
        "Origen",
    )

    validar_nombre_persona(
        errores,
        datos.get("municipio", ""),
        "municipio",
        "Municipio",
    )

    validar_nombre_persona(
        errores,
        datos.get("localidad", ""),
        "localidad",
        "Localidad",
    )

    validar_texto_con_numeros(
        errores,
        datos.get("barrio", ""),
        "barrio",
        "Barrio",
        obligatorio=False,
    )

    return {
        "valido": len(errores) == 0,
        "errores": errores,
    }


# ============================================================
# VALIDACIONES COMPUESTAS - BAJA
# ============================================================

def validar_baja_institucional(datos: dict[str, Any]) -> dict[str, Any]:
    errores: list[dict[str, str]] = []

    validar_texto_libre_basico(
        errores,
        datos.get("centroEnvion", ""),
        "centroEnvion",
        "Centro Envión",
        obligatorio=True,
    )

    validar_texto_libre_basico(
        errores,
        datos.get("sede", ""),
        "sede",
        "Sede",
        obligatorio=True,
    )

    validar_texto_libre_basico(
        errores,
        datos.get("modalidad", ""),
        "modalidad",
        "Modalidad",
        obligatorio=True,
    )

    profesionales = datos.get("profesionalesIntervinientes", [])

    if not isinstance(profesionales, list) or len(profesionales) == 0:
        _agregar_error(
            errores,
            "profesionalesIntervinientes",
            "Profesional interviniente: debe cargar al menos un profesional.",
        )
    else:
        for indice, profesional in enumerate(profesionales, start=1):
            validar_texto_libre_basico(
                errores,
                profesional,
                "profesionalesIntervinientes",
                f"Profesional interviniente {indice}",
                obligatorio=True,
            )

    validar_texto_libre_basico(
        errores,
        datos.get("coordinadora", ""),
        "coordinadora",
        "Coordinadora",
        obligatorio=True,
    )

    validar_fecha_no_futura(
        errores,
        datos.get("fechaBaja", ""),
        "fechaBaja",
        "Fecha de baja",
    )

    return _resultado_validacion(errores)


def validar_baja_beneficiario(datos: dict[str, Any]) -> dict[str, Any]:
    errores: list[dict[str, str]] = []

    validar_opcion_en_conjunto(
        errores,
        datos.get("bajaTipoBeneficiario", ""),
        "bajaTipoBeneficiario",
        "Tipo de beneficiario",
        TIPOS_BENEFICIARIO_BAJA,
    )

    validar_nombre_persona(
        errores,
        datos.get("bajaNombre", ""),
        "bajaNombre",
        "Beneficiario - Nombre",
    )

    validar_nombre_persona(
        errores,
        datos.get("bajaApellido", ""),
        "bajaApellido",
        "Beneficiario - Apellido",
    )

    validar_texto_libre_basico(
        errores,
        datos.get("bajaTipoDni", ""),
        "bajaTipoDni",
        "Tipo de documento",
        obligatorio=True,
    )

    validar_dni(
        errores,
        datos.get("bajaDni", ""),
        "bajaDni",
        "Beneficiario - DNI",
    )

    validar_fecha_no_futura(
        errores,
        datos.get("bajaFechaIngreso", ""),
        "bajaFechaIngreso",
        "Fecha de ingreso a Envión",
    )

    validar_opcion_en_conjunto(
        errores,
        datos.get("bajaMotivo", ""),
        "bajaMotivo",
        "Motivo de baja",
        MOTIVOS_BAJA,
    )

    return _resultado_validacion(errores)


def validar_baja_responsable(datos: dict[str, Any]) -> dict[str, Any]:
    errores: list[dict[str, str]] = []

    validar_nombre_persona(
        errores,
        datos.get("bajaResponsableNombre", ""),
        "bajaResponsableNombre",
        "Responsable adulto - Nombre",
    )

    validar_nombre_persona(
        errores,
        datos.get("bajaResponsableApellido", ""),
        "bajaResponsableApellido",
        "Responsable adulto - Apellido",
    )

    validar_texto_libre_basico(
        errores,
        datos.get("bajaResponsableRelacion", ""),
        "bajaResponsableRelacion",
        "Relación con el joven",
        obligatorio=True,
    )

    validar_opcion_en_conjunto(
        errores,
        datos.get("bajaResponsableInformado", ""),
        "bajaResponsableInformado",
        "Adulto responsable informado",
        RESPUESTAS_SI_NO,
    )

    return _resultado_validacion(errores)


def validar_solicitud_baja(datos: dict[str, Any]) -> dict[str, Any]:
    """
    Validación de seguridad antes de generar la solicitud de baja.

    La validación principal del usuario debe ejecutarse por paso:
    - validar_baja_institucional()
    - validar_baja_beneficiario()
    - validar_baja_responsable()
    """

    errores: list[dict[str, str]] = []

    errores.extend(validar_baja_institucional(datos)["errores"])
    errores.extend(validar_baja_beneficiario(datos)["errores"])
    errores.extend(validar_baja_responsable(datos)["errores"])

    return _resultado_validacion(errores)


# ============================================================
# FORMATO DE ERRORES
# ============================================================

def errores_a_texto(errores: list[dict[str, str]]) -> str:
    return "\n".join(error["mensaje"] for error in errores)

