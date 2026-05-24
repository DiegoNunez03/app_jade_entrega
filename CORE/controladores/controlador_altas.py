# app_jade / CORE / controladores / controlador_altas.py

from pathlib import Path
from typing import Any
import json
import os
import re
import shutil
import subprocess
import sys
from datetime import date, datetime

from pydantic import BaseModel, ValidationError
from PySide6.QtCore import QObject, Slot

from ..generador_excel import generar_solicitud_alta
from ..validaciones import (
    validar_destinatario_o_tutor,
    errores_a_texto,
)

from CORE.schemas.personas_schema import (
    BeneficiarioAltaSchema,
    ResponsableAdultoSchema,
)
from CORE.schemas.solicitud_alta_schema import (
    SolicitudAltaSchema,
    validar_tipo_solicitud_alta,
)
from CORE.mapeadores.mapeador_dominio import mapear_solicitud_alta
from CORE.dominio.reglas import validar_reglas_solicitud_alta
from CORE.dominio.errores import errores_a_texto as errores_dominio_a_texto


# ============================================================
# SCHEMAS INTERNOS - VALIDACIÓN POR PASO ALTA
# ============================================================

class AltaDestinatarioPasoSchema(BaseModel):
    beneficiario: BeneficiarioAltaSchema


class AltaResponsablePasoSchema(BaseModel):
    responsable_adulto: ResponsableAdultoSchema


