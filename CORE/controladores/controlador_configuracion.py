# app_jade / CORE / controladores / controlador_configuracion.py

from __future__ import annotations

import json
import unicodedata
from datetime import date
from pathlib import Path
from typing import Any

from pydantic import BaseModel, ValidationError, field_validator
from PySide6.QtCore import QObject, Slot

from CORE.dominio.errores import (
    errores_a_texto,
    mensaje_resultado,
)
from CORE.dominio.reglas import validar_reglas_contexto_institucional
from CORE.mapeadores.mapeador_dominio import mapear_contexto_institucional
from CORE.schemas.base_schema import (
    UbicacionSchema,
    PATRON_TEXTO_PERSONA,
    PATRON_TEXTO_CON_NUMEROS,
    validar_texto_obligatorio,
    validar_patron,
)
from CORE.schemas.contexto_institucional_schema import ContextoInstitucionalSchema
from CORE.schemas.personas_schema import (
    PersonalInstitucionalSchema,
    validar_fecha_texto_dd_mm_aaaa,
)


# ============================================================
# SCHEMAS INTERNOS DEL CONTROLADOR
# ============================================================

class DatosSedeSchema(BaseModel):
    origen: str
    nombre_sede: str
    ubicacion: UbicacionSchema

    @field_validator("origen")
    @classmethod
    def validar_origen(cls, valor: str) -> str:
        valor = validar_texto_obligatorio(valor, "Origen")

        return validar_patron(
            valor=valor,
            patron=PATRON_TEXTO_PERSONA,
            mensaje_usuario="Origen: solo permite letras, acentos y espacios.",
            mensaje_tecnico=(
                f"DatosSedeSchema.origen recibió '{valor}'. "
                "Patrón esperado: letras, acentos y espacios."
            ),
        )

    @field_validator("nombre_sede")
    @classmethod
    def validar_nombre_sede(cls, valor: str) -> str:
        valor = validar_texto_obligatorio(valor, "Nombre de sede")

        return validar_patron(
            valor=valor,
            patron=PATRON_TEXTO_CON_NUMEROS,
            mensaje_usuario="Nombre de sede: solo permite letras, números, acentos y espacios.",
            mensaje_tecnico=(
                f"DatosSedeSchema.nombre_sede recibió '{valor}'. "
                "Patrón esperado: letras, números, acentos y espacios."
            ),
        )


class ConfiguracionAutomaticaSchema(BaseModel):
    fechaAutomatica: bool
    edadAutomatica: bool
    fechaActual: str

    @field_validator("fechaActual")
    @classmethod
    def validar_fecha_actual(cls, valor: str) -> str:
        return validar_fecha_texto_dd_mm_aaaa(
            valor=valor,
            campo="Fecha manual",
            clase="ConfiguracionAutomaticaSchema",
            atributo="fechaActual",
        )


# ============================================================
# CONTROLADOR
# ============================================================

