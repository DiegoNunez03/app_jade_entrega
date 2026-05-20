# test/dev_test_fuente_manager.py

from __future__ import annotations

import sys
from pathlib import Path

from PySide6.QtWidgets import QApplication

ROOT_DIR = Path(__file__).resolve().parents[1]
sys.path.append(str(ROOT_DIR))

from CORE.fuente_manager import FuenteManager


def main() -> None:
    app = QApplication(sys.argv)

    fuente_manager = FuenteManager()
    fuente_manager.imprimir_diagnostico()

    app.quit()


if __name__ == "__main__":
    main()