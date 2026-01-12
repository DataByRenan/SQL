MERGE `YOUR_TABLE_TO_BE_UPDATED` T

USING (
  WITH fee AS (
    SELECT 1 AS installments, 0 AS percentage UNION ALL
    SELECT 2, 0 UNION ALL
    SELECT 3, 0 UNION ALL
    SELECT 4, 0 UNION ALL
    SELECT 5, 0 UNION ALL
    SELECT 6, 0 UNION ALL
    SELECT 7, 0 UNION ALL
    SELECT 8, 0 UNION ALL
    SELECT 9, 0 UNION ALL
    SELECT 10, 0 UNION ALL
    SELECT 11, 0 UNION ALL
    SELECT 12, 0
  ) -- CTE parcelas, utilize a sua tabela de taxas

  SELECT 
    CAST(a.id AS STRING) AS id, 
    DATETIME(a.created_at, "America/Sao_Paulo") AS created_at_brasilia,
    a.customer_name,
    a.customer_email,
    ROUND(b.charges_amount, 2) AS charges_amount,

    CASE
      WHEN b.charges_status = 'paid' AND b.charges_payment_method = 'credit_card' THEN 0.90
      WHEN b.charges_status = 'failed' AND b.charges_payment_method = 'credit_card' THEN 0.30
      ELSE 0
    END AS cost,

    CASE
      WHEN b.charges_payment_method = 'credit_card' AND b.charges_status = 'paid' 
        THEN ROUND(b.charges_amount * COALESCE(f.percentage, 0), 2)
      WHEN b.charges_payment_method = 'pix' AND b.charges_status = 'paid'
        THEN ROUND(b.charges_amount * 0.0092, 2)
      ELSE 0
    END AS processing_fee,

    CASE
      WHEN b.charges_status = 'paid' AND b.charges_payment_method = 'credit_card'
        THEN ROUND(b.charges_amount - (b.charges_amount * COALESCE(f.percentage, 0) + 0.90), 2)
      WHEN b.charges_status = 'paid' AND b.charges_payment_method = 'pix'
        THEN ROUND(b.charges_amount - b.charges_amount * 0.0092, 2)
      ELSE 0
    END AS net_amount,

    CAST(b.charges_last_transaction_installments AS INT64) AS installments,
    b.charges_payment_method AS charges_payment_method,
    b.charges_status AS charges_status

  FROM `pagarme_orders_raw` a
  JOIN `pagarme_orders_charges_raw` b
    ON a.id = b.order_id
  LEFT JOIN fee f
    ON f.installments = b.charges_last_transaction_installments
) S
ON T.id = S.id

-- Atualiza status se mudou nos últimos 90 dias
WHEN MATCHED 
  AND DATE(S.created_at_brasilia) >= DATE_SUB(CURRENT_DATE(), INTERVAL 90 DAY)
  AND T.status != S.charges_status
THEN UPDATE SET
  T.status = S.charges_status

-- Insere se for novo
WHEN NOT MATCHED THEN
INSERT (
  id, created_at_brasilia, customer_name, customer_email, charges_amount,
  payment_method, status, installments, cost, processing_fee, net_amount
)
VALUES (
  S.id, S.created_at_brasilia, S.customer_name, S.customer_email, S.charges_amount,
  S.charges_payment_method, S.charges_status, S.installments,
  S.cost, S.processing_fee, S.net_amount
);
