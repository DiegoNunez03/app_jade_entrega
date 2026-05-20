#!/bin/bash
rm -f resources.py
rm -rf __pycache__

pyside6-rcc resources.qrc -o resources.py

python CORE/main.py