class ControladorConfiguracion(QObject):
    """
    Controlador para configuración institucional.

    Trabaja con la estructura nueva:

    {
        "origen": "...",
        "nombre_sede": "...",
        "ubicacion": {
            "municipio": "...",
            "localidad": "...",
            "barrio": ""
        },
        "coordinador": {
            "nombre": "...",
            "apellido": "...",
            "rol": {
                "nombre": "...",
                "siglas": "..."
            }
        },
        "profesionales": [
            {
                "nombre": "...",
                "apellido": "...",
                "rol": {
                    "nombre": "...",
                    "siglas": "..."
                }
            }
        ],
        "fechaAutomatica": true,
        "edadAutomatica": true,
        "fechaActual": "23/05/2026"
    }
    """

    def __init__(self) -> None:
        super().__init__()

        self.base_dir = Path(__file__).resolve().parent.parent.parent
        self.config_dir = self.base_dir / "config"

        self.config_path = self.config_dir / "configuracion_sede_v2.json"

        self.config_dir.mkdir(parents=True, exist_ok=True)

    # ============================================================
    # API QML - GUARDADO POR SECCIONES
    # ============================================================

    @Slot("QVariantMap", result=str)
    def guardarDatosSede(self, datos: dict[str, Any]) -> str:
        """
        Guarda solo la sección de datos de sede / ubicación.

        No valida coordinador.
        No valida profesionales.
        """

        print("\n" + "=" * 70)
        print("[CONFIGURACIÓN] Guardar datos de sede")
        print("=" * 70)
        print("[DATOS RECIBIDOS CORRECTAMENTE]")

        try:
            datos_sede = self._normalizar_datos_sede_recibidos(datos)
            schema = DatosSedeSchema(**datos_sede)

        except ValidationError as error:
            mensaje_usuario = self._mensaje_usuario_pydantic(error)

            print("[ERROR PYDANTIC]")
            print(mensaje_usuario)
            print("[DETALLE TÉCNICO]")
            print(self._mensaje_tecnico_pydantic(error))

            return f"ERROR|{mensaje_usuario}"

        configuracion = self._leer_configuracion_sede()
        configuracion["origen"] = schema.origen
        configuracion["nombre_sede"] = schema.nombre_sede
        configuracion["ubicacion"] = schema.ubicacion.model_dump(mode="json")

        self._guardar_diccionario_configuracion(configuracion)

        mensaje = mensaje_resultado([])

        print("[RESULTADO]")
        print(mensaje)

        return f"OK|{mensaje}"

    @Slot("QVariantMap", result=str)
    def agregarProfesional(self, datos: dict[str, Any]) -> str:
        """
        Valida un profesional individual y lo agrega a la lista.
        Si es inválido, no se agrega.
        """

        print("\n" + "=" * 70)
        print("[CONFIGURACIÓN] Agregar profesional")
        print("=" * 70)
        print("[DATOS RECIBIDOS CORRECTAMENTE]")

        try:
            profesional = PersonalInstitucionalSchema(**datos)

        except ValidationError as error:
            mensaje_usuario = self._mensaje_usuario_pydantic(error)

            print("[ERROR PYDANTIC]")
            print(mensaje_usuario)
            print("[DETALLE TÉCNICO]")
            print(self._mensaje_tecnico_pydantic(error))

            return f"ERROR|{mensaje_usuario}"

        configuracion = self._leer_configuracion_sede()
        profesionales = list(configuracion.get("profesionales", []))

        clave_nueva = self._clave_profesional(profesional.model_dump(mode="json"))

        for profesional_existente in profesionales:
            if self._clave_profesional(profesional_existente) == clave_nueva:
                mensaje = "Profesionales: ese profesional ya fue agregado."

                print("[ERROR DOMINIO]")
                print(mensaje)

                return f"ERROR|{mensaje}"

        profesionales.append(profesional.model_dump(mode="json"))
        configuracion["profesionales"] = profesionales

        self._guardar_diccionario_configuracion(configuracion)

        mensaje = mensaje_resultado([])

        print("[RESULTADO]")
        print(mensaje)

        return f"OK|{mensaje}"

    @Slot(int, result=str)
    def eliminarProfesional(self, indice: int) -> str:
        """
        Elimina un profesional puntual de la lista por índice.
        """

        print("\n" + "=" * 70)
        print("[CONFIGURACIÓN] Eliminar profesional")
        print("=" * 70)
        print("[DATOS RECIBIDOS CORRECTAMENTE]")

        configuracion = self._leer_configuracion_sede()
        profesionales = list(configuracion.get("profesionales", []))

        if indice < 0 or indice >= len(profesionales):
            mensaje = "Profesionales: no se pudo eliminar el profesional seleccionado."

            print("[ERROR]")
            print(mensaje)

            return f"ERROR|{mensaje}"

        profesionales.pop(indice)
        configuracion["profesionales"] = profesionales

        self._guardar_diccionario_configuracion(configuracion)

        mensaje = mensaje_resultado([])

        print("[RESULTADO]")
        print(mensaje)

        return f"OK|{mensaje}"

    @Slot("QVariantMap", result=str)
    def guardarCoordinador(self, datos: dict[str, Any]) -> str:
        """
        Guarda solo la sección de coordinador/coordinadora.
        """

        print("\n" + "=" * 70)
        print("[CONFIGURACIÓN] Guardar coordinador")
        print("=" * 70)
        print("[DATOS RECIBIDOS CORRECTAMENTE]")

        try:
            coordinador = PersonalInstitucionalSchema(**datos)

        except ValidationError as error:
            mensaje_usuario = self._mensaje_usuario_pydantic(error)

            print("[ERROR PYDANTIC]")
            print(mensaje_usuario)
            print("[DETALLE TÉCNICO]")
            print(self._mensaje_tecnico_pydantic(error))

            return f"ERROR|{mensaje_usuario}"

        configuracion = self._leer_configuracion_sede()
        configuracion["coordinador"] = coordinador.model_dump(mode="json")

        self._guardar_diccionario_configuracion(configuracion)

        mensaje = mensaje_resultado([])

        print("[RESULTADO]")
        print(mensaje)

        return f"OK|{mensaje}"

    # ============================================================
    # API QML - CONFIGURACIÓN AUTOMÁTICA
    # ============================================================

    @Slot("QVariantMap", result=str)
    def guardarConfiguracionAutomatica(self, datos: dict[str, Any]) -> str:
        print("\n" + "=" * 70)
        print("[CONFIGURACIÓN] Guardar configuración automática")
        print("=" * 70)
        print("[DATOS RECIBIDOS CORRECTAMENTE]")

        try:
            fecha_automatica = bool(
                datos.get("fechaAutomatica", True)
            )

            datos_schema = {
                "fechaAutomatica": fecha_automatica,
                "edadAutomatica": bool(
                    datos.get("edadAutomatica", True)
                ),
                "fechaActual": (
                    self.obtenerFechaActual()
                    if fecha_automatica
                    else str(datos.get("fechaActual", "")).strip()
                ),
            }

            schema = ConfiguracionAutomaticaSchema(**datos_schema)

        except ValidationError as error:
            mensaje_usuario = self._mensaje_usuario_pydantic(error)

            print("[ERROR PYDANTIC]")
            print(mensaje_usuario)
            print("[DETALLE TÉCNICO]")
            print(self._mensaje_tecnico_pydantic(error))

            return f"ERROR|{mensaje_usuario}"

        except Exception as error:
            return f"ERROR|No se pudo guardar la configuración automática: {error}"

        configuracion = self._leer_configuracion_sede()

        configuracion["fechaAutomatica"] = schema.fechaAutomatica
        configuracion["edadAutomatica"] = schema.edadAutomatica
        configuracion["fechaActual"] = schema.fechaActual

        self._guardar_diccionario_configuracion(configuracion)

        mensaje = mensaje_resultado([])

        print("[RESULTADO]")
        print(mensaje)

        return f"OK|{mensaje}"

    @Slot(result="QVariantMap")
    def cargarConfiguracionAutomatica(self) -> dict[str, Any]:
        configuracion = self._leer_configuracion_sede()

        fecha_automatica = bool(configuracion.get("fechaAutomatica", True))
        edad_automatica = bool(configuracion.get("edadAutomatica", True))

        if fecha_automatica:
            fecha_actual = self.obtenerFechaActual()
        else:
            fecha_actual = str(
                configuracion.get("fechaActual", self.obtenerFechaActual())
            ).strip()

        print("\n" + "=" * 70)
        print("[CONFIGURACIÓN] Cargar configuración automática")
        print("=" * 70)
        print("[DATOS ENVIADOS CORRECTAMENTE]")

        return {
            "fechaAutomatica": fecha_automatica,
            "edadAutomatica": edad_automatica,
            "fechaActual": fecha_actual,
        }

    @Slot(result=str)
    def obtenerFechaActual(self) -> str:
        return date.today().strftime("%d/%m/%Y")

    # ============================================================
    # API QML - GUARDADO COMPLETO / RESPALDO TEMPORAL
    # ============================================================

    @Slot("QVariantMap", result=str)
    def guardarConfiguracionSede(self, datos: dict[str, Any]) -> str:
        """
        Guardado completo de configuración institucional.

        Se mantiene como respaldo temporal para validar y guardar todo junto
        si alguna parte de la interfaz todavía lo necesita.
        """

        print("\n" + "=" * 70)
        print("[CONFIGURACIÓN] Guardar configuración institucional completa")
        print("=" * 70)
        print("[DATOS RECIBIDOS CORRECTAMENTE]")

        try:
            schema = ContextoInstitucionalSchema(**datos)

        except ValidationError as error:
            mensaje_usuario = self._mensaje_usuario_pydantic(error)

            print("[ERROR PYDANTIC]")
            print(mensaje_usuario)
            print("[DETALLE TÉCNICO]")
            print(self._mensaje_tecnico_pydantic(error))

            return f"ERROR|{mensaje_usuario}"

        contexto = mapear_contexto_institucional(schema)
        errores_dominio = validar_reglas_contexto_institucional(contexto)

        if errores_dominio:
            mensaje_usuario = errores_a_texto(errores_dominio)

            print("[ERROR DOMINIO]")
            print(mensaje_usuario)

            return f"ERROR|{mensaje_usuario}"

        self._guardar_configuracion_sede(schema)

        mensaje = mensaje_resultado(errores_dominio)

        print("[RESULTADO]")
        print(mensaje)
        print(f"[ARCHIVO] {self.config_path}")

        return f"OK|{mensaje}"

    @Slot(result="QVariantMap")
    def cargarConfiguracionSede(self) -> dict[str, Any]:
        """
        Carga la configuración institucional.

        No exige que la configuración esté completa, porque ahora se puede
        guardar por secciones.
        """

        print("\n" + "=" * 70)
        print("[CONFIGURACIÓN] Cargar configuración institucional")
        print("=" * 70)

        configuracion = self._leer_configuracion_sede()

        print("[DATOS ENVIADOS CORRECTAMENTE]")

        return configuracion

    # ============================================================
    # LECTURA / ESCRITURA
    # ============================================================

    def _leer_configuracion_sede(self) -> dict[str, Any]:
        if not self.config_path.exists():
            return self._configuracion_sede_vacia()

        try:
            with self.config_path.open("r", encoding="utf-8") as archivo:
                datos = json.load(archivo)

            return self._normalizar_configuracion_sede(datos)

        except Exception as error:
            print(f"[ERROR AL CARGAR CONFIGURACIÓN] {error}")
            return self._configuracion_sede_vacia()

    def _guardar_configuracion_sede(
        self,
        schema: ContextoInstitucionalSchema,
    ) -> None:
        datos = schema.model_dump(mode="json")
        self._guardar_diccionario_configuracion(datos)

    def _guardar_diccionario_configuracion(
        self,
        configuracion: dict[str, Any],
    ) -> None:
        self.config_dir.mkdir(parents=True, exist_ok=True)

        datos = self._normalizar_configuracion_sede(configuracion)

        with self.config_path.open("w", encoding="utf-8") as archivo:
            json.dump(datos, archivo, ensure_ascii=False, indent=4)

    def _configuracion_sede_vacia(self) -> dict[str, Any]:
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
            "fechaAutomatica": True,
            "edadAutomatica": True,
            "fechaActual": self._obtener_fecha_actual(),
        }

    def _normalizar_configuracion_sede(
        self,
        datos: dict[str, Any],
    ) -> dict[str, Any]:
        configuracion = self._configuracion_sede_vacia()

        configuracion["origen"] = str(datos.get("origen", "")).strip()
        configuracion["nombre_sede"] = str(datos.get("nombre_sede", "")).strip()

        ubicacion = datos.get("ubicacion", {}) or {}

        configuracion["ubicacion"] = {
            "municipio": str(ubicacion.get("municipio", "")).strip(),
            "localidad": str(ubicacion.get("localidad", "")).strip(),
            "barrio": str(ubicacion.get("barrio", "")).strip(),
        }

        coordinador = datos.get("coordinador", {}) or {}
        rol_coordinador = coordinador.get("rol", {}) or {}

        configuracion["coordinador"] = {
            "nombre": str(coordinador.get("nombre", "")).strip(),
            "apellido": str(coordinador.get("apellido", "")).strip(),
            "rol": {
                "nombre": str(rol_coordinador.get("nombre", "")).strip(),
                "siglas": str(rol_coordinador.get("siglas", "")).strip(),
            },
        }

        profesionales = datos.get("profesionales", []) or []
        profesionales_normalizados: list[dict[str, Any]] = []

        if isinstance(profesionales, list):
            for profesional in profesionales:
                if not isinstance(profesional, dict):
                    continue

                rol = profesional.get("rol", {}) or {}

                profesionales_normalizados.append({
                    "nombre": str(profesional.get("nombre", "")).strip(),
                    "apellido": str(profesional.get("apellido", "")).strip(),
                    "rol": {
                        "nombre": str(rol.get("nombre", "")).strip(),
                        "siglas": str(rol.get("siglas", "")).strip(),
                    },
                })

        configuracion["profesionales"] = profesionales_normalizados

        configuracion["fechaAutomatica"] = bool(
            datos.get("fechaAutomatica", True)
        )
        configuracion["edadAutomatica"] = bool(
            datos.get("edadAutomatica", True)
        )
        configuracion["fechaActual"] = str(
            datos.get("fechaActual", self._obtener_fecha_actual())
        ).strip()

        return configuracion

    def _normalizar_datos_sede_recibidos(
        self,
        datos: dict[str, Any],
    ) -> dict[str, Any]:
        """
        Acepta estructura nueva y también algunos nombres antiguos por seguridad.
        """

        ubicacion = datos.get("ubicacion", {}) or {}

        return {
            "origen": str(datos.get("origen", "")).strip(),
            "nombre_sede": str(
                datos.get("nombre_sede", datos.get("nombreSede", ""))
            ).strip(),
            "ubicacion": {
                "municipio": str(
                    ubicacion.get("municipio", datos.get("municipio", ""))
                ).strip(),
                "localidad": str(
                    ubicacion.get("localidad", datos.get("localidad", ""))
                ).strip(),
                "barrio": str(
                    ubicacion.get("barrio", datos.get("barrio", ""))
                ).strip(),
            },
        }

    def _obtener_fecha_actual(self) -> str:
        return date.today().strftime("%d/%m/%Y")

    # ============================================================
    # DUPLICADOS / CLAVES
    # ============================================================

    def _clave_profesional(
        self,
        profesional: dict[str, Any],
    ) -> str:
        rol = profesional.get("rol", {}) or {}

        partes = [
            profesional.get("nombre", ""),
            profesional.get("apellido", ""),
            rol.get("nombre", ""),
        ]

        return "|".join(self._normalizar_texto_clave(parte) for parte in partes)

    def _normalizar_texto_clave(self, valor: Any) -> str:
        texto = str(valor).strip().lower()

        texto = unicodedata.normalize("NFD", texto)
        texto = "".join(
            caracter
            for caracter in texto
            if unicodedata.category(caracter) != "Mn"
        )

        return texto

    # ============================================================
    # FORMATO DE ERRORES PYDANTIC
    # ============================================================

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

    def _mensaje_tecnico_pydantic(self, error: ValidationError) -> str:
        mensajes: list[str] = []

        for detalle in error.errors():
            campo = self._obtener_campo_error(detalle)
            contexto = detalle.get("ctx") or {}
            mensaje_tecnico = str(contexto.get("mensaje_tecnico", "")).strip()

            if mensaje_tecnico:
                mensajes.append(f"{campo}: {mensaje_tecnico}")
            else:
                mensajes.append(str(detalle))

        return "\n".join(mensajes)

    def _obtener_campo_error(self, detalle_error: dict[str, Any]) -> str:
        ubicacion = detalle_error.get("loc", [])

        return " → ".join(str(parte) for parte in ubicacion)



