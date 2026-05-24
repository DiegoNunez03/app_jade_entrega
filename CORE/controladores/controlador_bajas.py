# # app_jade / CORE / controladores / controlador_bajas.py

# from pathlib import Path
# from typing import Any
# import json
# import os
# import re
# import shutil
# import subprocess
# import sys
# from datetime import date

# from pydantic import BaseModel, ValidationError, field_validator
# from PySide6.QtCore import QObject, Slot

# from ..validaciones import (
#     validar_baja_institucional,
#     validar_baja_responsable,
# )

# from ..generador_baja import generar_solicitud_baja

# from CORE.dominio.catalogos import (
#     TipoBeneficiarioBaja,
#     MotivoBaja,
# )

# from CORE.schemas.personas_schema import (
#     BeneficiarioBajaSchema,
#     ResponsableBajaSchema,
# )

# from CORE.schemas.solicitud_baja_schema import (
#     SolicitudBajaSchema,
#     validar_tipo_beneficiario_baja,
#     validar_motivo_baja,
# )
# from CORE.mapeadores.mapeador_dominio import mapear_solicitud_baja
# from CORE.dominio.reglas import validar_reglas_solicitud_baja
# from CORE.dominio.errores import errores_a_texto


# # ============================================================
# # SCHEMA INTERNO - VALIDACIÓN POR PASO BENEFICIARIO BAJA
# # ============================================================

# class BajaBeneficiarioPasoSchema(BaseModel):
#     tipo_beneficiario: TipoBeneficiarioBaja
#     beneficiario: BeneficiarioBajaSchema
#     motivo: MotivoBaja

#     @field_validator("tipo_beneficiario", mode="before")
#     @classmethod
#     def validar_tipo_beneficiario(cls, valor: Any) -> TipoBeneficiarioBaja:
#         return validar_tipo_beneficiario_baja(valor)

#     @field_validator("motivo", mode="before")
#     @classmethod
#     def validar_motivo(cls, valor: Any) -> MotivoBaja:
#         return validar_motivo_baja(valor)


# class BajaResponsablePasoSchema(BaseModel):
#     responsable_adulto: ResponsableBajaSchema

# class ControladorBajas(QObject):
#     """
#     Puente entre QML y el generador de solicitud de baja.

#     Recibe datos desde QML, valida por pasos, prepara datos para
#     previsualización y genera la solicitud en formato DOCX.
#     """

#     # ============================================================
#     # VALIDACIONES POR PASO
#     # ============================================================

#     @Slot("QVariantMap", result="QVariantMap")
#     def validarBajaInstitucional(self, datos: dict[str, Any]) -> dict[str, Any]:
#         return validar_baja_institucional(datos)

#     @Slot("QVariantMap", result="QVariantMap")
#     def validarBajaBeneficiario(self, datos: dict[str, Any]) -> dict[str, Any]:
#         try:
#             datos_schema = {
#                 "tipo_beneficiario": self._normalizar_tipo_beneficiario_schema(
#                     datos.get("bajaTipoBeneficiario", "")
#                 ),
#                 "beneficiario": {
#                     "nombre": str(datos.get("bajaNombre", "")).strip(),
#                     "apellido": str(datos.get("bajaApellido", "")).strip(),
#                     "tipo_dni": str(datos.get("bajaTipoDni", "")).strip(),
#                     "dni": str(datos.get("bajaDni", "")).strip(),
#                     "fecha_ingreso": str(datos.get("bajaFechaIngreso", "")).strip(),
#                 },
#                 "motivo": str(datos.get("bajaMotivo", "")).strip(),
#             }

#             BajaBeneficiarioPasoSchema(**datos_schema)

#             return {
#                 "valido": True,
#                 "errores": [],
#                 "mensaje": "",
#             }

#         except ValidationError as error:
#             return self._resultado_pydantic_para_qml(
#                 error=error,
#                 mapa_campos={
#                     "tipo_beneficiario": "bajaTipoBeneficiario",
#                     "beneficiario.nombre": "bajaNombre",
#                     "beneficiario.apellido": "bajaApellido",
#                     "beneficiario.tipo_dni": "bajaTipoDni",
#                     "beneficiario.dni": "bajaDni",
#                     "beneficiario.fecha_ingreso": "bajaFechaIngreso",
#                     "motivo": "bajaMotivo",
#                 },
#             )

#     # @Slot("QVariantMap", result="QVariantMap")
#     # def validarBajaResponsable(self, datos: dict[str, Any]) -> dict[str, Any]:
#     #     return validar_baja_responsable(datos)

#     @Slot("QVariantMap", result="QVariantMap")
#     def validarBajaResponsable(self, datos: dict[str, Any]) -> dict[str, Any]:
#         try:
#             datos_schema = {
#                 "responsable_adulto": {
#                     "nombre": str(
#                         datos.get("bajaResponsableNombre", "")
#                     ).strip(),
#                     "apellido": str(
#                         datos.get("bajaResponsableApellido", "")
#                     ).strip(),
#                     "relacion": str(
#                         datos.get("bajaResponsableRelacion", "")
#                     ).strip(),
#                     "informado": str(
#                         datos.get("bajaResponsableInformado", "")
#                     ).strip(),
#                 },
#             }

#             BajaResponsablePasoSchema(**datos_schema)

#             return {
#                 "valido": True,
#                 "errores": [],
#                 "mensaje": "",
#             }

#         except ValidationError as error:
#             return self._resultado_pydantic_para_qml(
#                 error=error,
#                 mapa_campos={
#                     "responsable_adulto.nombre": "bajaResponsableNombre",
#                     "responsable_adulto.apellido": "bajaResponsableApellido",
#                     "responsable_adulto.relacion": "bajaResponsableRelacion",
#                     "responsable_adulto.informado": "bajaResponsableInformado",
#                 },
#             )

#     # ============================================================
#     # PREVISUALIZACIÓN
#     # ============================================================

#     @Slot("QVariantMap", result="QVariantMap")
#     def prepararDatosBaja(self, datos: dict[str, Any]) -> dict[str, Any]:
#         """
#         Prepara los datos finales de la baja sin generar archivos.
#         Se usa para la previsualización QML.
#         """
#         try:
#             return self._mapear_datos_baja(datos)

#         except Exception as error:
#             print(f"ERROR al preparar datos de baja: {error}")
#             return {
#                 "error": f"No se pudieron preparar los datos de la baja: {error}"
#             }

#     # ============================================================
#     # GENERACIÓN
#     # ============================================================

#     @Slot("QVariantMap", result=str)
#     def generarSolicitudBaja(self, datos: dict[str, Any]) -> str:
#         try:
#             datos_baja = self._mapear_datos_baja(datos)

#             resultado_validacion = self._validar_solicitud_baja_con_modelo_nuevo(
#                 datos_baja
#             )

#             if not resultado_validacion["valido"]:
#                 return (
#                     "ERROR|No se pudo generar la solicitud de baja:\n"
#                     f"{resultado_validacion['mensaje']}"
#                 )

#             ruta_docx = self._crear_ruta_salida(datos_baja)

#             generar_solicitud_baja(
#                 datos=datos_baja,
#                 ruta_docx=ruta_docx,
#             )

#             if not ruta_docx.exists():
#                 return f"ERROR|El archivo DOCX no se generó en la ruta esperada: {ruta_docx}"

#             copias_externas = self._copiar_archivos_a_carpeta_externa_si_corresponde(
#                 [ruta_docx]
#             )

#             self._abrir_archivo(ruta_docx)

#             mensaje = f"OK|Solicitud de baja generada correctamente:\nDOCX: {ruta_docx}"

#             if copias_externas:
#                 mensaje += "\nCopias externas generadas:"
#                 for ruta_copia in copias_externas:
#                     mensaje += f"\n- {ruta_copia}"

#             return mensaje

#         except Exception as error:
#             return f"ERROR|No se pudo generar la solicitud de baja: {error}"

#     # ============================================================
#     # VALIDACIÓN FINAL NUEVA
#     # ============================================================

#     def _validar_solicitud_baja_con_modelo_nuevo(
#         self,
#         datos_baja: dict[str, Any],
#     ) -> dict[str, Any]:
#         try:
#             datos_schema = self._armar_datos_schema_solicitud_baja(datos_baja)

#             schema = SolicitudBajaSchema(**datos_schema)
#             solicitud = mapear_solicitud_baja(schema)
#             errores_dominio = validar_reglas_solicitud_baja(solicitud)

#             if errores_dominio:
#                 return {
#                     "valido": False,
#                     "mensaje": errores_a_texto(errores_dominio),
#                 }

#             return {
#                 "valido": True,
#                 "mensaje": "Operación exitosa.",
#             }

#         except ValidationError as error:
#             return {
#                 "valido": False,
#                 "mensaje": self._mensaje_usuario_pydantic(error),
#             }

#         except Exception as error:
#             return {
#                 "valido": False,
#                 "mensaje": str(error),
#             }

#     def _armar_datos_schema_solicitud_baja(
#         self,
#         datos_baja: dict[str, Any],
#     ) -> dict[str, Any]:
#         contexto = self._cargar_contexto_institucional_para_schema()

#         profesionales_intervinientes = self._obtener_profesionales_intervinientes_para_schema(
#             datos_baja=datos_baja,
#             contexto=contexto,
#         )

#         return {
#             "fecha_emision": date.today(),
#             "profesionales_intervinientes": profesionales_intervinientes,
#             "tipo_beneficiario": self._normalizar_tipo_beneficiario_schema(
#                 datos_baja.get("bajaTipoBeneficiario", "")
#             ),
#             "motivo": str(datos_baja.get("bajaMotivo", "")).strip(),
#             "beneficiario": {
#                 "nombre": str(datos_baja.get("bajaNombre", "")).strip(),
#                 "apellido": str(datos_baja.get("bajaApellido", "")).strip(),
#                 "tipo_dni": str(datos_baja.get("bajaTipoDni", "")).strip(),
#                 "dni": str(datos_baja.get("bajaDni", "")).strip(),
#                 "fecha_ingreso": str(datos_baja.get("bajaFechaIngreso", "")).strip(),
#             },
#             "responsable_adulto": {
#                 "nombre": str(datos_baja.get("bajaResponsableNombre", "")).strip(),
#                 "apellido": str(datos_baja.get("bajaResponsableApellido", "")).strip(),
#                 "relacion": str(datos_baja.get("bajaResponsableRelacion", "")).strip(),
#                 "informado": str(datos_baja.get("bajaResponsableInformado", "")).strip(),
#             },
#             "contexto_institucional": contexto,
#         }

#     def _normalizar_tipo_beneficiario_schema(self, valor: Any) -> str:
#         texto = str(valor).strip()

#         if texto == "Destinatario":
#             return "destinatario"

#         if texto == "Tutor":
#             return "tutor"

#         return texto

#     def _obtener_profesionales_intervinientes_para_schema(
#         self,
#         datos_baja: dict[str, Any],
#         contexto: dict[str, Any],
#     ) -> list[dict[str, Any]]:
#         profesionales_recibidos = self._normalizar_lista_profesionales(
#             datos_baja.get("profesionalesIntervinientes", [])
#         )

#         profesionales_contexto = contexto.get("profesionales", []) or []

#         profesionales_resultado: list[dict[str, Any]] = []

#         for profesional_recibido in profesionales_recibidos:
#             profesional_encontrado = self._buscar_profesional_por_texto(
#                 profesional_recibido,
#                 profesionales_contexto,
#             )

#             if profesional_encontrado is not None:
#                 profesionales_resultado.append(profesional_encontrado)
#                 continue

#             profesional_parseado = self._parsear_profesional_texto(
#                 profesional_recibido
#             )

#             if profesional_parseado is not None:
#                 profesionales_resultado.append(profesional_parseado)

#         return profesionales_resultado

#     def _buscar_profesional_por_texto(
#         self,
#         texto_profesional: str,
#         profesionales_contexto: list[dict[str, Any]],
#     ) -> dict[str, Any] | None:
#         clave_buscada = self._normalizar_texto_clave(texto_profesional)

#         for profesional in profesionales_contexto:
#             texto_contexto = self._formatear_personal_institucional(profesional)
#             clave_contexto = self._normalizar_texto_clave(texto_contexto)

#             if clave_contexto == clave_buscada:
#                 return profesional

#         return None

#     def _parsear_profesional_texto(
#         self,
#         texto_profesional: str,
#     ) -> dict[str, Any] | None:
#         texto = str(texto_profesional).strip()

#         if not texto:
#             return None

#         partes = texto.split("-")
#         nombre_apellido = partes[0].strip()
#         siglas = partes[1].strip() if len(partes) > 1 else ""

#         partes_nombre = nombre_apellido.split()

#         if len(partes_nombre) < 2:
#             return None

#         apellido = partes_nombre[0]
#         nombre = " ".join(partes_nombre[1:])

#         nombre_rol = self._nombre_rol_por_siglas(siglas)

