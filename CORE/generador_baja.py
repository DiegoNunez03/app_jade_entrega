from __future__ import annotations

from pathlib import Path
from typing import Any

from docx import Document


# ============================================================
# API PRINCIPAL
# ============================================================

def generar_solicitud_baja(
    datos: dict[str, Any],
    ruta_docx: Path,
    ruta_odt: Path | None = None,
) -> None:
    """
    Genera la solicitud de baja usando una plantilla DOCX.

    La plantilla debe estar en:
    templates/solicitud_baja_plantilla.docx

    ruta_odt queda como argumento opcional para mantener compatibilidad,
    pero en esta versión no se genera ODT.
    """

    ruta_docx = Path(ruta_docx)
    ruta_docx.parent.mkdir(parents=True, exist_ok=True)

    ruta_plantilla = _obtener_ruta_plantilla()

    if not ruta_plantilla.exists():
        raise FileNotFoundError(
            f"No se encontró la plantilla de baja en: {ruta_plantilla}"
        )

    documento = Document(ruta_plantilla)

    reemplazos = _crear_reemplazos(datos)

    _reemplazar_marcadores_documento(documento, reemplazos)

    documento.save(ruta_docx)


# ============================================================
# RUTAS
# ============================================================

def _obtener_ruta_plantilla() -> Path:
    base_dir = Path(__file__).resolve().parent.parent
    return base_dir / "templates" / "solicitud_baja_plantilla.docx"


# ============================================================
# REEMPLAZOS
# ============================================================

def _texto(valor: Any, fallback: str = "") -> str:
    if valor is None:
        return fallback

    texto = str(valor).strip()
    return texto if texto else fallback


def _tachar_texto(texto: str) -> str:
    """
    Tacha texto usando el carácter Unicode de tachado combinado.
    Evita tener que manipular formato interno de Word.
    """
    return "".join(caracter + "\u0336" for caracter in texto)


def _crear_opcion_tachada(tipo_beneficiario: str) -> str:
    tipo = _texto(tipo_beneficiario)

    if tipo == "Destinatario":
        return f"Destinatario / {_tachar_texto('Tutor')}"

    if tipo == "Tutor":
        return f"{_tachar_texto('Destinatario')} / Tutor"

    return "Destinatario / Tutor"


def _crear_opcion_responsable_informado(valor: str) -> str:
    informado = _texto(valor)

    if informado in {"Sí", "Si"}:
        return "Sí"

    if informado == "No":
        return "No"

    return informado


def _crear_reemplazos(datos: dict[str, Any]) -> dict[str, str]:
    motivo = _texto(datos.get("bajaMotivo"))

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

    reemplazos = {
        "{{NOMBRE_SEDE}}": _crear_nombre_sede(datos),
        "{{TIPO_MODALIDAD}}": _texto(datos.get("modalidad")),
        "{{NOMBRE_PROFESIONAL}}": _texto(datos.get("profesionalesIntervinientesTexto")),
        "{{NOMBRE_COORDINADORA}}": _texto(datos.get("coordinadora")),
        "{{FECHA_ACTUAL}}": _texto(datos.get("fechaBaja")),

        "{{OPCION_TACHADA}}": _crear_opcion_tachada(
            _texto(datos.get("bajaTipoBeneficiario"))
        ),

        "{{NOMBRE_COMPLETO_BENEFICIARIO}}": _texto(
            datos.get("bajaNombreCompleto")
        ),
        "{{NRO_DNI}}": _crear_tipo_y_dni(datos),
        "{{FECHA_INGRESO}}": _texto(datos.get("bajaFechaIngreso")),

        "{{NOMBRE_COMPLETO_RESPONSABLE_ADULTO}}": _texto(
            datos.get("bajaResponsableNombreCompleto")
        ),
        "{{RELACION}}": _texto(datos.get("bajaResponsableRelacion")),
        "{{OPCION}}": _crear_opcion_responsable_informado(
            _texto(datos.get("bajaResponsableInformado"))
        ),
    }

    for indice, motivo_actual in enumerate(motivos, start=1):
        reemplazos[f"{{{{marca_{indice}}}}}"] = "X" if motivo == motivo_actual else ""

    return reemplazos


