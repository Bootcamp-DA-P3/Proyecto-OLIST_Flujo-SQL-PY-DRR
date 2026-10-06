

-- Creamos o reemplazamos la tabla con el resultado limpio y una única fila por producto
DROP TABLE IF EXISTS df2_productos_limpios;
CREATE TABLE df2_productos_limpios AS
SELECT 
    p.product_id,
    COALESCE(LOWER(TRIM(p.product_category_name)), 'sin_categoria') AS categoria_original,
    COALESCE(ct.product_category_name_english, 'unknown') AS categoria_traducida,
    -- Si no hay ventas, estas funciones devuelven NULL automáticamente
    MAX(oi.price) AS price,
    MAX(oi.freight_value) AS freight_value,
    MAX(s.seller_id) AS seller_id,
    p.product_weight_g,
    -- Columna derivada: 1 si pesa 5kg (5000g) o más, 0 si pesa menos
    CASE 
        WHEN p.product_weight_g >= 5000 THEN 1 
        ELSE 0 
    END AS is_heavy,
    -- Columna derivada: proporción del envío frente al precio (maneja NULLs y división por cero)
    CASE 
        WHEN MAX(oi.price) > 0 THEN ROUND(MAX(oi.freight_value) / MAX(oi.price), 4)
        ELSE 0 
    END AS freight_ratio
FROM products p
-- LEFT JOIN para conservar productos sin traducción
LEFT JOIN categoria_traduccion ct 
    ON LOWER(TRIM(p.product_category_name)) = LOWER(TRIM(ct.product_category_name))
-- LEFT JOIN crítico para incluir productos sin ventas (aparecerán con NULL en métricas de venta)
LEFT JOIN order_items oi 
    ON p.product_id = oi.product_id
LEFT JOIN sellers s 
    ON oi.seller_id = s.seller_id
WHERE 
    p.product_weight_g > 0 
    AND p.product_length_cm IS NOT NULL 
    AND p.product_height_cm IS NOT NULL 
    AND p.product_width_cm IS NOT NULL
-- Agrupamos por producto para asegurar estrictamente una sola fila por cada uno del catálogo
GROUP BY 
    p.product_id, 
    p.product_category_name, 
    ct.product_category_name_english, 
    p.product_weight_g, 
    p.product_length_cm, 
    p.product_height_cm, 
    p.product_width_cm;
SELECT * FROM df2_productos_limpios;