"""
Proyecto III · Flujo de datos de SQL a Python

Lee UNA de las consultas de sql/, la ejecuta contra MySQL y exporta el
resultado a data/.

Ejecutar desde la RAÍZ del proyecto:

    python src/main.py

Las funciones están declaradas pero vacías: os toca a vosotros.
Cada TODO dice qué hacer, no cómo.
"""

from pathlib import Path

import pandas as pd
from sqlalchemy import create_engine, text

from config import DB_USER, DB_PASSWORD, DB_HOST, DB_NAME

RAIZ = Path(__file__).resolve().parent.parent
SQL = RAIZ / "sql"
DATA = RAIZ / "data"


# ---------------------------------------------------------------------------
# CONFIGURACIÓN DEL EQUIPO · rellenad estas tres líneas antes de programar
# ---------------------------------------------------------------------------

# ¿Cuál de las tres consultas lleváis hasta el CSV?
CONSULTA = "Df1_actividad_clientes.sql"

# El grano, en lenguaje de negocio. Ejemplo: "un pedido entregado"
GRANO = "Actividad de cada cliente"

# La columna que identifica una fila según ese grano. Ejemplo: "order_id"
# Sirve para comprobar que el JOIN no está multiplicando filas.
CLAVE_DE_GRANO = "customers_unique_id"


# ---------------------------------------------------------------------------


def crear_engine():
    """Crea el motor de conexión a MySQL con las credenciales del .env."""
    url = f"mysql+mysqlconnector://{DB_USER}:{DB_PASSWORD}@{DB_HOST}/{DB_NAME}"
    return create_engine(url)


def leer_consulta(nombre):
    """Devuelve el contenido del fichero .sql que hay en sql/.

    La consulta vive en su fichero, no incrustada aquí: así la misma que
    probasteis en Workbench es la que ejecuta el script.
    """
    return (SQL / nombre).read_text(encoding="utf-8")


def ejecutar(engine, consulta_sql):
   return pd.read_sql(consulta_sql, engine)


def comprobar_grano(df):
    """Avisa si el número de filas no cuadra con el grano declarado.

    Si el grano es 'un pedido', entonces debe cumplirse que
    len(df) == número de order_id distintos. Si no cuadra, el JOIN
    está duplicando filas y todas vuestras sumas serán mayores de lo real.
    """
    if len(df) != df[CLAVE_DE_GRANO].nunique():
        print(f"⚠️ Cuidado: El grano no coincide. Filas: {len(df)}, Claves únicas: {df[CLAVE_DE_GRANO].nunique()}")
else:
    print("✅ Grano validado correctamente.")


def exportar(df, nombre_csv):
    """Guarda el DataFrame en data/ como CSV."""
    DATA.mkdir(exist_ok=True)  # por si la carpeta no existe todavía
   ruta_salida = DATA / nombre_csv
df.to_csv(ruta_salida, index=False, encoding="utf-8")

def main():
    if not GRANO or not CLAVE_DE_GRANO:
        raise SystemExit(
            "Antes de ejecutar: rellenad GRANO y CLAVE_DE_GRANO arriba.\n"
            "Si no sabéis qué poner, aún no estáis listos para escribir el JOIN."
        )

    print(f"Consulta ....... {CONSULTA}")
    print(f"Grano .......... una fila = {GRANO}")

    engine = crear_engine()
    consulta_sql = leer_consulta(CONSULTA)
    df = ejecutar(engine, consulta_sql)

    print(f"Filas .......... {len(df):,}")
    print(f"Columnas ....... {df.shape[1]}")

    comprobar_grano(df)
    exportar(df, CONSULTA.replace(".sql", ".csv"))


if __name__ == "__main__":
    main()
