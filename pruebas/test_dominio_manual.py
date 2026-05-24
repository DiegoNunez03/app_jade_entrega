# pruebas/test_dominio_manual.py

from __future__ import annotations

import sys
from pathlib import Path
from datetime import date

RUTA_RAIZ_PROYECTO = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(RUTA_RAIZ_PROYECTO))

from CORE.dominio.catalogos import (
    TipoSolicitudAlta,
    TipoBeneficiarioBaja,
    MotivoBaja,
    TipoParentesco,
)
from CORE.dominio.entidades import (
    Rol,
    Ubicacion,
    Direccion,
    Telefono,
    PersonalInstitucional,
    ContextoInstitucional,
    Destinatario,
    Tutor,
    ResponsableAdulto,
    SolicitudAlta,
    SolicitudBaja,
)
from CORE.dominio.reglas import (
    validar_reglas_contexto_institucional,
    validar_reglas_solicitud_alta,
    validar_reglas_solicitud_baja,
)
from CORE.dominio.errores import mensaje_resultado


# ============================================================
# DATOS BASE PARA PRUEBAS
# ============================================================

def crear_contexto_valido() -> ContextoInstitucional:
    rol_coordinadora = Rol(
        nombre="Coordinadora",
        siglas="COORD",
    )

    rol_trabajadora_social = Rol(
        nombre="Trabajadora social",
        siglas="TS",
    )

    coordinadora = PersonalInstitucional(
        nombre="Ana",
        apellido="Pérez",
        rol=rol_coordinadora,
    )

    profesional = PersonalInstitucional(
        nombre="Laura",
        apellido="Gómez",
        rol=rol_trabajadora_social,
    )

    return ContextoInstitucional(
        origen="Envión",
        nombre_sede="Sede Centro",
        ubicacion=Ubicacion(
            municipio="Coronel Rosales",
            localidad="Punta Alta",
            barrio="",
        ),
        coordinador=coordinadora,
        profesionales=[profesional],
    )


def crear_destinatario_valido() -> Destinatario:
    return Destinatario(
        nombre="Juan",
        apellido="López",
        dni="12345678",
        direccion=Direccion(
            calle="Rivadavia",
            numero="123",
        ),
        fecha_nacimiento=date(2010, 5, 10),
        escolarizado=True,
    )


def crear_tutor_valido() -> Tutor:
    return Tutor(
        nombre="Carlos",
        apellido="Martínez",
        dni="23456789",
        direccion=Direccion(
            calle="Mitre",
            numero="456",
        ),
        fecha_nacimiento=date(1995, 8, 15),
        escolarizado=None,
    )


def crear_responsable_valido() -> ResponsableAdulto:
    return ResponsableAdulto(
        nombre="María",
        apellido="López",
        dni="87654321",
        direccion=Direccion(
            calle="Rivadavia",
            numero="123",
        ),
        fecha_nacimiento=date(1980, 3, 20),
        parentesco=TipoParentesco.MADRE,
        telefono=Telefono(
            codigo_area="2932",
            numero="123456",
        ),
    )


def imprimir_resultado(nombre_prueba: str, errores) -> None:
    print("\n" + "=" * 70)
    print(nombre_prueba)
    print("=" * 70)
    print(mensaje_resultado(errores))


# ============================================================
# PRUEBAS
# ============================================================

def prueba_contexto_valido() -> None:
    contexto = crear_contexto_valido()
    errores = validar_reglas_contexto_institucional(contexto)

    imprimir_resultado(
        "PRUEBA 1 - Contexto institucional válido",
        errores,
    )


def prueba_contexto_sin_profesionales() -> None:
    contexto_base = crear_contexto_valido()

    contexto_sin_profesionales = ContextoInstitucional(
        origen=contexto_base.origen,
        nombre_sede=contexto_base.nombre_sede,
        ubicacion=contexto_base.ubicacion,
        coordinador=contexto_base.coordinador,
        profesionales=[],
    )

    errores = validar_reglas_contexto_institucional(contexto_sin_profesionales)

    imprimir_resultado(
        "PRUEBA 2 - Contexto institucional sin profesionales",
        errores,
    )


