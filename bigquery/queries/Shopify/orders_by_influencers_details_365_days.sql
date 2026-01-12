-- DROP TABLE IF EXISTS `SET_YOUR_DATASET_AND_TABLE`;
-- CREATE TABLE `SET_YOUR_DATASET_AND_TABLE` AS

WITH cupons AS (
  SELECT DISTINCT
    TRIM(LOWER(cupom)) AS cupom,
    comissao,
    parceria_ativa
  FROM `cupons_influencers_raw`
  WHERE cupom IS NOT NULL
), -- Tabela com os cupons de influencers


base_orders AS (
  SELECT
    a.id AS order_id,
    b.shipping_address_company AS cpf,
    DATE(a.created_at) AS created_at
  FROM `shopify_orders_raw` a
  JOIN `shopify_orders_details_raw` b
    ON a.id = b.order_id
  WHERE LOWER(a.financial_status) = 'paid'
    AND b.shipping_address_company IS NOT NULL
), -- Tabela com todos os pedidos para a contagem


purchase_number_por_cpf AS (
  SELECT
    order_id,
    cpf,
    created_at,
    ROW_NUMBER() OVER (
      PARTITION BY cpf
      ORDER BY created_at
    ) AS purchase_number
  FROM base_orders
), -- Contagem de quantas vezes o cliente comprou


orders_filtrados AS (
  SELECT
    a.id AS order_id,
    b.shipping_address_company AS cpf,
    a.email,
    a.name AS order_number_shopify,
    DATE(a.created_at) AS created_at,

    b.shipping_address_city, 
    b.shipping_address_province_code, 
    b.shipping_address_latitude, 
    b.shipping_address_longitude,

    LOWER(a.fulfillment_status) AS fulfillment_status, 
    LOWER(a.financial_status) AS financial_status,
    a.total_price,

    ROUND(
      COALESCE(a.totallineitemspriceshopamount, 0)
      - COALESCE(a.totalshippingpricepresentmentamount, 0),
      2
    ) AS valor_base_para_comissao,

    CASE
      WHEN c.parceria_ativa = 'Sim' THEN
        ROUND(
          (
            COALESCE(a.totallineitemspriceshopamount, 0)
            - COALESCE(a.totalshippingpricepresentmentamount, 0)
          ) * (c.comissao / 100),
          2
        )
      ELSE 0
    END AS valor_comissao,

    UPPER(c.cupom) AS cupom,
    pn.purchase_number

  FROM `shopify_orders_raw` a

  JOIN `shopify_orders_details_raw` b
    ON a.id = b.order_id

  JOIN purchase_number_por_cpf pn
    ON pn.order_id = a.id

  JOIN UNNEST(SPLIT(LOWER(COALESCE(a.tags, '')), ',')) AS tag
  JOIN cupons c
    ON TRIM(tag) = c.cupom

  WHERE DATE(a.created_at)
    BETWEEN DATE_SUB(CURRENT_DATE(), INTERVAL 365 DAY)
    AND CURRENT_DATE()
)


SELECT *
FROM orders_filtrados;
