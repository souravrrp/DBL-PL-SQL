SELECT oha.org_id,
                     cus.customer_number,
                     cus.customer_name,
                     oha.header_id,
                     ola.line_id,
                     oha.order_number,
                     oha.booked_date,
                     SUM (ola.ordered_quantity)                 ordered_quantity,
                     ola.order_quantity_uom                     uom,
                     SUM (
                           (ola.ordered_quantity * ola.unit_selling_price)
                         - ABS (NVL (clv.charge_amount, 0)))    amount,
                     hcp.phone_number
                FROM oe_order_headers_all       oha,
                     oe_order_lines_all         ola,
                     apps.oe_charge_lines_v     clv,
                     oe_price_adjustments_v     pav,
                     ar_customers               cus,
                     apps.hz_cust_accounts      hca,
                     apps.hz_party_sites        hps,
                     apps.hz_cust_acct_sites_all hcasa,
                     apps.hz_cust_site_uses_all hcsua,
                     ar.hz_contact_points       hcp,
                     apps.hz_locations          hl
               WHERE     oha.header_id = ola.header_id
                     AND oha.header_id = clv.header_id(+)
                     AND ola.line_id = clv.line_id(+)
                     AND oha.header_id = pav.header_id
                     AND ola.line_id = pav.line_id
                     AND oha.org_id = ola.org_id
                     AND pav.adjustment_name = 'SO Header Adhoc Discount'
                     AND oha.sold_to_org_id = cus.customer_id
                     AND cus.customer_id = hca.cust_account_id
                     AND hca.party_id = hps.party_id
                     AND cus.customer_id = hca.cust_account_id
                     AND hca.status = 'A'
                     AND hca.cust_account_id = hcasa.cust_account_id(+)
                     AND hcasa.status = 'A'
                     AND hcsua.status = 'A'
                     AND hcasa.party_site_id = hps.party_site_id
                     AND hcsua.cust_acct_site_id = hcasa.cust_acct_site_id
                     AND hcsua.org_id = 126
                     AND hps.location_id = hl.location_id
                     AND site_use_code = 'BILL_TO'
                     AND hps.party_site_id = hcp.owner_table_id(+)
                     AND hcp.phone_number IS NOT NULL
                     AND oha.org_id = 126
                     AND TRUNC (oha.booked_date) >
                         (TRUNC (TO_DATE (SYSDATE)) - 2)    --'09-JUN-2020'
                     AND NOT EXISTS
                             (SELECT 1
                                FROM xxdbl.xxdbl_om_sms_data_upload_stg stg
                               WHERE     oha.org_id = stg.org_id
                                     AND oha.header_id = stg.ord_header_id
                                     AND ola.line_id = stg.ord_line_id)
            GROUP BY oha.org_id,
                     cus.customer_number,
                     cus.customer_name,
                     oha.header_id,
                     ola.line_id,
                     oha.order_number,
                     oha.booked_date,
                     ola.order_quantity_uom,
                     hcp.phone_number
            ORDER BY BOOKED_DATE DESC;


              SELECT DISTINCT
                     TL.ORG_ID,
                     WND.DELIVERY_ID,
                     (TL.DELIVERY_CHALLAN_NUMBER)     DELIVERY_CHALLAN_NUMBER,
                     TL.CUSTOMER_NAME,
                     TL.CUSTOMER_NUMBER,
                     HCP.PHONE_NUMBER,
                     OLV.ORDER_NUMBER,
                     TL.SECONDARY_QUANTITY            SECONDARY_QUANTITY_CTN,
                     TL.PRIMARY_QUANTITY              PRIMARY_QUANTITY_SFT,
                     WND.ATTRIBUTE4                   DRIVER_NAME,
                     WND.ATTRIBUTE5                   DRIVER_CONTACT_NO,
                     WND.ATTRIBUTE2                   VEHICLE_NO,
                     WND.CONFIRM_DATE,
                     TH.TRANSPOTER_CHALLAN_NUMBER
                FROM XXDBL.XXDBL_OMSHIPPING_LINE_V OLV,
                     WSH_NEW_DELIVERIES           WND,
                     XXDBL_TRANSPOTER_LINE        TL,
                     XXDBL_TRANSPOTER_HEADERS     TH,
                     APPS.HZ_CUST_ACCOUNTS        HCA,
                     APPS.HZ_PARTY_SITES          HPS,
                     AR.HZ_CONTACT_POINTS         HCP
               WHERE     OLV.DELIVERY_ID = WND.DELIVERY_ID
                     AND OLV.DELIVERY_CHALLAN_NUMBER =
                         TL.DELIVERY_CHALLAN_NUMBER
                     AND TL.TRANSPOTER_HEADER_ID = TH.TRANSPOTER_HEADER_ID
                     AND TL.CUSTOMER_NUMBER = HCA.ACCOUNT_NUMBER
                     AND HCA.PARTY_ID = HPS.PARTY_ID
                     AND HPS.PARTY_SITE_ID = HCP.OWNER_TABLE_ID
                     AND HCP.PHONE_NUMBER IS NOT NULL
                     AND TL.ORG_ID = 126
                     AND TRUNC (WND.CONFIRM_DATE) >
                         (TRUNC (TO_DATE (SYSDATE)) - 2)     --'06-MAY-2020'
                     AND NOT EXISTS
                             (SELECT 1
                                FROM xxdbl.xxdbl_om_sms_data_upload_stg stg
                               WHERE     tl.org_id = stg.org_id
                                     AND STG.DELIVERY_ID = WND.DELIVERY_ID)
            ORDER BY TL.DELIVERY_CHALLAN_NUMBER DESC;

select
*
from
ar_customers;

SELECT
*
FROM
ar.hz_contact_points hcp
where 1=1
--and OBJECT_VERSION_NUMBER!=1
AND ORIG_SYSTEM_REFERENCE='92821'
--AND CONTACT_POINT_ID='92821'
;

select
*
from
WSH_NEW_DELIVERIES;

select
--MAX(LENGTH(MESSAGE_TEXT))
--MAX(SMS_ID)
*
from
xxdbl.xxdbl_om_sms_data_upload_stg
WHERE 1=1
AND SENT_FLAG IS NULL
--AND ORDER_NUMBER='2011010014579'
;

--truncate table xxdbl.xxdbl_om_sms_data_upload_stg;
