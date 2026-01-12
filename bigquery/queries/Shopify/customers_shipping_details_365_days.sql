-- DROP TABLE IF EXISTS `SET_YOUR_DATASET_AND_TABLE`;
-- CREATE TABLE `SET_YOUR_DATASET_AND_TABLE` AS



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

FROM `shopify_orders_raw` a

JOIN `shopify_orders_details_raw` b
  ON a.id = b.order_id

WHERE DATE(a.created_at) BETWEEN DATE_SUB(CURRENT_DATE(), INTERVAL 365 DAY) AND CURRENT_DATE();
