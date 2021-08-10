/* Formatted on 5/23/2021 10:37:40 AM (QP5 v5.287) */
SELECT *
  FROM xxdbl.xxdbl_om_order_upld_stg cct
 WHERE 1 = 1
--AND cct.cust_id = :p_cust_id
--AND cct.status IS NULL
--AND UPPER (cct.customer_name) LIKE UPPER ('%' || :p_customer_name || '%')
;
--UPDATE xxdbl.xxdbl_cust_creation_tbl cct SET cct.status=NULL WHERE cct.cust_id = :p_cust_id;

--TRUNCATE TABLE xxdbl.xxdbl_cust_update_stg_tbl;

--SELECT TRIM (LPAD (apps.xxdbl_cust_creation_s.NEXTVAL, 7, '0')) FROM DUAL;

------------------------------Order Details---------------------------------------------------

  SELECT OOH.ORDER_NUMBER ORDER_NO,
         ----HEADER INFO------------
         OOH.TRANSACTIONAL_CURR_CODE,
         OOL.PRICING_DATE,
         OOH.CUST_PO_NUMBER,
         OOH.SOLD_TO_ORG_ID,
         OOL.PRICE_LIST_ID,
         OOH.ORDERED_DATE,
         OOH.SHIPPING_METHOD_CODE,
         OOH.SOLD_FROM_ORG_ID,
         OOH.SALESREP_ID,
         OOH.ORDER_TYPE_ID,
         ----LINE INFO--------
         OOL.INVENTORY_ITEM_ID,
         OOL.ORDERED_QUANTITY,
         OOL.SHIP_FROM_ORG_ID,
         OOL.SUBINVENTORY,
         ------OTHERS INFO----
         OOH.ORG_ID,
         OOH.ORDER_NUMBER,
         OOH.HEADER_ID,
         OOL.LINE_ID,
         OOH.DEMAND_CLASS_CODE DEMAND_CLASS,
         OOH.CONTEXT ORD_HDR_CONTEXT,
         OOH.ATTRIBUTE4 ORD_HDR_CTXT_VAL,
         OOH.PACKING_INSTRUCTIONS STYLE_NUMBER,
         OOH.SALES_CHANNEL_CODE BUYER,
         OOH.BOOKED_DATE,
         OOH.HEADER_ID,
         OOL.LINE_ID,
         OOL.ORDERED_ITEM ITEM_CODE,
         (SELECT DESCRIPTION
            FROM INV.MTL_SYSTEM_ITEMS_B MSI
           WHERE     MSI.INVENTORY_ITEM_ID = OOL.INVENTORY_ITEM_ID
                 AND MSI.ORGANIZATION_ID = OOL.SHIP_FROM_ORG_ID)
            ITEM_DESCRIPTION,
         OOL.ORDER_QUANTITY_UOM UOM_CODE,
         OOL.SHIPMENT_PRIORITY_CODE DO_NUMBER,
         OOH.FLOW_STATUS_CODE ORDER_HEADER_STATUS,
         OOL.FLOW_STATUS_CODE ORDER_LINE_STATUS,
         OOL.SHIPPED_QUANTITY,
         OOL.INVOICED_QUANTITY,
         OOL.CANCELLED_QUANTITY,
         OOL.ACTUAL_SHIPMENT_DATE,
         OOL.UNIT_SELLING_PRICE,
         OOL.CONTEXT,
         OOL.ATTRIBUTE1 COLOR_OR_SHADE,
         OOL.ATTRIBUTE2,
         OOL.ATTRIBUTE3 COLOR_REF_NO,
         OOL.SHIP_TO_ORG_ID,
         OOL.LINE_TYPE_ID
    --,(OOL.UNIT_SELLING_PRICE*OOL.ORDERED_QUANTITY) AMOUNT
    --,OOH.*
    --,OOL.*
    --,CUST.*
    FROM APPS.OE_ORDER_LINES_ALL OOL, APPS.OE_ORDER_HEADERS_ALL OOH
   WHERE     1 = 1
         AND ( ( :P_ORG_ID IS NULL) OR (OOH.ORG_ID = :P_ORG_ID))
         AND OOH.HEADER_ID = OOL.HEADER_ID
         AND OOH.ORDER_NUMBER IN (2011010026367, 2011010026368)
         AND ( :P_ORDER_NUMBER IS NULL OR (OOH.ORDER_NUMBER = :P_ORDER_NUMBER)) --2011100000725 --2011100000727
         AND EXISTS
                (SELECT 1
                   FROM APPS.AR_CUSTOMERS A
                  WHERE     A.CUSTOMER_ID = OOL.SOLD_TO_ORG_ID
                        AND (   :P_CUSTOMER_NUMBER IS NULL
                             OR (A.CUSTOMER_NUMBER = :P_CUSTOMER_NUMBER))
                        --AND CUSTOMER_NUMBER IN ('187056')
                        AND (   :P_CUST_NAME IS NULL
                             OR (UPPER (A.CUSTOMER_NAME) LIKE
                                    UPPER ('%' || :P_CUST_NAME || '%'))))
