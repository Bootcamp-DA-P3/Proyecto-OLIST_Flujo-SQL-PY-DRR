WITH agrupa_pedidos AS (
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
        freight_value
)
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
FROM agrupa_pedidos AS ag
LEFT JOIN olist.products AS p ON ag.product_id = p.product_id
LEFT JOIN olist.sellers AS s ON ag.seller_id = s.seller_id
GROUP BY ag.seller_id;