# # app_jade / CORE / controladores / controlador_configuracion.py

# from __future__ import annotations

# import json
# import unicodedata
# from datetime import date
# from pathlib import Path
# from typing import Any

# from pydantic import BaseModel, ValidationError, field_validator
# from PySide6.QtCore import QObject, Slot

# from CORE.dominio.errores import (
#     errores_a_texto,
#     mensaje_resultado,
# )
# from CORE.dominio.reglas import validar_reglas_contexto_institucional
# from CORE.mapeadores.mapeador_dominio import mapear_contexto_institucional
# from CORE.schemas.base_schema import (
#     UbicacionSchema,
#     PATRON_TEXTO_PERSONA,
#     PATRON_TEXTO_CON_NUMEROS,
#     validar_texto_obligatorio,
#     validar_patron,
# )
# from CORE.schemas.contexto_institucional_schema import ContextoInstitucionalSchema
# from CORE.schemas.personas_schema import PersonalInstitucionalSchema


# # ============================================================
# # SCHEMAS INTERNOS DEL CONTROLADOR
# # ============================================================

# class DatosSedeSchema(BaseModel):
#     origen: str
#     nombre_sede: str
#     ubicacion: UbicacionSchema

#     @field_validator("origen")
#     @classmethod
#     def validar_origen(cls, valor: str) -> str:
#         valor = validar_texto_obligatorio(valor, "Origen")