ORDER BY OOH.ORDERED_DATE DESC;


  SELECT *
    FROM OE_ORDER_HEADERS_ALL OOH
   WHERE     ( ( :P_ORG_ID IS NULL) OR (OOH.ORG_ID = :P_ORG_ID))
         AND OOH.ORDER_NUMBER IN (2011010026367,
                                  2011010026373,
                                  2011010026374,
                                  2011010026375)
         AND ( :P_ORDER_NUMBER IS NULL OR (OOH.ORDER_NUMBER = :P_ORDER_NUMBER))
ORDER BY CREATION_DATE DESC;


  SELECT *
    FROM APPS.OE_ORDER_LINES_ALL OOL
   WHERE     ( ( :P_ORG_ID IS NULL) OR (OOL.SOLD_FROM_ORG_ID = :P_ORG_ID))
         AND OOL.HEADER_ID IN (492970, 492975)
ORDER BY LINE_ID DESC;

SELECT hou.organization_id, hou.name
  FROM hr_organization_units hou
 WHERE hou.name = :p_unit_name;

SELECT NVL (customer_number, 0), ac.*
  --INTO l_customer_number
  FROM apps.ar_customers ac
 WHERE UPPER (ac.customer_name) LIKE UPPER ('%' || :p_customer_name || '%');

SELECT *
  FROM HZ_CUST_ACCOUNTS hca
 WHERE     1 = 1
       AND (   :p_customer_number IS NULL
            OR (hca.account_number = :p_customer_number))
       --AND ATTRIBUTE_CATEGORY = 'Additional Information'
       --AND CUSTOMER_TYPE = 'I'
       AND UPPER (hca.account_name) LIKE
              UPPER ('%' || :p_customer_name || '%');


SELECT *
  FROM apps.hz_locations loc
 WHERE 1 = 1 --AND (   :p_location IS NULL OR (UPPER (loc.address1) LIKE UPPER ('%' || :p_location || '%')))
                                             --AND ACCOUNT_NUMBER IN ('20072')
                                                --AND HP.CATEGORY_CODE IS NULL
        AND UPPER (loc.address1) = UPPER ( :p_location);


SELECT ood.operating_unit,
       ood.organization_id,
       ou.set_of_books_id,
       ou.default_legal_context_id
  --INTO L_OPERATING_UNIT, L_ORGANIZATION_ID, L_SET_OF_BOOKS, L_LEGAL_ENTITY_ID
  FROM org_organization_definitions ood, hr_operating_units ou
 WHERE     1 = 1
       AND ood.operating_unit = ou.organization_id
       AND ood.organization_code = :p_organization_code;


SELECT ca.cust_account_id
  FROM hz_cust_accounts ca
 WHERE ca.account_number = :p_customer_no;


SELECT csua.site_use_id
  FROM 
       hz_cust_accounts ca,
       hz_cust_acct_sites_all casa,
       hz_cust_site_uses_all csua
 WHERE     ca.cust_account_id = casa.cust_account_id
       AND casa.cust_acct_site_id = csua.cust_acct_site_id
       AND csua.site_use_code = 'SHIP_TO'
       AND csua.primary_flag = 'Y'
       AND ca.status = 'A'
       AND csua.status = 'A'
       AND ca.account_number = :p_customer_number
       AND casa.org_id = :l_operating_unit;

SELECT ca.cust_account_id
  --              INTO l_operating_unit,
  --                   l_unit_name,
  --                   l_customer_id,
  --                   l_bill_site_id,
  --                   l_bill_site_use_id
  FROM apps.hz_cust_accounts ca,
       apps.hz_cust_site_uses_all csua,
       apps.hz_cust_acct_sites_all casa,
       apps.hz_parties hp,
       apps.hz_party_sites hps,
       apps.hz_locations loc
 WHERE     1 = 1
       AND csua.cust_acct_site_id = casa.cust_acct_site_id
       AND ca.cust_account_id = casa.cust_account_id
       AND casa.org_id = :l_operating_unit
       AND ca.status = 'A'
       AND csua.status = 'A'
       AND hp.party_id = ca.party_id
       AND hps.party_id = hp.party_id
       AND hps.location_id = loc.location_id
       AND hp.status = 'A'
       AND hps.status = 'A'
       AND hps.identifying_address_flag = 'Y'
       AND csua.site_use_code = 'BILL_TO'
       AND ca.account_number = :p_customer_no;

