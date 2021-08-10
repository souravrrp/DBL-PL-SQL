/* Formatted on 9/13/2020 3:41:51 PM (QP5 v5.354) */
  SELECT CODE,
         Production_Date,
         TO_DATE ('01-Aug-2020', 'DD-Mon-RRRR')                                 AS StartDate,
         TO_DATE ('05-Aug-2020', 'DD-Mon-RRRR')                                 AS EndDate,
         CALIBRE                                                                AS CALIBER,
         TO_CHAR (SHADES, 'ddmmyy')                                             AS SHADE,
         SUM (A_GRADE)                                                          AS A_GRADE,
         SUM (A_SAMPLE_GRADE)                                                   AS A_SAMPLE_GRADE,
         SUM (B_GRADE)                                                          AS B_GRADE,
         SUM (B_SAMPLE_GRADE)                                                   AS B_SAMPLE_GRADE,
         SUM (BWC_GRADE)                                                        AS BWC_GRADE,
         SUM (REJECTION_GRADE)                                                  AS REJECTION_GRADE,
         MAX (LINE)                                                             AS LINE,
         (SELECT REMARKS
            FROM APPS.Q_DBLCL_PRODUCTION_STATUS_V
           WHERE     TO_DATE (START_DATE, 'DD-Mon-RRRR') =
                     TO_DATE ('01-Aug-2020', 'DD-Mon-RRRR')
                 AND TO_DATE (END_DATE, 'DD-Mon-RRRR') =
                     TO_DATE ('05-Aug-2020', 'DD-Mon-RRRR')
                 AND CERAMIC_LINE = 'All'
                 AND ROWNUM = 1)                                                AS REMARKS,
         (  SELECT ROUND (SUM (  apps.inv_convert.inv_um_convert (
                                     MAX (MSI.INVENTORY_ITEM_ID),
                                     '',
                                     1,
                                     'PCS',
                                     'SQM',
                                     '',
                                     '')
                               * SUM (S2.QUANTITY)),
                          2)    AS QUANTITY_SQM
              FROM gme.gme_material_details d,
                   gme.gme_batch_header    h,
                   apps.mtl_system_items_kfv msi,
                   xxdbl.XXDBL_KILN_HEADERS s,
                   xxdbl.XXDBL_KILN_LINE1  S1,
                   xxdbl.XXDBL_KILN_LINE2  S2,
                   APPS.MTL_ITEM_CATEGORIES_V MIC
             WHERE     d.batch_id = h.batch_id
                   AND d.inventory_item_id = msi.inventory_item_id
                   AND d.organization_id = msi.organization_id
                   AND d.batch_ID = s.BATCH_ID
                   AND s.KILN_HEADER_ID = S1.KILN_HEADER_ID
                   AND S1.KILN_LINE1_ID = S2.KILN_LINE1_ID
                   AND s1.KILN_HEADER_ID = S2.KILN_HEADER_ID
                   AND MSI.ORGANIZATION_ID = MIC.ORGANIZATION_ID
                   AND MSI.INVENTORY_ITEM_ID = MIC.INVENTORY_ITEM_ID
                   AND MIC.CATEGORY_SET_ID = 1100000061
                   AND d.LINE_TYPE = 1
                   AND s.OPRN_NO = 'KILN'
                   AND S1.KILN_DATE BETWEEN TO_DATE (
                                                   TO_CHAR (
                                                       TO_DATE ('01-Aug-2020',
                                                                'DD-Mon-RRRR'),
                                                       'MM-DD-YYYY')
                                                || ' 06:00:00',
                                                'MM-DD-YYYY HH24:MI:SS')
                                        AND TO_DATE (
                                                   TO_CHAR (
                                                         TO_DATE ('05-Aug-2020',
                                                                  'DD-Mon-RRRR')
                                                       + INTERVAL '1' DAY,
                                                       'MM-DD-YYYY')
                                                || ' 05:59:59',
                                                'MM-DD-YYYY HH24:MI:SS')
                   AND H.organization_id = 152
          GROUP BY h.BATCH_NO,
                   S1.LINE_NUMBER,
                   S1.SHIFT,
                   msi.concatenated_segments)                                   AS KILN_QTY_SQM,
         (SELECT ROUND (SUM (  apps.inv_convert.inv_um_convert (
                                   S.PRODUCT_ITEM_ID,
                                   '',
                                   1,
                                   CASE
                                       WHEN S1.UOM = 'CARTON' THEN 'CTN'
                                       ELSE 'PCS'
                                   END,
                                   'SQM',
                                   '',
                                   '')
                             * S1.PRODUCTION_QUANTITY),
                        2)    AS Cummalitive
            FROM gme.gme_batch_header        h,
                 xxdbl.xxdbl_sort_pack_header s,
                 xxdbl.xxdbl_sort_pack_lines S1,
                 APPS.FND_USER               FNU,
                 APPS.fm_form_mst            F
           WHERE     s.SORT_PACK_HEADER_ID = S1.SORT_PACK_HEADER_ID
                 AND h.batch_ID = s.BATCH_ID
                 AND s.OPRN_NO LIKE '%SORTING%'
                 AND h.organization_id = 152
                 AND FNU.USER_ID = S1.CREATED_BY
                 AND H.Formula_ID = F.Formula_ID
                 AND S.STATUS = 'APPROVED'
                 AND s.START_DATE_TIME BETWEEN   TO_DATE (
                                                        TO_CHAR (
                                                            TO_DATE (
                                                                '01-Aug-2020',
                                                                'DD-Mon-RRRR'),
                                                            'MM-DD-YYYY')
                                                     || ' 06:00:00',
                                                     'MM-DD-YYYY HH24:MI:SS')
                                               - (  TO_NUMBER (
                                                        TO_CHAR (
                                                            TO_DATE (
                                                                   TO_CHAR (
                                                                       TO_DATE (
                                                                           '01-Aug-2020',
                                                                           'DD-Mon-RRRR'),
                                                                       'MM-DD-YYYY')
                                                                || ' 06:00:00',
                                                                'MM-DD-YYYY HH24:MI:SS'),
                                                            'DD'))
                                                  - 1)
                                           AND TO_DATE (
                                                      TO_CHAR (
                                                            TO_DATE (
                                                                '05-Aug-2020',
                                                                'DD-Mon-RRRR')
                                                          + INTERVAL '1' DAY,
                                                          'MM-DD-YYYY')
                                                   || ' 05:59:59',
                                                   'MM-DD-YYYY HH24:MI:SS'))    AS MonthlyCumalitiveQty
    FROM (SELECT TO_CHAR (s.CREATION_DATE, 'DD-Mon-RRRR')
                     AS Production_Date,
                 S.SHIFT,
                 S1.PHASE_LINE_NUMBER,
                 F.FORMULA_NO
                     AS CODE,
                 CASE
                     WHEN S1.GRADE_CODE = 'A'
                     THEN
                           apps.inv_convert.inv_um_convert (S.PRODUCT_ITEM_ID,
                                                            '',
                                                            1,
                                                            'CTN',
                                                            'SQM',
                                                            '',
                                                            '')
                         * S1.PRODUCTION_QUANTITY
                     ELSE
                         0
                 END
                     A_GRADE,
                 CASE
                     WHEN S1.GRADE_CODE = 'A-SAMPLE'
                     THEN
                           apps.inv_convert.inv_um_convert (S.PRODUCT_ITEM_ID,
                                                            '',
                                                            1,
                                                            'CTN',
                                                            'SQM',
                                                            '',
                                                            '')
                         * S1.PRODUCTION_QUANTITY
                     ELSE
                         0
                 END
                     A_SAMPLE_GRADE,
                 CASE
                     WHEN S1.GRADE_CODE = 'B'
                     THEN
                           apps.inv_convert.inv_um_convert (S.PRODUCT_ITEM_ID,
                                                            '',
                                                            1,
                                                            'CTN',
                                                            'SQM',
                                                            '',
                                                            '')
                         * S1.PRODUCTION_QUANTITY
                     ELSE
                         0
                 END
                     B_GRADE,
                 CASE
                     WHEN S1.GRADE_CODE = 'B-SAMPLE'
                     THEN
                           apps.inv_convert.inv_um_convert (S.PRODUCT_ITEM_ID,
                                                            '',
                                                            1,
                                                            'CTN',
                                                            'SQM',
                                                            '',
                                                            '')
                         * S1.PRODUCTION_QUANTITY
                     ELSE
                         0
                 END
                     B_SAMPLE_GRADE,
                 CASE
                     WHEN S1.GRADE_CODE = 'BW/C'
                     THEN
                           apps.inv_convert.inv_um_convert (S.PRODUCT_ITEM_ID,
                                                            '',
                                                            1,
                                                            'CTN',
                                                            'SQM',
                                                            '',
                                                            '')
                         * S1.PRODUCTION_QUANTITY
                     ELSE
                         0
                 END
                     BWC_GRADE,
                 CASE
                     WHEN S1.GRADE_CODE = 'REJECTION'
                     THEN
                           apps.inv_convert.inv_um_convert (S.PRODUCT_ITEM_ID,
                                                            '',
                                                            1,
                                                            'CTN',
                                                            'SQM',
                                                            '',
                                                            '')
                         * S1.PRODUCTION_QUANTITY
                     ELSE
                         0
                 END
                     REJECTION_GRADE,
                 S1.CALIBRE,
                 S1.SHADES,
                 S1.PHASE_LINE_NUMBER
                     AS LINE,
                 S1.REMARKS_FROM_STORE
                     REMARKS
            FROM gme.gme_batch_header        h,
                 xxdbl.xxdbl_sort_pack_header s,
                 xxdbl.xxdbl_sort_pack_lines S1,
                 APPS.FND_USER               FNU,
                 APPS.fm_form_mst            F,
                 (SELECT organization_id,
                         INVENTORY_ITEM_ID,
                         SEGMENT1,
                         SEGMENT2
                    FROM apps.mtl_item_categories_v mic
                   WHERE     mic.organization_id = 152
                         AND CATEGORY_SET_NAME = 'DBL_SALES_CAT_SET') SI
           WHERE     s.SORT_PACK_HEADER_ID = S1.SORT_PACK_HEADER_ID
                 AND h.batch_ID = s.BATCH_ID
                 AND s.PRODUCT_ITEM_ID = SI.INVENTORY_ITEM_ID
                 AND h.organization_id = SI.organization_id
                 AND s.OPRN_NO LIKE '%SORTING%'
                 AND h.organization_id = 152
                 AND FNU.USER_ID = S1.CREATED_BY
                 AND H.Formula_ID = F.Formula_ID
                 AND s.START_DATE_TIME BETWEEN TO_DATE (
                                                      TO_CHAR (
                                                          TO_DATE (
                                                              '01-Aug-2020',
                                                              'DD-Mon-RRRR'),
                                                          'MM-DD-YYYY')
                                                   || ' 06:00:00',
                                                   'MM-DD-YYYY HH24:MI:SS')
                                           AND TO_DATE (
                                                      TO_CHAR (
                                                            TO_DATE (
                                                                '05-Aug-2020',
                                                                'DD-Mon-RRRR')
                                                          + INTERVAL '1' DAY,
                                                          'MM-DD-YYYY')
                                                   || ' 05:59:59',
                                                   'MM-DD-YYYY HH24:MI:SS')
                 AND S.STATUS = 'APPROVED'
                 AND S1.UOM = 'CARTON'
          UNION ALL
          SELECT TO_CHAR (s.CREATION_DATE, 'DD-Mon-RRRR')
                     AS Production_Date,
                 S.SHIFT,
                 S1.PHASE_LINE_NUMBER,
                 F.FORMULA_NO
                     AS CODE,
                 CASE
                     WHEN S1.GRADE_CODE = 'A'
                     THEN
                           apps.inv_convert.inv_um_convert (S.PRODUCT_ITEM_ID,
                                                            '',
                                                            1,
                                                            'PCS',
                                                            'SQM',
                                                            '',
                                                            '')
                         * S1.PRODUCTION_QUANTITY
                     ELSE
                         0
                 END
                     A_GRADE,
                 CASE
                     WHEN S1.GRADE_CODE = 'A-SAMPLE'
                     THEN
                           apps.inv_convert.inv_um_convert (S.PRODUCT_ITEM_ID,
                                                            '',
                                                            1,
                                                            'PCS',
                                                            'SQM',
                                                            '',
                                                            '')
                         * S1.PRODUCTION_QUANTITY
                     ELSE
                         0
                 END
                     A_SAMPLE_GRADE,
                 CASE
                     WHEN S1.GRADE_CODE = 'B'
                     THEN
                           apps.inv_convert.inv_um_convert (S.PRODUCT_ITEM_ID,
                                                            '',
                                                            1,
                                                            'PCS',
                                                            'SQM',
                                                            '',
                                                            '')
                         * S1.PRODUCTION_QUANTITY
                     ELSE
                         0
                 END
                     B_GRADE,
                 CASE
                     WHEN S1.GRADE_CODE = 'B-SAMPLE'
                     THEN
                           apps.inv_convert.inv_um_convert (S.PRODUCT_ITEM_ID,
                                                            '',
                                                            1,
                                                            'PCS',
                                                            'SQM',
                                                            '',
                                                            '')
                         * S1.PRODUCTION_QUANTITY
                     ELSE
                         0
                 END
                     B_SAMPLE_GRADE,
                 CASE
                     WHEN S1.GRADE_CODE = 'BW/C'
                     THEN
                           apps.inv_convert.inv_um_convert (S.PRODUCT_ITEM_ID,
                                                            '',
                                                            1,
                                                            'PCS',
                                                            'SQM',
                                                            '',
                                                            '')
                         * S1.PRODUCTION_QUANTITY
                     ELSE
                         0
                 END
                     BWC_GRADE,
                 CASE
                     WHEN S1.GRADE_CODE = 'REJECTION'
                     THEN
                           apps.inv_convert.inv_um_convert (S.PRODUCT_ITEM_ID,
                                                            '',
                                                            1,
                                                            'PCS',
                                                            'SQM',
                                                            '',
                                                            '')
                         * S1.PRODUCTION_QUANTITY
                     ELSE
                         0
                 END
                     REJECTION_GRADE,
                 S1.CALIBRE,
                 S1.SHADES,
                 S1.PHASE_LINE_NUMBER
                     AS LINE,
                 S1.REMARKS_FROM_STORE
                     REMARKS
            FROM gme.gme_batch_header        h,
                 xxdbl.xxdbl_sort_pack_header s,
                 xxdbl.xxdbl_sort_pack_lines S1,
                 APPS.FND_USER               FNU,
                 APPS.fm_form_mst            F,
                 (SELECT organization_id,
                         INVENTORY_ITEM_ID,
                         SEGMENT1,
                         SEGMENT2
                    FROM apps.mtl_item_categories_v mic
                   WHERE     mic.organization_id = 152
                         AND CATEGORY_SET_NAME = 'DBL_SALES_CAT_SET') SI
           WHERE     s.SORT_PACK_HEADER_ID = S1.SORT_PACK_HEADER_ID
                 AND s.PRODUCT_ITEM_ID = SI.INVENTORY_ITEM_ID
                 AND h.organization_id = SI.organization_id
                 AND h.batch_ID = s.BATCH_ID
                 AND s.OPRN_NO LIKE '%SORTING%'
                 AND h.organization_id = 152
                 AND FNU.USER_ID = S1.CREATED_BY
                 AND H.Formula_ID = F.Formula_ID
                 AND s.START_DATE_TIME BETWEEN TO_DATE (
                                                      TO_CHAR (
                                                          TO_DATE (
                                                              '01-Aug-2020',
                                                              'DD-Mon-RRRR'),
                                                          'MM-DD-YYYY')
                                                   || ' 06:00:00',
                                                   'MM-DD-YYYY HH24:MI:SS')
                                           AND TO_DATE (
                                                      TO_CHAR (
                                                            TO_DATE (
                                                                '31-Aug-2020',
                                                                'DD-Mon-RRRR')
                                                          + INTERVAL '1' DAY,
                                                          'MM-DD-YYYY')
                                                   || ' 05:59:59',
                                                   'MM-DD-YYYY HH24:MI:SS')
                 AND S.STATUS = 'APPROVED'
                 AND S1.UOM <> 'CARTON') TT
GROUP BY CODE,
         CALIBRE,
         SHADES,
         LINE,
         Production_Date
ORDER BY CODE,
         CALIBRE,
         SHADES,
         LINE