#         return {
#             "nombre": nombre,
#             "apellido": apellido,
#             "rol": {
#                 "nombre": nombre_rol,
#                 "siglas": siglas,
#             },
#         }

#     def _nombre_rol_por_siglas(self, siglas: str) -> str:
#         roles = {
#             "TS": "Trabajadora social",
#             "PSI": "Psicóloga",
#             "PSP": "Psicopedagoga",
#             "EFC": "Profesor de educación física",
#         }

#         return roles.get(siglas, siglas)

#     def _cargar_contexto_institucional_para_schema(self) -> dict[str, Any]:
#         base_dir = Path(__file__).resolve().parent.parent.parent
#         config_dir = base_dir / "config"
#         config_path_v2 = config_dir / "configuracion_sede_v2.json"
#         config_path_vieja = config_dir / "configuracion_sede.json"

#         if config_path_v2.exists():
#             try:
#                 with config_path_v2.open("r", encoding="utf-8") as archivo:
#                     configuracion = json.load(archivo)

#                 ubicacion = configuracion.get("ubicacion", {}) or {}
#                 coordinador = configuracion.get("coordinador", {}) or {}
#                 profesionales = configuracion.get("profesionales", []) or []

#                 return {
#                     "origen": str(configuracion.get("origen", "")).strip(),
#                     "nombre_sede": str(configuracion.get("nombre_sede", "")).strip(),
#                     "ubicacion": {
#                         "municipio": str(ubicacion.get("municipio", "")).strip(),
#                         "localidad": str(ubicacion.get("localidad", "")).strip(),
#                         "barrio": str(ubicacion.get("barrio", "")).strip(),
#                     },
#                     "coordinador": self._normalizar_personal_institucional_para_schema(
#                         coordinador
#                     ),
#                     "profesionales": [
#                         self._normalizar_personal_institucional_para_schema(
#                             profesional
#                         )
#                         for profesional in profesionales
#                         if isinstance(profesional, dict)
#                     ],
#                 }

#             except Exception as error:
#                 raise RuntimeError(
#                     f"No se pudo cargar configuracion_sede_v2.json: {error}"
#                 ) from error

#         if config_path_vieja.exists():
#             try:
#                 with config_path_vieja.open("r", encoding="utf-8") as archivo:
#                     configuracion = json.load(archivo)

#                 return {
#                     "origen": str(configuracion.get("origen", "")).strip(),
#                     "nombre_sede": str(configuracion.get("nombreSede", "")).strip(),
#                     "ubicacion": {
#                         "municipio": str(configuracion.get("municipio", "")).strip(),
#                         "localidad": str(configuracion.get("localidad", "")).strip(),
#                         "barrio": str(configuracion.get("barrio", "")).strip(),
#                     },
#                     "coordinador": {
#                         "nombre": "",
#                         "apellido": "",
#                         "rol": {
#                             "nombre": "",
#                             "siglas": "",
#                         },
#                     },
#                     "profesionales": [],
#                 }

#             except Exception as error:
#                 raise RuntimeError(
#                     f"No se pudo cargar configuracion_sede.json: {error}"
#                 ) from error

#         return {
#             "origen": "",
#             "nombre_sede": "",
#             "ubicacion": {
#                 "municipio": "",
#                 "localidad": "",
#                 "barrio": "",
#             },
#             "coordinador": {
#                 "nombre": "",
#                 "apellido": "",
#                 "rol": {
#                     "nombre": "",
#                     "siglas": "",
#                 },
#             },
#             "profesionales": [],
#         }

#     def _normalizar_personal_institucional_para_schema(
#         self,
#         persona: dict[str, Any],
#     ) -> dict[str, Any]:
#         if not isinstance(persona, dict):
#             return {
#                 "nombre": "",
#                 "apellido": "",
#                 "rol": {
#                     "nombre": "",
#                     "siglas": "",
#                 },
#             }

#         rol = persona.get("rol", {}) or {}

#         return {
#             "nombre": str(persona.get("nombre", "")).strip(),
#             "apellido": str(persona.get("apellido", "")).strip(),
#             "rol": {
#                 "nombre": str(rol.get("nombre", "")).strip(),
#                 "siglas": str(rol.get("siglas", "")).strip(),
#             },
#         }

#     # ============================================================
#     # MAPEO DE DATOS PARA DOCX
#     # ============================================================

#     def _mapear_datos_baja(self, datos: dict[str, Any]) -> dict[str, Any]:
#         configuracion_sede = self._cargar_configuracion_sede()

#         sede_configurada = str(configuracion_sede.get("nombreSede", "")).strip()
#         centro_envion_configurado = str(configuracion_sede.get("origen", "")).strip()
#         coordinadora_configurada = str(configuracion_sede.get("coordinadora", "")).strip()

#         profesionales_recibidos = datos.get("profesionalesIntervinientes", [])

#         datos_mapeados = {
#             # Institucional
#             "centroEnvion": str(
#                 datos.get("centroEnvion", centro_envion_configurado)
#             ).strip() or centro_envion_configurado,

#             "sede": str(
#                 datos.get("sede", sede_configurada)
#             ).strip() or sede_configurada,

#             "modalidad": str(datos.get("modalidad", "")).strip(),

#             "profesionalesIntervinientes": self._normalizar_lista_profesionales(
#                 profesionales_recibidos
#             ),

#             "profesionalesIntervinientesTexto": str(
#                 datos.get("profesionalesIntervinientesTexto", "")
#             ).strip(),

#             "coordinadora": str(
#                 datos.get("coordinadora", coordinadora_configurada)
#             ).strip() or coordinadora_configurada,

#             "fechaBaja": str(datos.get("fechaBaja", "")).strip(),

#             # Beneficiario
#             "bajaTipoBeneficiario": str(datos.get("bajaTipoBeneficiario", "")).strip(),
#             "bajaNombre": str(datos.get("bajaNombre", "")).strip(),
#             "bajaApellido": str(datos.get("bajaApellido", "")).strip(),
#             "bajaNombreCompleto": str(datos.get("bajaNombreCompleto", "")).strip(),
#             "bajaTipoDni": str(datos.get("bajaTipoDni", "")).strip(),
#             "bajaDni": str(datos.get("bajaDni", "")).strip(),
#             "bajaFechaIngreso": str(datos.get("bajaFechaIngreso", "")).strip(),
#             "bajaMotivo": str(datos.get("bajaMotivo", "")).strip(),

#             # Responsable Adulto
#             "bajaResponsableNombre": str(datos.get("bajaResponsableNombre", "")).strip(),
#             "bajaResponsableApellido": str(datos.get("bajaResponsableApellido", "")).strip(),
#             "bajaResponsableNombreCompleto": str(
#                 datos.get("bajaResponsableNombreCompleto", "")
#             ).strip(),
#             "bajaResponsableRelacion": str(
#                 datos.get("bajaResponsableRelacion", "")
#             ).strip(),
#             "bajaResponsableInformado": str(
#                 datos.get("bajaResponsableInformado", "")
#             ).strip(),

#             # Datos útiles para documento
#             "fechaEmision": self._obtener_fecha_actual(),
#         }

#         if not datos_mapeados["profesionalesIntervinientesTexto"]:
#             datos_mapeados["profesionalesIntervinientesTexto"] = " / ".join(
#                 datos_mapeados["profesionalesIntervinientes"]
#             )

#         if not datos_mapeados["bajaNombreCompleto"]:
#             datos_mapeados["bajaNombreCompleto"] = (
#                 f"{datos_mapeados['bajaNombre']} {datos_mapeados['bajaApellido']}"
#             ).strip()

#         if not datos_mapeados["bajaResponsableNombreCompleto"]:
#             datos_mapeados["bajaResponsableNombreCompleto"] = (
#                 f"{datos_mapeados['bajaResponsableNombre']} "
#                 f"{datos_mapeados['bajaResponsableApellido']}"
#             ).strip()

#         datos_mapeados.update(
#             self._crear_marcas_documento(datos_mapeados)
#         )

#         return datos_mapeados

#     def _crear_marcas_documento(self, datos: dict[str, Any]) -> dict[str, str]:
#         """
#         Crea marcas auxiliares para el documento:
#         - tipo beneficiario;
#         - responsable informado;
#         - motivo seleccionado.
#         """

#         tipo = datos.get("bajaTipoBeneficiario", "")
#         informado = datos.get("bajaResponsableInformado", "")
#         motivo = datos.get("bajaMotivo", "")

#         motivos = [
#             "Encontrarse privado de la libertad",
#             "Fallecimiento",
#             "Haber cumplimentado con todos los acuerdos para su egreso",
#             "Liquidaciones consecutivas impagas",
#             "Mudanza a otro Municipio",
#             "Negativa a cumplir con su Acuerdo de Compromiso",
#             "Negativa del Joven a participar",
#             "Negativa o dificultades al momento de la socialización",
#             "Pase de Destinatario a Tutor",
#             "Pase de Tutor a Destinatario",
#             "Trabajo Formal",
#             "Otros motivos",
#         ]

#         marcas = {
#             "marcaTipoDestinatario": "X" if tipo == "Destinatario" else "",
#             "marcaTipoTutor": "X" if tipo == "Tutor" else "",
#             "marcaResponsableInformadoSi": "X" if informado in {"Sí", "Si"} else "",
#             "marcaResponsableInformadoNo": "X" if informado == "No" else "",
#         }

#         for indice, motivo_actual in enumerate(motivos, start=1):
#             campo = f"marcaMotivo{indice:02d}"
#             marcas[campo] = "X" if motivo == motivo_actual else ""

#         return marcas

#     # ============================================================
#     # CONFIGURACIÓN
#     # ============================================================

#     def _obtener_fecha_actual(self) -> str:
#         return date.today().strftime("%d/%m/%Y")

#     def _cargar_configuracion_sede(self) -> dict[str, Any]:
#         """
#         Carga la configuración institucional nueva.

#         Devuelve una estructura compatible con el flujo actual de baja:
#         - nombreSede
#         - origen
#         - municipio
#         - localidad
#         - barrio
#         - coordinadora
#         - profesionalesIntervinientes
#         """
#         base_dir = Path(__file__).resolve().parent.parent.parent
#         config_dir = base_dir / "config"

#         config_path_v2 = config_dir / "configuracion_sede_v2.json"
#         config_path_vieja = config_dir / "configuracion_sede.json"

#         configuracion_vacia = {
#             "nombreSede": "",
#             "origen": "",
#             "municipio": "",
#             "localidad": "",
#             "barrio": "",
#             "coordinadora": "",
#             "profesionalesIntervinientes": [],
#             "fechaAutomatica": True,
#             "edadAutomatica": True,
#             "fechaActual": self._obtener_fecha_actual(),
#         }

#         if config_path_v2.exists():
#             try:
#                 with config_path_v2.open("r", encoding="utf-8") as archivo:
#                     configuracion = json.load(archivo)

#                 ubicacion = configuracion.get("ubicacion", {}) or {}
#                 coordinador = configuracion.get("coordinador", {}) or {}

#                 profesionales = self._normalizar_lista_profesionales(
#                     configuracion.get("profesionales", [])
#                 )

#                 return {
#                     "nombreSede": str(configuracion.get("nombre_sede", "")).strip(),
#                     "origen": str(configuracion.get("origen", "")).strip(),
#                     "municipio": str(ubicacion.get("municipio", "")).strip(),
#                     "localidad": str(ubicacion.get("localidad", "")).strip(),
#                     "barrio": str(ubicacion.get("barrio", "")).strip(),
#                     "coordinadora": self._formatear_personal_institucional(coordinador),
#                     "profesionalesIntervinientes": profesionales,
#                     "fechaAutomatica": True,
#                     "edadAutomatica": True,
#                     "fechaActual": self._obtener_fecha_actual(),
#                 }

#             except Exception as error:
#                 print(f"ERROR al cargar configuración de sede v2: {error}")
#                 return configuracion_vacia

#         if not config_path_vieja.exists():
#             return configuracion_vacia

#         try:
#             with config_path_vieja.open("r", encoding="utf-8") as archivo:
#                 configuracion = json.load(archivo)

#             return {
#                 "nombreSede": str(configuracion.get("nombreSede", "")),
#                 "origen": str(configuracion.get("origen", "")),
#                 "municipio": str(configuracion.get("municipio", "")),
#                 "localidad": str(configuracion.get("localidad", "")),
#                 "barrio": str(configuracion.get("barrio", "")),
#                 "coordinadora": str(configuracion.get("coordinadora", "")),
#                 "profesionalesIntervinientes": self._normalizar_lista_profesionales(
#                     configuracion.get("profesionalesIntervinientes", [])
#                 ),
#                 "fechaAutomatica": bool(configuracion.get("fechaAutomatica", True)),
#                 "edadAutomatica": bool(configuracion.get("edadAutomatica", True)),
#                 "fechaActual": str(
#                     configuracion.get("fechaActual", self._obtener_fecha_actual())
#                 ),
#             }

