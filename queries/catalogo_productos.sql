SELECT 
    p.product_id,
    COALESCE(LOWER(TRIM(p.product_category_name)), 'sin_categoria') AS categoria_original,
    COALESCE(ct.product_category_name_english, 'unknown') AS categoria_traducida,
    MAX(oi.price) AS price,
    MAX(oi.freight_value) AS freight_value,
    MAX(s.seller_id) AS seller_id,
    p.product_weight_g,
    CASE 
        WHEN p.product_weight_g >= 5000 THEN 1 
        ELSE 0 
    END AS is_heavy,
    CASE 
        WHEN MAX(oi.price) > 0 THEN ROUND(MAX(oi.freight_value) / MAX(oi.price), 4)
        ELSE 0 
    END AS freight_ratio
FROM products p
LEFT JOIN categoria_traduccion ct 
    ON LOWER(TRIM(p.product_category_name)) = LOWER(TRIM(ct.product_category_name))
LEFT JOIN order_items oi 
    ON p.product_id = oi.product_id
LEFT JOIN sellers s 
    ON oi.seller_id = s.seller_id
WHERE 
    p.product_weight_g > 0 
    AND p.product_length_cm IS NOT NULL 
    AND p.product_height_cm IS NOT NULL 
    AND p.product_width_cm IS NOT NULL
GROUP BY 
    p.product_id, 
    p.product_category_name, 
    ct.product_category_name_english, 
    p.product_weight_g, 
    p.product_length_cm, 
    p.product_height_cm, 
    p.product_width_cm;