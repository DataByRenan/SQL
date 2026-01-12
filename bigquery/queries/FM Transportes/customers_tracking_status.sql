-- DROP TABLE IF EXISTS `SET_YOUR_DATASET_AND_TABLE`;
-- CREATE TABLE `SET_YOUR_DATASET_AND_TABLE` AS

WITH status AS (
  SELECT 0 AS codigo, "Pedido Criado | Aguardando Postagem Remetente" AS status UNION ALL
  SELECT 1, "Encomenda Entregue" UNION ALL
  SELECT 6, "Endereço Errado| Endereço Insuficiente | Número Não Localizado" UNION ALL
  SELECT 10, "Sinistro Liquidado" UNION ALL
  SELECT 13, "Endereço Fora do Perímetro Urbano | Zona Rural" UNION ALL
  SELECT 14, "Mercadoria Avariada" UNION ALL
  SELECT 15, "Embalagem em Análise" UNION ALL
  SELECT 21, "Destinatário Ausente | Local Fechado" UNION ALL
  SELECT 25, "Em Processo de Devolução" UNION ALL
  SELECT 27, "Roubo de Carga" UNION ALL
  SELECT 29, "Retirar Objeto nos Correios" UNION ALL
  SELECT 30, "Extravio de Carga" UNION ALL
  SELECT 38, "Encomenda Postada nos Correios" UNION ALL
  SELECT 39, "Destinatário Mudou-se" UNION ALL
  SELECT 41, "Destinatário Desconhecido" UNION ALL
  SELECT 48, "Problemas Diversos na Entrega" UNION ALL
  SELECT 49, "Área Restrita de Acesso" UNION ALL
  SELECT 51, "Endereço Não Visitado" UNION ALL
  SELECT 52, "Recusado na Entrega" UNION ALL
  SELECT 56, "Entrega Cancelada" UNION ALL
  SELECT 57, "Encomenda Aguardando Tratativa" UNION ALL
  SELECT 58, "Favor Desconsiderar Informação Anterior" UNION ALL
  SELECT 61, "Devolvida ao Remetente" UNION ALL
  SELECT 64, "Aguardando Reenvio | Nova Tentativa" UNION ALL
  SELECT 83, "Coleta Realizada" UNION ALL
  SELECT 90, "Encomenda Finalizada" UNION ALL
  SELECT 92, "Encomenda Retida para Analise | Posto Fiscal" UNION ALL
  SELECT 93, "Problemas Operacionais" UNION ALL
  SELECT 95, "Falta de Complemento Físico" UNION ALL
  SELECT 101, "Encomenda Despachada" UNION ALL
  SELECT 102, "Encomenda em Transito | Transferencia entre unidades" UNION ALL
  SELECT 104, "Processo de Entrega Iniciado" UNION ALL
  SELECT 106, "Encomenda Conferida" UNION ALL
  SELECT 107, "Encomenda Apreendida" UNION ALL
  SELECT 108, "Em Rota | Preparando para entrega" UNION ALL
  SELECT 109, "Devolução Recusada" UNION ALL
  SELECT 110, "Transferencia entre unidades" UNION ALL
  SELECT 111, "Devolução em andamento ao remetente"
)



SELECT
  a.tracking_code,
  a.order_number,
  IF(a.received_by = 'nan', '', a.received_by) AS received_by,
  DATETIME(a.updated_at) AS updated_at,
  a.status AS status_code,
  b.status AS status_description 
FROM `fm_transportes_trackings_raw` a
JOIN status b

ON a.status = b.codigo

QUALIFY
  ROW_NUMBER() OVER (
    PARTITION BY tracking_code
    ORDER BY updated_at DESC
  ) = 1;