#         except Exception as error:
#             print(f"ERROR al cargar configuración de sede vieja: {error}")
#             return configuracion_vacia

#     def _cargar_configuracion_guardado(self) -> dict[str, Any]:
#         base_dir = Path(__file__).resolve().parent.parent.parent
#         config_dir = base_dir / "config"
#         config_path = config_dir / "configuracion_guardado.json"

#         configuracion_vacia = {
#             "carpeta_copia_externa_solicitudes": ""
#         }

#         config_dir.mkdir(parents=True, exist_ok=True)

#         if not config_path.exists():
#             with config_path.open("w", encoding="utf-8") as archivo:
#                 json.dump(configuracion_vacia, archivo, indent=4, ensure_ascii=False)

#             return configuracion_vacia

#         try:
#             with config_path.open("r", encoding="utf-8") as archivo:
#                 configuracion = json.load(archivo)

#             return {
#                 "carpeta_copia_externa_solicitudes": str(
#                     configuracion.get("carpeta_copia_externa_solicitudes", "")
#                 )
#             }

#         except Exception as error:
#             print(f"ERROR al cargar configuración de guardado: {error}")
#             return configuracion_vacia

#     @Slot(result="QVariantMap")
#     def obtenerConfiguracionBaja(self) -> dict[str, Any]:
#         """
#         Devuelve los datos institucionales base que usa la baja.

#         Para la solicitud de baja:
#         - centroEnvion se toma desde 'origen'
#         - sede se toma desde 'nombreSede' / 'nombre_sede'
#         - coordinadora se toma desde 'coordinador'
#         - profesionalesIntervinientes se toma desde 'profesionales'
#         """
#         configuracion = self._cargar_configuracion_sede()

#         return {
#             "centroEnvion": str(configuracion.get("origen", "")).strip(),
#             "sede": str(configuracion.get("nombreSede", "")).strip(),
#             "coordinadora": str(configuracion.get("coordinadora", "")).strip(),
#             "profesionalesIntervinientes": self._normalizar_lista_profesionales(
#                 configuracion.get("profesionalesIntervinientes", [])
#             ),
#         }

#     # ============================================================
#     # RUTAS Y ARCHIVOS
#     # ============================================================

#     def _crear_ruta_salida(self, datos_baja: dict[str, Any]) -> Path:
#         base_dir = Path(__file__).resolve().parent.parent.parent

#         output_dir = base_dir / "output" / "solicitudes_generadas"
#         output_dir.mkdir(parents=True, exist_ok=True)

#         nombre_completo = str(datos_baja.get("bajaNombreCompleto", "")).strip()

#         if not nombre_completo:
#             nombre = str(datos_baja.get("bajaNombre", "")).strip()
#             apellido = str(datos_baja.get("bajaApellido", "")).strip()
#             nombre_completo = f"{nombre} {apellido}".strip()

#         if not nombre_completo:
#             nombre_completo = "sin_nombre"

#         nombre_limpio = self._limpiar_nombre_archivo(nombre_completo)

#         nombre_base = f"solicitud_de_baja_{nombre_limpio}"
#         extension = ".docx"

#         ruta = output_dir / f"{nombre_base}{extension}"

#         contador = 1

#         while ruta.exists():
#             ruta = output_dir / f"{nombre_base}_{contador}{extension}"
#             contador += 1

#         return ruta.resolve()

#     def _copiar_archivos_a_carpeta_externa_si_corresponde(
#         self,
#         rutas_origen: list[Path],
#     ) -> list[Path]:
#         configuracion = self._cargar_configuracion_guardado()

#         carpeta_externa = str(
#             configuracion.get("carpeta_copia_externa_solicitudes", "")
#         ).strip()

#         if not carpeta_externa:
#             return []

#         ruta_carpeta_externa = Path(carpeta_externa).expanduser()
#         ruta_carpeta_externa.mkdir(parents=True, exist_ok=True)

#         rutas_copiadas: list[Path] = []

#         for ruta_origen in rutas_origen:
#             if not ruta_origen.exists():
#                 continue

#             ruta_destino = ruta_carpeta_externa / ruta_origen.name

#             contador = 1
#             nombre_base = ruta_origen.stem
#             extension = ruta_origen.suffix

#             while ruta_destino.exists():
#                 ruta_destino = ruta_carpeta_externa / f"{nombre_base}_{contador}{extension}"
#                 contador += 1

#             shutil.copy2(ruta_origen, ruta_destino)
#             rutas_copiadas.append(ruta_destino.resolve())

#         return rutas_copiadas

#     def _limpiar_nombre_archivo(self, texto: str) -> str:
#         texto = texto.strip().lower()

#         reemplazos = {
#             "á": "a",
#             "é": "e",
#             "í": "i",
#             "ó": "o",
#             "ú": "u",
#             "ñ": "n",
#         }

#         for original, reemplazo in reemplazos.items():
#             texto = texto.replace(original, reemplazo)

#         texto = re.sub(r"[^a-zA-Z0-9 _-]", "", texto)
#         texto = re.sub(r"\s+", "_", texto)
#         texto = re.sub(r"_+", "_", texto)

#         return texto.strip("_")

#     def _normalizar_lista_profesionales(self, valor: Any) -> list[str]:
#         """
#         Acepta:
#         - lista de strings vieja
#         - string separado por /
#         - lista de objetos nuevos con nombre/apellido/rol
#         """
#         if isinstance(valor, list):
#             resultado: list[str] = []

#             for item in valor:
#                 if isinstance(item, dict):
#                     texto = self._formatear_personal_institucional(item)
#                 else:
#                     texto = str(item).strip()

#                 if texto:
#                     resultado.append(texto)

#             return resultado

#         if isinstance(valor, tuple):
#             return [str(item).strip() for item in valor if str(item).strip()]

#         texto = str(valor).strip()

#         if not texto:
#             return []

#         return [parte.strip() for parte in texto.split("/") if parte.strip()]

#     def _formatear_personal_institucional(self, persona: Any) -> str:
#         if not isinstance(persona, dict):
#             return str(persona).strip()

#         nombre = str(persona.get("nombre", "")).strip()
#         apellido = str(persona.get("apellido", "")).strip()
#         rol = persona.get("rol", {}) or {}
#         siglas = str(rol.get("siglas", "")).strip()

#         nombre_completo = f"{apellido} {nombre}".strip()

#         if siglas:
#             return f"{nombre_completo} - {siglas}".strip()

#         return nombre_completo

#     def _normalizar_texto_clave(self, valor: Any) -> str:
#         texto = str(valor).strip().lower()
#         texto = texto.replace("á", "a")
#         texto = texto.replace("é", "e")
#         texto = texto.replace("í", "i")
#         texto = texto.replace("ó", "o")
#         texto = texto.replace("ú", "u")
#         texto = texto.replace("ñ", "n")

#         texto = re.sub(r"\s+", " ", texto)

#         return texto

#     # ============================================================
#     # FORMATO DE ERRORES PYDANTIC / QML
#     # ============================================================

#     def _resultado_pydantic_para_qml(
#         self,
#         error: ValidationError,
#         mapa_campos: dict[str, str],
#     ) -> dict[str, Any]:
#         errores = []
#         mensajes = []

#         for detalle in error.errors():
#             campo_schema = self._obtener_campo_error(detalle)
#             campo_qml = mapa_campos.get(campo_schema, campo_schema)

#             mensaje = str(detalle.get("msg", "")).strip()

#             errores.append({
#                 "campo": campo_qml,
#                 "mensaje": mensaje,
#             })

#             mensajes.append(f"{campo_qml}: {mensaje}")

#         return {
#             "valido": False,
#             "errores": errores,
#             "mensaje": "\n".join(mensajes),
#         }

#     def _mensaje_usuario_pydantic(self, error: ValidationError) -> str:
#         mensajes: list[str] = []

#         for detalle in error.errors():
#             campo = self._obtener_campo_error(detalle)
#             mensaje = str(detalle.get("msg", "")).strip()

#             if campo:
#                 mensajes.append(f"{campo}: {mensaje}")
#             else:
#                 mensajes.append(mensaje)

#         return "\n".join(mensajes)

#     def _obtener_campo_error(self, detalle_error: dict[str, Any]) -> str:
#         ubicacion = detalle_error.get("loc", [])

#         return ".".join(str(parte) for parte in ubicacion)

#     def _abrir_archivo(self, ruta: Path) -> None:
#         ruta = ruta.resolve()

#         if sys.platform.startswith("linux"):
#             libreoffice = shutil.which("libreoffice")

#             if libreoffice:
#                 subprocess.Popen(
#                     [libreoffice, "--writer", str(ruta)],
#                     stdout=subprocess.DEVNULL,
#                     stderr=subprocess.DEVNULL,
#                 )
#                 return

#             subprocess.Popen(
#                 ["xdg-open", str(ruta)],
#                 stdout=subprocess.DEVNULL,
#                 stderr=subprocess.DEVNULL,
#             )
#             return

#         if sys.platform == "darwin":
#             subprocess.Popen(
#                 ["open", str(ruta)],
#                 stdout=subprocess.DEVNULL,
#                 stderr=subprocess.DEVNULL,
#             )
#             return

#         if os.name == "nt":
#             os.startfile(str(ruta))


# # app_jade / CORE / controladores / controlador_bajas.py

# from pathlib import Path
# from typing import Any
# import json
# import os
# import re
# import shutil
# import subprocess
# import sys
# from datetime import date

# from pydantic import BaseModel, ValidationError, field_validator
# from PySide6.QtCore import QObject, Slot

# from ..validaciones import (
#     validar_baja_institucional,
# )

# from ..generador_baja import generar_solicitud_baja

# from CORE.dominio.catalogos import (
#     TipoBeneficiarioBaja,
#     MotivoBaja,
# )

# from CORE.schemas.personas_schema import (
#     BeneficiarioBajaSchema,
#     ResponsableBajaSchema,
# )

# from CORE.schemas.solicitud_baja_schema import (
#     SolicitudBajaSchema,
#     validar_tipo_beneficiario_baja,
#     validar_motivo_baja,
# )
# from CORE.mapeadores.mapeador_dominio import mapear_solicitud_baja
# from CORE.dominio.reglas import validar_reglas_solicitud_baja
# from CORE.dominio.errores import errores_a_texto


# # ============================================================
# # SCHEMA INTERNO - VALIDACIÓN POR PASO BENEFICIARIO BAJA
# # ============================================================

# class BajaBeneficiarioPasoSchema(BaseModel):
#     tipo_beneficiario: TipoBeneficiarioBaja
#     beneficiario: BeneficiarioBajaSchema
#     motivo: MotivoBaja

#     @field_validator("tipo_beneficiario", mode="before")
#     @classmethod
#     def validar_tipo_beneficiario(cls, valor: Any) -> TipoBeneficiarioBaja:
#         return validar_tipo_beneficiario_baja(valor)

#     @field_validator("motivo", mode="before")
#     @classmethod
#     def validar_motivo(cls, valor: Any) -> MotivoBaja:
#         return validar_motivo_baja(valor)


# class BajaResponsablePasoSchema(BaseModel):
#     responsable_adulto: ResponsableBajaSchema


# class ControladorBajas(QObject):
#     """
#     Puente entre QML y el generador de solicitud de baja.

#     Recibe datos desde QML, valida por pasos, prepara datos para
#     previsualización y genera la solicitud en formato DOCX.
#     """

#     # ============================================================
#     # VALIDACIONES POR PASO
#     # ============================================================

#     @Slot("QVariantMap", result="QVariantMap")
#     def validarBajaInstitucional(self, datos: dict[str, Any]) -> dict[str, Any]:
#         return validar_baja_institucional(datos)

#     @Slot("QVariantMap", result="QVariantMap")
#     def validarBajaBeneficiario(self, datos: dict[str, Any]) -> dict[str, Any]:
#         try:
#             datos_schema = {
#                 "tipo_beneficiario": self._normalizar_tipo_beneficiario_schema(
#                     datos.get("bajaTipoBeneficiario", "")
#                 ),
#                 "beneficiario": {
#                     "nombre": str(datos.get("bajaNombre", "")).strip(),
#                     "apellido": str(datos.get("bajaApellido", "")).strip(),
#                     "tipo_dni": str(datos.get("bajaTipoDni", "")).strip(),
#                     "dni": str(datos.get("bajaDni", "")).strip(),
#                     "fecha_ingreso": str(datos.get("bajaFechaIngreso", "")).strip(),
#                 },
#                 "motivo": str(datos.get("bajaMotivo", "")).strip(),
#             }

#             BajaBeneficiarioPasoSchema(**datos_schema)

#             return {
#                 "valido": True,
#                 "errores": [],
#                 "mensaje": "",
#             }

#         except ValidationError as error:
#             return self._resultado_pydantic_para_qml(
#                 error=error,
#                 mapa_campos={
#                     "tipo_beneficiario": "bajaTipoBeneficiario",
#                     "beneficiario.nombre": "bajaNombre",
#                     "beneficiario.apellido": "bajaApellido",
#                     "beneficiario.tipo_dni": "bajaTipoDni",
#                     "beneficiario.dni": "bajaDni",
#                     "beneficiario.fecha_ingreso": "bajaFechaIngreso",
#                     "motivo": "bajaMotivo",
#                 },
#             )

