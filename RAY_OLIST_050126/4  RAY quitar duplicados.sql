SELECT
    order_id,
    product_id,
    COUNT(*) AS cantidad,
    seller_id,
    shipping_limit_date,
    price,
    freight_value
FROM olist.order_items
GROUP BY
    order_id,
    product_id,
    seller_id,
    shipping_limit_date,
    price,
    freight_value;