SELECT csua.site_use_id, sal.salesrep_id
  FROM hz_parties hp,
       hz_party_sites hps,
       hz_cust_accounts ca,
       hz_cust_acct_sites_all casa,
       hz_cust_site_uses_all csua,
       ra_territories ter,
       jtf_rs_salesreps sal
 WHERE     hp.party_id = hps.party_id
       AND ca.party_id = hp.party_id
       AND ca.cust_account_id = casa.cust_account_id
       AND casa.cust_acct_site_id = csua.cust_acct_site_id
       AND hps.party_site_id = casa.party_site_id
       AND csua.territory_id = ter.territory_id(+)
       AND csua.site_use_code = 'SHIP_TO'
       AND csua.primary_flag = 'Y'
       AND ca.status = 'A'
       AND csua.status = 'A'
       AND hp.status = 'A'
       AND hps.status = 'A'
       AND hps.identifying_address_flag = 'Y'
       AND ca.account_number = :p_customer_number
       AND casa.org_id = :l_operating_unit
       AND csua.primary_salesrep_id = sal.salesrep_id(+);

SELECT MSI.ORGANIZATION_ID,
       OOD.ORGANIZATION_CODE,
       OOD.ORGANIZATION_NAME,
       MSI.INVENTORY_ITEM_ID,
       MSI.SEGMENT1 ITEM_CODE,
       MSI.DESCRIPTION,
       MSI.PRIMARY_UOM_CODE,
       MSI.SECONDARY_UOM_CODE,
       MSI.ATTRIBUTE14 TEMPLATE_NAME,
       CAT.CATEGORY_SET_NAME CATEGORY_SET,
       CAT.CATEGORY_ID,
       CAT.SEGMENT1 LINE_OF_BUSINESS,
       CAT.SEGMENT2 ITEM_CATEGORY,
       CAT.SEGMENT3 ITEM_TYPE,
       CAT.SEGMENT4 CATELOG,
       CAT.CATEGORY_CONCAT_SEGS CATEGORY_SEGMENTS,
       MSI.CREATION_DATE
  --,MSI.*
  --,OOD.*
  --,CAT.*
  FROM APPS.MTL_SYSTEM_ITEMS_B MSI,
       APPS.ORG_ORGANIZATION_DEFINITIONS OOD,
       APPS.MTL_ITEM_CATEGORIES_V CAT
 WHERE     1 = 1
       AND MSI.ORGANIZATION_ID = OOD.ORGANIZATION_ID
       AND MSI.INVENTORY_ITEM_ID = CAT.INVENTORY_ITEM_ID
       AND MSI.ORGANIZATION_ID = CAT.ORGANIZATION_ID
       AND (   :P_OPERATING_UNIT IS NULL
            OR (OOD.OPERATING_UNIT = :P_OPERATING_UNIT))
       AND (   :P_ORG_NAME IS NULL
            OR (UPPER (OOD.ORGANIZATION_NAME) LIKE
                   UPPER ('%' || :P_ORG_NAME || '%')))
       AND (   :P_ORGANIZATION_CODE IS NULL
            OR (OOD.ORGANIZATION_CODE = :P_ORGANIZATION_CODE))
       AND ( :P_ITEM_CODE IS NULL OR (MSI.SEGMENT1 = :P_ITEM_CODE))
       AND (   :P_ITEM_DESC IS NULL
            OR (UPPER (MSI.DESCRIPTION) LIKE
                   UPPER ('%' || :P_ITEM_DESC || '%')))
       AND (   :P_LINE_OF_BUSINESS IS NULL
            OR (CAT.SEGMENT1 = :P_LINE_OF_BUSINESS))
       AND ( :P_MAJOR_CATEGORY IS NULL OR (CAT.SEGMENT2 = :P_MAJOR_CATEGORY))
       AND ( :P_MINOR_CATEGORY IS NULL OR (CAT.SEGMENT3 = :P_MINOR_CATEGORY))
       AND ( :P_ITEM_CATELOG IS NULL OR (CAT.SEGMENT4 = :P_ITEM_CATELOG))
       AND MSI.INVENTORY_ITEM_STATUS_CODE = 'Active'
       --AND ORGANIZATION_CODE NOT IN ('IMO')
       --AND ORGANIZATION_CODE IN ('251')
       --AND OPERATING_UNIT IN (85)
       --AND MSI.INVENTORY_ITEM_ID IN ('7297')
       --AND MSI.SEGMENT1 IN ('FT-GP6060-038BK')
       --AND MSI.SEGMENT1 LIKE ('PUMA%')
       --AND MSI.DESCRIPTION IN ('40S1-COTTON-100%-CH ORGANIC')
       --AND MSI.PRIMARY_UOM_CODE='PCS'
       --AND MSI.ORGANIZATION_ID IN (101)
       AND CAT.CATEGORY_SET_ID = 1
       --AND CAT.CATEGORY_ID='74551'
       --AND CAT.SEGMENT2 NOT IN ('FINISH GOODS')
       --AND CAT.SEGMENT2='BRND'
       --AND CAT.SEGMENT3='GIFT'
       --AND TO_CHAR(MSI.CREATION_DATE,'DD-MON-RR')>'05-MAR-21'
       AND MSI.ENABLED_FLAG = 'Y';