#     @Slot("QVariantMap", result="QVariantMap")
#     def validarBajaResponsable(self, datos: dict[str, Any]) -> dict[str, Any]:
#         try:
#             datos_schema = {
#                 "responsable_adulto": {
#                     "nombre": str(
#                         datos.get("bajaResponsableNombre", "")
#                     ).strip(),
#                     "apellido": str(
#                         datos.get("bajaResponsableApellido", "")
#                     ).strip(),
#                     "relacion": str(
#                         datos.get("bajaResponsableRelacion", "")
#                     ).strip(),
#                     "informado": str(
#                         datos.get("bajaResponsableInformado", "")
#                     ).strip(),
#                 },
#             }

#             BajaResponsablePasoSchema(**datos_schema)

#             return {
#                 "valido": True,
#                 "errores": [],
#                 "mensaje": "",
#             }

#         except ValidationError as error:
#             return self._resultado_pydantic_para_qml(
#                 error=error,
#                 mapa_campos={
#                     "responsable_adulto.nombre": "bajaResponsableNombre",
#                     "responsable_adulto.apellido": "bajaResponsableApellido",
#                     "responsable_adulto.relacion": "bajaResponsableRelacion",
#                     "responsable_adulto.informado": "bajaResponsableInformado",
#                 },
#             )

#     # ============================================================
#     # PREVISUALIZACIÓN
#     # ============================================================

#     @Slot("QVariantMap", result="QVariantMap")
#     def prepararDatosBaja(self, datos: dict[str, Any]) -> dict[str, Any]:
#         """
#         Prepara los datos finales de la baja sin generar archivos.
#         Se usa para la previsualización QML.
#         """
#         try:
#             return self._mapear_datos_baja(datos)

#         except Exception as error:
#             print(f"ERROR al preparar datos de baja: {error}")
#             return {
#                 "error": f"No se pudieron preparar los datos de la baja: {error}"
#             }

#     # ============================================================
#     # GENERACIÓN
#     # ============================================================

#     @Slot("QVariantMap", result=str)
#     def generarSolicitudBaja(self, datos: dict[str, Any]) -> str:
#         try:
#             datos_baja = self._mapear_datos_baja(datos)

#             resultado_validacion = self._validar_solicitud_baja_con_modelo_nuevo(
#                 datos_baja
#             )

#             if not resultado_validacion["valido"]:
#                 return (
#                     "ERROR|No se pudo generar la solicitud de baja:\n"
#                     f"{resultado_validacion['mensaje']}"
#                 )

#             ruta_docx = self._crear_ruta_salida(datos_baja)

#             generar_solicitud_baja(
#                 datos=datos_baja,
#                 ruta_docx=ruta_docx,
#             )

#             if not ruta_docx.exists():
#                 return f"ERROR|El archivo DOCX no se generó en la ruta esperada: {ruta_docx}"

#             copias_externas = self._copiar_archivos_a_carpeta_externa_si_corresponde(
#                 [ruta_docx]
#             )

#             self._abrir_archivo(ruta_docx)

#             mensaje = f"OK|Solicitud de baja generada correctamente:\nDOCX: {ruta_docx}"

#             if copias_externas:
#                 mensaje += "\nCopias externas generadas:"
#                 for ruta_copia in copias_externas:
#                     mensaje += f"\n- {ruta_copia}"

#             return mensaje

#         except Exception as error:
#             return f"ERROR|No se pudo generar la solicitud de baja: {error}"

#     # ============================================================
#     # VALIDACIÓN FINAL NUEVA
#     # ============================================================

#     def _validar_solicitud_baja_con_modelo_nuevo(
#         self,
#         datos_baja: dict[str, Any],
#     ) -> dict[str, Any]:
#         try:
#             datos_schema = self._armar_datos_schema_solicitud_baja(datos_baja)

#             schema = SolicitudBajaSchema(**datos_schema)
#             solicitud = mapear_solicitud_baja(schema)
#             errores_dominio = validar_reglas_solicitud_baja(solicitud)

#             if errores_dominio:
#                 return {
#                     "valido": False,
#                     "mensaje": errores_a_texto(errores_dominio),
#                 }

#             return {
#                 "valido": True,
#                 "mensaje": "Operación exitosa.",
#             }

#         except ValidationError as error:
#             return {
#                 "valido": False,
#                 "mensaje": self._mensaje_usuario_pydantic(error),
#             }

#         except Exception as error:
#             return {
#                 "valido": False,
#                 "mensaje": str(error),
#             }

#     def _armar_datos_schema_solicitud_baja(
#         self,
#         datos_baja: dict[str, Any],
#     ) -> dict[str, Any]:
#         contexto = self._cargar_contexto_institucional_para_schema()

#         profesionales_intervinientes = self._obtener_profesionales_intervinientes_para_schema(
#             datos_baja=datos_baja,
#             contexto=contexto,
#         )

#         return {
#             "fecha_emision": date.today(),
#             "profesionales_intervinientes": profesionales_intervinientes,
#             "tipo_beneficiario": self._normalizar_tipo_beneficiario_schema(
#                 datos_baja.get("bajaTipoBeneficiario", "")
#             ),
#             "motivo": str(datos_baja.get("bajaMotivo", "")).strip(),
#             "beneficiario": {
#                 "nombre": str(datos_baja.get("bajaNombre", "")).strip(),
#                 "apellido": str(datos_baja.get("bajaApellido", "")).strip(),
#                 "tipo_dni": str(datos_baja.get("bajaTipoDni", "")).strip(),
#                 "dni": str(datos_baja.get("bajaDni", "")).strip(),
#                 "fecha_ingreso": str(datos_baja.get("bajaFechaIngreso", "")).strip(),
#             },
#             "responsable_adulto": {
#                 "nombre": str(datos_baja.get("bajaResponsableNombre", "")).strip(),
#                 "apellido": str(datos_baja.get("bajaResponsableApellido", "")).strip(),
#                 "relacion": str(datos_baja.get("bajaResponsableRelacion", "")).strip(),
#                 "informado": str(datos_baja.get("bajaResponsableInformado", "")).strip(),
#             },
#             "contexto_institucional": contexto,
#         }

#     def _normalizar_tipo_beneficiario_schema(self, valor: Any) -> str:
#         texto = str(valor).strip()

#         if texto == "Destinatario":
#             return "destinatario"

#         if texto == "Tutor":
#             return "tutor"

#         return texto

#     def _obtener_profesionales_intervinientes_para_schema(
#         self,
#         datos_baja: dict[str, Any],
#         contexto: dict[str, Any],
#     ) -> list[dict[str, Any]]:
#         profesionales_recibidos = self._normalizar_lista_profesionales(
#             datos_baja.get("profesionalesIntervinientes", [])
#         )

#         profesionales_contexto = contexto.get("profesionales", []) or []

#         profesionales_resultado: list[dict[str, Any]] = []

#         for profesional_recibido in profesionales_recibidos:
#             profesional_encontrado = self._buscar_profesional_por_texto(
#                 profesional_recibido,
#                 profesionales_contexto,
#             )

#             if profesional_encontrado is not None:
#                 profesionales_resultado.append(profesional_encontrado)
#                 continue

#             profesional_parseado = self._parsear_profesional_texto(
#                 profesional_recibido
#             )

#             if profesional_parseado is not None:
#                 profesionales_resultado.append(profesional_parseado)

#         return profesionales_resultado

#     def _buscar_profesional_por_texto(
#         self,
#         texto_profesional: str,
#         profesionales_contexto: list[dict[str, Any]],
#     ) -> dict[str, Any] | None:
#         clave_buscada = self._normalizar_texto_clave(texto_profesional)

#         for profesional in profesionales_contexto:
#             texto_contexto = self._formatear_personal_institucional(profesional)
#             clave_contexto = self._normalizar_texto_clave(texto_contexto)

#             if clave_contexto == clave_buscada:
#                 return profesional

#         return None

#     def _parsear_profesional_texto(
#         self,
#         texto_profesional: str,
#     ) -> dict[str, Any] | None:
#         texto = str(texto_profesional).strip()

#         if not texto:
#             return None

#         partes = texto.split("-")
#         nombre_apellido = partes[0].strip()
#         siglas = partes[1].strip() if len(partes) > 1 else ""

#         partes_nombre = nombre_apellido.split()

#         if len(partes_nombre) < 2:
#             return None

#         apellido = partes_nombre[0]
#         nombre = " ".join(partes_nombre[1:])

#         nombre_rol = self._nombre_rol_por_siglas(siglas)

#         return {
#             "nombre": nombre,
#             "apellido": apellido,
#             "rol": {
#                 "nombre": nombre_rol,
#                 "siglas": siglas,
#             },
#         }

#     def _nombre_rol_por_siglas(self, siglas: str) -> str:
#         roles = {
#             "TS": "Trabajadora social",
#             "PSI": "Psicóloga",
#             "PSP": "Psicopedagoga",
#             "EFC": "Profesor de educación física",
#         }

#         return roles.get(siglas, siglas)

#     def _cargar_contexto_institucional_para_schema(self) -> dict[str, Any]:
#         base_dir = Path(__file__).resolve().parent.parent.parent
#         config_dir = base_dir / "config"
#         config_path_v2 = config_dir / "configuracion_sede_v2.json"
#         config_path_vieja = config_dir / "configuracion_sede.json"

#         if config_path_v2.exists():
#             try:
#                 with config_path_v2.open("r", encoding="utf-8") as archivo:
#                     configuracion = json.load(archivo)

#                 ubicacion = configuracion.get("ubicacion", {}) or {}
#                 coordinador = configuracion.get("coordinador", {}) or {}
#                 profesionales = configuracion.get("profesionales", []) or []

#                 return {
#                     "origen": str(configuracion.get("origen", "")).strip(),
#                     "nombre_sede": str(configuracion.get("nombre_sede", "")).strip(),
#                     "ubicacion": {
#                         "municipio": str(ubicacion.get("municipio", "")).strip(),
#                         "localidad": str(ubicacion.get("localidad", "")).strip(),
#                         "barrio": str(ubicacion.get("barrio", "")).strip(),
#                     },
#                     "coordinador": self._normalizar_personal_institucional_para_schema(
#                         coordinador
#                     ),
#                     "profesionales": [
#                         self._normalizar_personal_institucional_para_schema(
#                             profesional
#                         )
#                         for profesional in profesionales
#                         if isinstance(profesional, dict)
#                     ],
#                 }

#             except Exception as error:
#                 raise RuntimeError(
#                     f"No se pudo cargar configuracion_sede_v2.json: {error}"
#                 ) from error

#         if config_path_vieja.exists():
#             try:
#                 with config_path_vieja.open("r", encoding="utf-8") as archivo:
#                     configuracion = json.load(archivo)

#                 return {
#                     "origen": str(configuracion.get("origen", "")).strip(),
#                     "nombre_sede": str(configuracion.get("nombreSede", "")).strip(),
#                     "ubicacion": {
#                         "municipio": str(configuracion.get("municipio", "")).strip(),
#                         "localidad": str(configuracion.get("localidad", "")).strip(),
#                         "barrio": str(configuracion.get("barrio", "")).strip(),
#                     },
#                     "coordinador": {
#                         "nombre": "",
#                         "apellido": "",
#                         "rol": {
#                             "nombre": "",
#                             "siglas": "",
#                         },
#                     },
#                     "profesionales": [],
#                 }

#             except Exception as error:
#                 raise RuntimeError(
#                     f"No se pudo cargar configuracion_sede.json: {error}"
#                 ) from error

#         return {
#             "origen": "",
#             "nombre_sede": "",
#             "ubicacion": {
#                 "municipio": "",
#                 "localidad": "",
#                 "barrio": "",
#             },
#             "coordinador": {
#                 "nombre": "",
#                 "apellido": "",
#                 "rol": {
#                     "nombre": "",
#                     "siglas": "",
#                 },
#             },
#             "profesionales": [],
#         }

#     def _normalizar_personal_institucional_para_schema(
#         self,
#         persona: dict[str, Any],
#     ) -> dict[str, Any]:
#         if not isinstance(persona, dict):
#             return {
#                 "nombre": "",
#                 "apellido": "",
#                 "rol": {
#                     "nombre": "",
#                     "siglas": "",
#                 },
#             }

#         rol = persona.get("rol", {}) or {}

#         return {
#             "nombre": str(persona.get("nombre", "")).strip(),
#             "apellido": str(persona.get("apellido", "")).strip(),
#             "rol": {
#                 "nombre": str(rol.get("nombre", "")).strip(),
#                 "siglas": str(rol.get("siglas", "")).strip(),
#             },
#         }

#     # ============================================================
#     # MAPEO DE DATOS PARA DOCX
#     # ============================================================

