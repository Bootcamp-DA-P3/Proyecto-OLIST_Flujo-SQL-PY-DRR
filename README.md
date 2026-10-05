# Proyecto 3: Flujo SQL - Python - DRR
Tercer Proyecto - Bootcamp de Data Analytics

## **¿Por qué elegimos este grano y lo dejamos aquí explicado?**
* **Nivel de detalle:** Lo hemos definido así porque es la forma perfecta de ver el detalle exacto de cada venta (qué producto se vendió, cuánto costó, quién lo envió y su categoría), sin complicarnos con datos que no necesitamos y manteniendo la información muy limpia.
  
* **Justificación en el código:** Lo dejamos por escrito para que, si en el futuro tocamos estos datos para hacer gráficos o más código, sepamos exactamente qué es cada fila y evitemos mezclar cosas que puedan falsear los resultados o duplicar las ventas por error.

## 📊 Grano DF1 - Actividad del cliente
* Registro y seguimiento de la actividad detallada del cliente dentro del flujo del proyecto.

## 📌 Definición del Grano del Proyecto DF2
* **Definición:** Una fila representa una línea de pedido (order item) que contiene un producto específico, su categoría traducida, su precio, el coste de envío y el vendedor asociado.

## 📌 Definición del Grano del Proyecto DF3

Una fila representa una línea de **pedido**, el código de **producto** solicitado, el código del **vendedor**, la **fecha límite** de envío, el **precio** de cada **unidad del producto**, los **gastos de envío** y la cantidad de **unidades** del producto **enviadas**.

*order_id,	product_id,	seller_id,	shipping_limit_date,	price	freight_value,	cantidad*


***Criterio general aplicado DF3***

Durante la limpieza se siguieron estos criterios:
- No modificar directamente los datos originales.
- No eliminar registros sin una justificación clara.
- Diferenciar duplicados reales de múltiples unidades de producto.
- Estandarizar formatos de texto.
- Validar las claves antes de continuar con el análisis.
- Mantener la mayor cantidad posible de información útil.
Los scripts SQL generados para esta parte del proyecto fueron:
01_estandarizar_seller_city_state.sql
02_validar_ids.sql
03_productos_no_vendidos.sql
4_RAY_quitar_duplicados.sql
RAY_FICHERO FINAL.sql

### 1. Estandarización de seller_city y seller_state
Se normalizaron los campos seller_city y seller_state utilizando:
LOWER(TRIM(...))

Con ello se eliminaron espacios al principio y al final y se unificó el texto en minúsculas.

También se detectaron variantes de una misma ciudad y algunos valores anómalos. Para los casos más evidentes se aplicaron correcciones puntuales con CASE.

Ejemplos de variantes detectadas:
- sao paulo
- sao paulo sp
- sao paulo / sao paulo
- sao paluo
- sao pauo
- angra dos reis
- angra dos reis rj

Además, se utilizó:
COUNT(*) AS veces
para comprobar cuántas veces aparecía cada combinación de ciudad y estado después de la limpieza.

### 2. Validación de seller_id y product_id
Se comprobó que los identificadores presentes en order_items existieran en sus tablas correspondientes.

Se validó:
- seller_id contra la tabla sellers
- product_id contra la tabla products
  
Para ello se utilizaron consultas con LEFT JOIN y búsqueda de valores NULL.
Resultados obtenidos:
sellers_huerfanos = 0
productos_huerfanos = 0

Por tanto, **no se detectaron claves huérfanas** y todos los seller_id y product_id presentes en order_items tienen correspondencia en sus tablas de referencia.

### 3. Comprobación de productos nunca vendidos
Se comparó el número total de productos del catálogo con el número de productos distintos presentes en order_items.
Resultados obtenidos:
productos_en_catalogo = 32951
productos_vendidos = 32951
productos_no_vendidos = 0

Por tanto, **todos los productos de la tabla products aparecen al menos una vez en order_items**.

No fue necesario aplicar ningún filtro para eliminar productos nunca vendidos.

### 4. Agrupación de unidades en order_items
Se comprobó que order_items contiene una fila por unidad de producto.
Esto significa que un pedido con varias unidades del mismo producto genera varias filas con:
- el mismo order_id
- el mismo product_id
- distintos valores de order_item_id
Estas filas no se eliminaron como duplicados, ya que representan unidades reales del pedido.
En su lugar, se agruparon utilizando:
COUNT(*) AS cantidad

junto con un GROUP BY.

De esta forma, varias unidades del mismo producto dentro de un pedido quedan representadas en una única fila con una columna cantidad. Esta columna "cantidad" se puede emplear para calcular precios de envíos de pedidos en un futuro multiplicando los productos por cantidad y añadiendo los gastos de envío.

También se generó un archivo CSV con los resultados de la limpieza:

LIMPIEZA OLIST RAY.csv




