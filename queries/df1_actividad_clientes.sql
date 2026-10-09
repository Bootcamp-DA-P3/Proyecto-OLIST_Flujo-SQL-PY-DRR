-- GRANO DECLARADO: Una fila = Actividad de compra de un cliente
-- Por actividad de compra entendemos método de pago, satisfacción y lugar desde donde se realiza el pedido

-- Preparamos la geolocalización promediada e indexada
DROP TABLE IF EXISTS temp_geolocation_clean;

CREATE TABLE temp_geolocation_clean AS
SELECT 
    geolocation_zip_code_prefix,
    AVG(geolocation_lat) AS geolocation_lat,
    AVG(geolocation_lng) AS geolocation_lng,
    MAX(geolocation_city) AS geolocation_city,
    MAX(geolocation_state) AS geolocation_state
FROM geolocation
GROUP BY geolocation_zip_code_prefix;

ALTER TABLE temp_geolocation_clean ADD PRIMARY KEY (geolocation_zip_code_prefix);

-- CREAMOS EL NUEVO DATAFRAME (AGRUPANDO PAGOS Y REVIEWS)

DROP TABLE IF EXISTS actividad_de_clientes;

CREATE TABLE actividad_de_clientes AS
SELECT 
    -- Columnas de customers (incluye customer_unique_id)
    c.customer_id,
    c.customer_unique_id,
    c.customer_zip_code_prefix,
    c.customer_city,
    c.customer_state,
    
    -- Columnas de orders
    o.order_id,
    o.order_status,
    o.order_purchase_timestamp,
    o.order_approved_at,
    o.order_delivered_carrier_date,
    o.order_delivered_customer_date,
    o.order_estimated_delivery_date,
    
    -- Columnas de order_payments (agrupados por pedido)
    p.payment_sequential,
    p.payment_type,
    p.payment_installments,
    p.payment_value,
    
    -- Columnas de order_reviews (agrupadas por pedido)
    r.review_id,
    r.review_score,
    r.review_comment_title,
    r.review_comment_message,
    r.review_creation_date,
    r.review_answer_timestamp,
    
    -- Columnas de geolocation
    g.geolocation_lat,
    g.geolocation_lng,
    g.geolocation_city AS geo_city,
    g.geolocation_state AS geo_state

FROM orders o
LEFT JOIN customers c 
    ON o.customer_id = c.customer_id

-- 1. SUBPROBLEMA RESUELTO: Agrupamos pagos para consolidar 1 fila por pedido
LEFT JOIN (
    SELECT 
        order_id,
        MIN(payment_sequential) AS payment_sequential,
        GROUP_CONCAT(DISTINCT payment_type SEPARATOR '/') AS payment_type,
        MAX(payment_installments) AS payment_installments,
        SUM(payment_value) AS payment_value
    FROM order_payments
    GROUP BY order_id
) p ON o.order_id = p.order_id

-- 2. SUBPROBLEMA RESUELTO: Agrupamos reviews para consolidar 1 fila por pedido
LEFT JOIN (
    SELECT 
        order_id,
        MAX(review_id) AS review_id,
        AVG(review_score) AS review_score,
        MAX(review_comment_title) AS review_comment_title,
        MAX(review_comment_message) AS review_comment_message,
        MAX(review_creation_date) AS review_creation_date,
        MAX(review_answer_timestamp) AS review_answer_timestamp
    FROM order_reviews
    GROUP BY order_id
) r ON o.order_id = r.order_id

LEFT JOIN temp_geolocation_clean g 
    ON c.customer_zip_code_prefix = g.geolocation_zip_code_prefix;
    
-- REALIZAMOS LA LIMPIEZA DEL DATAFRAME CREADO

DROP TABLE IF EXISTS actividad_de_clientes_limpio;

CREATE TABLE actividad_de_clientes_limpio AS
SELECT 
    customer_id,
    customer_unique_id,
    customer_zip_code_prefix,
    -- Estandarizar textos: minusculas y sin espacios extras
    LOWER(TRIM(customer_city)) AS customer_city,
    LOWER(TRIM(customer_state)) AS customer_state,
    
    order_id,
    order_status,
    order_purchase_timestamp,
    order_approved_at,
    order_delivered_carrier_date,
    order_delivered_customer_date,
    order_estimated_delivery_date,
    
    -- Columna derivada 1: Dias reales de entrega
    DATEDIFF(order_delivered_customer_date, order_purchase_timestamp) AS delivery_days,
    
    -- Columna derivada 2: Indicador de retraso (1 si se entrego despues de lo estimado, 0 si no)
    CASE 
        WHEN order_delivered_customer_date > order_estimated_delivery_date THEN 1 
        ELSE 0 
    END AS is_late,
    
    payment_sequential,
    payment_type,
    payment_installments,
    payment_value,
    
    review_id,
    review_score,
    review_comment_title,
    review_comment_message,
    review_creation_date,
    review_answer_timestamp,
    
    geolocation_lat,
    geolocation_lng,
    -- Estandarizar textos de geolocalizacion
    LOWER(TRIM(geo_city)) AS geo_city,
    LOWER(TRIM(geo_state)) AS geo_state

FROM actividad_de_clientes

WHERE 
    -- 1. Filtrar solo pedidos entregados exitosamente
    order_status = 'delivered'
    
    -- 2. Eliminar pedidos no entregados o con fechas nulas
    AND order_delivered_customer_date IS NOT NULL
    
    -- 3. Asegurar importes validos y tipos definidos
    AND payment_value > 0
    AND payment_type != 'not_defined'
    
    -- 4. Inconsistencia temporal: la compra debe ser anterior a la entrega
    AND order_purchase_timestamp < order_delivered_customer_date;

-- SELECT FINAL PARA EXTRAER LOS DATOS DESDE PYTHON
SELECT * FROM actividad_de_clientes_limpio;
