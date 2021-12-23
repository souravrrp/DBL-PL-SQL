/* Formatted on 9/9/2020 9:43:35 AM (QP5 v5.354) */
  SELECT oha.org_id,
         cus.customer_number,
         cus.customer_name,
         oha.header_id,
         oha.order_number,
         oha.booked_date,
         SUM (ola.ordered_quantity)                 ordered_quantity,
         SUM (ola.ordered_quantity2)                ordered_sec_quantity,
         ola.order_quantity_uom                     uom,
         SUM (
               (ola.ordered_quantity * ola.unit_selling_price)
             - ABS (NVL (clv.charge_amount, 0)))    amount,
         hcp.phone_number,
         pp.phone_number                            sr_phone_number
    FROM oe_order_headers_all       oha,
         oe_order_lines_all         ola,
         apps.oe_charge_lines_v     clv,
         oe_price_adjustments_v     pav,
         ar_customers               cus,
         apps.hz_cust_accounts      hca,
         apps.hz_party_sites        hps,
         apps.hz_cust_acct_sites_all hcasa,
         apps.hz_cust_site_uses_all hcsua,
         apps.hz_locations          hl,
         jtf_rs_salesreps           sal,
         jtf_rs_defresources_v      rsv,
         per_phones                 pp,
         ar.hz_contact_points       hcp
   WHERE     oha.header_id = ola.header_id
         AND oha.header_id = clv.header_id(+)
         AND ola.line_id = clv.line_id(+)
         AND oha.header_id = pav.header_id
         AND ola.line_id = pav.line_id
         AND oha.org_id = ola.org_id
         AND oha.flow_status_code != 'CANCELLED'
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
         AND oha.salesrep_id = sal.salesrep_id(+)
         AND sal.resource_id = rsv.resource_id
         AND oha.org_id = sal.org_id(+)
         AND rsv.source_id = pp.parent_id(+)
         AND pp.phone_type(+) = 'W1'
         --AND TRUNC (oha.booked_date) = (TRUNC (TO_DATE (SYSDATE)))
         AND TO_CHAR (oha.booked_date, 'MON-RRRR') = TO_CHAR ('AUG-2020')
         --AND 'BOOKED' = NVL (SMS_TYPE_PM, 'BOOKED')
         AND NOT EXISTS
                 (SELECT 1
                    FROM ONT.OE_ORDER_HOLDS_ALL OOHA
                   WHERE     OHA.HEADER_ID = OOHA.HEADER_ID
                         AND OOHA.RELEASED_FLAG <> 'Y')
         AND NOT EXISTS
                 (SELECT 1
                    FROM xxdbl.xxdbl_om_sms_data_upload_stg stg
                   WHERE     oha.org_id = stg.org_id
                         AND oha.header_id = stg.ord_header_id)
GROUP BY oha.org_id,
         cus.customer_number,
         cus.customer_name,
         oha.header_id,
         oha.order_number,
         oha.booked_date,
         ola.order_quantity_uom,
         hcp.phone_number,
         pp.phone_number
