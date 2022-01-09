---------------------Booking Stage----------------------------
/* Formatted on 1/1/2022 11:47:24 AM (QP5 v5.256.13226.35538) */
SELECT ORG_ID,
       CUSTOMER_NUMBER,
       CUSTOMER_NAME,
       HEADER_ID,
       ORDER_NUMBER,
       BOOKED_DATE,
       ORDERED_QUANTITY,
       ORDERED_SEC_QUANTITY,
       UOM,
       AMOUNT,
       XXDBL_OM_PKG.GET_PARTY_SITE_ADDRESS (BILL_TO_SITE_USE_ID) BILL_TO_ADDRESS,
       XXDBL_OM_PKG.GET_PARTY_SITE_ADDRESS (SITE_USE_ID) SHIP_TO_ADDRESS,
       XXDBL_OM_PKG.GET_OM_PHONE_NUMBER (SOLD_TO_ORG_ID, 'ACCOUNT') BILL_TO_CONTACT,
       XXDBL_OM_PKG.GET_OM_PHONE_NUMBER (PARTY_SITE_ID, 'SITE') SHIP_TO_CONTACT,
       XXDBL_OM_PKG.GET_OM_PHONE_NUMBER (ATTRIBUTE3, 'ACCOUNT') CORRESPONDING_DEALER_PHONE,
       XXDBL_OM_PKG.GET_OM_PHONE_NUMBER (PERSON_ID, 'SR') SR_PHONE_NUMBER,
       XXDBL_OM_PKG.GET_OM_PHONE_NUMBER (PERSON_ID, 'SRS') SRS_PHONE
  FROM (  SELECT OH.ORG_ID,
                 CUST.CUSTOMER_NUMBER,
                 CUST.CUSTOMER_NAME,
                 OH.HEADER_ID,
                 OH.ORDER_NUMBER,
                 OH.BOOKED_DATE,
                 SUM (OL.ORDERED_QUANTITY) ORDERED_QUANTITY,
                 SUM (OL.ORDERED_QUANTITY2) ORDERED_SEC_QUANTITY,
                 OL.ORDER_QUANTITY_UOM UOM,
                 SUM (
                      (OL.ORDERED_QUANTITY * OL.UNIT_SELLING_PRICE)
                    - ABS (NVL (CLV.CHARGE_AMOUNT, 0)))
                    AMOUNT,
                 OH.SOLD_TO_ORG_ID,
                 HCASA.PARTY_SITE_ID,
                 OH.ATTRIBUTE3,
                 SR.PERSON_ID,
                 HCSUA.BILL_TO_SITE_USE_ID,
                 HCSUA.SITE_USE_ID
            FROM OE_ORDER_HEADERS_ALL OH,
                 OE_ORDER_LINES_ALL OL,
                 APPS.OE_CHARGE_LINES_V CLV,
                 AR_CUSTOMERS CUST,
                 APPS.HZ_CUST_ACCT_SITES_ALL HCASA,
                 APPS.HZ_CUST_SITE_USES_ALL HCSUA,
                 RA_SALESREPS_ALL SR
           WHERE     OH.HEADER_ID = OL.HEADER_ID
                 AND OL.LINE_ID = CLV.LINE_ID(+)
                 AND OL.FLOW_STATUS_CODE <> 'CANCELLED'
                 AND OH.SOLD_TO_ORG_ID = CUST.CUSTOMER_ID
                 AND OL.SHIP_TO_ORG_ID = HCSUA.SITE_USE_ID
                 AND HCSUA.CUST_ACCT_SITE_ID = HCASA.CUST_ACCT_SITE_ID
                 -- AND HCP.PHONE_NUMBER IS NOT NULL
                 AND OH.ORG_ID = 126
                 AND OH.SALESREP_ID = SR.SALESREP_ID
                 AND OH.ORG_ID = SR.ORG_ID
                 AND TRUNC (OH.BOOKED_DATE) = (TRUNC (TO_DATE (SYSDATE)))
                 AND 'BOOKED' = NVL ( :SMS_TYPE_PM, 'BOOKED')
                 --  AND CUST.CUSTOMER_NUMBER='2593'
                 -- AND CUST.CUSTOMER_ID = 271522          --(Corporate)   --2622(Dealer)
                 --   AND OL.SHIP_TO_ORG_ID=226951
                 AND NOT EXISTS
                            (SELECT 1
                               FROM ONT.OE_ORDER_HOLDS_ALL OHH
                              WHERE     OH.HEADER_ID = OHH.HEADER_ID
                                    AND OHH.RELEASED_FLAG <> 'Y')
        AND NOT EXISTS
               (SELECT 1
                  FROM XXDBL.XXDBL_OM_SMS_DATA_UPLOAD_STG STG
                 WHERE OH.HEADER_ID = STG.ORD_HEADER_ID)
        GROUP BY OH.ORG_ID,
                 CUST.CUSTOMER_NUMBER,
                 CUST.CUSTOMER_NAME,
                 OH.HEADER_ID,
                 OH.ORDER_NUMBER,
                 OH.BOOKED_DATE,
                 OL.ORDER_QUANTITY_UOM,
                 OH.SOLD_TO_ORG_ID,
                 HCASA.PARTY_SITE_ID,
                 OH.ATTRIBUTE3,
                 SR.PERSON_ID,
                 HCSUA.BILL_TO_SITE_USE_ID,
                 HCSUA.SITE_USE_ID);

-----------------------Delivery Stage-----------------------------

