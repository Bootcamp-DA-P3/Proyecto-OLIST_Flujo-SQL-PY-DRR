SELECT
    CASE
        WHEN LOWER(TRIM(seller_city)) IN (
            'sao paulo',
            'sao paulo sp',
            'sao paulo / sao paulo',
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