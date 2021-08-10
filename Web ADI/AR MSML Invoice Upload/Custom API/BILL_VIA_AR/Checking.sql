/* Formatted on 6/10/2020 3:37:12 PM (QP5 v5.287) */

SELECT user_id FROM fnd_user WHERE USER_ID=apps.fnd_global.user_id;

select organization_id from org_organization_definitions where organization_id=fnd_profile.value ('MFG_ORGANIZATION_ID');

SELECT ou.short_code FROM hr_operating_units ou WHERE ORGANIZATION_ID=apps.fnd_global.org_id;

SELECT user_id FROM fnd_user WHERE USER_ID='5429'--fnd_profile.value ('MFG_ORGANIZATION_ID')


select OPERATING_UNIT,
   ORG_ID,
   CUSTOMER_NUMBER,
   CUSTOMER_ID,
   CUSTOMER_NAME,
   CUSTOMER_TYPE,
   BILL_CURRENCY,
   BILL_CATEGORY,
   EXCHANCE_RATE,
   LAST_UPDATE_DATE,
   LAST_UPDATED_BY,
   LAST_UPDATE_LOGIN,
       CREATED_BY,
   CREATION_DATE,
   BILL_TYPE
   ,stg.*
    from apps.ar_bill_upload_adi_stg stg;

SELECT hou.ORGANIZATION_ID, hou.NAME
--  INTO l_organization_id, l_operating_unit
  FROM hr_organization_units hou
 WHERE hou.NAME = :p_organization_name;
 

SELECT CUSTOMER_ID, CUSTOMER_NUMBER, CUSTOMER_NAME,DECODE(CUSTOMER_TYPE,'R','External','I','Internal') 
  INTO l_CUSTOMER_ID, l_CUSTOMER_NUMBER, l_CUSTOMER_NAME , L_CUSTOMER_TYPE
  FROM ar_customers ac
 WHERE CUSTOMER_NUMBER = :P_CUSTOMER_NUMBER;
 
 SELECT
 XX_COM_PKG.GET_SEQUENCE_VALUE('XX_AR_BILLS_HEADERS_ALL', 'BILL_HEADER_ID') SEQ INTO l_bill_header_id
 FROM
 DUAL;
 
 SELECT REPLACE (short_code, ' ', '') OP, xx_get_bill_number (short_code) SEQ, REPLACE (short_code, ' ', '') || DECODE (REPLACE (short_code, ' ', ''), NULL, NULL, '/') || xx_get_bill_number (REPLACE (short_code, ' ', '')) OP_SQ
--     INTO v_short_code
     FROM hr_operating_units
    WHERE organization_id = :xx_ar_bills_headers_all--.org_id
    ;

   SELECT xx_get_bill_number (v_short_code)
     --INTO v_do_seq
     FROM DUAL;

-- Generate DO number
   SELECT v_short_code || DECODE (v_short_code, NULL, NULL, '/') || v_do_seq
     INTO v_bill_number
     FROM DUAL;
 

SELECT xxdbl_bill_chalan_no_s.NEXTVAL
--        INTO l_seq
        FROM DUAL;

      
         SELECT ou.short_code || '/' || TRIM (LPAD (xxdbl_bill_chalan_no_s.NEXTVAL, 5, '0')) SEQ
           --INTO l_short_code
           FROM hr_operating_units ou
          WHERE ou.NAME = :operating_unit;
          
          ou.short_code
                || '/'
                || TRIM (LPAD (xxdbl_bill_chalan_no_s.NEXTVAL, 5, '0'))
                
                
          SELECT hou.NAME
                || '/'
                || TRIM (LPAD (xxdbl_bill_chalan_no_s.NEXTVAL, 5, '0'))
            --  INTO l_organization_id, l_operating_unit
              FROM hr_organization_units hou
             WHERE hou.NAME = :p_organization_name;
                            
                
          /* Formatted on 6/11/2020 10:43:01 AM (QP5 v5.287) */
  SELECT xfi.item_code,
         xfi.item_name,
         xfi.uom,
         xfi.ORGANIZATION
    FROM xxdbl_fg_items_v xfi
   WHERE :xx_ar_bills_headers_all.operating_unit LIKE
            '%' || xfi.ORGANIZATION || '%'
ORDER BY xfi.item_code;

  SELECT xfi.item_code,
         xfi.item_name,
         xfi.uom,
         xfi.ORGANIZATION
    FROM xxdbl_fg_items_v xfi
   WHERE 1=1
   AND xfi.item_code=P_ITEM_CODE
   AND l_operating_unit LIKE
            '%' || xfi.ORGANIZATION || '%'
ORDER BY xfi.item_code;


UPDATE
    apps.ar_bill_upload_adi_stg
SET
    BILL_HEADER_ID = r_int_trans.BILL_HEADER_ID
