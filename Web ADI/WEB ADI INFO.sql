/* Formatted on 7/12/2020 12:51:43 PM (QP5 v5.287) */
SELECT DISTINCT bit.application_id APP_ID,
                bit.user_name INTEGRATOR_NAME,
                bit.integrator_code INTEGRATOR_CODE,
                blcv.layout_code INTEGRATOR_LAYOUT,
                bm.mapping_code INTEGRATOR_MAPPING,
                biv.interface_name API,
                biv.upload_type TYPE,
                bc.content_code
  FROM bne_integrators_tl bit,
       bne_layout_cols_v blcv,
       bne_layouts_b bl,
       bne_interfaces_vl biv,
       bne_contents_vl BC,
       bne_mappings_vl BM
 WHERE     bit.INTEGRATOR_CODE = biv.INTEGRATOR_CODE
       AND biv.interface_code = blcv.INTERFACE_CODE
       AND bit.integrator_code = bl.integrator_code
       AND bit.integrator_code = bc.integrator_code
       AND bit.integrator_code = bm.integrator_code
       --AND (UPPER (bit.USER_NAME) IS NULL) OR (UPPER (bit.USER_NAME) LIKE UPPER ('%' || :P_WEB_ADI || '%'))
       AND UPPER (bit.USER_NAME) LIKE UPPER ('Customized - Bill Upload Adi');

SELECT i.application_id,
       i.user_name,
       bi.interface_name,
       i.integrator_code,
       bi.upload_param_list_code,
       ba.attribute_code,
       ba.attribute1,
       ba.attribute2,
       l.layout_code
  FROM bne_integrators_vl i,
       bne_layouts_b l,
       bne_interfaces_b bi,
       bne_param_lists_b bpl,
       bne_attributes ba
 WHERE     1 = 1
       AND i.user_name = 'Customized - Bill Upload Adi'     -- <<WebADI Name>>
       AND bi.integrator_code = i.integrator_code
       AND i.integrator_code = l.integrator_code
       AND bi.upload_param_list_code = bpl.param_list_code
       AND bpl.attribute_code = ba.attribute_code;


SELECT biv.application_id,
       biv.integrator_code,
       biv.user_name,
       bib.interface_code,
       lo.LAYOUT_CODE,
       (SELECT user_name
          FROM BNE_LAYOUTS_TL
         WHERE LAYOUT_CODE = lo.LAYOUT_CODE)
          layoutname,
       (SELECT user_name
          FROM BNE_CONTENTS_TL
         WHERE content_code = cont.content_code)
          contentname,
       cont.content_code,
       cont.param_list_code,
       cont.content_class,
       (SELECT QUERY
          FROM BNE_STORED_SQL
         WHERE CONTENT_CODE = CONT.CONTENT_CODE)
          QUERY
  FROM bne_integrators_vl biv,
       bne_interfaces_b bib,
       BNE_LAYOUTS_B lo,
       BNE_CONTENTS_b cont
 WHERE     1 = 1
       --AND upper(user_name) like '%WEB%'
       AND bib.integrator_code = biv.integrator_code
       AND lo.integrator_code = biv.integrator_code
       AND cont.integrator_code = biv.integrator_code;


  SELECT integrator_app_id || ':' || integrator_code integrators,
         application_id || ':' || layout_code layouts
    FROM bne_layouts_b
   WHERE integrator_app_id = 101
ORDER BY 1, 2