def _crear_nombre_sede(datos: dict[str, Any]) -> str:
    centro = _texto(datos.get("centroEnvion"))
    sede = _texto(datos.get("sede"))

    if centro and sede:
        return f"{centro}: {sede}"

    if sede:
        return sede

    return centro


def _crear_tipo_y_dni(datos: dict[str, Any]) -> str:
    tipo_dni = _texto(datos.get("bajaTipoDni"), "DNI")
    dni = _texto(datos.get("bajaDni"))

    if tipo_dni and dni:
        return f"{tipo_dni} {dni}"

    return dni or tipo_dni


# ============================================================
# REEMPLAZO EN DOCUMENTO
# ============================================================

def _reemplazar_marcadores_documento(
    documento: Document,
    reemplazos: dict[str, str],
) -> None:
    """
    Reemplaza marcadores en:
    - cuerpo principal;
    - tablas del cuerpo;
    - encabezados;
    - pies de página.
    """

    # Cuerpo principal
    _reemplazar_marcadores_en_contenedor(documento, reemplazos)

    # Encabezados y pies de página
    for section in documento.sections:
        _reemplazar_marcadores_en_contenedor(section.header, reemplazos)
        _reemplazar_marcadores_en_contenedor(section.footer, reemplazos)


def _reemplazar_marcadores_en_contenedor(
    contenedor,
    reemplazos: dict[str, str],
) -> None:
    for parrafo in contenedor.paragraphs:
        _reemplazar_marcadores_en_parrafo(parrafo, reemplazos)

    for tabla in contenedor.tables:
        for fila in tabla.rows:
            for celda in fila.cells:
                for parrafo in celda.paragraphs:
                    _reemplazar_marcadores_en_parrafo(parrafo, reemplazos)


def _reemplazar_marcadores_en_parrafo(
    parrafo,
    reemplazos: dict[str, str],
) -> None:
    """
    Reemplazo simple conservando el formato del primer run del párrafo.

    Para esta plantilla alcanza porque los marcadores están escritos completos.
    Si Google Docs parte internamente algún marcador en varios runs,
    este método reconstruye el texto completo del párrafo.
    """

    texto_original = "".join(run.text for run in parrafo.runs)

    if not texto_original:
        return

    texto_nuevo = texto_original

    for marcador, valor in reemplazos.items():
        texto_nuevo = texto_nuevo.replace(marcador, valor)

    if texto_nuevo == texto_original:
        return

    # Conserva el formato base del primer run y limpia el resto.
    if parrafo.runs:
        parrafo.runs[0].text = texto_nuevo

        for run in parrafo.runs[1:]:
            run.text = ""




# from __future__ import annotations

# from pathlib import Path
# from typing import Any

# from docx import Document


# # ============================================================
# # API PRINCIPAL
# # ============================================================

# def generar_solicitud_baja(
#     datos: dict[str, Any],
#     ruta_docx: Path,
#     ruta_odt: Path | None = None,
# ) -> None:
#     """
#     Genera la solicitud de baja usando una plantilla DOCX.

#     La plantilla debe estar en:
#     templates/solicitud_baja_plantilla.docx

#     ruta_odt queda como argumento opcional para mantener compatibilidad,
#     pero en esta versión no se genera ODT.
#     """

#     ruta_docx = Path(ruta_docx)
#     ruta_docx.parent.mkdir(parents=True, exist_ok=True)

#     ruta_plantilla = _obtener_ruta_plantilla()

#     if not ruta_plantilla.exists():
#         raise FileNotFoundError(
#             f"No se encontró la plantilla de baja en: {ruta_plantilla}"
#         )

#     documento = Document(ruta_plantilla)

#     reemplazos = _crear_reemplazos(datos)

#     _reemplazar_marcadores_documento(documento, reemplazos)

#     documento.save(ruta_docx)


# # ============================================================
# # RUTAS
# # ============================================================