def prueba_alta_destinatario_valida() -> None:
    solicitud = SolicitudAlta(
        fecha_emision=date.today(),
        tipo_solicitud=TipoSolicitudAlta.DESTINATARIO,
        beneficiario=crear_destinatario_valido(),
        responsable_adulto=crear_responsable_valido(),
        contexto_institucional=crear_contexto_valido(),
    )

    errores = validar_reglas_solicitud_alta(solicitud)

    imprimir_resultado(
        "PRUEBA 3 - Alta destinatario válida",
        errores,
    )


def prueba_alta_destinatario_sin_responsable() -> None:
    solicitud = SolicitudAlta(
        fecha_emision=date.today(),
        tipo_solicitud=TipoSolicitudAlta.DESTINATARIO,
        beneficiario=crear_destinatario_valido(),
        responsable_adulto=None,
        contexto_institucional=crear_contexto_valido(),
    )

    errores = validar_reglas_solicitud_alta(solicitud)

    imprimir_resultado(
        "PRUEBA 4 - Alta destinatario sin responsable adulto",
        errores,
    )


def prueba_alta_tutor_valida() -> None:
    solicitud = SolicitudAlta(
        fecha_emision=date.today(),
        tipo_solicitud=TipoSolicitudAlta.TUTOR,
        beneficiario=crear_tutor_valido(),
        responsable_adulto=None,
        contexto_institucional=crear_contexto_valido(),
    )

    errores = validar_reglas_solicitud_alta(solicitud)

    imprimir_resultado(
        "PRUEBA 5 - Alta tutor válida",
        errores,
    )


def prueba_alta_tutor_con_destinatario() -> None:
    solicitud = SolicitudAlta(
        fecha_emision=date.today(),
        tipo_solicitud=TipoSolicitudAlta.TUTOR,
        beneficiario=crear_destinatario_valido(),
        responsable_adulto=None,
        contexto_institucional=crear_contexto_valido(),
    )

    errores = validar_reglas_solicitud_alta(solicitud)

    imprimir_resultado(
        "PRUEBA 6 - Alta tutor con beneficiario de tipo Destinatario",
        errores,
    )


def prueba_baja_valida() -> None:
    contexto = crear_contexto_valido()

    solicitud = SolicitudBaja(
        fecha_emision=date.today(),
        profesionales_intervinientes=contexto.profesionales,
        tipo_beneficiario=TipoBeneficiarioBaja.DESTINATARIO,
        motivo=MotivoBaja.TRABAJO_FORMAL,
        beneficiario=crear_destinatario_valido(),
        responsable_adulto=crear_responsable_valido(),
        contexto_institucional=contexto,
    )

    errores = validar_reglas_solicitud_baja(solicitud)

    imprimir_resultado(
        "PRUEBA 7 - Baja válida",
        errores,
    )


def prueba_baja_sin_profesionales_intervinientes() -> None:
    contexto = crear_contexto_valido()

    solicitud = SolicitudBaja(
        fecha_emision=date.today(),
        profesionales_intervinientes=[],
        tipo_beneficiario=TipoBeneficiarioBaja.DESTINATARIO,
        motivo=MotivoBaja.TRABAJO_FORMAL,
        beneficiario=crear_destinatario_valido(),
        responsable_adulto=crear_responsable_valido(),
        contexto_institucional=contexto,
    )

    errores = validar_reglas_solicitud_baja(solicitud)

    imprimir_resultado(
        "PRUEBA 8 - Baja sin profesionales intervinientes",
        errores,
    )


def prueba_baja_con_profesional_no_configurado() -> None:
    contexto = crear_contexto_valido()

    profesional_no_configurado = PersonalInstitucional(
        nombre="Sofía",
        apellido="Ramírez",
        rol=Rol(
            nombre="Psicóloga",
            siglas="PSI",
        ),
    )

    solicitud = SolicitudBaja(
        fecha_emision=date.today(),
        profesionales_intervinientes=[profesional_no_configurado],
        tipo_beneficiario=TipoBeneficiarioBaja.DESTINATARIO,
        motivo=MotivoBaja.TRABAJO_FORMAL,
        beneficiario=crear_destinatario_valido(),
        responsable_adulto=crear_responsable_valido(),
        contexto_institucional=contexto,
    )

    errores = validar_reglas_solicitud_baja(solicitud)

    imprimir_resultado(
        "PRUEBA 9 - Baja con profesional no configurado",
        errores,
    )


