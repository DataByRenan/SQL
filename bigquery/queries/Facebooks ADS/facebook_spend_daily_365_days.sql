-- DROP TABLE IF `EXISTS SET_YOUR_DATASET_AND_TABLE`;

-- CREATE `TABLE SET_YOUR_DATASET_AND_TABLE` AS 

-- Query possui ajuste automático com o repasse de impostos por parte do Facebook a partir de 05/01/2026

SELECT

CAST(metric_date AS DATE) AS metric_date,

ROUND(
  SUM(
    CASE
      WHEN metric_date >= DATE '2026-01-05'
        THEN CAST(spend AS FLOAT64) * 1.1215
      ELSE CAST(spend AS FLOAT64)
    END
  ),
  2
) AS spend


FROM `facebook_adaccounts_raw`

WHERE metric_date BETWEEN DATE_SUB(CURRENT_DATE(), INTERVAL 365 DAY) AND CURRENT_DATE()


GROUP BY metric_date