WHERE
    SL_NO = r_int_trans.SL_NO;
    
    
    
    SELECT MEANING,LOOKUP_CODE FROM FND_LOOKUP_VALUES_VL 
WHERE LOOKUP_TYPE='DBL_BILL_CATEGORY'
AND ENABLED_FLAG='Y' 
AND TRUNC(SYSDATE) BETWEEN TRUNC(START_DATE_ACTIVE) AND NVL(TRUNC(END_DATE_ACTIVE),TRUNC(SYSDATE));


SELECT   pha.segment1, pha.po_header_id,
         INITCAP (pha.type_lookup_code) po_type, pv.vendor_name supplier,
         cl.legal_entity_name po_legal_entity,pha.*
    FROM po_headers_all pha, po_vendors pv, xxdbl_company_le_mapping_v cl
   WHERE pha.type_lookup_code IN ('BLANKET', 'STANDARD')
     AND NVL (pha.authorization_status, 'INCOMPLETE') = 'APPROVED'
     AND pha.approved_flag = 'Y'
     AND NVL (pha.cancel_flag, 'N') = 'N'
     AND pha.vendor_id = pv.vendor_id(+)
     AND cl.org_id = pha.org_id
     AND UPPER (cl.legal_entity_name) LIKE
             RTRIM (UPPER (:xx_ar_bills_headers_all--.customer_name
             ), '.')
             || '%'
     AND EXISTS (SELECT 1
                   FROM xx_dbl_po_recv_adjust x
                  WHERE x.po_no = pha.segment1)
ORDER BY po_header_id, pha.segment1;

SELECT   pha.segment1, pha.po_header_id,
         INITCAP (pha.type_lookup_code) po_type, pv.vendor_name supplier,
         cl.legal_entity_name po_legal_entity,pla.unit_price
         ,(select DISTINCT MSI.segment1 from apps.mtl_system_items_vl msi where msi.inventory_item_id=pla.item_id) ITEM_CODE
         --,pla.*
    FROM po_headers_all pha, apps.po_lines_all pla, po_vendors pv, xxdbl_company_le_mapping_v cl
   WHERE pha.type_lookup_code IN ('BLANKET', 'STANDARD')
     AND NVL (pha.authorization_status, 'INCOMPLETE') = 'APPROVED'
     AND pha.approved_flag = 'Y'
     AND NVL (pha.cancel_flag, 'N') = 'N'
     AND pha.vendor_id = pv.vendor_id(+)
     AND cl.org_id = pha.org_id
     and pla.po_header_id=pha.po_header_id
     AND pha.segment1 = :P_PO_NUMBER
     --and exists(select 1 from apps.mtl_system_items_vl msi where msi.inventory_item_id=pla.item_id and msi.segment1 =:P_ITEM_CODE  )
     --and =:P_ITEM_CODE     --YRN20S100CVC54699919
     AND UPPER (cl.legal_entity_name) LIKE
             RTRIM (UPPER (:xx_ar_bills_headers_all--.customer_name
             ), '.')
             || '%'
     AND EXISTS (SELECT 1
                   FROM xx_dbl_po_recv_adjust x
                  WHERE x.po_no = pha.segment1)
--ORDER BY po_header_id, pha.segment1
;


SELECT   pha.segment1, pla.unit_price
    FROM po_headers_all pha, apps.po_lines_all pla, po_vendors pv, xxdbl_company_le_mapping_v cl
   WHERE pha.type_lookup_code IN ('BLANKET', 'STANDARD')
     AND NVL (pha.authorization_status, 'INCOMPLETE') = 'APPROVED'
     AND pha.approved_flag = 'Y'
     AND NVL (pha.cancel_flag, 'N') = 'N'
     AND pha.vendor_id = pv.vendor_id(+)
     AND cl.org_id = pha.org_id
     and pla.po_header_id=pha.po_header_id
     AND pha.segment1 = :P_PO_NUMBER
     and exists(select 1 from apps.mtl_system_items_vl msi where msi.inventory_item_id=pla.item_id and msi.segment1 =:P_ITEM_CODE )
     --and =:P_ITEM_CODE     --YRN20S100CVC54699919
     AND UPPER (cl.legal_entity_name) LIKE
             RTRIM (UPPER (:xx_ar_bills_headers_all--.customer_name
             ), '.')
             || '%'
     AND EXISTS (SELECT 1
                   FROM xx_dbl_po_recv_adjust x
                  WHERE x.po_no = pha.segment1);


execute APPS.ar_bill_upload_pkg.cust_upload_data_to_staging('MSML','2100','BDT','Yarn Export',84,'11-JUN-20','Sample',25,'09-JUN-20','YRN34S100CVC53820513',22,10,1);

execute APPS.ar_bill_upload_pkg.cust_import_data_to_interface;