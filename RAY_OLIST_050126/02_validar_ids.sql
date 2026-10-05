-- Número de seller_id huérfanos
SELECT COUNT(*) AS sellers_huerfanos
FROM olist.order_items AS oi
LEFT JOIN olist.sellers AS s
    ON oi.seller_id = s.seller_id
WHERE s.seller_id IS NULL;

-- Número de product_id huérfanos
SELECT COUNT(*) AS productos_huerfanos
FROM olist.order_items AS oi
LEFT JOIN olist.products AS p
    ON oi.product_id = p.product_id
WHERE p.product_id IS NULL;