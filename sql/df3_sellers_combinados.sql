#
-- ==========================================
-- LIMPIEZA Y VALIDACIÓN DEL DATASET OLIST
-- ==========================================


-- 1. Estandarizar seller_city y seller_state
-- Se aplican LOWER() y TRIM() para unificar mayúsculas/minúsculas
-- y eliminar espacios al principio y al final.
-- Además, se corrigen algunas variantes evidentes de ciudades.

SELECT
    CASE
        WHEN LOWER(TRIM(seller_city)) IN (
            'sao paulo',
            'sao paulo sp',
            'sao paulo / sao paulo',
            'sao paulo - sp',
            'sao paluo',
            'sao pauo',
            'sao paulop'
        ) THEN 'sao paulo'

        WHEN LOWER(TRIM(seller_city)) IN (
            'angra dos reis',
            'angra dos reis rj'
        ) THEN 'angra dos reis'

        ELSE LOWER(TRIM(seller_city))
    END AS seller_city_clean,

    LOWER(TRIM(seller_state)) AS seller_state_clean,

    COUNT(*) AS veces

FROM olist.sellers

GROUP BY
    seller_city_clean,
    seller_state_clean

ORDER BY
    veces ASC,
    seller_city_clean;


-- Resultado obtenido:
-- Se normalizan los nombres de ciudad y estado.
-- Se detectan además valores anómalos y distintas variantes
-- de una misma ciudad.


-- ==========================================


-- 2. Asegurar que seller_id y product_id existan
-- en sus tablas correspondientes.


-- 2.1 Comprobar seller_id huérfanos

SELECT
    COUNT(*) AS sellers_huerfanos
FROM olist.order_items AS oi
LEFT JOIN olist.sellers AS s
    ON oi.seller_id = s.seller_id
WHERE s.seller_id IS NULL;


-- Resultado obtenido:
-- sellers_huerfanos = 0


-- 2.2 Comprobar product_id huérfanos

SELECT
    COUNT(*) AS productos_huerfanos
FROM olist.order_items AS oi
LEFT JOIN olist.products AS p
    ON oi.product_id = p.product_id
WHERE p.product_id IS NULL;


-- Resultado obtenido:
-- productos_huerfanos = 0


-- Conclusión:
-- Todos los seller_id y product_id presentes en order_items
-- existen en sus tablas de referencia.


-- ==========================================


-- 3. Comprobar productos nunca vendidos


-- 3.1 Total de productos del catálogo

SELECT
    COUNT(DISTINCT product_id) AS productos_en_catalogo
FROM olist.products;


-- Resultado obtenido:
-- productos_en_catalogo = 32951


-- 3.2 Total de productos vendidos

SELECT
    COUNT(DISTINCT product_id) AS productos_vendidos
FROM olist.order_items;


-- Resultado obtenido:
-- productos_vendidos = 32951


-- 3.3 Productos nunca vendidos

SELECT
    COUNT(*) AS productos_no_vendidos
FROM olist.products AS p
LEFT JOIN olist.order_items AS oi
    ON p.product_id = oi.product_id
WHERE oi.product_id IS NULL;


-- Resultado obtenido:
-- productos_no_vendidos = 0


-- Conclusión:
-- Todos los productos del catálogo aparecen al menos una vez
-- en order_items, por lo que no hay productos nunca vendidos
-- y no es necesario aplicar ningún filtro.


-- ==========================================


-- 4. Evitar duplicación en order_items
-- order_items contiene una fila por unidad.
-- Se agrupan las filas del mismo producto dentro del pedido
-- y se crea una columna cantidad con COUNT(*).

-- 4. Evitar duplicación en order_items
-- order_items contiene una fila por unidad.
-- Se agrupan las filas del mismo producto dentro del pedido
-- y se crea una columna cantidad con COUNT(*).

DROP TABLE IF EXISTS Df3_agrupacion_pedidos;

CREATE TABLE Df3_agrupacion_pedidos AS
SELECT
    order_id,
    product_id,
    seller_id,
    shipping_limit_date,
    price,
    freight_value,
    COUNT(*) AS cantidad
FROM olist.order_items
GROUP BY
    order_id,
    product_id,
    seller_id,
    shipping_limit_date,
    price,
    freight_value;


-- Resultado obtenido:
-- Las unidades repetidas del mismo producto dentro de un pedido
-- quedan agrupadas en una sola fila.
-- La columna cantidad indica el número de unidades

-- ==========================================================
-- CONSULTA FINAL: AGREGACIÓN DE PRODUCTOS Y VENDEDORES A NIVEL PEDIDO
-- Devuelve exactamente las 98,666 filas requeridas
-- ==========================================================

SELECT 
    ag.seller_id,
    COUNT(DISTINCT ag.order_id) AS total_pedidos,
    COUNT(DISTINCT ag.product_id) AS total_productos_distintos,
    GROUP_CONCAT(
        DISTINCT p.product_category_name
        ORDER BY p.product_category_name
        SEPARATOR '|'
    ) AS product_category_name,
    SUM(ag.price * ag.cantidad) AS precio_total_vendedor,
    SUM(ag.freight_value * ag.cantidad) AS transporte_total_vendedor,
    SUM(ag.cantidad) AS total_articulos_vendedor,
    MAX(CASE
        WHEN LOWER(TRIM(s.seller_city)) IN ('sao paulo','sao paulo sp','sao paulo / sao paulo','sao paulo - sp','sao paluo','sao acu','sao paulop') THEN 'sao paulo'
        WHEN LOWER(TRIM(s.seller_city)) IN ('angra dos reis','angra dos reis rj') THEN 'angra dos reis'
        ELSE LOWER(TRIM(s.seller_city))
    END) AS seller_city_clean,
    MAX(LOWER(TRIM(s.seller_state))) AS seller_state_clean
FROM Df3_agrupacion_pedidos AS ag
LEFT JOIN olist.products AS p ON ag.product_id = p.product_id
LEFT JOIN olist.sellers AS s ON ag.seller_id = s.seller_id
GROUP BY ag.seller_id;

-- Cambios realizados
-- Antes (por pedido)    Ahora (por vendedor)