class ControladorAltas(QObject):
    """
    Puente entre QML y el generador de Excel.
    Recibe datos desde QML, los adapta al formato del generador
    y produce la solicitud de alta en Excel.
    """

    # ============================================================
    # VALIDACIONES POR PASO
    # ============================================================

    @Slot("QVariantMap", result="QVariantMap")
    def validarDestinatario(self, datos: dict[str, Any]) -> dict[str, Any]:
        """
        Valida solo los datos del paso Destinatario/Tutor.
        Se usa al presionar Siguiente en Alta.
        """
        errores_manuales: list[dict[str, str]] = []

        fecha_nacimiento = self._convertir_fecha_nacimiento_alta(
            valor=datos.get("fechaNacimiento", ""),
            campo_qml="fechaNacimiento",
            etiqueta="Fecha de nacimiento",
            errores=errores_manuales,
        )

        escolarizado = self._normalizar_escolarizado_alta(
            valor=datos.get("escolarizado", ""),
            errores=errores_manuales,
        )

        try:
            datos_schema = {
                "beneficiario": {
                    "nombre": str(datos.get("nombre", "")).strip(),
                    "apellido": str(datos.get("apellido", "")).strip(),
                    "dni": str(datos.get("dni", "")).strip(),
                    "direccion": self._obtener_direccion_schema_destinatario(datos),
                    "fecha_nacimiento": fecha_nacimiento,
                    "escolarizado": escolarizado,
                }
            }

            AltaDestinatarioPasoSchema(**datos_schema)

            if errores_manuales:
                return self._resultado_errores_manuales(errores_manuales)

            return {
                "valido": True,
                "errores": [],
                "mensaje": "",
            }

        except ValidationError as error:
            resultado = self._resultado_pydantic_para_qml(
                error=error,
                mapa_campos={
                    "beneficiario.nombre": "nombre",
                    "beneficiario.apellido": "apellido",
                    "beneficiario.dni": "dni",
                    "beneficiario.direccion.calle": "calle",
                    "beneficiario.direccion.numero": "numero",
                    "beneficiario.fecha_nacimiento": "fechaNacimiento",
                    "beneficiario.escolarizado": "escolarizado",
                },
            )

            if errores_manuales:
                resultado = self._combinar_errores(
                    resultado=resultado,
                    errores_manuales=errores_manuales,
                )

            return resultado

    @Slot("QVariantMap", result="QVariantMap")
    def validarTutor(self, datos: dict[str, Any]) -> dict[str, Any]:
        """
        Se mantiene por compatibilidad si algún QML viejo todavía lo llama.
        Actualmente SectionTwo usa validarDestinatario() también para tutor.
        """
        return self.validarDestinatario(datos)

    @Slot("QVariantMap", result="QVariantMap")
    def validarResponsable(self, datos: dict[str, Any]) -> dict[str, Any]:
        """
        Valida solo los datos del paso Responsable Adulto.
        Se usa al presionar Siguiente en Alta Destinatario.
        """
        errores_manuales: list[dict[str, str]] = []

        fecha_nacimiento = self._convertir_fecha_nacimiento_alta(
            valor=datos.get("responsableFechaNacimiento", ""),
            campo_qml="responsableFechaNacimiento",
            etiqueta="Responsable adulto - Fecha de nacimiento",
            errores=errores_manuales,
        )

        try:
            datos_schema = {
                "responsable_adulto": {
                    "nombre": str(datos.get("responsableNombre", "")).strip(),
                    "apellido": str(datos.get("responsableApellido", "")).strip(),
                    "dni": str(datos.get("responsableDni", "")).strip(),
                    "direccion": self._obtener_direccion_schema_responsable(datos),
                    "fecha_nacimiento": fecha_nacimiento,
                    "parentesco": str(
                        datos.get("responsableParentesco", "")
                    ).strip(),
                    "telefono": self._obtener_telefono_schema_responsable(datos),
                }
            }

            AltaResponsablePasoSchema(**datos_schema)

            if errores_manuales:
                return self._resultado_errores_manuales(errores_manuales)

            return {
                "valido": True,
                "errores": [],
                "mensaje": "",
            }

        except ValidationError as error:
            resultado = self._resultado_pydantic_para_qml(
                error=error,
                mapa_campos={
                    "responsable_adulto.nombre": "responsableNombre",
                    "responsable_adulto.apellido": "responsableApellido",
                    "responsable_adulto.dni": "responsableDni",
                    "responsable_adulto.direccion.calle": "responsableDomicilio",
                    "responsable_adulto.direccion.numero": "responsableDomicilio",
                    "responsable_adulto.fecha_nacimiento": "responsableFechaNacimiento",
                    "responsable_adulto.parentesco": "responsableParentesco",
                    "responsable_adulto.telefono.codigo_area": "responsableCodigoArea",
                    "responsable_adulto.telefono.numero": "responsableNumeroTelefono",
                },
            )

            if errores_manuales:
                resultado = self._combinar_errores(
                    resultado=resultado,
                    errores_manuales=errores_manuales,
                )

            return resultado

    # ============================================================
    # GENERACIÓN DE SOLICITUD
    # ============================================================

    @Slot("QVariantMap", result=str)
    def generarSolicitud(self, datos: dict[str, Any]) -> str:
        try:
            resultado_validacion = self._validar_solicitud_alta_con_modelo_nuevo(
                datos
            )

            if not resultado_validacion["valido"]:
                return (
                    "ERROR|No se pudo generar la solicitud:\n"
                    f"{resultado_validacion['mensaje']}"
                )

            datos_excel = self._mapear_datos_destinatario(datos)

            ruta_salida = self._crear_ruta_salida(datos_excel)

            generar_solicitud_alta(
                datos=datos_excel,
                ruta_salida=ruta_salida,
            )

            if not ruta_salida.exists():
                return f"ERROR|El archivo no se generó en la ruta esperada: {ruta_salida}"

            ruta_copia_externa = self._copiar_a_carpeta_externa_si_corresponde(
                ruta_salida
            )

            self._abrir_archivo(ruta_salida)

            if ruta_copia_externa:
                return (
                    f"OK|Solicitud generada correctamente: {ruta_salida}\n"
                    f"Copia externa generada en: {ruta_copia_externa}"
                )

            return f"OK|Solicitud generada correctamente: {ruta_salida}"

        except Exception as error:
            return f"ERROR|No se pudo generar la solicitud: {error}"

    @Slot("QVariantMap", result="QVariantMap")
    def prepararDatosSolicitud(self, datos: dict[str, Any]) -> dict[str, Any]:
        """
        Prepara los datos finales de la solicitud sin generar el archivo Excel.
        Sirve para previsualización.
        """
        try:
            return self._mapear_datos_destinatario(datos)

        except Exception as error:
            print(f"ERROR al preparar datos de solicitud: {error}")
            return {
                "error": f"No se pudieron preparar los datos de la solicitud: {error}"
            }

    # ============================================================
    # VALIDACIÓN FINAL NUEVA
    # ============================================================

    def _validar_solicitud_alta_con_modelo_nuevo(
        self,
        datos: dict[str, Any],
    ) -> dict[str, Any]:
        errores_manuales: list[dict[str, str]] = []

        try:
            datos_schema = self._armar_datos_schema_solicitud_alta(
                datos=datos,
                errores=errores_manuales,
            )

            if errores_manuales:
                return {
                    "valido": False,
                    "mensaje": self._texto_errores_manuales(errores_manuales),
                }

            schema = SolicitudAltaSchema(**datos_schema)
            solicitud = mapear_solicitud_alta(schema)
            errores_dominio = validar_reglas_solicitud_alta(solicitud)

            if errores_dominio:
                return {
                    "valido": False,
                    "mensaje": errores_dominio_a_texto(errores_dominio),
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

    def _armar_datos_schema_solicitud_alta(
        self,
        datos: dict[str, Any],
        errores: list[dict[str, str]],
    ) -> dict[str, Any]:
        tipo_solicitud = self._normalizar_tipo_solicitud_alta(
            datos.get("tipoSolicitudAlta", "destinatario")
        )

        fecha_nacimiento_beneficiario = self._convertir_fecha_nacimiento_alta(
            valor=datos.get("fechaNacimiento", ""),
            campo_qml="fechaNacimiento",
            etiqueta="Fecha de nacimiento",
            errores=errores,
        )

        escolarizado = self._normalizar_escolarizado_alta(
            valor=datos.get("escolarizado", ""),
            errores=errores,
        )

        datos_schema = {
            "fecha_emision": date.today(),
            "tipo_solicitud": tipo_solicitud,
            "beneficiario": {
                "nombre": str(datos.get("nombre", "")).strip(),
                "apellido": str(datos.get("apellido", "")).strip(),
                "dni": str(datos.get("dni", "")).strip(),
                "direccion": self._obtener_direccion_schema_destinatario(datos),
                "fecha_nacimiento": fecha_nacimiento_beneficiario,
                "escolarizado": escolarizado,
            },
            "contexto_institucional": self._cargar_contexto_institucional_para_schema(),
            "responsable_adulto": None,
        }

        if tipo_solicitud == "destinatario":
            fecha_nacimiento_responsable = self._convertir_fecha_nacimiento_alta(
                valor=datos.get("responsableFechaNacimiento", ""),
                campo_qml="responsableFechaNacimiento",
                etiqueta="Responsable adulto - Fecha de nacimiento",
                errores=errores,
            )

            datos_schema["responsable_adulto"] = {
                "nombre": str(datos.get("responsableNombre", "")).strip(),
                "apellido": str(datos.get("responsableApellido", "")).strip(),
                "dni": str(datos.get("responsableDni", "")).strip(),
                "direccion": self._obtener_direccion_schema_responsable(datos),
                "fecha_nacimiento": fecha_nacimiento_responsable,
                "parentesco": str(datos.get("responsableParentesco", "")).strip(),
                "telefono": self._obtener_telefono_schema_responsable(datos),
            }

        return datos_schema

    def _normalizar_tipo_solicitud_alta(self, valor: Any) -> str:
        texto = str(valor).strip().lower()

        if texto in {"destinatario", "alta destinatario"}:
            return "destinatario"

        if texto in {"tutor", "alta tutor"}:
            return "tutor"

        # Dejo que el schema arroje el error formal si llega algo inválido.
        return texto

    # ============================================================
    # NORMALIZACIÓN PARA VALIDACIÓN DE ALTA
    # ============================================================

    def _obtener_direccion_schema_destinatario(
        self,
        datos: dict[str, Any],
    ) -> dict[str, Any]:
        direccion_schema = datos.get("direccionSchema", {})

        if isinstance(direccion_schema, dict):
            return {
                "calle": str(direccion_schema.get("calle", "")).strip(),
                "numero": str(direccion_schema.get("numero", "")).strip(),
            }

        return {
            "calle": str(datos.get("calle", "")).strip(),
            "numero": str(datos.get("numero", "")).strip(),
        }

    def _obtener_direccion_schema_responsable(
        self,
        datos: dict[str, Any],
    ) -> dict[str, Any]:
        direccion_schema = datos.get("responsableDireccionSchema", {})

        if isinstance(direccion_schema, dict):
            return {
                "calle": str(direccion_schema.get("calle", "")).strip(),
                "numero": str(direccion_schema.get("numero", "")).strip(),
            }

        domicilio = str(datos.get("responsableDomicilio", "")).strip()

        return {
            "calle": domicilio,
            "numero": "",
        }

    def _obtener_telefono_schema_responsable(
        self,
        datos: dict[str, Any],
    ) -> dict[str, Any]:
        telefono_schema = datos.get("responsableTelefonoSchema", {})

        if isinstance(telefono_schema, dict):
            return {
                "codigo_area": str(
                    telefono_schema.get("codigo_area", "")
                ).strip(),
                "numero": str(
                    telefono_schema.get("numero", "")
                ).strip(),
            }

        return {
            "codigo_area": "",
            "numero": str(datos.get("responsableTelefono", "")).strip(),
        }

    def _convertir_fecha_nacimiento_alta(
        self,
        valor: Any,
        campo_qml: str,
        etiqueta: str,
        errores: list[dict[str, str]],
    ) -> date:
        texto = str(valor).strip()

        if not texto:
            errores.append({
                "campo": campo_qml,
                "mensaje": f"{etiqueta}: es obligatoria.",
            })

            return date.today()

        try:
            return datetime.strptime(texto, "%d/%m/%Y").date()

        except ValueError:
            errores.append({
                "campo": campo_qml,
                "mensaje": f"{etiqueta}: debe tener formato DD/MM/AAAA.",
            })

            return date.today()

    def _normalizar_escolarizado_alta(
        self,
        valor: Any,
        errores: list[dict[str, str]],
    ) -> bool:
        texto = str(valor).strip()

        if texto in {"Sí", "Si"}:
            return True

        if texto == "No":
            return False

        errores.append({
            "campo": "escolarizado",
            "mensaje": "Escolarizado: debe seleccionar Sí o No.",
        })

        return False

    # ============================================================
    # FECHAS / EDADES
    # ============================================================

    def _obtener_fecha_actual(self) -> str:
        return date.today().strftime("%d/%m/%Y")

    def _calcular_edad(self, fecha_nacimiento: str) -> str:
        """
        Calcula la edad a partir de una fecha de nacimiento en formato dd/mm/aaaa.
        Si la fecha está vacía o tiene formato inválido, devuelve cadena vacía.
        """
        fecha_nacimiento = str(fecha_nacimiento).strip()

        if not fecha_nacimiento:
            return ""

        try:
            nacimiento = datetime.strptime(fecha_nacimiento, "%d/%m/%Y").date()
            hoy = date.today()
            edad = hoy.year - nacimiento.year

            if (hoy.month, hoy.day) < (nacimiento.month, nacimiento.day):
                edad -= 1

            return str(edad)

        except ValueError:
            return ""

    # ============================================================
    # CONFIGURACIÓN
    # ============================================================

    def _cargar_configuracion_sede(self) -> dict[str, Any]:
        base_dir = Path(__file__).resolve().parent.parent.parent
        config_path_v2 = base_dir / "config" / "configuracion_sede_v2.json"
        config_path_vieja = base_dir / "config" / "configuracion_sede.json"

        configuracion_vacia = {
            "nombreSede": "",
            "origen": "",
            "municipio": "",
            "localidad": "",
            "barrio": "",
            "fechaAutomatica": True,
            "edadAutomatica": True,
            "fechaActual": self._obtener_fecha_actual(),
        }

        if config_path_v2.exists():
            try:
                with config_path_v2.open("r", encoding="utf-8") as archivo:
                    configuracion = json.load(archivo)

                ubicacion = configuracion.get("ubicacion", {}) or {}

                return {
                    "nombreSede": str(configuracion.get("nombre_sede", "")).strip(),
                    "origen": str(configuracion.get("origen", "")).strip(),
                    "municipio": str(ubicacion.get("municipio", "")).strip(),
                    "localidad": str(ubicacion.get("localidad", "")).strip(),
                    "barrio": str(ubicacion.get("barrio", "")).strip(),
                    "fechaAutomatica": bool(configuracion.get("fechaAutomatica", True)),
                    "edadAutomatica": bool(configuracion.get("edadAutomatica", True)),
                    "fechaActual": str(
                        configuracion.get(
                            "fechaActual",
                            self._obtener_fecha_actual(),
                        )
                    ).strip(),
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
                "fechaAutomatica": bool(configuracion.get("fechaAutomatica", True)),
                "edadAutomatica": bool(configuracion.get("edadAutomatica", True)),
                "fechaActual": str(
                    configuracion.get(
                        "fechaActual",
                        self._obtener_fecha_actual(),
                    )
                ),
            }

        except Exception as error:
            print(f"ERROR al cargar configuración de sede: {error}")
            return configuracion_vacia

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

    # ============================================================
    # MAPEO PARA EXCEL / PREVISUALIZACIÓN
    # ============================================================

    def _mapear_datos_destinatario(self, datos: dict[str, Any]) -> dict[str, Any]:
        configuracion_sede = self._cargar_configuracion_sede()

        fecha_automatica = bool(configuracion_sede.get("fechaAutomatica", True))
        edad_automatica = bool(configuracion_sede.get("edadAutomatica", True))

        fecha = (
            self._obtener_fecha_actual()
            if fecha_automatica
            else configuracion_sede.get("fechaActual", "")
        )

        edad_destinatario = (
            self._calcular_edad(datos.get("fechaNacimiento", ""))
            if edad_automatica
            else datos.get("edad", "")
        )

        edad_responsable = (
            self._calcular_edad(datos.get("responsableFechaNacimiento", ""))
            if edad_automatica
            else datos.get("responsableEdad", "")
        )

        return {
            "fecha": fecha,
            "origen": configuracion_sede.get("origen", ""),
            "municipio": configuracion_sede.get("municipio", ""),
            "sede": configuracion_sede.get("nombreSede", ""),
            "barrio": configuracion_sede.get("barrio", ""),
            "localidad": configuracion_sede.get("localidad", ""),

            "destinatario_nombre": datos.get("nombre", ""),
            "destinatario_apellido": datos.get("apellido", ""),
            "destinatario_dni": datos.get("dni", ""),
            "destinatario_direccion": datos.get("direccion", ""),
            "destinatario_fecha_nacimiento": datos.get("fechaNacimiento", ""),
            "destinatario_edad": edad_destinatario,
            "destinatario_escolarizado": datos.get("escolarizado", ""),

            "responsable_nombre": datos.get("responsableNombre", ""),
            "responsable_apellido": datos.get("responsableApellido", ""),
            "responsable_telefono": datos.get("responsableTelefono", ""),
            "responsable_domicilio": datos.get("responsableDomicilio", ""),
            "responsable_dni": datos.get("responsableDni", ""),
            "responsable_parentesco": datos.get("responsableParentesco", ""),
            "responsable_fecha_nacimiento": datos.get(
                "responsableFechaNacimiento",
                "",
            ),
            "responsable_edad": edad_responsable,
        }

    # ============================================================
    # RUTAS Y ARCHIVOS
    # ============================================================

    def _crear_ruta_salida(self, datos_excel: dict[str, Any]) -> Path:
        base_dir = Path(__file__).resolve().parent.parent.parent

        output_dir = base_dir / "output" / "solicitudes_generadas"
        output_dir.mkdir(parents=True, exist_ok=True)

        nombre = str(datos_excel.get("destinatario_nombre", "")).strip()
        apellido = str(datos_excel.get("destinatario_apellido", "")).strip()

        nombre_completo = f"{nombre} {apellido}".strip()

        if not nombre_completo:
            nombre_completo = "sin_nombre"

        nombre_limpio = self._limpiar_nombre_archivo(nombre_completo)

        tipo_solicitud = str(datos_excel.get("tipo_solicitud", "alta")).strip()

        if tipo_solicitud:
            nombre_base = f"solicitud_de_{tipo_solicitud}_{nombre_limpio}"
        else:
            nombre_base = f"solicitud_de_alta_{nombre_limpio}"

        extension = ".xlsx"

        ruta = output_dir / f"{nombre_base}{extension}"

        contador = 1

        while ruta.exists():
            ruta = output_dir / f"{nombre_base}_{contador}{extension}"
            contador += 1

        return ruta.resolve()

    def _copiar_a_carpeta_externa_si_corresponde(
        self,
        ruta_origen: Path,
    ) -> Path | None:
        configuracion = self._cargar_configuracion_guardado()

        carpeta_externa = str(
            configuracion.get("carpeta_copia_externa_solicitudes", "")
        ).strip()

        if not carpeta_externa:
            return None

        ruta_carpeta_externa = Path(carpeta_externa).expanduser()
        ruta_carpeta_externa.mkdir(parents=True, exist_ok=True)

        ruta_destino = ruta_carpeta_externa / ruta_origen.name

        contador = 1
        nombre_base = ruta_origen.stem
        extension = ruta_origen.suffix

        while ruta_destino.exists():
            ruta_destino = ruta_carpeta_externa / f"{nombre_base}_{contador}{extension}"
            contador += 1

        shutil.copy2(ruta_origen, ruta_destino)

        return ruta_destino.resolve()

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

    def _abrir_archivo(self, ruta: Path) -> None:
        ruta = ruta.resolve()

        if sys.platform.startswith("linux"):
            libreoffice = shutil.which("libreoffice")

            if libreoffice:
                subprocess.Popen(
                    [libreoffice, "--calc", str(ruta)],
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

    # ============================================================
    # FORMATO DE ERRORES PYDANTIC / QML
    # ============================================================

    def _resultado_errores_manuales(
        self,
        errores: list[dict[str, str]],
    ) -> dict[str, Any]:
        mensajes = [
            f"{error['campo']}: {error['mensaje']}"
            for error in errores
        ]

        return {
            "valido": False,
            "errores": errores,
            "mensaje": "\n".join(mensajes),
        }

    def _texto_errores_manuales(
        self,
        errores: list[dict[str, str]],
    ) -> str:
        return "\n".join(
            f"{error['campo']}: {error['mensaje']}"
            for error in errores
        )

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

    def _combinar_errores(
        self,
        resultado: dict[str, Any],
        errores_manuales: list[dict[str, str]],
    ) -> dict[str, Any]:
        resultado["errores"].extend(errores_manuales)

        mensajes = [resultado.get("mensaje", "").strip()]
        mensajes.extend(
            f"{error_manual['campo']}: {error_manual['mensaje']}"
            for error_manual in errores_manuales
        )

        resultado["mensaje"] = "\n".join(
            mensaje for mensaje in mensajes if mensaje
        )

        return resultado

    def _obtener_campo_error(self, detalle_error: dict[str, Any]) -> str:
        ubicacion = detalle_error.get("loc", [])

        return ".".join(str(parte) for parte in ubicacion)



# # app_jade / CORE / controladores / controlador_altas.py

# from pathlib import Path
# from typing import Any
# import json
# import os
# import re
# import shutil
# import subprocess
# import sys
# from datetime import date, datetime

# from pydantic import BaseModel, ValidationError
# from PySide6.QtCore import QObject, Slot

# from ..generador_excel import generar_solicitud_alta
# from ..validaciones import (
#     validar_solicitud_alta,
#     validar_destinatario_o_tutor,
#     validar_responsable,
#     errores_a_texto,
# )

# from CORE.schemas.personas_schema import (
#     BeneficiarioAltaSchema,
#     ResponsableAdultoSchema,
# )


# # ============================================================
# # SCHEMAS INTERNOS - VALIDACIÓN POR PASO ALTA
# # ============================================================

# class AltaDestinatarioPasoSchema(BaseModel):
#     beneficiario: BeneficiarioAltaSchema


# class AltaResponsablePasoSchema(BaseModel):
#     responsable_adulto: ResponsableAdultoSchema


# class ControladorAltas(QObject):
#     """
#     Puente entre QML y el generador de Excel.
#     Recibe datos desde QML, los adapta al formato del generador
#     y produce la solicitud de alta en Excel.
#     """

#     # ============================================================
#     # VALIDACIONES POR PASO
#     # ============================================================

#     @Slot("QVariantMap", result="QVariantMap")
#     def validarDestinatario(self, datos: dict[str, Any]) -> dict[str, Any]:
#         """
#         Valida solo los datos del paso Destinatario.
#         Se usa al presionar Siguiente en Alta Destinatario.

#         Migrado parcialmente al modelo nuevo:
#         - usa BeneficiarioAltaSchema
#         - mantiene compatibilidad con los datos QML actuales
#         - usa direccionSchema para validar calle/número
#         """
#         errores_manuales: list[dict[str, str]] = []

#         fecha_nacimiento = self._convertir_fecha_nacimiento_alta(
#             valor=datos.get("fechaNacimiento", ""),
#             campo_qml="fechaNacimiento",
#             etiqueta="Fecha de nacimiento",
#             errores=errores_manuales,
#         )

#         escolarizado = self._normalizar_escolarizado_alta(
#             valor=datos.get("escolarizado", ""),
#             errores=errores_manuales,
#         )

#         try:
#             datos_schema = {
#                 "beneficiario": {
#                     "nombre": str(datos.get("nombre", "")).strip(),
#                     "apellido": str(datos.get("apellido", "")).strip(),
#                     "dni": str(datos.get("dni", "")).strip(),
#                     "direccion": self._obtener_direccion_schema_destinatario(datos),
#                     "fecha_nacimiento": fecha_nacimiento,
#                     "escolarizado": escolarizado,
#                 }
#             }

#             AltaDestinatarioPasoSchema(**datos_schema)

#             if errores_manuales:
#                 return self._resultado_errores_manuales(errores_manuales)

#             return {
#                 "valido": True,
#                 "errores": [],
#                 "mensaje": "",
#             }

#         except ValidationError as error:
#             resultado = self._resultado_pydantic_para_qml(
#                 error=error,
#                 mapa_campos={
#                     "beneficiario.nombre": "nombre",
#                     "beneficiario.apellido": "apellido",
#                     "beneficiario.dni": "dni",
#                     "beneficiario.direccion.calle": "calle",
#                     "beneficiario.direccion.numero": "numero",
#                     "beneficiario.fecha_nacimiento": "fechaNacimiento",
#                     "beneficiario.escolarizado": "escolarizado",
#                 },
#             )

#             if errores_manuales:
#                 resultado = self._combinar_errores(
#                     resultado=resultado,
#                     errores_manuales=errores_manuales,
#                 )

#             return resultado

#     @Slot("QVariantMap", result="QVariantMap")
#     def validarTutor(self, datos: dict[str, Any]) -> dict[str, Any]:
#         """
#         Valida solo los datos del paso Tutor.
#         Reutiliza las mismas reglas que Destinatario.
#         """
#         errores = validar_destinatario_o_tutor(datos)

#         return {
#             "valido": len(errores) == 0,
#             "errores": errores,
#             "mensaje": errores_a_texto(errores),
#         }

#     @Slot("QVariantMap", result="QVariantMap")
#     def validarResponsable(self, datos: dict[str, Any]) -> dict[str, Any]:
#         """
#         Valida solo los datos del paso Responsable Adulto.
#         Se usa al presionar Siguiente en Alta Destinatario.

#         Migrado parcialmente al modelo nuevo:
#         - usa ResponsableAdultoSchema
#         - mantiene compatibilidad con los datos QML actuales
#         - usa responsableDireccionSchema para validar calle/número
#         - usa responsableTelefonoSchema para validar código de área/número
#         """
#         errores_manuales: list[dict[str, str]] = []

#         fecha_nacimiento = self._convertir_fecha_nacimiento_alta(
#             valor=datos.get("responsableFechaNacimiento", ""),
#             campo_qml="responsableFechaNacimiento",
#             etiqueta="Responsable adulto - Fecha de nacimiento",
#             errores=errores_manuales,
#         )

#         try:
#             datos_schema = {
#                 "responsable_adulto": {
#                     "nombre": str(datos.get("responsableNombre", "")).strip(),
#                     "apellido": str(datos.get("responsableApellido", "")).strip(),
#                     "dni": str(datos.get("responsableDni", "")).strip(),
#                     "direccion": self._obtener_direccion_schema_responsable(datos),
#                     "fecha_nacimiento": fecha_nacimiento,
#                     "parentesco": str(
#                         datos.get("responsableParentesco", "")
#                     ).strip(),
#                     "telefono": self._obtener_telefono_schema_responsable(datos),
#                 }
#             }

#             AltaResponsablePasoSchema(**datos_schema)

#             if errores_manuales:
#                 return self._resultado_errores_manuales(errores_manuales)

#             return {
#                 "valido": True,
#                 "errores": [],
#                 "mensaje": "",
#             }

#         except ValidationError as error:
#             resultado = self._resultado_pydantic_para_qml(
#                 error=error,
#                 mapa_campos={
#                     "responsable_adulto.nombre": "responsableNombre",
#                     "responsable_adulto.apellido": "responsableApellido",
#                     "responsable_adulto.dni": "responsableDni",
#                     "responsable_adulto.direccion.calle": "responsableDomicilio",
#                     "responsable_adulto.direccion.numero": "responsableDomicilio",
#                     "responsable_adulto.fecha_nacimiento": "responsableFechaNacimiento",
#                     "responsable_adulto.parentesco": "responsableParentesco",
#                     "responsable_adulto.telefono.codigo_area": "responsableCodigoArea",
#                     "responsable_adulto.telefono.numero": "responsableNumeroTelefono",
#                 },
#             )

#             if errores_manuales:
#                 resultado = self._combinar_errores(
#                     resultado=resultado,
#                     errores_manuales=errores_manuales,
#                 )

#             return resultado

#     # ============================================================
#     # GENERACIÓN DE SOLICITUD
#     # ============================================================

#     @Slot("QVariantMap", result=str)
#     def generarSolicitud(self, datos: dict[str, Any]) -> str:
#         try:
#             # Validación final de seguridad.
#             # La validación principal se hace por paso desde QML.
#             resultado_validacion = validar_solicitud_alta(datos)

#             if not resultado_validacion["valido"]:
#                 errores = errores_a_texto(resultado_validacion["errores"])
#                 return f"ERROR|No se pudo generar la solicitud:\n{errores}"

#             datos_excel = self._mapear_datos_destinatario(datos)

#             ruta_salida = self._crear_ruta_salida(datos_excel)

#             generar_solicitud_alta(
#                 datos=datos_excel,
#                 ruta_salida=ruta_salida,
#             )

#             if not ruta_salida.exists():
#                 return f"ERROR|El archivo no se generó en la ruta esperada: {ruta_salida}"

#             ruta_copia_externa = self._copiar_a_carpeta_externa_si_corresponde(
#                 ruta_salida
#             )

#             self._abrir_archivo(ruta_salida)

#             if ruta_copia_externa:
#                 return (
#                     f"OK|Solicitud generada correctamente: {ruta_salida}\n"
#                     f"Copia externa generada en: {ruta_copia_externa}"
#                 )

#             return f"OK|Solicitud generada correctamente: {ruta_salida}"

#         except Exception as error:
#             return f"ERROR|No se pudo generar la solicitud: {error}"

#     @Slot("QVariantMap", result="QVariantMap")
#     def prepararDatosSolicitud(self, datos: dict[str, Any]) -> dict[str, Any]:
#         """
#         Prepara los datos finales de la solicitud sin generar el archivo Excel.
#         Sirve para previsualización.
#         """
#         try:
#             return self._mapear_datos_destinatario(datos)

#         except Exception as error:
#             print(f"ERROR al preparar datos de solicitud: {error}")
#             return {
#                 "error": f"No se pudieron preparar los datos de la solicitud: {error}"
#             }

#     # ============================================================
#     # NORMALIZACIÓN PARA VALIDACIÓN DE ALTA
#     # ============================================================

#     def _obtener_direccion_schema_destinatario(
#         self,
#         datos: dict[str, Any],
#     ) -> dict[str, Any]:
#         direccion_schema = datos.get("direccionSchema", {})

#         if isinstance(direccion_schema, dict):
#             return {
#                 "calle": str(direccion_schema.get("calle", "")).strip(),
#                 "numero": str(direccion_schema.get("numero", "")).strip(),
#             }

#         return {
#             "calle": str(datos.get("calle", "")).strip(),
#             "numero": str(datos.get("numero", "")).strip(),
#         }

#     def _obtener_direccion_schema_responsable(
#         self,
#         datos: dict[str, Any],
#     ) -> dict[str, Any]:
#         direccion_schema = datos.get("responsableDireccionSchema", {})

#         if isinstance(direccion_schema, dict):
#             return {
#                 "calle": str(direccion_schema.get("calle", "")).strip(),
#                 "numero": str(direccion_schema.get("numero", "")).strip(),
#             }

#         domicilio = str(datos.get("responsableDomicilio", "")).strip()

#         return {
#             "calle": domicilio,
#             "numero": "",
#         }

#     def _obtener_telefono_schema_responsable(
#         self,
#         datos: dict[str, Any],
#     ) -> dict[str, Any]:
#         telefono_schema = datos.get("responsableTelefonoSchema", {})

#         if isinstance(telefono_schema, dict):
#             return {
#                 "codigo_area": str(
#                     telefono_schema.get("codigo_area", "")
#                 ).strip(),
#                 "numero": str(
#                     telefono_schema.get("numero", "")
#                 ).strip(),
#             }

#         return {
#             "codigo_area": "",
#             "numero": str(datos.get("responsableTelefono", "")).strip(),
#         }

#     def _convertir_fecha_nacimiento_alta(
#         self,
#         valor: Any,
#         campo_qml: str,
#         etiqueta: str,
#         errores: list[dict[str, str]],
#     ) -> date:
#         texto = str(valor).strip()

#         if not texto:
#             errores.append({
#                 "campo": campo_qml,
#                 "mensaje": f"{etiqueta}: es obligatoria.",
#             })

#             return date.today()

#         try:
#             return datetime.strptime(texto, "%d/%m/%Y").date()

#         except ValueError:
#             errores.append({
#                 "campo": campo_qml,
#                 "mensaje": f"{etiqueta}: debe tener formato DD/MM/AAAA.",
#             })

#             return date.today()

#     def _normalizar_escolarizado_alta(
#         self,
#         valor: Any,
#         errores: list[dict[str, str]],
#     ) -> bool:
#         texto = str(valor).strip()

#         if texto in {"Sí", "Si"}:
#             return True

#         if texto == "No":
#             return False

#         errores.append({
#             "campo": "escolarizado",
#             "mensaje": "Escolarizado: debe seleccionar Sí o No.",
#         })

#         return False

#     # ============================================================
#     # FECHAS / EDADES
#     # ============================================================

#     def _obtener_fecha_actual(self) -> str:
#         return date.today().strftime("%d/%m/%Y")

#     def _calcular_edad(self, fecha_nacimiento: str) -> str:
#         """
#         Calcula la edad a partir de una fecha de nacimiento en formato dd/mm/aaaa.
#         Si la fecha está vacía o tiene formato inválido, devuelve cadena vacía.
#         """
#         fecha_nacimiento = str(fecha_nacimiento).strip()

#         if not fecha_nacimiento:
#             return ""

#         try:
#             nacimiento = datetime.strptime(fecha_nacimiento, "%d/%m/%Y").date()
#             hoy = date.today()
#             edad = hoy.year - nacimiento.year

#             if (hoy.month, hoy.day) < (nacimiento.month, nacimiento.day):
#                 edad -= 1

#             return str(edad)

#         except ValueError:
#             return ""

#     # ============================================================
#     # CONFIGURACIÓN
#     # ============================================================

#     def _cargar_configuracion_sede(self) -> dict[str, Any]:
#         base_dir = Path(__file__).resolve().parent.parent.parent
#         config_path = base_dir / "config" / "configuracion_sede.json"

#         configuracion_vacia = {
#             "nombreSede": "",
#             "origen": "",
#             "municipio": "",
#             "localidad": "",
#             "barrio": "",
#             "fechaAutomatica": True,
#             "edadAutomatica": True,
#             "fechaActual": self._obtener_fecha_actual(),
#         }

#         if not config_path.exists():
#             return configuracion_vacia

#         try:
#             with config_path.open("r", encoding="utf-8") as archivo:
#                 configuracion = json.load(archivo)

#             return {
#                 "nombreSede": str(configuracion.get("nombreSede", "")),
#                 "origen": str(configuracion.get("origen", "")),
#                 "municipio": str(configuracion.get("municipio", "")),
#                 "localidad": str(configuracion.get("localidad", "")),
#                 "barrio": str(configuracion.get("barrio", "")),
#                 "fechaAutomatica": bool(configuracion.get("fechaAutomatica", True)),
#                 "edadAutomatica": bool(configuracion.get("edadAutomatica", True)),
#                 "fechaActual": str(
#                     configuracion.get(
#                         "fechaActual",
#                         self._obtener_fecha_actual(),
#                     )
#                 ),
#             }

#         except Exception as error:
#             print(f"ERROR al cargar configuración de sede: {error}")
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

#     # ============================================================
#     # MAPEO PARA EXCEL / PREVISUALIZACIÓN
#     # ============================================================

#     def _mapear_datos_destinatario(self, datos: dict[str, Any]) -> dict[str, Any]:
#         configuracion_sede = self._cargar_configuracion_sede()

#         fecha_automatica = bool(configuracion_sede.get("fechaAutomatica", True))
#         edad_automatica = bool(configuracion_sede.get("edadAutomatica", True))

#         fecha = (
#             self._obtener_fecha_actual()
#             if fecha_automatica
#             else configuracion_sede.get("fechaActual", "")
#         )

#         edad_destinatario = (
#             self._calcular_edad(datos.get("fechaNacimiento", ""))
#             if edad_automatica
#             else datos.get("edad", "")
#         )

#         edad_responsable = (
#             self._calcular_edad(datos.get("responsableFechaNacimiento", ""))
#             if edad_automatica
#             else datos.get("responsableEdad", "")
#         )

#         return {
#             "fecha": fecha,
#             "origen": configuracion_sede.get("origen", ""),
#             "municipio": configuracion_sede.get("municipio", ""),
#             "sede": configuracion_sede.get("nombreSede", ""),
#             "barrio": configuracion_sede.get("barrio", ""),
#             "localidad": configuracion_sede.get("localidad", ""),

#             "destinatario_nombre": datos.get("nombre", ""),
#             "destinatario_apellido": datos.get("apellido", ""),
#             "destinatario_dni": datos.get("dni", ""),
#             "destinatario_direccion": datos.get("direccion", ""),
#             "destinatario_fecha_nacimiento": datos.get("fechaNacimiento", ""),
#             "destinatario_edad": edad_destinatario,
#             "destinatario_escolarizado": datos.get("escolarizado", ""),

#             "responsable_nombre": datos.get("responsableNombre", ""),
#             "responsable_apellido": datos.get("responsableApellido", ""),
#             "responsable_telefono": datos.get("responsableTelefono", ""),
#             "responsable_domicilio": datos.get("responsableDomicilio", ""),
#             "responsable_dni": datos.get("responsableDni", ""),
#             "responsable_parentesco": datos.get("responsableParentesco", ""),
#             "responsable_fecha_nacimiento": datos.get(
#                 "responsableFechaNacimiento",
#                 "",
#             ),
#             "responsable_edad": edad_responsable,
#         }

#     # ============================================================
#     # RUTAS Y ARCHIVOS
#     # ============================================================

#     def _crear_ruta_salida(self, datos_excel: dict[str, Any]) -> Path:
#         base_dir = Path(__file__).resolve().parent.parent.parent

#         output_dir = base_dir / "output" / "solicitudes_generadas"
#         output_dir.mkdir(parents=True, exist_ok=True)

#         nombre = str(datos_excel.get("destinatario_nombre", "")).strip()
#         apellido = str(datos_excel.get("destinatario_apellido", "")).strip()

#         nombre_completo = f"{nombre} {apellido}".strip()

#         if not nombre_completo:
#             nombre_completo = "sin_nombre"

#         nombre_limpio = self._limpiar_nombre_archivo(nombre_completo)

#         nombre_base = f"solicitud_de_alta_{nombre_limpio}"
#         extension = ".xlsx"

#         ruta = output_dir / f"{nombre_base}{extension}"

#         contador = 1

#         while ruta.exists():
#             ruta = output_dir / f"{nombre_base}_{contador}{extension}"
#             contador += 1

#         return ruta.resolve()

#     def _copiar_a_carpeta_externa_si_corresponde(
#         self,
#         ruta_origen: Path,
#     ) -> Path | None:
#         configuracion = self._cargar_configuracion_guardado()

#         carpeta_externa = str(
#             configuracion.get("carpeta_copia_externa_solicitudes", "")
#         ).strip()

#         if not carpeta_externa:
#             return None

#         ruta_carpeta_externa = Path(carpeta_externa).expanduser()
#         ruta_carpeta_externa.mkdir(parents=True, exist_ok=True)

#         ruta_destino = ruta_carpeta_externa / ruta_origen.name

#         contador = 1
#         nombre_base = ruta_origen.stem
#         extension = ruta_origen.suffix

#         while ruta_destino.exists():
#             ruta_destino = ruta_carpeta_externa / f"{nombre_base}_{contador}{extension}"
#             contador += 1

#         shutil.copy2(ruta_origen, ruta_destino)

#         return ruta_destino.resolve()

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

#     def _abrir_archivo(self, ruta: Path) -> None:
#         ruta = ruta.resolve()

#         if sys.platform.startswith("linux"):
#             libreoffice = shutil.which("libreoffice")

#             if libreoffice:
#                 subprocess.Popen(
#                     [libreoffice, "--calc", str(ruta)],
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

#     # ============================================================
#     # FORMATO DE ERRORES PYDANTIC / QML
#     # ============================================================

#     def _resultado_errores_manuales(
#         self,
#         errores: list[dict[str, str]],
#     ) -> dict[str, Any]:
#         mensajes = [
#             f"{error['campo']}: {error['mensaje']}"
#             for error in errores
#         ]

#         return {
#             "valido": False,
#             "errores": errores,
#             "mensaje": "\n".join(mensajes),
#         }

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

#     def _combinar_errores(
#         self,
#         resultado: dict[str, Any],
#         errores_manuales: list[dict[str, str]],
#     ) -> dict[str, Any]:
#         resultado["errores"].extend(errores_manuales)

#         mensajes = [resultado.get("mensaje", "").strip()]
#         mensajes.extend(
#             f"{error_manual['campo']}: {error_manual['mensaje']}"
#             for error_manual in errores_manuales
#         )

#         resultado["mensaje"] = "\n".join(
#             mensaje for mensaje in mensajes if mensaje
#         )

#         return resultado

#     def _obtener_campo_error(self, detalle_error: dict[str, Any]) -> str:
#         ubicacion = detalle_error.get("loc", [])

#         return ".".join(str(parte) for parte in ubicacion)

