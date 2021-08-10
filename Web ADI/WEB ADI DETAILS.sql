/* Formatted on 7/9/2019 10:51:26 AM (QP5 v5.287) */
SELECT FA.APPLICATION_NAME,
       BIG.USER_NAME,
       BI.INTERFACE_NAME "PROCEDURE/FUNCTION NAME",
       BI.USER_NAME INTERFACE_NAME,
       BIC.INTERFACE_COL_NAME ATTRIBUTE_NAME,
       BIC.PROMPT_LEFT,
       BL.LAYOUT_CODE LAYOUT_NAME
  --,BIV.*
  --,BCB.*
  --,BI.*
  --,BIC.*
  --,BC.*
  --,BL.*
  --,BLC.*
  FROM APPS.FND_APPLICATION_VL FA,
       APPS.BNE_INTEGRATORS_VL BIG
       ,APPS.BNE_CONTENTS_VL BCB
       ,APPS.BNE_INTERFACES_VL BI
       ,APPS.BNE_INTERFACE_COLS_VL BIC
       ,APPS.BNE_CONTENTS_VL BC
       ,APPS.BNE_LAYOUTS_VL BL
       ,APPS.BNE_LAYOUT_COLS BLC
 WHERE     1 = 1
       AND BL.LAYOUT_CODE = BLC.LAYOUT_CODE
       AND BI.INTERFACE_CODE = BLC.INTERFACE_CODE
       AND BIC.SEQUENCE_NUM = BLC.INTERFACE_SEQ_NUM
       AND BC.INTEGRATOR_CODE = BL.INTEGRATOR_CODE
       AND BC.INTEGRATOR_CODE = BIG.INTEGRATOR_CODE
       AND BI.INTERFACE_CODE = BIC.INTERFACE_CODE
       AND BI.INTEGRATOR_CODE = BIG.INTEGRATOR_CODE
       AND BCB.INTEGRATOR_CODE = BIG.INTEGRATOR_CODE
       AND BIG.ENABLED_FLAG = 'Y'
       AND BIG.APPLICATION_ID = FA.APPLICATION_ID
       AND BIG.USER_NAME = 'YARN Item Upload' --XXAKG_CUS_CREDIT_UPD
       --AND BL.LAYOUT_CODE NOT LIKE 'COPY%'
       --AND FA.APPLICATION_NAME='Receivables'
       --AND (UPPER (:P_WEB_ADI) IS NULL) OR (UPPER (BIG.USER_NAME) LIKE UPPER ('%' || :P_WEB_ADI || '%'))
;

--------------------------------------------------------------------------------

/* Formatted on 6/30/2020 12:39:37 PM (QP5 v5.287) */
SELECT --DISTINCT 
                FA.APPLICATION_NAME,
                BIG.USER_NAME,
                BI.INTERFACE_NAME "PROCEDURE/FUNCTION NAME",
                BI.USER_NAME INTERFACE_NAME,
                BIC.INTERFACE_COL_NAME ATTRIBUTE_NAME,
                BIC.PROMPT_LEFT
                --BL.LAYOUT_CODE LAYOUT_NAME
  --,BIG.*
  --,BIV.*
  ,BCB.*
  --,BI.*
  ,BIC.*
  --,BC.*
  --,BL.*
  --,BLC.*
  FROM APPS.FND_APPLICATION_VL FA,
       APPS.BNE_INTEGRATORS_VL BIG,
       APPS.BNE_INTERFACES_VL BI,
       APPS.BNE_INTERFACE_COLS_VL BIC,
       APPS.BNE_CONTENTS_VL BCB
       --APPS.BNE_CONTENTS_VL BC
       --APPS.BNE_LAYOUTS_VL BL,
       --APPS.BNE_LAYOUT_COLS BLC
 WHERE     1 = 1
       --AND BL.LAYOUT_CODE = BLC.LAYOUT_CODE(+)
       --AND BI.INTERFACE_CODE = BLC.INTERFACE_CODE(+)
       --AND BIC.SEQUENCE_NUM = BLC.INTERFACE_SEQ_NUM(+)
       --AND BC.INTEGRATOR_CODE = BL.INTEGRATOR_CODE(+)
       --AND BC.OBJECT_VERSION_NUMBER=BL.OBJECT_VERSION_NUMBER(+)
       --AND BIG.INTEGRATOR_CODE = BC.INTEGRATOR_CODE(+)
       --AND BIC.OBJECT_VERSION_NUMBER=BC.OBJECT_VERSION_NUMBER(+)
       AND BI.INTERFACE_CODE = BIC.INTERFACE_CODE(+)
       AND BIG.INTEGRATOR_CODE = BCB.INTEGRATOR_CODE(+)
       AND BIG.ENABLED_FLAG = 'Y'
       AND FA.APPLICATION_ID = BIG.APPLICATION_ID(+)
       AND BIG.INTEGRATOR_CODE = BI.INTEGRATOR_CODE(+)
       AND BIG.USER_NAME = 'YARN Item Upload'           --XXAKG_CUS_CREDIT_UPD
