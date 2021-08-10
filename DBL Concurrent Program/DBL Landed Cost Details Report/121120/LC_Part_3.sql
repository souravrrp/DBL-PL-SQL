/* Formatted on 11/14/2020 9:11:51 AM (QP5 v5.287) */
  SELECT fa.asset_number,
         fa.asset_id,
         lc.lc_number,
         fa.description,
         fai.feeder_system_name,
         fai.date_effective,
         0 - SUM (NVL (fixed_assets_cost, 0)) amount
    FROM fa_additions fa, xx_lc_details lc, fa_invoice_details_v fai
   WHERE     fa.asset_id = fai.asset_id
         AND fa.attribute15 = lc.lc_number
         AND lc_status = 'Y'
-- and lc_number='DPCDAK211710'
GROUP BY fa.asset_number,
         fa.asset_id,
         lc.lc_number,
         fa.description,
         fai.feeder_system_name,
         fai.date_effective
ORDER BY fa.asset_number