def prueba_baja_con_profesionales_repetidos() -> None:
    contexto = crear_contexto_valido()

    profesional = contexto.profesionales[0]

    solicitud = SolicitudBaja(
        fecha_emision=date.today(),
        profesionales_intervinientes=[profesional, profesional],
        tipo_beneficiario=TipoBeneficiarioBaja.DESTINATARIO,
        motivo=MotivoBaja.TRABAJO_FORMAL,
        beneficiario=crear_destinatario_valido(),
        responsable_adulto=crear_responsable_valido(),
        contexto_institucional=contexto,
    )

    errores = validar_reglas_solicitud_baja(solicitud)

    imprimir_resultado(
        "PRUEBA 10 - Baja con profesionales repetidos",
        errores,
    )


# ============================================================
# EJECUCIÓN MANUAL
# ============================================================

if __name__ == "__main__":
    prueba_contexto_valido()
    prueba_contexto_sin_profesionales()

    prueba_alta_destinatario_valida()
    prueba_alta_destinatario_sin_responsable()
    prueba_alta_tutor_valida()
    prueba_alta_tutor_con_destinatario()

    prueba_baja_valida()
    prueba_baja_sin_profesionales_intervinientes()
    prueba_baja_con_profesional_no_configurado()
    prueba_baja_con_profesionales_repetidos()




# # pruebas/test_dominio_manual.py

# from __future__ import annotations

# from datetime import date

# import sys
# from pathlib import Path

# RUTA_RAIZ_PROYECTO = Path(__file__).resolve().parents[1]
# sys.path.insert(0, str(RUTA_RAIZ_PROYECTO))

# from CORE.dominio.catalogos import (
#     TipoSolicitudAlta,
#     TipoBeneficiarioBaja,
#     MotivoBaja,
#     TipoParentesco,
# )
# from CORE.dominio.entidades import (
#     Rol,
#     Ubicacion,
#     Direccion,
#     Telefono,
#     PersonalInstitucional,
#     ContextoInstitucional,
#     Destinatario,
#     Tutor,
#     ResponsableAdulto,
#     SolicitudAlta,
#     SolicitudBaja,
# )
# from CORE.dominio.reglas import (
#     validar_reglas_contexto_institucional,
#     validar_reglas_solicitud_alta,
#     validar_reglas_solicitud_baja,
# )
# from CORE.dominio.errores import errores_a_texto


# # ============================================================
# # DATOS BASE PARA PRUEBAS
# # ============================================================

# def crear_contexto_valido() -> ContextoInstitucional:
#     rol_coordinadora = Rol(
#         nombre="Coordinadora",
#         siglas="COORD",
#     )

#     rol_trabajadora_social = Rol(
#         nombre="Trabajadora social",
#         siglas="TS",
#     )

#     coordinadora = PersonalInstitucional(
#         nombre="Ana",
#         apellido="Pérez",
#         rol=rol_coordinadora,
#     )

#     profesional = PersonalInstitucional(
#         nombre="Laura",
#         apellido="Gómez",
#         rol=rol_trabajadora_social,
#     )

#     return ContextoInstitucional(
#         origen="Envión",
#         nombre_sede="Sede Centro",
#         ubicacion=Ubicacion(
#             municipio="Coronel Rosales",
#             localidad="Punta Alta",
#             barrio="",
#         ),
#         coordinador=coordinadora,
#         profesionales=[profesional],
#     )


# def crear_destinatario_valido() -> Destinatario:
#     return Destinatario(
#         nombre="Juan",
#         apellido="López",
#         dni="12345678",
#         direccion=Direccion(
#             calle="Rivadavia",
#             numero="123",
#         ),
#         fecha_nacimiento=date(2010, 5, 10),
#         escolarizado=True,
#     )