ORDER BY BOOKED_DATE DESC;


  SELECT DISTINCT TL.ORG_ID,
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
                  TH.TRANSPOTER_CHALLAN_NUMBER,
                  hl.address1                      bill_to_address,
                  hlsh.address1                    ship_to_address,
                  hcp.phone_number                 bill_to_contact,
                  hcph.phone_number                ship_to_contact
    FROM apps.ar_customers            ac,
         apps.hz_cust_accounts        hca,
         apps.hz_cust_acct_sites_all  hcasa,
         apps.hz_cust_acct_sites_all  hcasash,
         apps.hz_party_sites          hps,
         apps.hz_party_sites          hpsh,
         apps.hz_cust_site_uses_all   hcsua,
         apps.hz_cust_site_uses_all   hcsuash,
         apps.hz_locations            hl,
         apps.hz_locations            hlsh,
         apps.hr_operating_units      hou,
         oe_order_headers_all         oha,
         xxdbl.xxdbl_omshipping_line_v olv,
         wsh_new_deliveries           wnd,
         xxdbl_transpoter_line        tl,
         xxdbl_transpoter_headers     th,
         (SELECT owner_table_id, phone_number
            FROM ar.hz_contact_points
           WHERE contact_point_type = 'PHONE' AND status = 'A') hcp,
         (SELECT owner_table_id, phone_number
            FROM ar.hz_contact_points
           WHERE contact_point_type = 'PHONE' AND status = 'A') hcph
   WHERE     hcsua.site_use_id = hcsuash.bill_to_site_use_id(+)
         AND ac.customer_id = hca.cust_account_id(+)
         AND hcasa.party_site_id = hps.party_site_id(+)
         AND hcasash.party_site_id = hpsh.party_site_id(+)
         AND hcsua.cust_acct_site_id = hcasa.cust_acct_site_id(+)
         AND hcsuash.cust_acct_site_id = hcasash.cust_acct_site_id(+)
         AND hps.location_id = hl.location_id(+)
         AND hpsh.location_id = hlsh.location_id(+)
         AND hou.organization_id = hcsua.org_id
         AND hou.organization_id = hcsuash.org_id
         AND hca.cust_account_id = hcasa.cust_account_id(+)
         AND hca.cust_account_id = hcasash.cust_account_id(+)
         AND ac.customer_id = oha.sold_to_org_id
         AND hcsua.site_use_id = oha.invoice_to_org_id
         AND hcsuash.site_use_id = oha.ship_to_org_id
         AND hcasa.status = 'A'
         AND hcsua.status = 'A'
         AND hcasash.status = 'A'
         AND hcsuash.status = 'A'
         AND hca.status = 'A'
         AND hca.status = 'A'
         AND hps.status = 'A'
         AND hpsh.status = 'A'
         AND olv.order_number = oha.order_number
         AND olv.delivery_id = wnd.delivery_id
         AND olv.delivery_challan_number = tl.delivery_challan_number
         AND tl.transpoter_header_id = th.transpoter_header_id
         AND hps.party_site_id = hcp.owner_table_id(+)
         AND hpsh.party_site_id = hcph.owner_table_id(+)
         AND tl.customer_number = hca.account_number
         AND tl.org_id = oha.org_id
         AND oha.org_id = hcasa.org_id
         AND hcasa.org_id = hcasash.org_id
         AND tl.org_id = 126
         AND hcp.phone_number IS NOT NULL
         AND TO_CHAR (WND.CONFIRM_DATE, 'MON-RRRR') = TO_CHAR ('MAY-2020')
         --AND TRUNC (wnd.confirm_date) = (TRUNC (TO_DATE (SYSDATE)))
         --AND 'DELIVERY' = NVL (SMS_TYPE_PM, 'DELIVERY')
         AND NOT EXISTS
                 (SELECT 1
                    FROM xxdbl.xxdbl_om_sms_data_upload_stg stg
                   WHERE     tl.org_id = stg.org_id
                         AND STG.DELIVERY_ID = WND.DELIVERY_ID)
ORDER BY TL.DELIVERY_CHALLAN_NUMBER DESC;


SELECT *
  FROM per_phones PP
 WHERE 1 = 1 AND PP.PHONE_TYPE = 'W1';

SELECT *
  FROM OE_ORDER_HEADERS_ALL
 WHERE ORDER_NUMBER = '2011010014598';

  SELECT *
    FROM APPS.JTF_RS_DEFRESOURCES_V
   WHERE 1 = 1
--and RESOURCE_NUMBER='10329'
--AND RESOURCE_ID='100001065'
--AND SOURCE_NUMBER='103908'
ORDER BY CREATION_DATE DESC;

SELECT *
  FROM jtf_rs_salesreps sal
 WHERE RESOURCE_ID = '100001065';


SELECT *
  FROM jtf_rs_defresources_v
 WHERE 1 = 1;

SELECT * FROM ar_customers;

SELECT *
  FROM ar.hz_contact_points hcp
 WHERE 1 = 1 AND ORIG_SYSTEM_REFERENCE = '92821'
--and OBJECT_VERSION_NUMBER!=1
--AND CONTACT_POINT_ID='92821'
;


SELECT * FROM WSH_NEW_DELIVERIES;

--delete
--from
--xxdbl.xxdbl_om_sms_data_upload_stg
--WHERE 1=1
----AND TRUNC(CREATION_DATE)=TRUNC(SYSDATE)
----AND SMS_SENT_DATE IS NULL
----AND MESSAGE_TEXT IS NULL
----AND SENT_FLAG IS NULL
----AND SMS_TYPE='BOOKED'
--AND SMS_TYPE='DELIVERY'
----AND ORDER_NUMBER='2011010014579'
--;

  SELECT                                           
         *
         --COUNT(SMS_ID)/6, SMS_TYPE
    FROM xxdbl.xxdbl_om_sms_data_upload_stg
   WHERE     1 = 1
         --AND TRUNC (CREATION_DATE) between '14-NOV-20' AND '19-NOV-20'
         --AND TRUNC (CREATION_DATE) = TRUNC (SYSDATE-1)
         --AND SMS_SENT_DATE IS NULL
         --AND MESSAGE_TEXT IS NULL
         --AND SENT_FLAG IS NULL
         --AND DELIVERED_FLAG IS NULL
         --AND SMS_TYPE='BOOKED'
         --AND ORDER_NUMBER='2011010014579'
         --AND SMS_TYPE = 'DELIVERY'
         --AND CREATION_DATE IS NOT NULL
--ORDER BY CREATION_DATE
--ORDER_NUMBER
--DESC
--GROUP BY SMS_TYPE
;
--truncate table xxdbl.xxdbl_om_sms_data_upload_stg;