# def _obtener_ruta_plantilla() -> Path:
#     base_dir = Path(__file__).resolve().parent.parent
#     return base_dir / "templates" / "solicitud_baja_plantilla.docx"


# # ============================================================
# # REEMPLAZOS
# # ============================================================

# def _texto(valor: Any, fallback: str = "") -> str:
#     if valor is None:
#         return fallback

#     texto = str(valor).strip()
#     return texto if texto else fallback


# def _tachar_texto(texto: str) -> str:
#     """
#     Tacha texto usando el carácter Unicode de tachado combinado.
#     Evita tener que manipular formato interno de Word.
#     """
#     return "".join(caracter + "\u0336" for caracter in texto)


# def _crear_opcion_tachada(tipo_beneficiario: str) -> str:
#     tipo = _texto(tipo_beneficiario)

#     if tipo == "Destinatario":
#         return f"Destinatario / {_tachar_texto('Tutor')}"

#     if tipo == "Tutor":
#         return f"{_tachar_texto('Destinatario')} / Tutor"

#     return "Destinatario / Tutor"


# def _crear_opcion_responsable_informado(valor: str) -> str:
#     informado = _texto(valor)

#     if informado in {"Sí", "Si"}:
#         return "Sí"

#     if informado == "No":
#         return "No"

#     return informado


# def _crear_reemplazos(datos: dict[str, Any]) -> dict[str, str]:
#     motivo = _texto(datos.get("bajaMotivo"))

#     motivos = [
#         "Encontrarse privado de la libertad",
#         "Fallecimiento",
#         "Haber cumplimentado con todos los acuerdos para su egreso",
#         "Liquidaciones consecutivas impagas",
#         "Mudanza a otro Municipio",
#         "Negativa a cumplir con su Acuerdo de Compromiso",
#         "Negativa del Joven a participar",
#         "Negativa o dificultades al momento de la socialización",
#         "Pase de Destinatario a Tutor",
#         "Pase de Tutor a Destinatario",
#         "Trabajo Formal",
#         "Otros motivos",
#     ]

#     reemplazos = {
#         "{{NOMBRE_SEDE}}": _crear_nombre_sede(datos),
#         "{{TIPO_MODALIDAD}}": _texto(datos.get("modalidad")),
#         "{{NOMBRE_PROFESIONAL}}": _texto(datos.get("profesionalesIntervinientesTexto")),
#         "{{NOMBRE_COORDINADORA}}": _texto(datos.get("coordinadora")),
#         "{{FECHA_ACTUAL}}": _texto(datos.get("fechaBaja")),

#         "{{OPCION_TACHADA}}": _crear_opcion_tachada(
#             _texto(datos.get("bajaTipoBeneficiario"))
#         ),

#         "{{NOMBRE_COMPLETO_BENEFICIARIO}}": _texto(
#             datos.get("bajaNombreCompleto")
#         ),
#         "{{NRO_DNI}}": _crear_tipo_y_dni(datos),
#         "{{FECHA_INGRESO}}": _texto(datos.get("bajaFechaIngreso")),

#         "{{NOMBRE_COMPLETO_RESPONSABLE_ADULTO}}": _texto(
#             datos.get("bajaResponsableNombreCompleto")
#         ),
#         "{{RELACION}}": _texto(datos.get("bajaResponsableRelacion")),
#         "{{OPCION}}": _crear_opcion_responsable_informado(
#             _texto(datos.get("bajaResponsableInformado"))
#         ),
#     }

#     for indice, motivo_actual in enumerate(motivos, start=1):
#         reemplazos[f"{{{{marca_{indice}}}}}"] = "X" if motivo == motivo_actual else ""

#     return reemplazos


# def _crear_nombre_sede(datos: dict[str, Any]) -> str:
#     centro = _texto(datos.get("centroEnvion"))
#     sede = _texto(datos.get("sede"))

#     if centro and sede:
#         return f"{centro}: {sede}"

#     if sede:
#         return sede

#     return centro