#         return validar_patron(
#             valor=valor,
#             patron=PATRON_TEXTO_PERSONA,
#             mensaje_usuario="Origen: solo permite letras, acentos y espacios.",
#             mensaje_tecnico=(
#                 f"DatosSedeSchema.origen recibió '{valor}'. "
#                 "Patrón esperado: letras, acentos y espacios."
#             ),
#         )

#     @field_validator("nombre_sede")
#     @classmethod
#     def validar_nombre_sede(cls, valor: str) -> str:
#         valor = validar_texto_obligatorio(valor, "Nombre de sede")

#         return validar_patron(
#             valor=valor,
#             patron=PATRON_TEXTO_CON_NUMEROS,
#             mensaje_usuario="Nombre de sede: solo permite letras, números, acentos y espacios.",
#             mensaje_tecnico=(
#                 f"DatosSedeSchema.nombre_sede recibió '{valor}'. "
#                 "Patrón esperado: letras, números, acentos y espacios."
#             ),
#         )


# # ============================================================
# # CONTROLADOR
# # ============================================================

# class ControladorConfiguracion(QObject):
#     """
#     Controlador para configuración institucional.

#     Trabaja con la estructura nueva:

#     {
#         "origen": "...",
#         "nombre_sede": "...",
#         "ubicacion": {
#             "municipio": "...",
#             "localidad": "...",
#             "barrio": ""
#         },
#         "coordinador": {
#             "nombre": "...",
#             "apellido": "...",
#             "rol": {
#                 "nombre": "...",
#                 "siglas": "..."
#             }
#         },
#         "profesionales": [
#             {
#                 "nombre": "...",
#                 "apellido": "...",
#                 "rol": {
#                     "nombre": "...",
#                     "siglas": "..."
#                 }
#             }
#         ],
#         "fechaAutomatica": true,
#         "edadAutomatica": true,
#         "fechaActual": "23/05/2026"
#     }
#     """