#     def _mapear_datos_baja(self, datos: dict[str, Any]) -> dict[str, Any]:
#         configuracion_sede = self._cargar_configuracion_sede()

#         sede_configurada = str(configuracion_sede.get("nombreSede", "")).strip()
#         centro_envion_configurado = str(configuracion_sede.get("origen", "")).strip()
#         coordinadora_configurada = str(configuracion_sede.get("coordinadora", "")).strip()

#         profesionales_recibidos = datos.get("profesionalesIntervinientes", [])

#         datos_mapeados = {
#             # Institucional
#             "centroEnvion": str(
#                 datos.get("centroEnvion", centro_envion_configurado)
#             ).strip() or centro_envion_configurado,

#             "sede": str(
#                 datos.get("sede", sede_configurada)
#             ).strip() or sede_configurada,

#             "modalidad": str(datos.get("modalidad", "")).strip(),

#             "profesionalesIntervinientes": self._normalizar_lista_profesionales(
#                 profesionales_recibidos
#             ),

#             "profesionalesIntervinientesTexto": str(
#                 datos.get("profesionalesIntervinientesTexto", "")
#             ).strip(),

#             "coordinadora": str(
#                 datos.get("coordinadora", coordinadora_configurada)
#             ).strip() or coordinadora_configurada,

#             "fechaBaja": str(datos.get("fechaBaja", "")).strip(),

#             # Beneficiario
#             "bajaTipoBeneficiario": str(datos.get("bajaTipoBeneficiario", "")).strip(),
#             "bajaNombre": str(datos.get("bajaNombre", "")).strip(),
#             "bajaApellido": str(datos.get("bajaApellido", "")).strip(),
#             "bajaNombreCompleto": str(datos.get("bajaNombreCompleto", "")).strip(),
#             "bajaTipoDni": str(datos.get("bajaTipoDni", "")).strip(),
#             "bajaDni": str(datos.get("bajaDni", "")).strip(),
#             "bajaFechaIngreso": str(datos.get("bajaFechaIngreso", "")).strip(),
#             "bajaMotivo": str(datos.get("bajaMotivo", "")).strip(),

#             # Responsable Adulto
#             "bajaResponsableNombre": str(datos.get("bajaResponsableNombre", "")).strip(),
#             "bajaResponsableApellido": str(datos.get("bajaResponsableApellido", "")).strip(),
#             "bajaResponsableNombreCompleto": str(
#                 datos.get("bajaResponsableNombreCompleto", "")
#             ).strip(),
#             "bajaResponsableRelacion": str(
#                 datos.get("bajaResponsableRelacion", "")
#             ).strip(),
#             "bajaResponsableInformado": str(
#                 datos.get("bajaResponsableInformado", "")
#             ).strip(),

#             # Datos útiles para documento
#             "fechaEmision": self._obtener_fecha_actual(),
#         }

#         if not datos_mapeados["profesionalesIntervinientesTexto"]:
#             datos_mapeados["profesionalesIntervinientesTexto"] = " / ".join(
#                 datos_mapeados["profesionalesIntervinientes"]
#             )

#         if not datos_mapeados["bajaNombreCompleto"]:
#             datos_mapeados["bajaNombreCompleto"] = (
#                 f"{datos_mapeados['bajaNombre']} {datos_mapeados['bajaApellido']}"
#             ).strip()

#         if not datos_mapeados["bajaResponsableNombreCompleto"]:
#             datos_mapeados["bajaResponsableNombreCompleto"] = (
#                 f"{datos_mapeados['bajaResponsableNombre']} "
#                 f"{datos_mapeados['bajaResponsableApellido']}"
#             ).strip()

#         datos_mapeados.update(
#             self._crear_marcas_documento(datos_mapeados)
#         )

#         return datos_mapeados

#     def _crear_marcas_documento(self, datos: dict[str, Any]) -> dict[str, str]:
#         """
#         Crea marcas auxiliares para el documento:
#         - tipo beneficiario;
#         - responsable informado;
#         - motivo seleccionado.
#         """

#         tipo = datos.get("bajaTipoBeneficiario", "")
#         informado = datos.get("bajaResponsableInformado", "")
#         motivo = datos.get("bajaMotivo", "")

#         motivos = [
#             "Encontrarse privado de la libertad",
#             "Fallecimiento",
#             "Haber cumplimentado con todos los acuerdos para su egreso",
#             "Liquidaciones consecutivas impagas",
#             "Mudanza a otro Municipio",
#             "Negativa a cumplir con su Acuerdo de Compromiso",
#             "Negativa del Joven a participar",
#             "Negativa o dificultades al momento de la socialización",
#             "Pase de Destinatario a Tutor",
#             "Pase de Tutor a Destinatario",
#             "Trabajo Formal",
#             "Otros motivos",
#         ]

#         marcas = {
#             "marcaTipoDestinatario": "X" if tipo == "Destinatario" else "",
#             "marcaTipoTutor": "X" if tipo == "Tutor" else "",
#             "marcaResponsableInformadoSi": "X" if informado in {"Sí", "Si"} else "",
#             "marcaResponsableInformadoNo": "X" if informado == "No" else "",
#         }

#         for indice, motivo_actual in enumerate(motivos, start=1):
#             campo = f"marcaMotivo{indice:02d}"
#             marcas[campo] = "X" if motivo == motivo_actual else ""

#         return marcas

#     # ============================================================
#     # CONFIGURACIÓN
#     # ============================================================

#     def _obtener_fecha_actual(self) -> str:
#         return date.today().strftime("%d/%m/%Y")

#     def _cargar_configuracion_sede(self) -> dict[str, Any]:
#         """
#         Carga la configuración institucional nueva.

#         Devuelve una estructura compatible con el flujo actual de baja:
#         - nombreSede
#         - origen
#         - municipio
#         - localidad
#         - barrio
#         - coordinadora
#         - profesionalesIntervinientes
#         """
#         base_dir = Path(__file__).resolve().parent.parent.parent
#         config_dir = base_dir / "config"

#         config_path_v2 = config_dir / "configuracion_sede_v2.json"
#         config_path_vieja = config_dir / "configuracion_sede.json"

#         configuracion_vacia = {
#             "nombreSede": "",
#             "origen": "",
#             "municipio": "",
#             "localidad": "",
#             "barrio": "",
#             "coordinadora": "",
#             "profesionalesIntervinientes": [],
#             "fechaAutomatica": True,
#             "edadAutomatica": True,
#             "fechaActual": self._obtener_fecha_actual(),
#         }

#         if config_path_v2.exists():
#             try:
#                 with config_path_v2.open("r", encoding="utf-8") as archivo:
#                     configuracion = json.load(archivo)

#                 ubicacion = configuracion.get("ubicacion", {}) or {}
#                 coordinador = configuracion.get("coordinador", {}) or {}

#                 profesionales = self._normalizar_lista_profesionales(
#                     configuracion.get("profesionales", [])
#                 )

#                 return {
#                     "nombreSede": str(configuracion.get("nombre_sede", "")).strip(),
#                     "origen": str(configuracion.get("origen", "")).strip(),
#                     "municipio": str(ubicacion.get("municipio", "")).strip(),
#                     "localidad": str(ubicacion.get("localidad", "")).strip(),
#                     "barrio": str(ubicacion.get("barrio", "")).strip(),
#                     "coordinadora": self._formatear_personal_institucional(coordinador),
#                     "profesionalesIntervinientes": profesionales,
#                     "fechaAutomatica": True,
#                     "edadAutomatica": True,
#                     "fechaActual": self._obtener_fecha_actual(),
#                 }

#             except Exception as error:
#                 print(f"ERROR al cargar configuración de sede v2: {error}")
#                 return configuracion_vacia

#         if not config_path_vieja.exists():
#             return configuracion_vacia

#         try:
#             with config_path_vieja.open("r", encoding="utf-8") as archivo:
#                 configuracion = json.load(archivo)

#             return {
#                 "nombreSede": str(configuracion.get("nombreSede", "")),
#                 "origen": str(configuracion.get("origen", "")),
#                 "municipio": str(configuracion.get("municipio", "")),
#                 "localidad": str(configuracion.get("localidad", "")),
#                 "barrio": str(configuracion.get("barrio", "")),
#                 "coordinadora": str(configuracion.get("coordinadora", "")),
#                 "profesionalesIntervinientes": self._normalizar_lista_profesionales(
#                     configuracion.get("profesionalesIntervinientes", [])
#                 ),
#                 "fechaAutomatica": bool(configuracion.get("fechaAutomatica", True)),
#                 "edadAutomatica": bool(configuracion.get("edadAutomatica", True)),
#                 "fechaActual": str(
#                     configuracion.get("fechaActual", self._obtener_fecha_actual())
#                 ),
#             }

#         except Exception as error:
#             print(f"ERROR al cargar configuración de sede vieja: {error}")
#             return configuracion_vacia

#     def _cargar_configuracion_guardado(self) -> dict[str, Any]:
#         base_dir = Path(__file__).resolve().parent.parent.parent
#         config_dir = base_dir / "config"
#         config_path = config_dir / "configuracion_guardado.json"

#         configuracion_vacia = {
#             "carpeta_copia_externa_solicitudes": ""
#         }

#         config_dir.mkdir(parents=True, exist_ok=True)

#         if not config_path.exists():
#             with config_path.open("w", encoding="utf-8") as archivo:
#                 json.dump(configuracion_vacia, archivo, indent=4, ensure_ascii=False)

#             return configuracion_vacia

#         try:
#             with config_path.open("r", encoding="utf-8") as archivo:
#                 configuracion = json.load(archivo)

#             return {
#                 "carpeta_copia_externa_solicitudes": str(
#                     configuracion.get("carpeta_copia_externa_solicitudes", "")
#                 )
#             }

#         except Exception as error:
#             print(f"ERROR al cargar configuración de guardado: {error}")
#             return configuracion_vacia

#     @Slot(result="QVariantMap")
#     def obtenerConfiguracionBaja(self) -> dict[str, Any]:
#         """
#         Devuelve los datos institucionales base que usa la baja.

#         Para la solicitud de baja:
#         - centroEnvion se toma desde 'origen'
#         - sede se toma desde 'nombreSede' / 'nombre_sede'
#         - coordinadora se toma desde 'coordinador'
#         - profesionalesIntervinientes se toma desde 'profesionales'
#         """
#         configuracion = self._cargar_configuracion_sede()

#         return {
#             "centroEnvion": str(configuracion.get("origen", "")).strip(),
#             "sede": str(configuracion.get("nombreSede", "")).strip(),
#             "coordinadora": str(configuracion.get("coordinadora", "")).strip(),
#             "profesionalesIntervinientes": self._normalizar_lista_profesionales(
#                 configuracion.get("profesionalesIntervinientes", [])
#             ),
#         }

#     # ============================================================
#     # RUTAS Y ARCHIVOS
#     # ============================================================

#     def _crear_ruta_salida(self, datos_baja: dict[str, Any]) -> Path:
#         base_dir = Path(__file__).resolve().parent.parent.parent

#         output_dir = base_dir / "output" / "solicitudes_generadas"
#         output_dir.mkdir(parents=True, exist_ok=True)

#         nombre_completo = str(datos_baja.get("bajaNombreCompleto", "")).strip()

#         if not nombre_completo:
#             nombre = str(datos_baja.get("bajaNombre", "")).strip()
#             apellido = str(datos_baja.get("bajaApellido", "")).strip()
#             nombre_completo = f"{nombre} {apellido}".strip()

#         if not nombre_completo:
#             nombre_completo = "sin_nombre"

#         nombre_limpio = self._limpiar_nombre_archivo(nombre_completo)

#         nombre_base = f"solicitud_de_baja_{nombre_limpio}"
#         extension = ".docx"

#         ruta = output_dir / f"{nombre_base}{extension}"

#         contador = 1

#         while ruta.exists():
#             ruta = output_dir / f"{nombre_base}_{contador}{extension}"
#             contador += 1

#         return ruta.resolve()

#     def _copiar_archivos_a_carpeta_externa_si_corresponde(
#         self,
#         rutas_origen: list[Path],
#     ) -> list[Path]:
#         configuracion = self._cargar_configuracion_guardado()

#         carpeta_externa = str(
#             configuracion.get("carpeta_copia_externa_solicitudes", "")
#         ).strip()

#         if not carpeta_externa:
#             return []

#         ruta_carpeta_externa = Path(carpeta_externa).expanduser()
#         ruta_carpeta_externa.mkdir(parents=True, exist_ok=True)

#         rutas_copiadas: list[Path] = []

#         for ruta_origen in rutas_origen:
#             if not ruta_origen.exists():
#                 continue

#             ruta_destino = ruta_carpeta_externa / ruta_origen.name

#             contador = 1
#             nombre_base = ruta_origen.stem
#             extension = ruta_origen.suffix

#             while ruta_destino.exists():
#                 ruta_destino = ruta_carpeta_externa / f"{nombre_base}_{contador}{extension}"
#                 contador += 1