# def _crear_tipo_y_dni(datos: dict[str, Any]) -> str:
#     tipo_dni = _texto(datos.get("bajaTipoDni"), "DNI")
#     dni = _texto(datos.get("bajaDni"))

#     if tipo_dni and dni:
#         return f"{tipo_dni} {dni}"

#     return dni or tipo_dni


# # ============================================================
# # REEMPLAZO EN DOCUMENTO
# # ============================================================

# def _reemplazar_marcadores_documento(
#     documento: Document,
#     reemplazos: dict[str, str],
# ) -> None:
#     for parrafo in documento.paragraphs:
#         _reemplazar_marcadores_en_parrafo(parrafo, reemplazos)

#     for tabla in documento.tables:
#         for fila in tabla.rows:
#             for celda in fila.cells:
#                 for parrafo in celda.paragraphs:
#                     _reemplazar_marcadores_en_parrafo(parrafo, reemplazos)


# def _reemplazar_marcadores_en_parrafo(
#     parrafo,
#     reemplazos: dict[str, str],
# ) -> None:
#     """
#     Reemplazo simple conservando el formato del primer run del párrafo.

#     Para esta plantilla alcanza porque los marcadores están escritos completos.
#     Si Google Docs parte internamente algún marcador en varios runs,
#     este método igual reconstruye el texto completo del párrafo.
#     """

#     texto_original = "".join(run.text for run in parrafo.runs)

#     if not texto_original:
#         return

#     texto_nuevo = texto_original

#     for marcador, valor in reemplazos.items():
#         texto_nuevo = texto_nuevo.replace(marcador, valor)

#     if texto_nuevo == texto_original:
#         return

#     # Conserva el formato base del primer run y limpia el resto.
#     if parrafo.runs:
#         parrafo.runs[0].text = texto_nuevo

#         for run in parrafo.runs[1:]:
#             run.text = ""


# # app_jade / CORE / generador_baja.py

# from __future__ import annotations

# from pathlib import Path
# from typing import Any

# from docx import Document
# from docx.enum.section import WD_SECTION
# from docx.enum.table import WD_CELL_VERTICAL_ALIGNMENT, WD_TABLE_ALIGNMENT
# from docx.enum.text import WD_ALIGN_PARAGRAPH
# from docx.shared import Cm, Pt, RGBColor


# # ============================================================
# # API PRINCIPAL
# # ============================================================

# def generar_solicitud_baja(
#     datos: dict[str, Any],
#     ruta_docx: Path,
#     ruta_odt: Path | None = None,
# ) -> None:
#     """
#     Genera la solicitud de baja en formato DOCX desde cero.

#     ruta_odt queda como argumento opcional para compatibilidad con el
#     controlador, pero en esta versión no se genera ODT.
#     """

#     ruta_docx = Path(ruta_docx)
#     ruta_docx.parent.mkdir(parents=True, exist_ok=True)

#     documento = Document()

#     _configurar_documento(documento)
#     _configurar_estilos_base(documento)

#     _agregar_encabezado(documento, datos)
#     _agregar_titulo(documento)
#     _agregar_datos_institucionales(documento, datos)
#     _agregar_datos_beneficiario(documento, datos)
#     _agregar_responsable_adulto(documento, datos)
#     _agregar_motivos(documento, datos)
#     _agregar_firmas(documento)
#     _agregar_pie_documental(documento)

#     documento.save(ruta_docx)


# # ============================================================
# # CONFIGURACIÓN GENERAL
# # ============================================================

# def _configurar_documento(documento: Document) -> None:
#     section = documento.sections[0]

#     section.page_width = Cm(21)
#     section.page_height = Cm(29.7)

#     section.top_margin = Cm(1.2)
#     section.bottom_margin = Cm(1.2)
#     section.left_margin = Cm(1.5)
#     section.right_margin = Cm(1.5)

#     section.header_distance = Cm(0.5)
#     section.footer_distance = Cm(0.5)


# def _configurar_estilos_base(documento: Document) -> None:
#     styles = documento.styles

