/* Formatted on 9/28/2020 9:52:06 AM (QP5 v5.354) */
-----------------Batch------------------------------------

SELECT gbh.*
  FROM gme_batch_header gbh
 WHERE     gbh.batch_no = '3406'
       AND gbh.organization_id = (SELECT organization_id
                                    FROM org_organization_definitions ood
                                   WHERE ood.organization_code = '251');

-----------------Batch Material Details ------------------------------------

  SELECT ood.organization_code,
         gbh.batch_no,
         gbh.batch_id,
         gmd.*
    FROM gme_material_details        gmd,
         gme_batch_header            gbh,
         org_organization_definitions ood
   WHERE     gmd.batch_id = gbh.batch_id
         AND gbh.batch_no = '3406'
         AND gbh.organization_id = ood.organization_id
         AND ood.organization_code = '251'
ORDER BY gbh.batch_id, gmd.material_detail_id;

-----------------Batch Material Transactions Temp------------------------------------

  SELECT ood.organization_code,
         gbh.batch_no,
         gbh.batch_id,
         gmd.line_no,
         gmd.material_detail_id,
         gmd.line_type,
         mmtt.*
    FROM apps.mtl_material_transactions_temp mmtt,
         gme_material_details               gmd,
         gme_batch_header                   gbh,
         org_organization_definitions       ood
   WHERE     mmtt.transaction_source_type_id = 5
         AND mmtt.trx_source_line_id = gmd.material_detail_id
         AND mmtt.transaction_source_id = gbh.batch_id
         AND gmd.batch_id = gbh.batch_id
         AND gbh.batch_no = '3406'
         AND gbh.organization_id = ood.organization_id
         AND ood.organization_code = '251'
ORDER BY gbh.batch_id,
         gmd.line_type,
         gmd.material_detail_id,
         mmtt.transaction_temp_id;


-----------------Batch Material Transactions------------------------------------

  SELECT ood.organization_code,
         gbh.batch_no,
         gbh.batch_id,
         gmd.line_no,
         gmd.material_detail_id,
         gmd.line_type,
         mmt.*
    FROM mtl_material_transactions   mmt,
         gme_material_details        gmd,
         gme_batch_header            gbh,
         org_organization_definitions ood
   WHERE     1 = 1
         ---AND mmt.transaction_source_type_id = 5
         AND mmt.trx_source_line_id = gmd.material_detail_id
         AND mmt.transaction_source_id = gbh.batch_id
         AND gmd.batch_id = gbh.batch_id
         AND gbh.batch_no = '3406'
         AND gbh.organization_id = ood.organization_id
         AND ood.organization_code = '251'
ORDER BY gbh.batch_id,
         gmd.line_type,
         gmd.material_detail_id,
         mmt.transaction_id;


-----------------Lot Numbers ------------------------------------

  SELECT ood.organization_code,
         gbh.batch_no,
         gbh.batch_id,
         gmd.line_no,
         gmd.material_detail_id,
         gmd.line_type,
         mtln.*
    FROM mtl_transaction_lot_numbers mtln,
         mtl_material_transactions   mmt,
         gme_material_details        gmd,
         gme_batch_header            gbh,
         org_organization_definitions ood
   WHERE     mtln.transaction_id = mmt.transaction_id
         AND mmt.transaction_source_type_id = 5
         AND mmt.trx_source_line_id = gmd.material_detail_id
         AND gmd.batch_id = gbh.batch_id
         AND gbh.batch_no = '3040'
         AND gbh.organization_id = ood.organization_id
         AND ood.organization_code = '251'
ORDER BY gbh.batch_id,
         gmd.line_type,
         gmd.material_detail_id,
         gmd.line_type,
         mmt.transaction_id;

-----------------Reservations ------------------------------------


  SELECT ood.organization_code,
         gbh.batch_no,
         gbh.batch_id,
         gmd.line_no,
         gmd.material_detail_id,
         gmd.line_type,
         mr.*
    FROM mtl_reservations            mr,
         gme_material_details        gmd,
         gme_batch_header            gbh,
         org_organization_definitions ood
   WHERE     1=1
         --AND mr.demand_source_type_id = 5
         AND mr.demand_source_line_id = gmd.material_detail_id
         AND gmd.batch_id = gbh.batch_id
         --AND gbh.batch_no = '3406'
         AND gbh.organization_id = ood.organization_id
         --AND ood.organization_code = '251'
ORDER BY gbh.batch_id,
         gmd.line_type,
         gmd.material_detail_id,
         gmd.line_type;

-----------------Pending Product Lots ------------------------------------

  SELECT ood.organization_code,
         gbh.batch_no,
         gbh.batch_id,
         gmd.line_no,
         gmd.material_detail_id,
         gmd.line_type,
         gppl.*
    FROM gme_pending_product_lots    gppl,
         gme_material_details        gmd,
         gme_batch_header            gbh,
         org_organization_definitions ood
   WHERE     gppl.material_detail_id = gmd.material_detail_id
         AND gmd.batch_id = gbh.batch_id
         --AND gbh.batch_no = '3406'
         AND gbh.organization_id = ood.organization_id
         --AND ood.organization_code = '251'
ORDER BY gbh.batch_id,
         gmd.line_type,
         gmd.material_detail_id,
         gmd.line_type;


-----------------Requirements ------------------------------------

  SELECT ood.organization_code,
         gbh.batch_no,
         gbh.batch_id,
         gbr.*
    FROM gmf_batch_requirements      gbr,
         gme_batch_header            gbh,
         org_organization_definitions ood
   WHERE     gbr.batch_id = gbh.batch_id
         AND gbh.batch_no = '3406'
         AND gbh.organization_id = ood.organization_id
         AND ood.organization_code = '251'
ORDER BY gbr.requirement_id;