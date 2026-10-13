"""
Credenciales de la base de datos.

Este fichero NO contiene ninguna contraseña: las lee del `.env`, que no se
sube al repositorio. Si te falta el `.env`, copia `.env_example` y rellénalo.

Aquí no hace falta tocar nada.
"""

import os
from pathlib import Path

from dotenv import load_dotenv

# La raíz del proyecto es la carpeta que contiene a src/.
# Calcularla así hace que funcione lo lances desde donde lo lances.
RAIZ = Path(__file__).resolve().parent.parent

load_dotenv(RAIZ / ".env")

DB_USER = os.getenv("DB_USER")
DB_PASSWORD = os.getenv("DB_PASSWORD")
DB_HOST = os.getenv("DB_HOST", "localhost")
DB_PORT = os.getenv("DB_PORT", "3306")
DB_NAME = os.getenv("DB_NAME", "olist")

# Carpetas de trabajo
CARPETA_QUERIES = RAIZ / "queries"
CARPETA_OUTPUT = RAIZ / os.getenv("OUTPUT_FOLDER", "output")

# Excel. El ETL no disena el dashboard: solo crea el libro si no existe,
# apunta a las fuentes y lo abre.
EXCEL_FILE = RAIZ / os.getenv("EXCEL_FILE", "dashboard/Olist_Dashboard.xlsx")
AUTO_OPEN_EXCEL = os.getenv("AUTO_OPEN_EXCEL", "true").lower() == "true"