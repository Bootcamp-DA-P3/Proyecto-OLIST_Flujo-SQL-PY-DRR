# Proyecto 3: Flujo SQL - Python - DRR

Tercer Proyecto - Bootcamp de Data Analytics

## 📊 Criterios de Selección y Grano General
¿Por qué elegimos este grano y lo dejamos aquí explicado?
* **Nivel de detalle:** Lo hemos definido así porque es la forma perfecta de ver el detalle exacto de cada elemento, sin complicarnos con datos que no necesitamos y manteniendo la información muy limpia.
* **Justificación en el código:** Lo dejamos por escrito para que, si en el futuro tocamos estos datos para hacer gráficos o más código, sepamos exactamente qué es cada fila y evitemos mezclar cosas que puedan falsear los resultados.

---

## 📋 Grano DF1 - Actividad del cliente
* **Definición:** Registro y seguimiento de la actividad detallada del cliente dentro del flujo del proyecto.

---

## 📌 Definición del Grano del Proyecto DF2 (Catálogo de Productos)
* **Definición:** Una fila representa un producto único del catálogo de Olist con sus dimensiones físicas y su categoría normalizada y traducida.
* **Script SQL asociado:** `df2_catalogo_productos.sql`

### Criterios y pasos de limpieza aplicados en DF2:
1. **Traducción y normalización de categorías:** 
   * Se cruzó la tabla de productos con la tabla de traducción (`product_category_name_translation`) para obtener la categoría en inglés.
   * Se estandarizaron los campos de texto de las categorías utilizando `LOWER(TRIM(...))` para eliminar espacios sobrantes y unificar el formato en minúsculas.
2. **Tratamiento de valores nulos:**
   * Se utilizaron funciones `COALESCE` para detectar categorías vacías o nulas, asignándoles una etiqueta por defecto (`'sin_categoria'`).
3. **Control de dimensiones del producto:**
   * Se mantuvieron y validaron las columnas de peso (`product_weight_g`), longitud (`product_length_cm`), altura (`product_height_cm`) y anchura para futuros análisis logísticos.

---

## 📌 Definición del Grano del Proyecto DF3 y Limpieza

### Criterio general aplicado
Durante la limpieza se siguieron estos criterios:
* No modificar directamente los datos originales.
* No eliminar registros sin una justificación clara.
* Diferenciar duplicados reales de múltiples unidades de producto.
* Estandarizar formatos de texto.
* Validar las claves antes de continuar con el análisis.
* Mantener la mayor cantidad posible de información útil. 

Los scripts SQL generados para esta parte del proyecto fueron: 
* `01_estandarizar_seller_city_state.sql` 
* `02_validar_ids.sql` 
* `03_productos_no_vendidos.sql` 
* `4_RAY_quitar_duplicados.sql` 
* `RAY_FICHERO FINAL.sql`

### 1. Estandarización de seller_city y seller_state
Se normalizaron los campos `seller_city` y `seller_state` utilizando: `LOWER(TRIM(...))`
Con ello se eliminaron espacios al principio y al final y se unificó el texto en minúsculas.
También se detectaron variantes de una misma ciudad y algunos valores anómalos. Para los casos más evidentes se aplicaron correcciones puntuales con `CASE`.
Ejemplos de variantes detectadas:
* `sao paulo`
* `sao paulo sp`
* `sao paulo / sao paulo`
* `sao paluo`
* `sao pauo`
* `angra dos reis`
* `angra dos reis rj`

Además, se utilizó: `COUNT(*) AS veces` para comprobar cuántas veces aparecía cada combinación de ciudad y estado después de la limpieza.

### 2. Validación de seller_id y product_id
Se comprobó que los identificadores presentes en `order_items` existieran en sus tablas correspondientes.
Se validó:
* `seller_id` contra la tabla `sellers`
* `product_id` contra la tabla `products`

Para ello se utilizaron consultas con `LEFT JOIN` y búsqueda de valores `NULL`. Resultados obtenidos: 
* `sellers_huerfanos = 0` 
* `productos_huerfanos = 0`

Por tanto, no se detectaron claves huérfanas y todos los identificadores tienen correspondencia en sus tablas de referencia.

### 3. Comprobación de productos nunca vendidos
Se comparó el número total de productos del catálogo con el número de productos distintos presentes en `order_items`. Resultados obtenidos: 
* `productos_en_catalogo = 32951` 
* `productos_vendidos = 32951` 
* `productos_no_vendidos = 0`

Por tanto, todos los productos de la tabla `products` aparecen al menos una vez en `order_items`. No fue necesario aplicar ningún filtro para eliminar productos nunca vendidos.

### 4. Agrupación de unidades en `order_items`
Se comprobó que `order_items` contiene una fila por unidad de producto. Esto significa que un pedido con varias unidades del mismo producto genera varias filas con:
* el mismo `order_id`
* el mismo `product_id`
* distintos valores de `order_item_id` 

Estas filas no se eliminaron como duplicados, ya que representan unidades reales del pedido. En su lugar, se agruparon utilizando: `COUNT(*) AS cantidad` junto con un `GROUP BY`.

De esta forma, varias unidades del mismo producto dentro de un pedido quedan representadas en una única fila con una columna cantidad. Esta columna "cantidad" se puede emplear para calcular precios de envíos de pedidos en un futuro multiplicando los productos por cantidad y añadiendo los gastos de envío.

También se generó un archivo CSV con los resultados de la limpieza: `LIMPIEZA OLIST RAY.csv`.