#             shutil.copy2(ruta_origen, ruta_destino)
#             rutas_copiadas.append(ruta_destino.resolve())

#         return rutas_copiadas

#     def _limpiar_nombre_archivo(self, texto: str) -> str:
#         texto = texto.strip().lower()

#         reemplazos = {
#             "á": "a",
#             "é": "e",
#             "í": "i",
#             "ó": "o",
#             "ú": "u",
#             "ñ": "n",
#         }

#         for original, reemplazo in reemplazos.items():
#             texto = texto.replace(original, reemplazo)

#         texto = re.sub(r"[^a-zA-Z0-9 _-]", "", texto)
#         texto = re.sub(r"\s+", "_", texto)
#         texto = re.sub(r"_+", "_", texto)

#         return texto.strip("_")

#     def _normalizar_lista_profesionales(self, valor: Any) -> list[str]:
#         """
#         Acepta:
#         - lista de strings vieja
#         - string separado por /
#         - lista de objetos nuevos con nombre/apellido/rol
#         """
#         if isinstance(valor, list):
#             resultado: list[str] = []

#             for item in valor:
#                 if isinstance(item, dict):
#                     texto = self._formatear_personal_institucional(item)
#                 else:
#                     texto = str(item).strip()

#                 if texto:
#                     resultado.append(texto)

#             return resultado

#         if isinstance(valor, tuple):
#             return [str(item).strip() for item in valor if str(item).strip()]

#         texto = str(valor).strip()

#         if not texto:
#             return []

#         return [parte.strip() for parte in texto.split("/") if parte.strip()]

#     def _formatear_personal_institucional(self, persona: Any) -> str:
#         if not isinstance(persona, dict):
#             return str(persona).strip()

#         nombre = str(persona.get("nombre", "")).strip()
#         apellido = str(persona.get("apellido", "")).strip()
#         rol = persona.get("rol", {}) or {}
#         siglas = str(rol.get("siglas", "")).strip()

#         nombre_completo = f"{apellido} {nombre}".strip()

#         if siglas:
#             return f"{nombre_completo} - {siglas}".strip()

#         return nombre_completo

#     def _normalizar_texto_clave(self, valor: Any) -> str:
#         texto = str(valor).strip().lower()
#         texto = texto.replace("á", "a")
#         texto = texto.replace("é", "e")
#         texto = texto.replace("í", "i")
#         texto = texto.replace("ó", "o")
#         texto = texto.replace("ú", "u")
#         texto = texto.replace("ñ", "n")

#         texto = re.sub(r"\s+", " ", texto)

#         return texto

#     # ============================================================
#     # FORMATO DE ERRORES PYDANTIC / QML
#     # ============================================================

#     def _resultado_pydantic_para_qml(
#         self,
#         error: ValidationError,
#         mapa_campos: dict[str, str],
#     ) -> dict[str, Any]:
#         errores = []
#         mensajes = []

#         for detalle in error.errors():
#             campo_schema = self._obtener_campo_error(detalle)
#             campo_qml = mapa_campos.get(campo_schema, campo_schema)

#             mensaje = str(detalle.get("msg", "")).strip()

#             errores.append({
#                 "campo": campo_qml,
#                 "mensaje": mensaje,
#             })

#             mensajes.append(f"{campo_qml}: {mensaje}")

#         return {
#             "valido": False,
#             "errores": errores,
#             "mensaje": "\n".join(mensajes),
#         }

#     def _mensaje_usuario_pydantic(self, error: ValidationError) -> str:
#         mensajes: list[str] = []

#         for detalle in error.errors():
#             campo = self._obtener_campo_error(detalle)
#             mensaje = str(detalle.get("msg", "")).strip()

#             if campo:
#                 mensajes.append(f"{campo}: {mensaje}")
#             else:
#                 mensajes.append(mensaje)

#         return "\n".join(mensajes)

#     def _obtener_campo_error(self, detalle_error: dict[str, Any]) -> str:
#         ubicacion = detalle_error.get("loc", [])

#         return ".".join(str(parte) for parte in ubicacion)

#     def _abrir_archivo(self, ruta: Path) -> None:
#         ruta = ruta.resolve()

#         if sys.platform.startswith("linux"):
#             libreoffice = shutil.which("libreoffice")

#             if libreoffice:
#                 subprocess.Popen(
#                     [libreoffice, "--writer", str(ruta)],
#                     stdout=subprocess.DEVNULL,
#                     stderr=subprocess.DEVNULL,
#                 )
#                 return

#             subprocess.Popen(
#                 ["xdg-open", str(ruta)],
#                 stdout=subprocess.DEVNULL,
#                 stderr=subprocess.DEVNULL,
#             )
#             return

#         if sys.platform == "darwin":
#             subprocess.Popen(
#                 ["open", str(ruta)],
#                 stdout=subprocess.DEVNULL,
#                 stderr=subprocess.DEVNULL,
#             )
#             return

#         if os.name == "nt":
#             os.startfile(str(ruta))

# app_jade / CORE / controladores / controlador_bajas.py

from pathlib import Path
from typing import Any
import json
import os
import re
import shutil
import subprocess
import sys
from datetime import date

from pydantic import BaseModel, ValidationError, field_validator
from PySide6.QtCore import QObject, Slot

from ..generador_baja import generar_solicitud_baja

from CORE.dominio.catalogos import (
    TipoBeneficiarioBaja,
    MotivoBaja,
)

from CORE.schemas.base_schema import (
    validar_texto_obligatorio,
    error_validacion,
)

from CORE.schemas.personas_schema import (
    BeneficiarioBajaSchema,
    ResponsableBajaSchema,
    validar_fecha_texto_dd_mm_aaaa,
)

from CORE.schemas.solicitud_baja_schema import (
    SolicitudBajaSchema,
    validar_tipo_beneficiario_baja,
    validar_motivo_baja,
)
from CORE.mapeadores.mapeador_dominio import mapear_solicitud_baja
from CORE.dominio.reglas import validar_reglas_solicitud_baja
from CORE.dominio.errores import errores_a_texto


# ============================================================
# SCHEMAS INTERNOS - VALIDACIÓN POR PASO BAJA
# ============================================================

class BajaInstitucionalPasoSchema(BaseModel):
    modalidad: str
    profesionales_intervinientes: list[str]
    fecha_baja: str

    @field_validator("modalidad")
    @classmethod
    def validar_modalidad(cls, valor: str) -> str:
        return validar_texto_obligatorio(
            valor=valor,
            campo="Modalidad",
        )

    @field_validator("profesionales_intervinientes")
    @classmethod
    def validar_profesionales_intervinientes(
        cls,
        valor: list[str],
    ) -> list[str]:
        profesionales = [
            str(profesional).strip()
            for profesional in valor
            if str(profesional).strip()
        ]

        if len(profesionales) == 0:
            error_validacion(
                mensaje_usuario=(
                    "Profesionales intervinientes: debe seleccionar al menos "
                    "un profesional."
                ),
                mensaje_tecnico=(
                    "BajaInstitucionalPasoSchema.profesionales_intervinientes "
                    "recibió una lista vacía. Se esperaba al menos un profesional."
                ),
            )

        return profesionales

    @field_validator("fecha_baja")
    @classmethod
    def validar_fecha_baja(cls, valor: str) -> str:
        return validar_fecha_texto_dd_mm_aaaa(
            valor=valor,
            campo="Fecha de baja",
            clase="BajaInstitucionalPasoSchema",
            atributo="fecha_baja",
        )


class BajaBeneficiarioPasoSchema(BaseModel):
    tipo_beneficiario: TipoBeneficiarioBaja
    beneficiario: BeneficiarioBajaSchema
    motivo: MotivoBaja

    @field_validator("tipo_beneficiario", mode="before")
    @classmethod
    def validar_tipo_beneficiario(cls, valor: Any) -> TipoBeneficiarioBaja:
        return validar_tipo_beneficiario_baja(valor)

    @field_validator("motivo", mode="before")
    @classmethod
    def validar_motivo(cls, valor: Any) -> MotivoBaja:
        return validar_motivo_baja(valor)


class BajaResponsablePasoSchema(BaseModel):
    responsable_adulto: ResponsableBajaSchema