# def crear_tutor_valido() -> Tutor:
#     return Tutor(
#         nombre="Carlos",
#         apellido="Martínez",
#         dni="23456789",
#         direccion=Direccion(
#             calle="Mitre",
#             numero="456",
#         ),
#         fecha_nacimiento=date(1995, 8, 15),
#         escolarizado=None,
#     )


# def crear_responsable_valido() -> ResponsableAdulto:
#     return ResponsableAdulto(
#         nombre="María",
#         apellido="López",
#         dni="87654321",
#         direccion=Direccion(
#             calle="Rivadavia",
#             numero="123",
#         ),
#         fecha_nacimiento=date(1980, 3, 20),
#         parentesco=TipoParentesco.MADRE,
#         telefono=Telefono(
#             codigo_area="2932",
#             numero="123456",
#         ),
#     )


# def imprimir_resultado(nombre_prueba: str, errores) -> None:
#     print("\n" + "=" * 70)
#     print(nombre_prueba)
#     print("=" * 70)

#     if errores:
#         print("ERRORES:")
#         print(errores_a_texto(errores))
#     else:
#         print("OK: no hay errores de dominio.")


# # ============================================================
# # PRUEBAS
# # ============================================================

# def prueba_contexto_valido() -> None:
#     contexto = crear_contexto_valido()
#     errores = validar_reglas_contexto_institucional(contexto)

#     imprimir_resultado(
#         "PRUEBA 1 - Contexto institucional válido",
#         errores,
#     )


# def prueba_contexto_sin_profesionales() -> None:
#     contexto_base = crear_contexto_valido()

#     contexto_sin_profesionales = ContextoInstitucional(
#         origen=contexto_base.origen,
#         nombre_sede=contexto_base.nombre_sede,
#         ubicacion=contexto_base.ubicacion,
#         coordinador=contexto_base.coordinador,
#         profesionales=[],
#     )

#     errores = validar_reglas_contexto_institucional(contexto_sin_profesionales)

#     imprimir_resultado(
#         "PRUEBA 2 - Contexto institucional sin profesionales",
#         errores,
#     )


# def prueba_alta_destinatario_valida() -> None:
#     solicitud = SolicitudAlta(
#         fecha_emision=date.today(),
#         tipo_solicitud=TipoSolicitudAlta.DESTINATARIO,
#         beneficiario=crear_destinatario_valido(),
#         responsable_adulto=crear_responsable_valido(),
#         contexto_institucional=crear_contexto_valido(),
#     )

#     errores = validar_reglas_solicitud_alta(solicitud)

#     imprimir_resultado(
#         "PRUEBA 3 - Alta destinatario válida",
#         errores,
#     )


# def prueba_alta_destinatario_sin_responsable() -> None:
#     solicitud = SolicitudAlta(
#         fecha_emision=date.today(),
#         tipo_solicitud=TipoSolicitudAlta.DESTINATARIO,
#         beneficiario=crear_destinatario_valido(),
#         responsable_adulto=None,
#         contexto_institucional=crear_contexto_valido(),
#     )

#     errores = validar_reglas_solicitud_alta(solicitud)

#     imprimir_resultado(
#         "PRUEBA 4 - Alta destinatario sin responsable adulto",
#         errores,
#     )


# def prueba_alta_tutor_valida() -> None:
#     solicitud = SolicitudAlta(
#         fecha_emision=date.today(),
#         tipo_solicitud=TipoSolicitudAlta.TUTOR,
#         beneficiario=crear_tutor_valido(),
#         responsable_adulto=None,
#         contexto_institucional=crear_contexto_valido(),
#     )

#     errores = validar_reglas_solicitud_alta(solicitud)

#     imprimir_resultado(
#         "PRUEBA 5 - Alta tutor válida",
#         errores,
#     )


# def prueba_alta_tutor_con_destinatario() -> None:
#     solicitud = SolicitudAlta(
#         fecha_emision=date.today(),
#         tipo_solicitud=TipoSolicitudAlta.TUTOR,
#         beneficiario=crear_destinatario_valido(),
#         responsable_adulto=None,
#         contexto_institucional=crear_contexto_valido(),
#     )