#     def __init__(self) -> None:
#         super().__init__()

#         self.base_dir = Path(__file__).resolve().parent.parent.parent
#         self.config_dir = self.base_dir / "config"

#         self.config_path = self.config_dir / "configuracion_sede_v2.json"

#         self.config_dir.mkdir(parents=True, exist_ok=True)

#     # ============================================================
#     # API QML - GUARDADO POR SECCIONES
#     # ============================================================

#     @Slot("QVariantMap", result=str)
#     def guardarDatosSede(self, datos: dict[str, Any]) -> str:
#         """
#         Guarda solo la sección de datos de sede / ubicación.

#         No valida coordinador.
#         No valida profesionales.
#         """

#         print("\n" + "=" * 70)
#         print("[CONFIGURACIÓN] Guardar datos de sede")
#         print("=" * 70)
#         print("[DATOS RECIBIDOS CORRECTAMENTE]")

#         try:
#             datos_sede = self._normalizar_datos_sede_recibidos(datos)
#             schema = DatosSedeSchema(**datos_sede)

#         except ValidationError as error:
#             mensaje_usuario = self._mensaje_usuario_pydantic(error)

#             print("[ERROR PYDANTIC]")
#             print(mensaje_usuario)
#             print("[DETALLE TÉCNICO]")
#             print(self._mensaje_tecnico_pydantic(error))

#             return f"ERROR|{mensaje_usuario}"

#         configuracion = self._leer_configuracion_sede()
#         configuracion["origen"] = schema.origen
#         configuracion["nombre_sede"] = schema.nombre_sede
#         configuracion["ubicacion"] = schema.ubicacion.model_dump(mode="json")

#         self._guardar_diccionario_configuracion(configuracion)