#     normal = styles["Normal"]
#     normal.font.name = "Arial"
#     normal.font.size = Pt(9)

#     for style_name in ["Header", "Footer"]:
#         style = styles[style_name]
#         style.font.name = "Arial"
#         style.font.size = Pt(8)


# # ============================================================
# # HELPERS VISUALES
# # ============================================================

# def _texto(valor: Any, fallback: str = "") -> str:
#     if valor is None:
#         return fallback

#     texto = str(valor).strip()
#     return texto if texto else fallback


# def _agregar_parrafo(
#     documento: Document,
#     texto: str = "",
#     bold: bool = False,
#     size: int = 9,
#     align: int | None = None,
#     underline: bool = False,
# ) -> Any:
#     parrafo = documento.add_paragraph()

#     if align is not None:
#         parrafo.alignment = align

#     run = parrafo.add_run(texto)
#     run.bold = bold
#     run.underline = underline
#     run.font.name = "Arial"
#     run.font.size = Pt(size)

#     return parrafo


# def _set_cell_text(
#     cell,
#     texto: str,
#     bold: bool = False,
#     size: int = 8,
#     align: int = WD_ALIGN_PARAGRAPH.LEFT,
# ) -> None:
#     cell.text = ""

#     parrafo = cell.paragraphs[0]
#     parrafo.alignment = align
#     parrafo.paragraph_format.space_after = Pt(0)
#     parrafo.paragraph_format.space_before = Pt(0)

#     run = parrafo.add_run(texto)
#     run.bold = bold
#     run.font.name = "Arial"
#     run.font.size = Pt(size)

#     cell.vertical_alignment = WD_CELL_VERTICAL_ALIGNMENT.CENTER


# def _set_cell_shading(cell, fill: str) -> None:
#     """
#     Sombreado simple de celda.
#     fill ejemplo: "EDEDED"
#     """
#     from docx.oxml import OxmlElement
#     from docx.oxml.ns import qn

#     tc_pr = cell._tc.get_or_add_tcPr()
#     shading = OxmlElement("w:shd")
#     shading.set(qn("w:fill"), fill)
#     tc_pr.append(shading)


# def _set_cell_width(cell, width_cm: float) -> None:
#     cell.width = Cm(width_cm)


# def _set_table_borders(table) -> None:
#     """
#     Bordes finos para toda la tabla.
#     """
#     from docx.oxml import OxmlElement
#     from docx.oxml.ns import qn

#     tbl = table._tbl
#     tbl_pr = tbl.tblPr

#     borders = tbl_pr.first_child_found_in("w:tblBorders")

#     if borders is None:
#         borders = OxmlElement("w:tblBorders")
#         tbl_pr.append(borders)

#     for border_name in ["top", "left", "bottom", "right", "insideH", "insideV"]:
#         border = borders.find(qn(f"w:{border_name}"))

#         if border is None:
#             border = OxmlElement(f"w:{border_name}")
#             borders.append(border)

#         border.set(qn("w:val"), "single")
#         border.set(qn("w:sz"), "6")
#         border.set(qn("w:space"), "0")
#         border.set(qn("w:color"), "000000")


# def _aplicar_alto_fila(row, alto_cm: float) -> None:
#     tr_pr = row._tr.get_or_add_trPr()

#     from docx.oxml import OxmlElement
#     from docx.oxml.ns import qn

#     tr_height = OxmlElement("w:trHeight")
#     tr_height.set(qn("w:val"), str(int(alto_cm * 567)))
#     tr_height.set(qn("w:hRule"), "atLeast")
#     tr_pr.append(tr_height)


# def _espacio(documento: Document, puntos: int = 4) -> None:
#     parrafo = documento.add_paragraph()
#     parrafo.paragraph_format.space_after = Pt(puntos)
#     parrafo.paragraph_format.space_before = Pt(0)


# # ============================================================
# # ENCABEZADO Y TÍTULO
# # ============================================================

# def _agregar_encabezado(documento: Document, datos: dict[str, Any]) -> None:
#     """
#     Encabezado visual sin logos reales todavía.