#     errores = validar_reglas_solicitud_alta(solicitud)

#     imprimir_resultado(
#         "PRUEBA 6 - Alta tutor con beneficiario de tipo Destinatario",
#         errores,
#     )


# def prueba_baja_valida() -> None:
#     contexto = crear_contexto_valido()

#     solicitud = SolicitudBaja(
#         fecha_emision=date.today(),
#         profesionales_intervinientes=contexto.profesionales,
#         tipo_beneficiario=TipoBeneficiarioBaja.DESTINATARIO,
#         motivo=MotivoBaja.TRABAJO_FORMAL,
#         beneficiario=crear_destinatario_valido(),
#         responsable_adulto=crear_responsable_valido(),
#         contexto_institucional=contexto,
#     )

#     errores = validar_reglas_solicitud_baja(solicitud)

#     imprimir_resultado(
#         "PRUEBA 7 - Baja válida",
#         errores,
#     )


# def prueba_baja_sin_profesionales_intervinientes() -> None:
#     contexto = crear_contexto_valido()

#     solicitud = SolicitudBaja(
#         fecha_emision=date.today(),
#         profesionales_intervinientes=[],
#         tipo_beneficiario=TipoBeneficiarioBaja.DESTINATARIO,
#         motivo=MotivoBaja.TRABAJO_FORMAL,
#         beneficiario=crear_destinatario_valido(),
#         responsable_adulto=crear_responsable_valido(),
#         contexto_institucional=contexto,
#     )

#     errores = validar_reglas_solicitud_baja(solicitud)

#     imprimir_resultado(
#         "PRUEBA 8 - Baja sin profesionales intervinientes",
#         errores,
#     )


# def prueba_baja_con_profesional_no_configurado() -> None:
#     contexto = crear_contexto_valido()

#     profesional_no_configurado = PersonalInstitucional(
#         nombre="Sofía",
#         apellido="Ramírez",
#         rol=Rol(
#             nombre="Psicóloga",
#             siglas="PSI",
#         ),
#     )

#     solicitud = SolicitudBaja(
#         fecha_emision=date.today(),
#         profesionales_intervinientes=[profesional_no_configurado],
#         tipo_beneficiario=TipoBeneficiarioBaja.DESTINATARIO,
#         motivo=MotivoBaja.TRABAJO_FORMAL,
#         beneficiario=crear_destinatario_valido(),
#         responsable_adulto=crear_responsable_valido(),
#         contexto_institucional=contexto,
#     )

#     errores = validar_reglas_solicitud_baja(solicitud)

#     imprimir_resultado(
#         "PRUEBA 9 - Baja con profesional no configurado",
#         errores,
#     )


# def prueba_baja_con_profesionales_repetidos() -> None:
#     contexto = crear_contexto_valido()

#     profesional = contexto.profesionales[0]

#     solicitud = SolicitudBaja(
#         fecha_emision=date.today(),
#         profesionales_intervinientes=[profesional, profesional],
#         tipo_beneficiario=TipoBeneficiarioBaja.DESTINATARIO,
#         motivo=MotivoBaja.TRABAJO_FORMAL,
#         beneficiario=crear_destinatario_valido(),
#         responsable_adulto=crear_responsable_valido(),
#         contexto_institucional=contexto,
#     )

#     errores = validar_reglas_solicitud_baja(solicitud)

#     imprimir_resultado(
#         "PRUEBA 10 - Baja con profesionales repetidos",
#         errores,
#     )


# # ============================================================
# # EJECUCIÓN MANUAL
# # ============================================================

# if __name__ == "__main__":
#     prueba_contexto_valido()
#     prueba_contexto_sin_profesionales()

#     prueba_alta_destinatario_valida()
#     prueba_alta_destinatario_sin_responsable()
#     prueba_alta_tutor_valida()
#     prueba_alta_tutor_con_destinatario()

#     prueba_baja_valida()
#     prueba_baja_sin_profesionales_intervinientes()
#     prueba_baja_con_profesional_no_configurado()
#     prueba_baja_con_profesionales_repetidos()