--AND BL.LAYOUT_CODE NOT LIKE 'COPY%'
--AND FA.APPLICATION_NAME='Receivables'
--AND (UPPER (:P_WEB_ADI) IS NULL) OR (UPPER (BIG.USER_NAME) LIKE UPPER ('%' || :P_WEB_ADI || '%'))
;

--------------------------------------------------------------------------------

SELECT *
  FROM APPS.BNE_INTERFACES_VL BI
 WHERE 1 = 1 AND INTEGRATOR_APP_ID = 660;



SELECT *
  FROM APPS.BNE_INTERFACE_COLS_TL BIC
 WHERE     1 = 1
       AND INTERFACE_CODE = 'XXAKG_CUS_CREDIT_UPD_X_INTF1'
       AND BIC.SEQUENCE_NUM = 3;


--------------------------------------------------------------------------------

SELECT *
  FROM APPS.BNE_CONTENTS_VL BC
 WHERE 1 = 1 AND INTEGRATOR_CODE = 'XXAKG_CUS_CREDIT_UPD_XINTG';


--------------------------------------------------------------------------------

SELECT *
  FROM APPS.BNE_MAPPINGS_VL BM
 WHERE 1 = 1 AND INTEGRATOR_CODE = 'XXAKG_CUS_CREDIT_UPD_XINTG';

--------------------------------------------------------------------------------

SELECT *
  FROM APPS.BNE_LAYOUTS_VL BL
 WHERE 1 = 1 AND INTEGRATOR_CODE = 'XXAKG_CUS_CREDIT_UPD_XINTG';

SELECT *
  FROM APPS.BNE_LAYOUT_COLS BLC
 WHERE 1 = 1 AND LAYOUT_CODE = 'XXAKG_CUS_CREDIT_UPD'
--AND BLC.SEQUENCE_NUM=3
;
--------------------------------------------------------------------------------

SELECT *
  FROM APPS.BNE_INTEGRATORS_TL
 WHERE 1 = 1 AND USER_NAME = 'XXAKG_CUS_CREDIT_UPD'
-- AND UPPER (USER_NAME) LIKE UPPER ('%' || :P_WEB_ADI || '%')
;
--------------------------------------------------------------------------------

SELECT *
  FROM APPS.BNE_CONTENTS_B
 WHERE 1 = 1 AND INTEGRATOR_CODE = 'XXAKG_CUS_CREDIT_UPD_XINTG';



--------------------------------------------------------------------------------

SELECT BA.ATTRIBUTE2, BIT.USER_NAME
  FROM APPS.BNE_ATTRIBUTES BA,
       APPS.BNE_PARAM_LISTS_B BPLB,
       APPS.BNE_INTERFACES_B BIB,
       APPS.BNE_INTEGRATORS_TL BIT
 WHERE     BIB.UPLOAD_PARAM_LIST_CODE = BPLB.PARAM_LIST_CODE
       AND BIB.INTEGRATOR_CODE = BIT.INTEGRATOR_CODE
       AND BA.ATTRIBUTE_CODE = BPLB.ATTRIBUTE_CODE
       AND BIT.USER_NAME = 'XXAKG_CUS_CREDIT_UPD';


--------------------------------------------------------------------------------

SELECT application_id,
       layout_code,
       user_name layout_name,
       integrator_app_id,
       integrator_code,
       created_by,
       creation_date
  FROM apps.bne_layouts_vl;