#         mensaje = mensaje_resultado([])

#         print("[RESULTADO]")
#         print(mensaje)

#         return f"OK|{mensaje}"

#     @Slot("QVariantMap", result=str)
#     def agregarProfesional(self, datos: dict[str, Any]) -> str:
#         """
#         Valida un profesional individual y lo agrega a la lista.
#         Si es inválido, no se agrega.
#         """

#         print("\n" + "=" * 70)
#         print("[CONFIGURACIÓN] Agregar profesional")
#         print("=" * 70)
#         print("[DATOS RECIBIDOS CORRECTAMENTE]")

#         try:
#             profesional = PersonalInstitucionalSchema(**datos)

#         except ValidationError as error:
#             mensaje_usuario = self._mensaje_usuario_pydantic(error)

#             print("[ERROR PYDANTIC]")
#             print(mensaje_usuario)
#             print("[DETALLE TÉCNICO]")
#             print(self._mensaje_tecnico_pydantic(error))

#             return f"ERROR|{mensaje_usuario}"

#         configuracion = self._leer_configuracion_sede()
#         profesionales = list(configuracion.get("profesionales", []))

#         clave_nueva = self._clave_profesional(profesional.model_dump(mode="json"))

#         for profesional_existente in profesionales:
#             if self._clave_profesional(profesional_existente) == clave_nueva:
#                 mensaje = "Profesionales: ese profesional ya fue agregado."

#                 print("[ERROR DOMINIO]")
#                 print(mensaje)

#                 return f"ERROR|{mensaje}"

#         profesionales.append(profesional.model_dump(mode="json"))
#         configuracion["profesionales"] = profesionales

#         self._guardar_diccionario_configuracion(configuracion)

#         mensaje = mensaje_resultado([])

#         print("[RESULTADO]")
#         print(mensaje)

#         return f"OK|{mensaje}"

#     @Slot(int, result=str)
#     def eliminarProfesional(self, indice: int) -> str:
#         """
#         Elimina un profesional puntual de la lista por índice.
#         """

#         print("\n" + "=" * 70)
#         print("[CONFIGURACIÓN] Eliminar profesional")
#         print("=" * 70)
#         print("[DATOS RECIBIDOS CORRECTAMENTE]")

#         configuracion = self._leer_configuracion_sede()
#         profesionales = list(configuracion.get("profesionales", []))

#         if indice < 0 or indice >= len(profesionales):
#             mensaje = "Profesionales: no se pudo eliminar el profesional seleccionado."

#             print("[ERROR]")
#             print(mensaje)

#             return f"ERROR|{mensaje}"

#         profesionales.pop(indice)
#         configuracion["profesionales"] = profesionales

#         self._guardar_diccionario_configuracion(configuracion)

#         mensaje = mensaje_resultado([])

#         print("[RESULTADO]")
#         print(mensaje)

#         return f"OK|{mensaje}"

#     @Slot("QVariantMap", result=str)
#     def guardarCoordinador(self, datos: dict[str, Any]) -> str:
#         """
#         Guarda solo la sección de coordinador/coordinadora.
#         """

#         print("\n" + "=" * 70)
#         print("[CONFIGURACIÓN] Guardar coordinador")
#         print("=" * 70)
#         print("[DATOS RECIBIDOS CORRECTAMENTE]")

#         try:
#             coordinador = PersonalInstitucionalSchema(**datos)

#         except ValidationError as error:
#             mensaje_usuario = self._mensaje_usuario_pydantic(error)

#             print("[ERROR PYDANTIC]")
#             print(mensaje_usuario)
#             print("[DETALLE TÉCNICO]")
#             print(self._mensaje_tecnico_pydantic(error))

#             return f"ERROR|{mensaje_usuario}"

#         configuracion = self._leer_configuracion_sede()
#         configuracion["coordinador"] = coordinador.model_dump(mode="json")

#         self._guardar_diccionario_configuracion(configuracion)

#         mensaje = mensaje_resultado([])

#         print("[RESULTADO]")
#         print(mensaje)

#         return f"OK|{mensaje}"

#     # ============================================================
#     # API QML - CONFIGURACIÓN AUTOMÁTICA
#     # ============================================================

#     @Slot("QVariantMap", result=str)
#     def guardarConfiguracionAutomatica(self, datos: dict[str, Any]) -> str:
#         try:
#             print("\n" + "=" * 70)
#             print("[CONFIGURACIÓN] Guardar configuración automática")
#             print("=" * 70)
#             print("[DATOS RECIBIDOS CORRECTAMENTE]")

#             configuracion = self._leer_configuracion_sede()

#             configuracion["fechaAutomatica"] = bool(
#                 datos.get("fechaAutomatica", True)
#             )
#             configuracion["edadAutomatica"] = bool(
#                 datos.get("edadAutomatica", True)
#             )
#             configuracion["fechaActual"] = str(
#                 datos.get("fechaActual", self.obtenerFechaActual())
#             ).strip()

#             self._guardar_diccionario_configuracion(configuracion)

