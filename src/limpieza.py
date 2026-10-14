"""Donde aterriza la limpieza que traeis del Proyecto III.

Una celda de notebook se convierte en funcion de python con dos cambios: un `def` arriba
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
   """ q1, q3 = df["ingresos"].quantile([0.25, 0.75])
    techo = q3 + 1.5 * (q3 - q1)
    df["ingresos_atipico"] = df["ingresos"] > techo
    """
    return df

def limpiar_df3_vendedores(df):
    """Limpieza del dataset Df3: una fila por vendedor."""
    df = df.copy()

    # Normalizar los textos conservando los valores nulos.
    for columna in [
        "seller_city_clean",
        "seller_state_clean",
        "product_category_name",
    ]:
        df[columna] = (
            df[columna]
            .astype("string")
            .str.strip()
            .str.lower()
        )

    # Convertir los contadores a números enteros.
    for columna in [
        "total_pedidos",
        "total_productos_distintos",
        "total_articulos_vendedor",
    ]:
        df[columna] = pd.to_numeric(
            df[columna], errors="raise"
        ).astype("Int64")

    # Convertir los importes a números.
    for columna in [
        "precio_total_vendedor",
        "transporte_total_vendedor",
    ]:
        df[columna] = pd.to_numeric(
            df[columna], errors="raise"
        )

    return df

# Reglas que se aplican a todos los datasets.
COMUNES = [tipar_fechas]

# Reglas propias de cada dataset. Aqui van las vuestras del Proyecto III.
LIMPIEZA = {
    "clientes_actividad": [],
    "catalogo_productos": [marcar_ingresos_atipicos],
    "vendedores": [limpiar_df3_vendedores],
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