-- 1. Productos totales del catálogo
SELECT COUNT(DISTINCT product_id) AS productos_en_catalogo
FROM olist.products;


-- 2. Productos distintos que aparecen en ventas
SELECT COUNT(DISTINCT product_id) AS productos_vendidos
FROM olist.order_items;


-- 3. Productos nunca vendidos
SELECT
    p.product_id
FROM olist.products AS p
LEFT JOIN olist.order_items AS oi
    ON p.product_id = oi.product_id
WHERE oi.product_id IS NULL;


-- 4. Número de productos nunca vendidos
SELECT
    COUNT(*) AS productos_no_vendidos
FROM olist.products AS p
LEFT JOIN olist.order_items AS oi
    ON p.product_id = oi.product_id
WHERE oi.product_id IS NULL;
