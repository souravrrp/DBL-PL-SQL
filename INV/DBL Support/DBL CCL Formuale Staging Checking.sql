/* Formatted on 8/23/2021 9:36:51 AM (QP5 v5.287) */
--xxdbl_thread_fml_upload_prc
--xx_dbl_formula.xxdbl_formula_insert

SELECT *
  FROM xxdbl_thread_formula_upd_stg
 WHERE 1 = 1                     --AND TRUNC (CREATION_DATE) = TRUNC (SYSDATE)
            AND ERROR_MSG IS NOT NULL
--and ERROR_MSG like '%Duplicate line no for item EPR1080-P%'
;
 
 
--DELETE xxdbl.xxdbl_thread_formula_upd_stg WHERE ERROR_MSG IS NOT NULL; COMMIT;

SELECT xxdbl.formula_no,
       xxdbl.formula_vers,
       xxdbl.formula_desc1,
       xxdbl.formula_class,
       NVL (xxdbl.inactive_ind, 0) inactive_ind,
       ood.organization_id,
       DECODE (xxdbl.formula_type, 'Yes', 1, 0) formula_type,
       DECODE (xxdbl.formula_status, 'Approved for General Use', 700, 700)
          formula_status,
       --fu.user_id owner_id,
       xxdbl.owner_code,
       DECODE (UPPER (xxdbl.line_type),  'PRODUCT', 1,  'INGREDIENT', -1,  2)
          line_type,
       xxdbl.line_no,
       xxdbl.item_no,
       xxdbl.qty,
       xxdbl.detail_uom,
       (TO_NUMBER (NVL (xxdbl.scrap_factor, 0)) / 100) scrap_factor,
       TO_NUMBER (DECODE (UPPER (xxdbl.scale_type_hdr), 'YES', 1, 0))
          scale_type_hdr,
       TO_NUMBER (DECODE (UPPER (xxdbl.scale_type_hdr), 'YES', 1, 0))
          scale_type_dtl,
       xxdbl.cost_alloc,
       --xxdbl.by_product_type,
       DECODE (UPPER (xxdbl.by_product_type),
               'SAMPLE', 'S',
               'REWORK', 'R',
               'WASTE', 'W',
               'YIELD', 'Y')
          by_product_type,
       DECODE (UPPER (xxdbl.contribute_yield_ind), 'YES', 'Y', 'N')
          contribute_yield_ind,
       DECODE (UPPER (xxdbl.contribute_step_qty_ind), 'YES', 'Y', 'N')
          contribute_step_qty_ind,
       DECODE (
          UPPER (xxdbl.line_type),
          'PRODUCT', 1,
          DECODE (UPPER (xxdbl.prod_or_ingr_scale_type),
                  'PROPORTIONAL', 1,
                  'FIXED', 0,
                  'INTEGER', 2,
                  1)                                    -- changed 21-Nov-2019
                    )
          prod_or_ingr_scale_type,
       DECODE (
          UPPER (
             (SUBSTR (xxdbl.yield_or_consumption_type,
                      1,
                      (LENGTH (xxdbl.yield_or_consumption_type))))),
          'AUTOMATIC', 0,
          'MANUAL', 1,
          'INCREMENTAL', 2,
          'AUTOMATIC BY STEP', 3)
          yield_or_consumption_type,            -- added by Jagan on 03Sep2014
       xxdbl.attribute3,
       xxdbl.attribute1 comments,      -- Added By Manas on 06-Jan-2016 Starts
       xxdbl.dtl_attribute1,             -- Added By Manas on 06-Jan-2016 Ends
       -- Added by Manas for Defect ID 1751 Starts

       xxdbl.scale_multiple,
       xxdbl.rounding_direction,
       xxdbl.scale_rounding_variance, -- Added by Manas for Defect ID 1751 Ends
       NVL (xxdbl.phantom_type, 0) phantom_type
  FROM xxdbl_thread_formula_upd_stg xxdbl, org_organization_definitions ood --,
 --fnd_user fu
 WHERE xxdbl.owner_organization_code = ood.organization_code --AND xxdbl.owner_code = fu.user_name
--AND xxdbl.formula_no = :p_formula_no --AND xxdbl.verify_flag IS NULL
--AND NVL (xxdbl.verify_flag, 'N') != 'Y'
--AND NVL (batch_number, -1) = NVL (:p_batch_number, NVL (batch_number, -1))
;

SELECT DISTINCT formula_no, formula_vers, attribute3
  FROM xxdbl_thread_formula_upd_stg
 WHERE attribute3 IS NOT NULL