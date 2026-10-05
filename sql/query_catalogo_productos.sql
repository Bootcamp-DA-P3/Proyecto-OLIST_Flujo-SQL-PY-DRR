USE olist;

SELECT 
    p.product_id,
    p.product_category_name AS categoria_original,
    ct.product_category_name_english AS categoria_traducida,
    oi.price,
    oi.freight_value,
    s.seller_id
FROM products p
LEFT JOIN categoria_traduccion ct 
    ON p.product_category_name = ct.product_category_name
LEFT JOIN order_items oi 
    ON p.product_id = oi.product_id
LEFT JOIN sellers s 
    ON oi.seller_id = s.seller_id;
    USE olist;

SELECT 
    product_id,
    product_category_name AS categoria_original_sucia,
    LOWER(TRIM(product_category_name)) AS categoria_normalizada,
    COALESCE(LOWER(TRIM(product_category_name)), 'sin_categoria') AS categoria_limpia
FROM products;

SELECT 
    product_id,
    COALESCE(LOWER(TRIM(product_category_name)), 'sin_categoria') AS categoria_limpia,
    product_weight_g,
    product_length_cm,
    product_height_cm,
    product_width_cm
FROM products
WHERE 
    product_weight_g > 0 
    AND product_length_cm IS NOT NULL 
    AND product_height_cm IS NOT NULL 
    AND product_width_cm IS NOT NULL;
    SELECT 
    p.product_id,
    COALESCE(LOWER(TRIM(p.product_category_name)), 'sin_categoria') AS categoria_original,
    COALESCE(ct.product_category_name_english, 'unknown') AS categoria_traducida,
    p.product_weight_g
FROM products p
LEFT JOIN categoria_traduccion ct 
    ON LOWER(TRIM(p.product_category_name)) = LOWER(TRIM(ct.product_category_name))
WHERE 
    p.product_weight_g > 0 
    AND p.product_length_cm IS NOT NULL 
    AND p.product_height_cm IS NOT NULL 
    AND p.product_width_cm IS NOT NULL;
    SELECT 
    p.product_id,
    COALESCE(LOWER(TRIM(p.product_category_name)), 'sin_categoria') AS categoria_original,
    COALESCE(ct.product_category_name_english, 'unknown') AS categoria_traducida,
    oi.price,
    oi.freight_value,
    s.seller_id,
    p.product_weight_g
FROM products p
LEFT JOIN categoria_traduccion ct 
    ON LOWER(TRIM(p.product_category_name)) = LOWER(TRIM(ct.product_category_name))
INNER JOIN order_items oi 
    ON p.product_id = oi.product_id
LEFT JOIN sellers s 
    ON oi.seller_id = s.seller_id
WHERE 
    p.product_weight_g > 0 
    AND p.product_length_cm IS NOT NULL 
    AND p.product_height_cm IS NOT NULL 
    AND p.product_width_cm IS NOT NULL;
    USE olist;

SELECT 
    p.product_id,
    COALESCE(LOWER(TRIM(p.product_category_name)), 'sin_categoria') AS categoria_original,
    COALESCE(ct.product_category_name_english, 'unknown') AS categoria_traducida,
    oi.price,
    oi.freight_value,
    s.seller_id,
    p.product_weight_g,
    -- Columna derivada: 1 si pesa 5kg (5000g) o más, 0 si pesa menos
    CASE 
        WHEN p.product_weight_g >= 5000 THEN 1 
        ELSE 0 
    END AS is_heavy,
    -- Columna derivada: proporción del envío frente al precio (evitando división por cero)
    CASE 
        WHEN oi.price > 0 THEN ROUND(oi.freight_value / oi.price, 4)
        ELSE 0 
    END AS freight_ratio
FROM products p
-- Usamos LEFT JOIN para conservar productos sin traducción (como pc_gamer)
LEFT JOIN categoria_traduccion ct 
    ON LOWER(TRIM(p.product_category_name)) = LOWER(TRIM(ct.product_category_name))
INNER JOIN order_items oi 
    ON p.product_id = oi.product_id
LEFT JOIN sellers s 
    ON oi.seller_id = s.seller_id
WHERE 
    p.product_weight_g > 0 
    AND p.product_length_cm IS NOT NULL 
    AND p.product_height_cm IS NOT NULL 
    AND p.product_width_cm IS NOT NULL;