#             mensaje = mensaje_resultado([])

#             print("[RESULTADO]")
#             print(mensaje)

#             return f"OK|{mensaje}"

#         except Exception as error:
#             return f"ERROR|No se pudo guardar la configuración automática: {error}"

#     @Slot(result="QVariantMap")
#     def cargarConfiguracionAutomatica(self) -> dict[str, Any]:
#         configuracion = self._leer_configuracion_sede()

#         fecha_automatica = bool(configuracion.get("fechaAutomatica", True))
#         edad_automatica = bool(configuracion.get("edadAutomatica", True))

#         if fecha_automatica:
#             fecha_actual = self.obtenerFechaActual()
#         else:
#             fecha_actual = str(
#                 configuracion.get("fechaActual", self.obtenerFechaActual())
#             ).strip()

#         print("\n" + "=" * 70)
#         print("[CONFIGURACIÓN] Cargar configuración automática")
#         print("=" * 70)
#         print("[DATOS ENVIADOS CORRECTAMENTE]")

#         return {
#             "fechaAutomatica": fecha_automatica,
#             "edadAutomatica": edad_automatica,
#             "fechaActual": fecha_actual,
#         }

#     @Slot(result=str)
#     def obtenerFechaActual(self) -> str:
#         return date.today().strftime("%d/%m/%Y")

#     # ============================================================
#     # API QML - GUARDADO COMPLETO / RESPALDO TEMPORAL
#     # ============================================================

#     @Slot("QVariantMap", result=str)
#     def guardarConfiguracionSede(self, datos: dict[str, Any]) -> str:
#         """
#         Guardado completo de configuración institucional.

#         Se mantiene como respaldo temporal para validar y guardar todo junto
#         si alguna parte de la interfaz todavía lo necesita.
#         """

#         print("\n" + "=" * 70)
#         print("[CONFIGURACIÓN] Guardar configuración institucional completa")
#         print("=" * 70)
#         print("[DATOS RECIBIDOS CORRECTAMENTE]")

#         try:
#             schema = ContextoInstitucionalSchema(**datos)

#         except ValidationError as error:
#             mensaje_usuario = self._mensaje_usuario_pydantic(error)

#             print("[ERROR PYDANTIC]")
#             print(mensaje_usuario)
#             print("[DETALLE TÉCNICO]")
#             print(self._mensaje_tecnico_pydantic(error))

#             return f"ERROR|{mensaje_usuario}"

#         contexto = mapear_contexto_institucional(schema)
#         errores_dominio = validar_reglas_contexto_institucional(contexto)

#         if errores_dominio:
#             mensaje_usuario = errores_a_texto(errores_dominio)

#             print("[ERROR DOMINIO]")
#             print(mensaje_usuario)

#             return f"ERROR|{mensaje_usuario}"

#         self._guardar_configuracion_sede(schema)

#         mensaje = mensaje_resultado(errores_dominio)

#         print("[RESULTADO]")
#         print(mensaje)
#         print(f"[ARCHIVO] {self.config_path}")

#         return f"OK|{mensaje}"

#     @Slot(result="QVariantMap")
#     def cargarConfiguracionSede(self) -> dict[str, Any]:
#         """
#         Carga la configuración institucional.

#         No exige que la configuración esté completa, porque ahora se puede
#         guardar por secciones.
#         """

#         print("\n" + "=" * 70)
#         print("[CONFIGURACIÓN] Cargar configuración institucional")
#         print("=" * 70)

#         configuracion = self._leer_configuracion_sede()

#         print("[DATOS ENVIADOS CORRECTAMENTE]")

#         return configuracion

#     # ============================================================
#     # LECTURA / ESCRITURA
#     # ============================================================

#     def _leer_configuracion_sede(self) -> dict[str, Any]:
#         if not self.config_path.exists():
#             return self._configuracion_sede_vacia()

#         try:
#             with self.config_path.open("r", encoding="utf-8") as archivo:
#                 datos = json.load(archivo)

#             return self._normalizar_configuracion_sede(datos)

#         except Exception as error:
#             print(f"[ERROR AL CARGAR CONFIGURACIÓN] {error}")
#             return self._configuracion_sede_vacia()

#     def _guardar_configuracion_sede(
#         self,
#         schema: ContextoInstitucionalSchema,
#     ) -> None:
#         datos = schema.model_dump(mode="json")
#         self._guardar_diccionario_configuracion(datos)

#     def _guardar_diccionario_configuracion(
#         self,
#         configuracion: dict[str, Any],
#     ) -> None:
#         self.config_dir.mkdir(parents=True, exist_ok=True)

#         datos = self._normalizar_configuracion_sede(configuracion)

#         with self.config_path.open("w", encoding="utf-8") as archivo:
#             json.dump(datos, archivo, ensure_ascii=False, indent=4)

#     def _configuracion_sede_vacia(self) -> dict[str, Any]:
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
#             "fechaAutomatica": True,
#             "edadAutomatica": True,
#             "fechaActual": self._obtener_fecha_actual(),
#         }

