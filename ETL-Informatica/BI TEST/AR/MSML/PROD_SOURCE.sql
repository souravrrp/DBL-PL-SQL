/* Formatted on 8/11/2020 2:37:20 PM (QP5 v5.354) */
SELECT DISTINCT
       PId,
       CASE WHEN p.PUnit = 'MSML' THEN 'COTTON' ELSE p.PUnit END
           AS CATEGORY,
       p.pprocesstype,
       p.PDate,
       --sum(p.PProd) ProductionQty
       p.PProd
           ProductionQty
  FROM dbo.tblProduction p