class ControladorBajas(QObject):
    """
    Puente entre QML y el generador de solicitud de baja.

    Recibe datos desde QML, valida por pasos, prepara datos para
    previsualización y genera la solicitud en formato DOCX.
    """

    # ============================================================
    # VALIDACIONES POR PASO
    # ============================================================

    @Slot("QVariantMap", result="QVariantMap")
    def validarBajaInstitucional(self, datos: dict[str, Any]) -> dict[str, Any]:
        try:
            datos_schema = {
                "modalidad": str(datos.get("modalidad", "")).strip(),
                "profesionales_intervinientes": self._normalizar_lista_profesionales(
                    datos.get("profesionalesIntervinientes", [])
                ),
                "fecha_baja": str(datos.get("fechaBaja", "")).strip(),
            }

            BajaInstitucionalPasoSchema(**datos_schema)

            return {
                "valido": True,
                "errores": [],
                "mensaje": "",
            }

        except ValidationError as error:
            return self._resultado_pydantic_para_qml(
                error=error,
                mapa_campos={
                    "modalidad": "modalidad",
                    "profesionales_intervinientes": "profesionalesIntervinientes",
                    "fecha_baja": "fechaBaja",
                },
            )

    @Slot("QVariantMap", result="QVariantMap")
    def validarBajaBeneficiario(self, datos: dict[str, Any]) -> dict[str, Any]:
        try:
            datos_schema = {
                "tipo_beneficiario": self._normalizar_tipo_beneficiario_schema(
                    datos.get("bajaTipoBeneficiario", "")
                ),
                "beneficiario": {
                    "nombre": str(datos.get("bajaNombre", "")).strip(),
                    "apellido": str(datos.get("bajaApellido", "")).strip(),
                    "tipo_dni": str(datos.get("bajaTipoDni", "")).strip(),
                    "dni": str(datos.get("bajaDni", "")).strip(),
                    "fecha_ingreso": str(datos.get("bajaFechaIngreso", "")).strip(),
                },
                "motivo": str(datos.get("bajaMotivo", "")).strip(),
            }

            BajaBeneficiarioPasoSchema(**datos_schema)

            return {
                "valido": True,
                "errores": [],
                "mensaje": "",
            }

        except ValidationError as error:
            return self._resultado_pydantic_para_qml(
                error=error,
                mapa_campos={
                    "tipo_beneficiario": "bajaTipoBeneficiario",
                    "beneficiario.nombre": "bajaNombre",
                    "beneficiario.apellido": "bajaApellido",
                    "beneficiario.tipo_dni": "bajaTipoDni",
                    "beneficiario.dni": "bajaDni",
                    "beneficiario.fecha_ingreso": "bajaFechaIngreso",
                    "motivo": "bajaMotivo",
                },
            )

    @Slot("QVariantMap", result="QVariantMap")
    def validarBajaResponsable(self, datos: dict[str, Any]) -> dict[str, Any]:
        try:
            datos_schema = {
                "responsable_adulto": {
                    "nombre": str(
                        datos.get("bajaResponsableNombre", "")
                    ).strip(),
                    "apellido": str(
                        datos.get("bajaResponsableApellido", "")
                    ).strip(),
                    "relacion": str(
                        datos.get("bajaResponsableRelacion", "")
                    ).strip(),
                    "informado": str(
                        datos.get("bajaResponsableInformado", "")
                    ).strip(),
                },
            }

            BajaResponsablePasoSchema(**datos_schema)

            return {
                "valido": True,
                "errores": [],
                "mensaje": "",
            }

        except ValidationError as error:
            return self._resultado_pydantic_para_qml(
                error=error,
                mapa_campos={
                    "responsable_adulto.nombre": "bajaResponsableNombre",
                    "responsable_adulto.apellido": "bajaResponsableApellido",
                    "responsable_adulto.relacion": "bajaResponsableRelacion",
                    "responsable_adulto.informado": "bajaResponsableInformado",
                },
            )

    # ============================================================
    # PREVISUALIZACIÓN
    # ============================================================

    @Slot("QVariantMap", result="QVariantMap")
    def prepararDatosBaja(self, datos: dict[str, Any]) -> dict[str, Any]:
        """
        Prepara los datos finales de la baja sin generar archivos.
        Se usa para la previsualización QML.
        """
        try:
            return self._mapear_datos_baja(datos)

        except Exception as error:
            print(f"ERROR al preparar datos de baja: {error}")
            return {
                "error": f"No se pudieron preparar los datos de la baja: {error}"
            }

    # ============================================================
    # GENERACIÓN
    # ============================================================

    @Slot("QVariantMap", result=str)
    def generarSolicitudBaja(self, datos: dict[str, Any]) -> str:
        try:
            datos_baja = self._mapear_datos_baja(datos)

            resultado_validacion = self._validar_solicitud_baja_con_modelo_nuevo(
                datos_baja
            )

            if not resultado_validacion["valido"]:
                return (
                    "ERROR|No se pudo generar la solicitud de baja:\n"
                    f"{resultado_validacion['mensaje']}"
                )

            ruta_docx = self._crear_ruta_salida(datos_baja)

            generar_solicitud_baja(
                datos=datos_baja,
                ruta_docx=ruta_docx,
            )

            if not ruta_docx.exists():
                return f"ERROR|El archivo DOCX no se generó en la ruta esperada: {ruta_docx}"

            copias_externas = self._copiar_archivos_a_carpeta_externa_si_corresponde(
                [ruta_docx]
            )

            self._abrir_archivo(ruta_docx)

            mensaje = f"OK|Solicitud de baja generada correctamente:\nDOCX: {ruta_docx}"

            if copias_externas:
                mensaje += "\nCopias externas generadas:"
                for ruta_copia in copias_externas:
                    mensaje += f"\n- {ruta_copia}"

            return mensaje

        except Exception as error:
            return f"ERROR|No se pudo generar la solicitud de baja: {error}"

    # ============================================================
    # VALIDACIÓN FINAL NUEVA
    # ============================================================

    def _validar_solicitud_baja_con_modelo_nuevo(
        self,
        datos_baja: dict[str, Any],
    ) -> dict[str, Any]:
        try:
            datos_schema = self._armar_datos_schema_solicitud_baja(datos_baja)

            schema = SolicitudBajaSchema(**datos_schema)
            solicitud = mapear_solicitud_baja(schema)
            errores_dominio = validar_reglas_solicitud_baja(solicitud)

            if errores_dominio:
                return {
                    "valido": False,
                    "mensaje": errores_a_texto(errores_dominio),
                }

            return {
                "valido": True,
                "mensaje": "Operación exitosa.",
            }

        except ValidationError as error:
            return {
                "valido": False,
                "mensaje": self._mensaje_usuario_pydantic(error),
            }

        except Exception as error:
            return {
                "valido": False,
                "mensaje": str(error),
            }

    def _armar_datos_schema_solicitud_baja(
        self,
        datos_baja: dict[str, Any],
    ) -> dict[str, Any]:
        contexto = self._cargar_contexto_institucional_para_schema()

        profesionales_intervinientes = self._obtener_profesionales_intervinientes_para_schema(
            datos_baja=datos_baja,
            contexto=contexto,
        )

        return {
            "fecha_emision": date.today(),
            "profesionales_intervinientes": profesionales_intervinientes,
            "tipo_beneficiario": self._normalizar_tipo_beneficiario_schema(
                datos_baja.get("bajaTipoBeneficiario", "")
            ),
            "motivo": str(datos_baja.get("bajaMotivo", "")).strip(),
            "beneficiario": {
                "nombre": str(datos_baja.get("bajaNombre", "")).strip(),
                "apellido": str(datos_baja.get("bajaApellido", "")).strip(),
                "tipo_dni": str(datos_baja.get("bajaTipoDni", "")).strip(),
                "dni": str(datos_baja.get("bajaDni", "")).strip(),
                "fecha_ingreso": str(datos_baja.get("bajaFechaIngreso", "")).strip(),
            },
            "responsable_adulto": {
                "nombre": str(datos_baja.get("bajaResponsableNombre", "")).strip(),
                "apellido": str(datos_baja.get("bajaResponsableApellido", "")).strip(),
                "relacion": str(datos_baja.get("bajaResponsableRelacion", "")).strip(),
                "informado": str(datos_baja.get("bajaResponsableInformado", "")).strip(),
            },
            "contexto_institucional": contexto,
        }

    def _normalizar_tipo_beneficiario_schema(self, valor: Any) -> str:
        texto = str(valor).strip()

        if texto == "Destinatario":
            return "destinatario"

        if texto == "Tutor":
            return "tutor"

        return texto

    def _obtener_profesionales_intervinientes_para_schema(
        self,
        datos_baja: dict[str, Any],
        contexto: dict[str, Any],
    ) -> list[dict[str, Any]]:
        profesionales_recibidos = self._normalizar_lista_profesionales(
            datos_baja.get("profesionalesIntervinientes", [])
        )

        profesionales_contexto = contexto.get("profesionales", []) or []

        profesionales_resultado: list[dict[str, Any]] = []

        for profesional_recibido in profesionales_recibidos:
            profesional_encontrado = self._buscar_profesional_por_texto(
                profesional_recibido,
                profesionales_contexto,
            )

            if profesional_encontrado is not None:
                profesionales_resultado.append(profesional_encontrado)
                continue

            profesional_parseado = self._parsear_profesional_texto(
                profesional_recibido
            )

            if profesional_parseado is not None:
                profesionales_resultado.append(profesional_parseado)

        return profesionales_resultado

    def _buscar_profesional_por_texto(
        self,
        texto_profesional: str,
        profesionales_contexto: list[dict[str, Any]],
    ) -> dict[str, Any] | None:
        clave_buscada = self._normalizar_texto_clave(texto_profesional)

        for profesional in profesionales_contexto:
            texto_contexto = self._formatear_personal_institucional(profesional)
            clave_contexto = self._normalizar_texto_clave(texto_contexto)

            if clave_contexto == clave_buscada:
                return profesional

        return None

    def _parsear_profesional_texto(
        self,
        texto_profesional: str,
    ) -> dict[str, Any] | None:
        texto = str(texto_profesional).strip()

        if not texto:
            return None

        partes = texto.split("-")
        nombre_apellido = partes[0].strip()
        siglas = partes[1].strip() if len(partes) > 1 else ""

        partes_nombre = nombre_apellido.split()

        if len(partes_nombre) < 2:
            return None

        apellido = partes_nombre[0]
        nombre = " ".join(partes_nombre[1:])

        nombre_rol = self._nombre_rol_por_siglas(siglas)

        return {
            "nombre": nombre,
            "apellido": apellido,
            "rol": {
                "nombre": nombre_rol,
                "siglas": siglas,
            },
        }

    def _nombre_rol_por_siglas(self, siglas: str) -> str:
        roles = {
            "TS": "Trabajadora social",
            "PSI": "Psicóloga",
            "PSP": "Psicopedagoga",
            "EFC": "Profesor de educación física",
        }

        return roles.get(siglas, siglas)

    def _cargar_contexto_institucional_para_schema(self) -> dict[str, Any]:
        base_dir = Path(__file__).resolve().parent.parent.parent
        config_dir = base_dir / "config"
        config_path_v2 = config_dir / "configuracion_sede_v2.json"
        config_path_vieja = config_dir / "configuracion_sede.json"

        if config_path_v2.exists():
            try:
                with config_path_v2.open("r", encoding="utf-8") as archivo:
                    configuracion = json.load(archivo)

                ubicacion = configuracion.get("ubicacion", {}) or {}
                coordinador = configuracion.get("coordinador", {}) or {}
                profesionales = configuracion.get("profesionales", []) or []

                return {
                    "origen": str(configuracion.get("origen", "")).strip(),
                    "nombre_sede": str(configuracion.get("nombre_sede", "")).strip(),
                    "ubicacion": {
                        "municipio": str(ubicacion.get("municipio", "")).strip(),
                        "localidad": str(ubicacion.get("localidad", "")).strip(),
                        "barrio": str(ubicacion.get("barrio", "")).strip(),
                    },
                    "coordinador": self._normalizar_personal_institucional_para_schema(
                        coordinador
                    ),
                    "profesionales": [
                        self._normalizar_personal_institucional_para_schema(
                            profesional
                        )
                        for profesional in profesionales
                        if isinstance(profesional, dict)
                    ],
                }

            except Exception as error:
                raise RuntimeError(
                    f"No se pudo cargar configuracion_sede_v2.json: {error}"
                ) from error

        if config_path_vieja.exists():
            try:
                with config_path_vieja.open("r", encoding="utf-8") as archivo:
                    configuracion = json.load(archivo)

                return {
                    "origen": str(configuracion.get("origen", "")).strip(),
                    "nombre_sede": str(configuracion.get("nombreSede", "")).strip(),
                    "ubicacion": {
                        "municipio": str(configuracion.get("municipio", "")).strip(),
                        "localidad": str(configuracion.get("localidad", "")).strip(),
                        "barrio": str(configuracion.get("barrio", "")).strip(),
                    },
                    "coordinador": {
                        "nombre": "",
                        "apellido": "",
                        "rol": {
                            "nombre": "",
                            "siglas": "",
                        },
                    },
                    "profesionales": [],
                }

            except Exception as error:
                raise RuntimeError(
                    f"No se pudo cargar configuracion_sede.json: {error}"
                ) from error

        return {
            "origen": "",
            "nombre_sede": "",
            "ubicacion": {
                "municipio": "",
                "localidad": "",
                "barrio": "",
            },
            "coordinador": {
                "nombre": "",
                "apellido": "",
                "rol": {
                    "nombre": "",
                    "siglas": "",
                },
            },
            "profesionales": [],
        }

    def _normalizar_personal_institucional_para_schema(
        self,
        persona: dict[str, Any],
    ) -> dict[str, Any]:
        if not isinstance(persona, dict):
            return {
                "nombre": "",
                "apellido": "",
                "rol": {
                    "nombre": "",
                    "siglas": "",
                },
            }

        rol = persona.get("rol", {}) or {}

        return {
            "nombre": str(persona.get("nombre", "")).strip(),
            "apellido": str(persona.get("apellido", "")).strip(),
            "rol": {
                "nombre": str(rol.get("nombre", "")).strip(),
                "siglas": str(rol.get("siglas", "")).strip(),
            },
        }

    # ============================================================
    # MAPEO DE DATOS PARA DOCX
    # ============================================================

    def _mapear_datos_baja(self, datos: dict[str, Any]) -> dict[str, Any]:
        configuracion_sede = self._cargar_configuracion_sede()

        sede_configurada = str(configuracion_sede.get("nombreSede", "")).strip()
        centro_envion_configurado = str(configuracion_sede.get("origen", "")).strip()
        coordinadora_configurada = str(configuracion_sede.get("coordinadora", "")).strip()

        profesionales_recibidos = datos.get("profesionalesIntervinientes", [])

        datos_mapeados = {
            # Institucional
            "centroEnvion": str(
                datos.get("centroEnvion", centro_envion_configurado)
            ).strip() or centro_envion_configurado,

            "sede": str(
                datos.get("sede", sede_configurada)
            ).strip() or sede_configurada,

            "modalidad": str(datos.get("modalidad", "")).strip(),

            "profesionalesIntervinientes": self._normalizar_lista_profesionales(
                profesionales_recibidos
            ),

            "profesionalesIntervinientesTexto": str(
                datos.get("profesionalesIntervinientesTexto", "")
            ).strip(),

            "coordinadora": str(
                datos.get("coordinadora", coordinadora_configurada)
            ).strip() or coordinadora_configurada,

            "fechaBaja": str(datos.get("fechaBaja", "")).strip(),

            # Beneficiario
            "bajaTipoBeneficiario": str(datos.get("bajaTipoBeneficiario", "")).strip(),
            "bajaNombre": str(datos.get("bajaNombre", "")).strip(),
            "bajaApellido": str(datos.get("bajaApellido", "")).strip(),
            "bajaNombreCompleto": str(datos.get("bajaNombreCompleto", "")).strip(),
            "bajaTipoDni": str(datos.get("bajaTipoDni", "")).strip(),
            "bajaDni": str(datos.get("bajaDni", "")).strip(),
            "bajaFechaIngreso": str(datos.get("bajaFechaIngreso", "")).strip(),
            "bajaMotivo": str(datos.get("bajaMotivo", "")).strip(),

            # Responsable Adulto
            "bajaResponsableNombre": str(datos.get("bajaResponsableNombre", "")).strip(),
            "bajaResponsableApellido": str(datos.get("bajaResponsableApellido", "")).strip(),
            "bajaResponsableNombreCompleto": str(
                datos.get("bajaResponsableNombreCompleto", "")
            ).strip(),
            "bajaResponsableRelacion": str(
                datos.get("bajaResponsableRelacion", "")
            ).strip(),
            "bajaResponsableInformado": str(
                datos.get("bajaResponsableInformado", "")
            ).strip(),

            # Datos útiles para documento
            "fechaEmision": self._obtener_fecha_actual(),
        }

        if not datos_mapeados["profesionalesIntervinientesTexto"]:
            datos_mapeados["profesionalesIntervinientesTexto"] = " / ".join(
                datos_mapeados["profesionalesIntervinientes"]
            )

        if not datos_mapeados["bajaNombreCompleto"]:
            datos_mapeados["bajaNombreCompleto"] = (
                f"{datos_mapeados['bajaNombre']} {datos_mapeados['bajaApellido']}"
            ).strip()

        if not datos_mapeados["bajaResponsableNombreCompleto"]:
            datos_mapeados["bajaResponsableNombreCompleto"] = (
                f"{datos_mapeados['bajaResponsableNombre']} "
                f"{datos_mapeados['bajaResponsableApellido']}"
            ).strip()

        datos_mapeados.update(
            self._crear_marcas_documento(datos_mapeados)
        )

        return datos_mapeados

    def _crear_marcas_documento(self, datos: dict[str, Any]) -> dict[str, str]:
        """
        Crea marcas auxiliares para el documento:
        - tipo beneficiario;
        - responsable informado;
        - motivo seleccionado.
        """

        tipo = datos.get("bajaTipoBeneficiario", "")
        informado = datos.get("bajaResponsableInformado", "")
        motivo = datos.get("bajaMotivo", "")

        motivos = [
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
        ]

        marcas = {
            "marcaTipoDestinatario": "X" if tipo == "Destinatario" else "",
            "marcaTipoTutor": "X" if tipo == "Tutor" else "",
            "marcaResponsableInformadoSi": "X" if informado in {"Sí", "Si"} else "",
            "marcaResponsableInformadoNo": "X" if informado == "No" else "",
        }

        for indice, motivo_actual in enumerate(motivos, start=1):
            campo = f"marcaMotivo{indice:02d}"
            marcas[campo] = "X" if motivo == motivo_actual else ""

        return marcas

    # ============================================================
    # CONFIGURACIÓN
    # ============================================================

    def _obtener_fecha_actual(self) -> str:
        return date.today().strftime("%d/%m/%Y")

    def _cargar_configuracion_sede(self) -> dict[str, Any]:
        """
        Carga la configuración institucional nueva.

        Devuelve una estructura compatible con el flujo actual de baja:
        - nombreSede
        - origen
        - municipio
        - localidad
        - barrio
        - coordinadora
        - profesionalesIntervinientes
        """
        base_dir = Path(__file__).resolve().parent.parent.parent
        config_dir = base_dir / "config"

        config_path_v2 = config_dir / "configuracion_sede_v2.json"
        config_path_vieja = config_dir / "configuracion_sede.json"

        configuracion_vacia = {
            "nombreSede": "",
            "origen": "",
            "municipio": "",
            "localidad": "",
            "barrio": "",
            "coordinadora": "",
            "profesionalesIntervinientes": [],
            "fechaAutomatica": True,
            "edadAutomatica": True,
            "fechaActual": self._obtener_fecha_actual(),
        }

        if config_path_v2.exists():
            try:
                with config_path_v2.open("r", encoding="utf-8") as archivo:
                    configuracion = json.load(archivo)

                ubicacion = configuracion.get("ubicacion", {}) or {}
                coordinador = configuracion.get("coordinador", {}) or {}

                profesionales = self._normalizar_lista_profesionales(
                    configuracion.get("profesionales", [])
                )

                return {
                    "nombreSede": str(configuracion.get("nombre_sede", "")).strip(),
                    "origen": str(configuracion.get("origen", "")).strip(),
                    "municipio": str(ubicacion.get("municipio", "")).strip(),
                    "localidad": str(ubicacion.get("localidad", "")).strip(),
                    "barrio": str(ubicacion.get("barrio", "")).strip(),
                    "coordinadora": self._formatear_personal_institucional(coordinador),
                    "profesionalesIntervinientes": profesionales,
                    "fechaAutomatica": True,
                    "edadAutomatica": True,
                    "fechaActual": self._obtener_fecha_actual(),
                }

            except Exception as error:
                print(f"ERROR al cargar configuración de sede v2: {error}")
                return configuracion_vacia

        if not config_path_vieja.exists():
            return configuracion_vacia

        try:
            with config_path_vieja.open("r", encoding="utf-8") as archivo:
                configuracion = json.load(archivo)

            return {
                "nombreSede": str(configuracion.get("nombreSede", "")),
                "origen": str(configuracion.get("origen", "")),
                "municipio": str(configuracion.get("municipio", "")),
                "localidad": str(configuracion.get("localidad", "")),
                "barrio": str(configuracion.get("barrio", "")),
                "coordinadora": str(configuracion.get("coordinadora", "")),
                "profesionalesIntervinientes": self._normalizar_lista_profesionales(
                    configuracion.get("profesionalesIntervinientes", [])
                ),
                "fechaAutomatica": bool(configuracion.get("fechaAutomatica", True)),
                "edadAutomatica": bool(configuracion.get("edadAutomatica", True)),
                "fechaActual": str(
                    configuracion.get("fechaActual", self._obtener_fecha_actual())
                ),
            }

        except Exception as error:
            print(f"ERROR al cargar configuración de sede vieja: {error}")
            return configuracion_vacia

    def _cargar_configuracion_guardado(self) -> dict[str, Any]:
        base_dir = Path(__file__).resolve().parent.parent.parent
        config_dir = base_dir / "config"
        config_path = config_dir / "configuracion_guardado.json"

        configuracion_vacia = {
            "carpeta_copia_externa_solicitudes": ""
        }

        config_dir.mkdir(parents=True, exist_ok=True)

        if not config_path.exists():
            with config_path.open("w", encoding="utf-8") as archivo:
                json.dump(configuracion_vacia, archivo, indent=4, ensure_ascii=False)

            return configuracion_vacia

        try:
            with config_path.open("r", encoding="utf-8") as archivo:
                configuracion = json.load(archivo)

            return {
                "carpeta_copia_externa_solicitudes": str(
                    configuracion.get("carpeta_copia_externa_solicitudes", "")
                )
            }

        except Exception as error:
            print(f"ERROR al cargar configuración de guardado: {error}")
            return configuracion_vacia

    @Slot(result="QVariantMap")
    def obtenerConfiguracionBaja(self) -> dict[str, Any]:
        """
        Devuelve los datos institucionales base que usa la baja.

        Para la solicitud de baja:
        - centroEnvion se toma desde 'origen'
        - sede se toma desde 'nombreSede' / 'nombre_sede'
        - coordinadora se toma desde 'coordinador'
        - profesionalesIntervinientes se toma desde 'profesionales'
        """
        configuracion = self._cargar_configuracion_sede()

        return {
            "centroEnvion": str(configuracion.get("origen", "")).strip(),
            "sede": str(configuracion.get("nombreSede", "")).strip(),
            "coordinadora": str(configuracion.get("coordinadora", "")).strip(),
            "profesionalesIntervinientes": self._normalizar_lista_profesionales(
                configuracion.get("profesionalesIntervinientes", [])
            ),
        }

    # ============================================================
    # RUTAS Y ARCHIVOS
    # ============================================================

    def _crear_ruta_salida(self, datos_baja: dict[str, Any]) -> Path:
        base_dir = Path(__file__).resolve().parent.parent.parent

        output_dir = base_dir / "output" / "solicitudes_generadas"
        output_dir.mkdir(parents=True, exist_ok=True)

        nombre_completo = str(datos_baja.get("bajaNombreCompleto", "")).strip()

        if not nombre_completo:
            nombre = str(datos_baja.get("bajaNombre", "")).strip()
            apellido = str(datos_baja.get("bajaApellido", "")).strip()
            nombre_completo = f"{nombre} {apellido}".strip()

        if not nombre_completo:
            nombre_completo = "sin_nombre"

        nombre_limpio = self._limpiar_nombre_archivo(nombre_completo)

        nombre_base = f"solicitud_de_baja_{nombre_limpio}"
        extension = ".docx"

        ruta = output_dir / f"{nombre_base}{extension}"

        contador = 1

        while ruta.exists():
            ruta = output_dir / f"{nombre_base}_{contador}{extension}"
            contador += 1

        return ruta.resolve()

    def _copiar_archivos_a_carpeta_externa_si_corresponde(
        self,
        rutas_origen: list[Path],
    ) -> list[Path]:
        configuracion = self._cargar_configuracion_guardado()

        carpeta_externa = str(
            configuracion.get("carpeta_copia_externa_solicitudes", "")
        ).strip()

        if not carpeta_externa:
            return []

        ruta_carpeta_externa = Path(carpeta_externa).expanduser()
        ruta_carpeta_externa.mkdir(parents=True, exist_ok=True)

        rutas_copiadas: list[Path] = []

        for ruta_origen in rutas_origen:
            if not ruta_origen.exists():
                continue

            ruta_destino = ruta_carpeta_externa / ruta_origen.name

            contador = 1
            nombre_base = ruta_origen.stem
            extension = ruta_origen.suffix

            while ruta_destino.exists():
                ruta_destino = ruta_carpeta_externa / f"{nombre_base}_{contador}{extension}"
                contador += 1

            shutil.copy2(ruta_origen, ruta_destino)
            rutas_copiadas.append(ruta_destino.resolve())

        return rutas_copiadas

    def _limpiar_nombre_archivo(self, texto: str) -> str:
        texto = texto.strip().lower()

        reemplazos = {
            "á": "a",
            "é": "e",
            "í": "i",
            "ó": "o",
            "ú": "u",
            "ñ": "n",
        }

        for original, reemplazo in reemplazos.items():
            texto = texto.replace(original, reemplazo)

        texto = re.sub(r"[^a-zA-Z0-9 _-]", "", texto)
        texto = re.sub(r"\s+", "_", texto)
        texto = re.sub(r"_+", "_", texto)

        return texto.strip("_")

    def _normalizar_lista_profesionales(self, valor: Any) -> list[str]:
        """
        Acepta:
        - lista de strings vieja
        - string separado por /
        - lista de objetos nuevos con nombre/apellido/rol
        """
        if isinstance(valor, list):
            resultado: list[str] = []

            for item in valor:
                if isinstance(item, dict):
                    texto = self._formatear_personal_institucional(item)
                else:
                    texto = str(item).strip()

                if texto:
                    resultado.append(texto)

            return resultado

        if isinstance(valor, tuple):
            return [str(item).strip() for item in valor if str(item).strip()]

        texto = str(valor).strip()

        if not texto:
            return []

        return [parte.strip() for parte in texto.split("/") if parte.strip()]

    def _formatear_personal_institucional(self, persona: Any) -> str:
        if not isinstance(persona, dict):
            return str(persona).strip()

        nombre = str(persona.get("nombre", "")).strip()
        apellido = str(persona.get("apellido", "")).strip()
        rol = persona.get("rol", {}) or {}
        siglas = str(rol.get("siglas", "")).strip()

        nombre_completo = f"{apellido} {nombre}".strip()

        if siglas:
            return f"{nombre_completo} - {siglas}".strip()

        return nombre_completo

    def _normalizar_texto_clave(self, valor: Any) -> str:
        texto = str(valor).strip().lower()
        texto = texto.replace("á", "a")
        texto = texto.replace("é", "e")
        texto = texto.replace("í", "i")
        texto = texto.replace("ó", "o")
        texto = texto.replace("ú", "u")
        texto = texto.replace("ñ", "n")

        texto = re.sub(r"\s+", " ", texto)

        return texto

    # ============================================================
    # FORMATO DE ERRORES PYDANTIC / QML
    # ============================================================

    def _resultado_pydantic_para_qml(
        self,
        error: ValidationError,
        mapa_campos: dict[str, str],
    ) -> dict[str, Any]:
        errores = []
        mensajes = []

        for detalle in error.errors():
            campo_schema = self._obtener_campo_error(detalle)
            campo_qml = mapa_campos.get(campo_schema, campo_schema)

            mensaje = str(detalle.get("msg", "")).strip()

            errores.append({
                "campo": campo_qml,
                "mensaje": mensaje,
            })

            mensajes.append(f"{campo_qml}: {mensaje}")

        return {
            "valido": False,
            "errores": errores,
            "mensaje": "\n".join(mensajes),
        }

    def _mensaje_usuario_pydantic(self, error: ValidationError) -> str:
        mensajes: list[str] = []

        for detalle in error.errors():
            campo = self._obtener_campo_error(detalle)
            mensaje = str(detalle.get("msg", "")).strip()

            if campo:
                mensajes.append(f"{campo}: {mensaje}")
            else:
                mensajes.append(mensaje)

        return "\n".join(mensajes)

    def _obtener_campo_error(self, detalle_error: dict[str, Any]) -> str:
        ubicacion = detalle_error.get("loc", [])

        return ".".join(str(parte) for parte in ubicacion)

    def _abrir_archivo(self, ruta: Path) -> None:
        ruta = ruta.resolve()

        if sys.platform.startswith("linux"):
            libreoffice = shutil.which("libreoffice")

            if libreoffice:
                subprocess.Popen(
                    [libreoffice, "--writer", str(ruta)],
                    stdout=subprocess.DEVNULL,
                    stderr=subprocess.DEVNULL,
                )
                return

            subprocess.Popen(
                ["xdg-open", str(ruta)],
                stdout=subprocess.DEVNULL,
                stderr=subprocess.DEVNULL,
            )
            return

        if sys.platform == "darwin":
            subprocess.Popen(
                ["open", str(ruta)],
                stdout=subprocess.DEVNULL,
                stderr=subprocess.DEVNULL,
            )
            return

        if os.name == "nt":
            os.startfile(str(ruta))