#     def _normalizar_configuracion_sede(
#         self,
#         datos: dict[str, Any],
#     ) -> dict[str, Any]:
#         configuracion = self._configuracion_sede_vacia()

#         configuracion["origen"] = str(datos.get("origen", "")).strip()
#         configuracion["nombre_sede"] = str(datos.get("nombre_sede", "")).strip()

#         ubicacion = datos.get("ubicacion", {}) or {}

#         configuracion["ubicacion"] = {
#             "municipio": str(ubicacion.get("municipio", "")).strip(),
#             "localidad": str(ubicacion.get("localidad", "")).strip(),
#             "barrio": str(ubicacion.get("barrio", "")).strip(),
#         }

#         coordinador = datos.get("coordinador", {}) or {}
#         rol_coordinador = coordinador.get("rol", {}) or {}

#         configuracion["coordinador"] = {
#             "nombre": str(coordinador.get("nombre", "")).strip(),
#             "apellido": str(coordinador.get("apellido", "")).strip(),
#             "rol": {
#                 "nombre": str(rol_coordinador.get("nombre", "")).strip(),
#                 "siglas": str(rol_coordinador.get("siglas", "")).strip(),
#             },
#         }

#         profesionales = datos.get("profesionales", []) or []
#         profesionales_normalizados: list[dict[str, Any]] = []

#         if isinstance(profesionales, list):
#             for profesional in profesionales:
#                 if not isinstance(profesional, dict):
#                     continue

#                 rol = profesional.get("rol", {}) or {}

#                 profesionales_normalizados.append({
#                     "nombre": str(profesional.get("nombre", "")).strip(),
#                     "apellido": str(profesional.get("apellido", "")).strip(),
#                     "rol": {
#                         "nombre": str(rol.get("nombre", "")).strip(),
#                         "siglas": str(rol.get("siglas", "")).strip(),
#                     },
#                 })

#         configuracion["profesionales"] = profesionales_normalizados

#         configuracion["fechaAutomatica"] = bool(
#             datos.get("fechaAutomatica", True)
#         )
#         configuracion["edadAutomatica"] = bool(
#             datos.get("edadAutomatica", True)
#         )
#         configuracion["fechaActual"] = str(
#             datos.get("fechaActual", self._obtener_fecha_actual())
#         ).strip()

#         return configuracion

#     def _normalizar_datos_sede_recibidos(
#         self,
#         datos: dict[str, Any],
#     ) -> dict[str, Any]:
#         """
#         Acepta estructura nueva y también algunos nombres antiguos por seguridad.
#         """

#         ubicacion = datos.get("ubicacion", {}) or {}

#         return {
#             "origen": str(datos.get("origen", "")).strip(),
#             "nombre_sede": str(
#                 datos.get("nombre_sede", datos.get("nombreSede", ""))
#             ).strip(),
#             "ubicacion": {
#                 "municipio": str(
#                     ubicacion.get("municipio", datos.get("municipio", ""))
#                 ).strip(),
#                 "localidad": str(
#                     ubicacion.get("localidad", datos.get("localidad", ""))
#                 ).strip(),
#                 "barrio": str(
#                     ubicacion.get("barrio", datos.get("barrio", ""))
#                 ).strip(),
#             },
#         }

#     def _obtener_fecha_actual(self) -> str:
#         return date.today().strftime("%d/%m/%Y")

#     # ============================================================
#     # DUPLICADOS / CLAVES
#     # ============================================================

#     def _clave_profesional(
#         self,
#         profesional: dict[str, Any],
#     ) -> str:
#         rol = profesional.get("rol", {}) or {}

#         partes = [
#             profesional.get("nombre", ""),
#             profesional.get("apellido", ""),
#             rol.get("nombre", ""),
#         ]

#         return "|".join(self._normalizar_texto_clave(parte) for parte in partes)

#     def _normalizar_texto_clave(self, valor: Any) -> str:
#         texto = str(valor).strip().lower()

#         texto = unicodedata.normalize("NFD", texto)
#         texto = "".join(
#             caracter
#             for caracter in texto
#             if unicodedata.category(caracter) != "Mn"
#         )

#         return texto

#     # ============================================================
#     # FORMATO DE ERRORES PYDANTIC
#     # ============================================================

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

#     def _mensaje_tecnico_pydantic(self, error: ValidationError) -> str:
#         mensajes: list[str] = []

#         for detalle in error.errors():
#             campo = self._obtener_campo_error(detalle)
#             contexto = detalle.get("ctx") or {}
#             mensaje_tecnico = str(contexto.get("mensaje_tecnico", "")).strip()

#             if mensaje_tecnico:
#                 mensajes.append(f"{campo}: {mensaje_tecnico}")
#             else:
#                 mensajes.append(str(detalle))

#         return "\n".join(mensajes)

#     def _obtener_campo_error(self, detalle_error: dict[str, Any]) -> str:
#         ubicacion = detalle_error.get("loc", [])

#         return " → ".join(str(parte) for parte in ubicacion)

