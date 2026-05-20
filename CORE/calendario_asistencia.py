# app_jade / CORE / calendario_asistencia.py

from __future__ import annotations

from calendar import monthrange
from dataclasses import dataclass
from datetime import date, timedelta


DIAS_SEMANA_ES = {
    0: "LUNES",
    1: "MARTES",
    2: "MIÉRCOLES",
    3: "JUEVES",
    4: "VIERNES",
    5: "SÁBADO",
    6: "DOMINGO",
}

MESES_ES = {
    1: "ENERO",
    2: "FEBRERO",
    3: "MARZO",
    4: "ABRIL",
    5: "MAYO",
    6: "JUNIO",
    7: "JULIO",
    8: "AGOSTO",
    9: "SEPTIEMBRE",
    10: "OCTUBRE",
    11: "NOVIEMBRE",
    12: "DICIEMBRE",
}


@dataclass(frozen=True)
class DiaAsistencia:
    """
    Representa una fecha que será usada como columna en la planilla.
    """
    fecha: date
    nombre_dia: str
    fecha_formateada: str
    etiqueta_corta: str


@dataclass(frozen=True)
class PeriodoAsistencia:
    """
    Representa el período completo que se mostrará en la planilla.
    """
    tipo: str
    etiqueta_periodo: str
    fecha_emision: str
    dias: list[DiaAsistencia]


def formatear_fecha(fecha: date) -> str:
    return fecha.strftime("%d/%m/%Y")


def obtener_nombre_mes(numero_mes: int) -> str:
    return MESES_ES.get(numero_mes, "")


def construir_dia_asistencia(fecha: date) -> DiaAsistencia:
    nombre_dia = DIAS_SEMANA_ES[fecha.weekday()]
    fecha_formateada = formatear_fecha(fecha)

    return DiaAsistencia(
        fecha=fecha,
        nombre_dia=nombre_dia,
        fecha_formateada=fecha_formateada,
        etiqueta_corta=f"{nombre_dia}\n{fecha_formateada}",
    )


def obtener_periodo_semanal(fecha_base: date | None = None) -> PeriodoAsistencia:
    """
    Devuelve lunes a viernes de la semana correspondiente a fecha_base.
    Si no se pasa fecha_base, usa la fecha actual del sistema.
    """
    if fecha_base is None:
        fecha_base = date.today()

    lunes = fecha_base - timedelta(days=fecha_base.weekday())

    fechas = [
        lunes,
        lunes + timedelta(days=1),
        lunes + timedelta(days=2),
        lunes + timedelta(days=3),
        lunes + timedelta(days=4),
    ]

    dias = [construir_dia_asistencia(fecha) for fecha in fechas]

    etiqueta_periodo = (
        f"{formatear_fecha(fechas[0])} AL {formatear_fecha(fechas[-1])}"
    )

    return PeriodoAsistencia(
        tipo="semanal",
        etiqueta_periodo=etiqueta_periodo,
        fecha_emision=formatear_fecha(date.today()),
        dias=dias,
    )


def obtener_periodo_mensual(fecha_base: date | None = None) -> PeriodoAsistencia:
    """
    Devuelve los días del mes actual que corresponden a actividad
    de destinatarios: lunes, martes, miércoles y jueves.

    Viernes, sábado y domingo quedan excluidos.
    """
    if fecha_base is None:
        fecha_base = date.today()

    anio = fecha_base.year
    mes = fecha_base.month

    cantidad_dias = monthrange(anio, mes)[1]

    fechas_actividad = []

    for dia in range(1, cantidad_dias + 1):
        fecha = date(anio, mes, dia)

        # 0 lunes, 1 martes, 2 miércoles, 3 jueves.
        if fecha.weekday() in [0, 1, 2, 3]:
            fechas_actividad.append(fecha)

    dias = [construir_dia_asistencia(fecha) for fecha in fechas_actividad]

    nombre_mes = obtener_nombre_mes(mes)
    etiqueta_periodo = f"{nombre_mes} {anio}"

    return PeriodoAsistencia(
        tipo="mensual",
        etiqueta_periodo=etiqueta_periodo,
        fecha_emision=formatear_fecha(date.today()),
        dias=dias,
    )