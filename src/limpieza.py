"""Donde aterriza la limpieza que traeis del Proyecto III.

Una celda de notebook se convierte en funcion con dos cambios: un `def` arriba
y un `return` abajo. El cuerpo no se toca.

    # Proyecto III, celda del notebook
    df = df[df["precio"] > 0]
    df["ciudad"] = df["ciudad"].str.strip()

    # Proyecto IV, funcion
    def quitar_precios_a_cero(df):
        df = df[df["precio"] > 0]
        df["ciudad"] = df["ciudad"].str.strip()
        return df

Despues se registra en LIMPIEZA, debajo del dataset al que se aplica. El ETL
la ejecuta sola en cada pasada.

Regla para decidir donde va cada limpieza:
    - Si es un filtro o un valor por defecto, va en SQL. Corre en el servidor
      y reduce lo que viaja por la red.
    - Si necesita mirar el conjunto entero (atipicos, medias, percentiles) o
      manipular texto, va aqui.
"""

import pandas as pd


def tipar_fechas(df):
    """Convierte a fecha las columnas que lo son.

    Sin esto Excel las lee como texto y no deja agrupar por mes ni por ano.
    """
    for columna in df.columns:
        if columna.startswith("fecha_") or columna.endswith("_compra"):
            df[columna] = pd.to_datetime(df[columna], errors="coerce")
    return df


def marcar_ingresos_atipicos(df):
    """Marca los productos con ingresos fuera del rango intercuartilico.

    Ejemplo de regla que SQL lleva mal: necesita los cuartiles de todo el
    conjunto. Marca, no borra: un producto caro no es un error, pero conviene
    poder excluirlo del grafico con un filtro.
    """
    q1, q3 = df["ingresos"].quantile([0.25, 0.75])
    techo = q3 + 1.5 * (q3 - q1)
    df["ingresos_atipico"] = df["ingresos"] > techo
    return df

# ==========================================
# NUESTRAS FUNCIONES DE LIMPIEZA (PROYECTO III)
# ==========================================
def normalizar_cadenas_texto_df2(df):
    """Quita espacios en blanco y pasa a minusculas las columnas de texto generales."""
    str_cols = df.select_dtypes(include=['object', 'string']).columns
    for col in str_cols:
        df[col] = df[col].astype(str).str.strip().str.lower()
    return df


def rellenar_comentarios_nulos_df2(df):
    """Rellena los titulos y mensajes de comentarios vacios con texto por defecto."""
    if 'review_comment_title' in df.columns:
        df['review_comment_title'] = df['review_comment_title'].fillna('sin titulo')
    if 'review_comment_message' in df.columns:
        df['review_comment_message'] = df['review_comment_message'].fillna('sin mensaje')
    return df


def normalizar_catalogo_df2(df):
    """Quita espacios en blanco y pasa a minusculas las columnas especificas del catalogo (df2)."""
    if 'categoria_original' in df.columns:
        df['categoria_original'] = df['categoria_original'].astype(str).str.strip().str.lower()
    if 'categoria_traducida' in df.columns:
        df['categoria_traducida'] = df['categoria_traducida'].astype(str).str.strip().str.lower()
    return df


def marcar_atipicos_ventas_df2(df):
    """Marca los precios o costes de envio fuera del rango normal (outliers)."""
    for col in ['price', 'freight_value']:
        if col in df.columns:
            q1 = df[col].quantile(0.25)
            q3 = df[col].quantile(0.75)
            iqr = q3 - q1
            lim_superior = q3 + 1.5 * iqr
            lim_inferior = q1 - 1.5 * iqr
            df[f"{col}_atipico"] = (df[col] < lim_inferior) | (df[col] > lim_superior)
    return df



# Reglas que se aplican a todos los datasets.
COMUNES = [tipar_fechas]

# Reglas propias de cada dataset. Aqui van las vuestras del Proyecto III.
LIMPIEZA = {
    "clientes_actividad": [],
    "catalogo_productos": [marcar_ingresos_atipicos],
    "vendedores": [],
    "entregas_retrasos": [],
    "ventas_detalle": [],
}

# Si algun equipo usa la tabla geolocation, es la unica de Olist que esta
# sucia de verdad y el sitio natural para tres reglas mas: quitar las 261.831
# filas duplicadas exactas, normalizar las tildes de geolocation_city (2.073
# ciudades son la misma escrita de dos formas) y descartar las 42 coordenadas
# que caen fuera de Brasil.


def limpiar(df, nombre):
    """Aplica las reglas comunes y las del dataset. Informa de lo que quitan."""
    for regla in COMUNES + LIMPIEZA.get(nombre, []):
        antes = len(df)
        df = regla(df)
        diferencia = antes - len(df)
        if diferencia > 0:
            print(f"    {regla.__name__}: {diferencia} filas fuera")
        elif diferencia < 0:
            print(f"    {regla.__name__}: {-diferencia} filas DE MAS, revisad la regla")
    return df