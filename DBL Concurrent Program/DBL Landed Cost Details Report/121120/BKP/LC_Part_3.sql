Select  
 fa.asset_number,
 fa.asset_id,
 lc.lc_number,
 fa.description,
 fai.feeder_system_name,
 fai.date_effective,
 0 - SUM (NVL (fixed_assets_cost, 0)) amount
From
 fa_additions fa,
 xx_lc_details lc,
 fa_invoice_details_v fai
where fa.asset_id = fai.asset_id
 and fa.attribute15 = lc.lc_number
 and lc_status='Y'
-- and lc_number='DPCDAK211710'
group by
 fa.asset_number,
 fa.asset_id,
 lc.lc_number,
 fa.description,
 fai.feeder_system_name,
 fai.date_effective
 order by fa.asset_number