SELECT FLV.VIEW_APPLICATION_ID,
       FLV.LOOKUP_TYPE,
       FLV.LOOKUP_CODE,
       FLV.MEANING,
       FLV.DESCRIPTION,
       FLV.TAG,
       FLV.ENABLED_FLAG,
       FLV.START_DATE_ACTIVE,
       FLV.END_DATE_ACTIVE
  FROM APPS.FND_LOOKUP_VALUES FLV
 WHERE     FLV.LANGUAGE = USERENV ('LANG')
       AND FLV.VIEW_APPLICATION_ID = 660
       AND UPPER (FLV.LOOKUP_TYPE) = (UPPER ('FREIGHT_TERMS'))
       AND ENABLED_FLAG = 'Y';

SELECT *
  FROM OE_PRICE_LISTS
 WHERE NAME = 'DBLCL Standatd Price List';

SELECT sal.salesrep_id l_l_salesperson, sal.*
  FROM jtf_rs_salesreps sal, hr.per_all_people_f papf
 WHERE     1 = 1
       AND sal.person_id = papf.person_id
       AND TRUNC (SYSDATE) BETWEEN TRUNC (papf.effective_start_date)
                               AND TRUNC (papf.effective_end_date)
       AND NVL (papf.current_emp_or_apl_flag, 'Y') = 'Y'
       --AND NVL (papf.employee_number, papf.npw_number)=:P_SALESPERSON
       AND sal.org_id = :l_operating_unit;

SELECT TRANSACTION_TYPE_ID,
       NAME,
       TRANSACTION_TYPE_CODE,
       ORDER_CATEGORY_CODE,
       CURRENCY_CODE,
       CUST_TRX_TYPE_ID,
       PRICE_LIST_ID,
       WAREHOUSE_ID,
       ORG_ID,
       CONTEXT
  --,OTT.*
  FROM APPS.OE_TRANSACTION_TYPES OTT
 WHERE 1 = 1 AND TRANSACTION_TYPE_ID = 1001              --AND NAME = 'Dealer'
                                           AND END_DATE_ACTIVE IS NULL;


SELECT OTT.TRANSACTION_TYPE_ID,
       OTT.NAME,
       OTT.TRANSACTION_TYPE_CODE,
       OTT.ORDER_CATEGORY_CODE,
       OTT.CURRENCY_CODE,
       OTT.CUST_TRX_TYPE_ID,
       OTT.PRICE_LIST_ID,
       OTT.WAREHOUSE_ID,
       OTT.ORG_ID,
       OTT.CONTEXT,
       OWLA.LINE_TYPE_ID
  --,OTT.*
  --,OWLA.*
  FROM OE_TRANSACTION_TYPES OTT, OE_WF_LINE_ASSIGN_V OWLA
 WHERE 1 = 1 AND OTT.TRANSACTION_TYPE_ID = OWLA.ORDER_TYPE_ID --AND TRANSACTION_TYPE_ID = 1002
                                                         --AND NAME = 'Dealer'
        AND owla.end_date_active IS NULL AND OTT.END_DATE_ACTIVE IS NULL;


EXECUTE APPS.xxdbl_cust_upld_webadi_pkg.import_data_from_web_adi('CCL2','Test Customer Upload 2','R','KSDKDSK','SEEW','JDFKFJ','IEWEWN','Test Customer 2, Corporate, Gulshan-1, Dhaka','LAKE','GULSHAN','DHAKA','1212');