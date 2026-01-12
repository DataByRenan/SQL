MERGE INTO `SET_YOUR_TABLE_TO_BE_UPDATED` T
USING (
  SELECT 
    a.name AS order_number_shopify, 
    DATE(a.created_at) AS created_at,
    a.email, 
    b.shipping_address_city, 
    b.shipping_address_province_code, 
    b.shipping_address_latitude, 
    b.shipping_address_longitude, 
    a.totalshippingpricepresentmentamount, 
    a.total_discounts,
    LOWER(a.fulfillment_status) AS fulfillment_status, 
    LOWER(a.financial_status) AS financial_status, 
    a.tags 
  FROM `select_your_shopify_orders_table` a
  JOIN `select_your_shopify_orders_details_table` b
    ON a.id = b.order_id
  
  WHERE 
    CAST(a.name AS INT64) > (
      SELECT MAX(CAST(order_number_shopify AS INT64))
      FROM `SET_YOUR_TABLE_TO_BE_UPDATED`
    ) -- Conversão do ID para INT64 por ter o formato como STRING possa se tornar um número e permitir a atualização de valores acima do ID de maior número
     AND DATE(a.created_at) BETWEEN DATE_SUB(CURRENT_DATE(), INTERVAL 365 DAY) AND CURRENT_DATE()
) S -- Puxa até 365 dias
ON T.order_number_shopify = S.order_number_shopify   -- Agora permite MATCH
WHEN NOT MATCHED THEN
  INSERT ROW


WHEN MATCHED
  AND DATE(S.created_at) >= DATE_SUB(CURRENT_DATE(), INTERVAL 5 DAY)  -- apenas últimos 5 dias
  AND (
        T.fulfillment_status != S.fulfillment_status OR
        T.financial_status   != S.financial_status   OR
        T.total_discounts    != S.total_discounts    OR
        T.totalshippingpricepresentmentamount != S.totalshippingpricepresentmentamount
      ) -- Comparar as linhas para ver se os valores estão batendo


THEN UPDATE SET
  T.fulfillment_status = S.fulfillment_status,
  T.financial_status   = S.financial_status,
  T.total_discounts    = S.total_discounts,
  T.totalshippingpricepresentmentamount = S.totalshippingpricepresentmentamount,
  T.email = S.email,
  T.shipping_address_city = S.shipping_address_city,
  T.shipping_address_province_code = S.shipping_address_province_code,
  T.shipping_address_latitude = S.shipping_address_latitude,
  T.shipping_address_longitude = S.shipping_address_longitude,
  T.nome_transportador = S.nome_transportador,
  T.tags = S.tags,
  T.created_at = S.created_at -- Atualiza os valores que não bateram
  
; 