#     Cuando tengas las tres imágenes, esta función se cambia para insertar:
#     - Buenos Aires Provincia
#     - Desarrollo Social / Ministerio
#     - Envión
#     """

#     tabla = documento.add_table(rows=1, cols=3)
#     tabla.alignment = WD_TABLE_ALIGNMENT.CENTER
#     tabla.autofit = True

#     c1, c2, c3 = tabla.rows[0].cells

#     _set_cell_text(c1, "BUENOS AIRES\nPROVINCIA", bold=True, size=8, align=WD_ALIGN_PARAGRAPH.CENTER)
#     _set_cell_text(c2, "DESARROLLO\nSOCIAL", bold=True, size=8, align=WD_ALIGN_PARAGRAPH.CENTER)
#     _set_cell_text(c3, "ENVION\nUna oportunidad de futuro", bold=True, size=8, align=WD_ALIGN_PARAGRAPH.CENTER)

#     for cell in [c1, c2, c3]:
#         for paragraph in cell.paragraphs:
#             for run in paragraph.runs:
#                 run.font.color.rgb = RGBColor(0, 0, 0)

#     _espacio(documento, 2)


# def _agregar_titulo(documento: Document) -> None:
#     parrafo = documento.add_paragraph()
#     parrafo.alignment = WD_ALIGN_PARAGRAPH.CENTER
#     parrafo.paragraph_format.space_before = Pt(4)
#     parrafo.paragraph_format.space_after = Pt(8)

#     run = parrafo.add_run("INFORME PARA SOLICITUD DE BAJA")
#     run.bold = True
#     run.underline = True
#     run.font.name = "Arial"
#     run.font.size = Pt(11)


# # ============================================================
# # SECCIONES DEL DOCUMENTO
# # ============================================================

# def _agregar_datos_institucionales(documento: Document, datos: dict[str, Any]) -> None:
#     centro = _texto(datos.get("centroEnvion"), "Centro Envión")
#     sede = _texto(datos.get("sede"))
#     modalidad = _texto(datos.get("modalidad"))
#     profesionales = _texto(datos.get("profesionalesIntervinientesTexto"))
#     coordinadora = _texto(datos.get("coordinadora"))
#     fecha_baja = _texto(datos.get("fechaBaja"))

#     tabla = documento.add_table(rows=4, cols=2)
#     tabla.alignment = WD_TABLE_ALIGNMENT.CENTER
#     tabla.autofit = True
#     _set_table_borders(tabla)

#     filas = tabla.rows

#     _set_cell_text(filas[0].cells[0], f"{centro}: {sede}", bold=True)
#     _set_cell_text(filas[0].cells[1], f"Modalidad: {modalidad}", bold=True)

#     _set_cell_text(filas[1].cells[0], "Profesional interviniente", bold=True)
#     _set_cell_text(filas[1].cells[1], profesionales)

#     _set_cell_text(filas[2].cells[0], "Coordinadora", bold=True)
#     _set_cell_text(filas[2].cells[1], coordinadora)

#     _set_cell_text(filas[3].cells[0], "Fecha de baja del destinatario", bold=True)
#     _set_cell_text(filas[3].cells[1], fecha_baja)

#     for row in filas:
#         _aplicar_alto_fila(row, 0.75)

#     _espacio(documento, 4)


# def _agregar_datos_beneficiario(documento: Document, datos: dict[str, Any]) -> None:
#     tipo = _texto(datos.get("bajaTipoBeneficiario"))
#     nombre = _texto(datos.get("bajaNombreCompleto"))
#     tipo_dni = _texto(datos.get("bajaTipoDni"), "DNI")
#     dni = _texto(datos.get("bajaDni"))
#     fecha_ingreso = _texto(datos.get("bajaFechaIngreso"))

#     marca_destinatario = "X" if tipo == "Destinatario" else " "
#     marca_tutor = "X" if tipo == "Tutor" else " "