--------------------------------------------------------------------------------

  SELECT ig.user_name integrator, fa.application_name application
    FROM apps.bne_integrators_vl ig, apps.fnd_application_vl fa
   WHERE ig.enabled_flag = 'Y' AND ig.application_id = fa.application_id
ORDER BY ig.application_id;


--------------------------------------------------------------------------------

SELECT
*
FROM
BNE_PARAM_LIST_ITEMS
WHERE 1=1
AND PARAM_LIST_CODE LIKE '%CUST_BILL_UPLOAD_ADI_UPL1%';


SELECT *
  FROM APPS.BNE_INTERFACE_COLS_TL BIC
 WHERE     1 = 1
       AND INTERFACE_CODE LIKE '%CUST_BILL_UPLOAD_ADI_INTF1%';
       
       SELECT *
  FROM APPS.BNE_INTERFACE_COLS_B BIB
 WHERE     1 = 1
       AND INTERFACE_CODE LIKE '%CUST_BILL_UPLOAD_ADI_INTF1%';
       
 UPDATE APPS.BNE_INTERFACE_COLS_B BIB
 SET UPLOAD_PARAM_LIST_ITEM_NUM=NULL
 WHERE     1 = 1
 AND SEQUENCE_NUM=14
       AND INTERFACE_CODE LIKE '%CUST_BILL_UPLOAD_ADI_INTF1%';
       
       

SELECT
*
FROM
BNE_ATTRIBUTES
WHERE 1=1
AND ATTRIBUTE_CODE LIKE '%CUST_BILL_UPLOAD_%';

select
*
from
APPS.BNE_INTEGRATORS_VL BIG
where BIG.USER_NAME = 'YARN Item Upload';


------Profile-------------------------------------------------------------------
select PA_WEBADI_TRX_XFACE.Get_Default_OU_Name from dual;

select PA_WEBADI_TRX_XFACE.Get_Default_OU_Id from dual


--------------------------------------------------------------------------------

/* Formatted on 11/7/2020 2:42:34 PM (QP5 v5.287) */
SELECT t.application_id,
       t.integrator_code,
       t.object_version_number,
       t.user_name,
       s.security_rule_app_id,
       s.security_rule_code
  FROM bne_integrators_vl t,
       (SELECT o.application_id,
               o.object_code,
               o.security_rule_app_id,
               o.security_rule_code
          FROM bne_secured_objects o, bne_security_rules r
         WHERE     o.object_type = 'INTEGRATOR'
               AND o.security_rule_app_id = r.application_id
               AND o.security_rule_code = r.security_code) s
 WHERE     t.enabled_flag = 'Y'
       AND t.application_id = s.application_id(+)
       AND t.integrator_code = s.object_code(+)
       AND t.integrator_code LIKE 'XXDBL%'
         
--------------------------------------------------------------------------------

 Select SECURITY_TYPE,SECURITY_VALUE from BNE_SECURITY_RULES where SECURITY_CODE='XXDBL_MO_CORRECTION_WEBA_SRULE'--&security_code --IDENTIFIED ABOVE
 
 
 1. SELECT menu_id
FROM fnd_menus_vl
WHERE menu_name = '&menu_name'

2. SELECT *
FROM fnd_menu_entries_vl
WHERE menu_id =
(
SELECT menu_id
FROM fnd_menus_vl
WHERE menu_name = '&menu_name'
)

3. SELECT *
FROM fnd_form_functions_vl
WHERE function_id =
(
SELECT function_id
FROM fnd_menu_entries_vl
WHERE menu_id =
(
SELECT menu_id
FROM fnd_menus_vl
WHERE menu_name = '&menu_name'
)
AND entry_sequence = 40
)

4. SELECT *
FROM fnd_form_functions_vl
WHERE function_id =
(
SELECT function_id
FROM fnd_menu_entries_vl
WHERE menu_id =
(
SELECT menu_id
FROM fnd_menus_vl
WHERE menu_name = '&menu_name'
)
AND entry_sequence = 50
)

5. SELECT *
FROM bne_secured_objects o
,bne_security_rules r
WHERE o.security_rule_app_id = r.application_id

6. SELECT *
FROM bne_security_rules
WHERE security_value = '&security_value'

7. SELECT *
FROM bne_security_rules
WHERE security_code IN ('&integrator_code_in_error_message')