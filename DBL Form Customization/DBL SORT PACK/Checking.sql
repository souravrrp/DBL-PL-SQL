/* Formatted on 1/10/2021 12:02:59 PM (QP5 v5.354) */
  SELECT gbh.batch_no,
         --sum(spl.production_quantity)
         SUM (  apps.inv_convert.inv_um_convert (sph.product_item_id,
                                                 '',
                                                 1,
                                                 'CTN',
                                                 'SQM',
                                                 '',
                                                 '')
              * spl.production_quantity)    prod_qty
    --sph.*
    --spl.*
    --gbh.*
    FROM gme.gme_batch_header        gbh,
         xxdbl.xxdbl_sort_pack_header sph,
         xxdbl.xxdbl_sort_pack_lines spl
   WHERE     1 = 1
         AND gbh.batch_ID = sph.batch_id
         AND sph.sort_pack_header_id = spl.sort_pack_header_id
         --AND sph.sort_pack_header_id = 8991
         --AND sph.batch_no = 3319
         --AND total_fired_tiles='341139'
         AND spl.grade_code != 'REJECTION'
         AND sph.status = 'APPROVED'
         --AND sph.oprn_no LIKE '%SORTING%'
         AND TO_CHAR (sph.transaction_date, 'DD-MON-RRRR') BETWEEN :p_date_from
                                                               AND :p_date_to
         --AND TO_CHAR (sph.transaction_date, 'DD-MON-RRRR') = '30-AUG-2020'
         AND ( :p_item_code IS NULL OR (sph.product_item_code = :p_item_code))
         AND ( :p_batch_no IS NULL OR (gbh.batch_no = :p_batch_no))
GROUP BY gbh.batch_no, sph.product_item_id
--ORDER BY sph.creation_date DESC
;
--------------------------------------------------------------------------------

  SELECT *
    FROM xxdbl.xxdbl_sort_pack_header sph
   WHERE     1 = 1
         AND sph.batch_no = 4520
         AND sph.attribute1 = '4520-090121-C-0002'
         AND sph.sort_pack_header_id = 13626
ORDER BY creation_date DESC;

SELECT spl.*
  FROM xxdbl.xxdbl_sort_pack_lines spl
 WHERE     1 = 1
       --AND PHASE_LINE_NUMBER = 'Phase1'
       --AND SORTING_LINE='Sorting Line1'
       --AND SHIFT='C'
       --AND SORTING_LINE='Glaze Line4'
       --and OPRN_NO='TF_LOADER'
       --AND sph.sort_pack_header_id = 8991
       --AND total_fired_tiles='341139'
       AND spl.sort_pack_line_id = 42730
       AND spl.sort_pack_header_id = 13626;

--------------------------------------------------------------------------------

  SELECT spl.*
    --spl.*
    FROM xxdbl.xxdbl_sort_pack_header sph, xxdbl.xxdbl_sort_pack_lines spl
   WHERE     1 = 1
         AND sph.sort_pack_header_id = spl.sort_pack_header_id
         --AND PHASE_LINE_NUMBER = 'Phase1'
         --AND SHIFT='C'
         --AND TO_CHAR (sph.TRANSACTION_DATE, 'DD-MON-RRRR') = '28-OCT-2020'
         --AND SORTING_LINE = 'Sorting Line1'
         --and OPRN_NO='TF_LOADER'
         AND sph.attribute1 = '4520-090121-C-0002'
         --AND spl.sort_pack_line_id = 42735
         AND sph.sort_pack_header_id = 13626
         --AND total_fired_tiles='341139'
         AND sph.batch_no = '4520'
ORDER BY sph.creation_date DESC;



UPDATE xxdbl.xxdbl_sort_pack_lines spl
   SET PHASE_LINE_NUMBER = 'Phase3', SORTING_LINE = 'Sorting Line3'
 WHERE     1 = 1
       AND PHASE_LINE_NUMBER = 'Phase1'
       AND SORTING_LINE = 'Sorting Line1'
       --AND sph.attribute1 = '4520-090121-C-0002'
       --AND SHIFT='C'
       --AND TO_CHAR (sph.TRANSACTION_DATE, 'DD-MON-RRRR') = '28-OCT-2020'
       --AND SORTING_LINE='Glaze Line4'
       --and OPRN_NO='TF_LOADER'
       AND spl.sort_pack_line_id=42730
       --AND    sph   . batch_no         =  '3240'
       --AND total_fired_tiles='341139'
       AND spl.sort_pack_header_id = 13626;