#     tabla = documento.add_table(rows=4, cols=4)
#     tabla.alignment = WD_TABLE_ALIGNMENT.CENTER
#     tabla.autofit = True
#     _set_table_borders(tabla)

#     # Fila 1
#     _set_cell_text(tabla.rows[0].cells[0], "Beneficiario", bold=True)
#     _set_cell_text(tabla.rows[0].cells[1], f"[{marca_destinatario}] Destinatario", size=8)
#     _set_cell_text(tabla.rows[0].cells[2], f"[{marca_tutor}] Tutor", size=8)
#     _set_cell_text(tabla.rows[0].cells[3], "", size=8)

#     # Fila 2
#     _set_cell_text(tabla.rows[1].cells[0], "Nombre y apellido", bold=True)
#     _set_cell_text(tabla.rows[1].cells[1], nombre)
#     tabla.rows[1].cells[1].merge(tabla.rows[1].cells[3])

#     # Fila 3
#     _set_cell_text(tabla.rows[2].cells[0], "Tipo y DNI", bold=True)
#     _set_cell_text(tabla.rows[2].cells[1], tipo_dni)
#     _set_cell_text(tabla.rows[2].cells[2], "N°", bold=True)
#     _set_cell_text(tabla.rows[2].cells[3], dni)

#     # Fila 4
#     _set_cell_text(tabla.rows[3].cells[0], "Fecha de ingreso a Envión", bold=True)
#     _set_cell_text(tabla.rows[3].cells[1], fecha_ingreso)
#     tabla.rows[3].cells[1].merge(tabla.rows[3].cells[3])

#     for row in tabla.rows:
#         _aplicar_alto_fila(row, 0.75)

#     _espacio(documento, 4)


# def _agregar_responsable_adulto(documento: Document, datos: dict[str, Any]) -> None:
#     nombre = _texto(datos.get("bajaResponsableNombreCompleto"))
#     relacion = _texto(datos.get("bajaResponsableRelacion"))
#     informado = _texto(datos.get("bajaResponsableInformado"))

#     marca_si = "X" if informado in {"Sí", "Si"} else " "
#     marca_no = "X" if informado == "No" else " "

#     tabla = documento.add_table(rows=3, cols=4)
#     tabla.alignment = WD_TABLE_ALIGNMENT.CENTER
#     tabla.autofit = True
#     _set_table_borders(tabla)

#     _set_cell_text(tabla.rows[0].cells[0], "Adulto responsable", bold=True)
#     _set_cell_text(tabla.rows[0].cells[1], nombre)
#     tabla.rows[0].cells[1].merge(tabla.rows[0].cells[3])

#     _set_cell_text(tabla.rows[1].cells[0], "Relación con el joven", bold=True)
#     _set_cell_text(tabla.rows[1].cells[1], relacion)
#     tabla.rows[1].cells[1].merge(tabla.rows[1].cells[3])

#     _set_cell_text(
#         tabla.rows[2].cells[0],
#         "¿Está el adulto responsable al tanto de la baja del joven al Envión?",
#         bold=True,
#         size=7,
#     )
#     _set_cell_text(tabla.rows[2].cells[1], f"[{marca_si}] Sí", align=WD_ALIGN_PARAGRAPH.CENTER)
#     _set_cell_text(tabla.rows[2].cells[2], f"[{marca_no}] No", align=WD_ALIGN_PARAGRAPH.CENTER)
#     _set_cell_text(tabla.rows[2].cells[3], "")

#     for row in tabla.rows:
#         _aplicar_alto_fila(row, 0.75)

#     _espacio(documento, 4)


# def _agregar_motivos(documento: Document, datos: dict[str, Any]) -> None:
#     motivo_seleccionado = _texto(datos.get("bajaMotivo"))

#     motivos = [
#         "Encontrarse privado de la libertad",
#         "Fallecimiento",
#         "Haber cumplimentado con todos los acuerdos para su egreso",
#         "Liquidaciones consecutivas impagas",
#         "Mudanza a otro Municipio",
#         "Negativa a cumplir con su Acuerdo de Compromiso",
#         "Negativa del Joven a participar",
#         "Negativa o dificultades al momento de la socialización",
#         "Pase de Destinatario a Tutor",
#         "Pase de Tutor a Destinatario",
#         "Trabajo Formal",
#         "Otros motivos",
#     ]