/* Formatted on 1/1/2022 11:29:26 AM (QP5 v5.256.13226.35538) */
SELECT ORG_ID,
       DELIVERY_ID,
       DELIVERY_CHALLAN_NUMBER,
       CUSTOMER_NAME,
       CUSTOMER_NUMBER,
       ORDER_NUMBER,
       SECONDARY_QUANTITY_CTN,
       PRIMARY_QUANTITY_SFT,
       DRIVER_NAME,
       DRIVER_CONTACT_NO,
       VEHICLE_NO,
       CONFIRM_DATE,
       TRANSPORT_CHALLAN_NUMBER,
       XXDBL_OM_PKG.GET_PARTY_SITE_ADDRESS (BILL_TO_SITE_USE_ID) BILL_TO_ADDRESS,
       XXDBL_OM_PKG.GET_PARTY_SITE_ADDRESS (SITE_USE_ID) SHIP_TO_ADDRESS,
       XXDBL_OM_PKG.GET_OM_PHONE_NUMBER (SOLD_TO_ORG_ID, 'ACCOUNT') BILL_TO_CONTACT,
       XXDBL_OM_PKG.GET_OM_PHONE_NUMBER (PARTY_SITE_ID, 'SITE') SHIP_TO_CONTACT,
       XXDBL_OM_PKG.GET_OM_PHONE_NUMBER (ATTRIBUTE3, 'ACCOUNT') CORRESPONDING_DEALER_PHONE,
       XXDBL_OM_PKG.GET_OM_PHONE_NUMBER (PERSON_ID, 'SR') SR_PHONE_NUMBER,
       XXDBL_OM_PKG.GET_OM_PHONE_NUMBER (PERSON_ID, 'SRS') SRS_PHONE
  FROM (  SELECT OH.ORG_ID,
                 WND.DELIVERY_ID,
                 OLV.DELIVERY_CHALLAN_NUMBER DELIVERY_CHALLAN_NUMBER,
                 AC.CUSTOMER_NAME,
                 AC.CUSTOMER_NUMBER,
                 OLV.ORDER_NUMBER,
                 SUM (PICKING_QTY_CRT) SECONDARY_QUANTITY_CTN,
                 SUM (PICKING_QTY_SFT) PRIMARY_QUANTITY_SFT,
                 WND.ATTRIBUTE4 DRIVER_NAME,
                 WND.ATTRIBUTE5 DRIVER_CONTACT_NO,
                 WND.ATTRIBUTE2 VEHICLE_NO,
                 WND.CONFIRM_DATE,
                 OLV.TRANSPORT_CHALLAN_NUMBER,
                 OH.SOLD_TO_ORG_ID,
                 HCASA.PARTY_SITE_ID,
                 OH.ATTRIBUTE3,
                 SR.PERSON_ID,
                 HCSUA.BILL_TO_SITE_USE_ID,
                 HCSUA.SITE_USE_ID                     --(259406 -DELIVERY_ID)
            FROM XXDBL.XXDBL_OMSHIPPING_LINE_V OLV,
                 APPS.HZ_CUST_SITE_USES_ALL HCSUA,
                 APPS.HZ_CUST_ACCT_SITES_ALL HCASA,
                 APPS.AR_CUSTOMERS AC,
                 WSH_NEW_DELIVERIES WND,
                 OE_ORDER_HEADERS_ALL OH,
                 RA_SALESREPS_ALL SR
           WHERE     OLV.ATTRIBUTE10 = HCSUA.SITE_USE_ID
                 AND HCSUA.CUST_ACCT_SITE_ID = HCASA.CUST_ACCT_SITE_ID
                 AND HCASA.CUST_ACCOUNT_ID = AC.CUSTOMER_ID
                 --  AND AC.CUSTOMER_ID = 271522
                 AND OLV.DELIVERY_ID = WND.DELIVERY_ID
                 -- AND WND.DELIVERY_ID =258788-- 644397
                 AND OLV.ORDER_ID = OH.HEADER_ID
                 AND OH.SALESREP_ID = SR.SALESREP_ID
                 AND OH.ORG_ID = SR.ORG_ID
                 AND OH.ORG_ID = 126
                 -- AND hcp.phone_number IS NOT NULL
                 --AND TO_CHAR (WND.CONFIRM_DATE, 'MON-RRRR') = TO_CHAR ('MAY-2020')
                 AND TRUNC (WND.CONFIRM_DATE) = (TRUNC (TO_DATE (SYSDATE)))
                 AND 'DELIVERY' = NVL ( :SMS_TYPE_PM, 'DELIVERY')
                 AND NOT EXISTS
                            (SELECT 1
                               FROM XXDBL.XXDBL_OM_SMS_DATA_UPLOAD_STG STG
                              WHERE     OLV.ORG_ID = STG.ORG_ID
                                    AND STG.DELIVERY_ID = WND.DELIVERY_ID)
        GROUP BY OH.ORG_ID,
                 WND.DELIVERY_ID,
                 OLV.DELIVERY_CHALLAN_NUMBER,
                 AC.CUSTOMER_NAME,
                 AC.CUSTOMER_NUMBER,
                 OLV.ORDER_NUMBER,
                 WND.ATTRIBUTE4,
                 WND.ATTRIBUTE5,
                 WND.ATTRIBUTE2,
                 WND.CONFIRM_DATE,
                 OLV.TRANSPORT_CHALLAN_NUMBER,
                 OH.SOLD_TO_ORG_ID,
                 HCASA.PARTY_SITE_ID,
                 OH.ATTRIBUTE3,
                 SR.PERSON_ID,
                 HCSUA.BILL_TO_SITE_USE_ID,
                 HCSUA.SITE_USE_ID)
--WHERE DELIVERY_ID = 258204