#     _agregar_parrafo(documento, "Motivos de la baja", bold=True, size=9)

#     tabla = documento.add_table(rows=len(motivos) + 1, cols=2)
#     tabla.alignment = WD_TABLE_ALIGNMENT.CENTER
#     tabla.autofit = True
#     _set_table_borders(tabla)

#     _set_cell_text(tabla.rows[0].cells[0], "Motivo", bold=True, align=WD_ALIGN_PARAGRAPH.CENTER)
#     _set_cell_text(tabla.rows[0].cells[1], "Marcar", bold=True, align=WD_ALIGN_PARAGRAPH.CENTER)

#     _set_cell_shading(tabla.rows[0].cells[0], "EDEDED")
#     _set_cell_shading(tabla.rows[0].cells[1], "EDEDED")

#     for indice, motivo in enumerate(motivos, start=1):
#         marca = "X" if motivo == motivo_seleccionado else ""

#         _set_cell_text(tabla.rows[indice].cells[0], motivo, size=7)
#         _set_cell_text(
#             tabla.rows[indice].cells[1],
#             marca,
#             bold=True,
#             size=9,
#             align=WD_ALIGN_PARAGRAPH.CENTER,
#         )

#         _aplicar_alto_fila(tabla.rows[indice], 0.45)

#     _aplicar_alto_fila(tabla.rows[0], 0.5)

#     # Espacio visual para "Otros motivos" / aclaración manuscrita si necesitan firmar o completar.
#     _espacio(documento, 3)
#     tabla_otros = documento.add_table(rows=1, cols=1)
#     tabla_otros.alignment = WD_TABLE_ALIGNMENT.CENTER
#     _set_table_borders(tabla_otros)
#     _set_cell_text(
#         tabla_otros.rows[0].cells[0],
#         "Otros motivos / aclaraciones: ................................................................................................................",
#         size=8,
#     )
#     _aplicar_alto_fila(tabla_otros.rows[0], 0.8)

#     _espacio(documento, 6)


# def _agregar_firmas(documento: Document) -> None:
#     tabla = documento.add_table(rows=2, cols=2)
#     tabla.alignment = WD_TABLE_ALIGNMENT.CENTER
#     tabla.autofit = True

#     _set_cell_text(
#         tabla.rows[0].cells[0],
#         "........................................................",
#         align=WD_ALIGN_PARAGRAPH.CENTER,
#     )
#     _set_cell_text(
#         tabla.rows[0].cells[1],
#         "........................................................",
#         align=WD_ALIGN_PARAGRAPH.CENTER,
#     )

#     _set_cell_text(
#         tabla.rows[1].cells[0],
#         "Firma profesional Envión",
#         bold=True,
#         size=8,
#         align=WD_ALIGN_PARAGRAPH.CENTER,
#     )
#     _set_cell_text(
#         tabla.rows[1].cells[1],
#         "Aclaración",
#         bold=True,
#         size=8,
#         align=WD_ALIGN_PARAGRAPH.CENTER,
#     )

#     _espacio(documento, 6)


# def _agregar_pie_documental(documento: Document) -> None:
#     tabla = documento.add_table(rows=1, cols=3)
#     tabla.alignment = WD_TABLE_ALIGNMENT.CENTER
#     tabla.autofit = True
#     _set_table_borders(tabla)

#     _set_cell_text(tabla.rows[0].cells[0], "Fecha: ....../....../......", size=7)
#     _set_cell_text(tabla.rows[0].cells[1], "Revisión: 0.0", size=7, align=WD_ALIGN_PARAGRAPH.CENTER)
#     _set_cell_text(tabla.rows[0].cells[2], "RC0108", size=7, align=WD_ALIGN_PARAGRAPH.RIGHT)

#     _aplicar_alto_fila(tabla.rows[0], 0.5)