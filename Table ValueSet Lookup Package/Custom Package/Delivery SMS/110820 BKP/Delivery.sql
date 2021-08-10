/* Formatted on 8/5/2020 2:24:33 PM (QP5 v5.354) */
  SELECT DISTINCT TL.ORG_ID,
                  (TL.DELIVERY_CHALLAN_NUMBER)     DELIVERY_CHALLAN_NUMBER,
                  TL.CUSTOMER_NAME,
                  TL.CUSTOMER_NUMBER,
                  HCP.PHONE_NUMBER,
                  OLV.ORDER_NUMBER,
                  TL.SECONDARY_QUANTITY            CTN,
                  TL.PRIMARY_QUANTITY              SFT,
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
         AND OLV.DELIVERY_CHALLAN_NUMBER = TL.DELIVERY_CHALLAN_NUMBER
         AND TL.TRANSPOTER_HEADER_ID = TH.TRANSPOTER_HEADER_ID
         AND TL.CUSTOMER_NUMBER = HCA.ACCOUNT_NUMBER
         AND HCA.PARTY_ID = HPS.PARTY_ID
         AND HPS.PARTY_SITE_ID = HCP.OWNER_TABLE_ID
         AND HCP.PHONE_NUMBER IS NOT NULL
         AND TL.ORG_ID = 126
         AND TRUNC (WND.CONFIRM_DATE) > (TRUNC (TO_DATE ('06-MAY-2020')) - 2)
ORDER BY TL.DELIVERY_CHALLAN_NUMBER DESC;

/* --------------------------------------------------------------------------- */
  SELECT DISTINCT (TL.DELIVERY_CHALLAN_NUMBER) DELIVERY_CHALLAN_NUMBER,
                  TL.CUSTOMER_NAME,
                  TL.CUSTOMER_NUMBER,
                  HCP.PHONE_NUMBER,
                  OLV.ORDER_NUMBER,
                  TL.SECONDARY_QUANTITY CTN,
                  TL.PRIMARY_QUANTITY SFT,
                  WND.ATTRIBUTE4 DRIVER_NAME,
                  WND.ATTRIBUTE5 DRIVER_CONTACT_NO,
                  WND.ATTRIBUTE2 VEHICLE_NO,
                  WND.CONFIRM_DATE,
                  TH.TRANSPOTER_CHALLAN_NUMBER
    FROM XXDBL.XXDBL_OMSHIPPING_LINE_V OLV,
         WSH_NEW_DELIVERIES WND,
         XXDBL_TRANSPOTER_LINE TL,
         XXDBL_TRANSPOTER_HEADERS TH,
         APPS.HZ_CUST_ACCOUNTS HCA,
         APPS.HZ_PARTY_SITES HPS,
         AR.HZ_CONTACT_POINTS HCP
   WHERE     OLV.DELIVERY_ID = WND.DELIVERY_ID
         AND OLV.DELIVERY_CHALLAN_NUMBER = TL.DELIVERY_CHALLAN_NUMBER
         AND TL.TRANSPOTER_HEADER_ID = TH.TRANSPOTER_HEADER_ID
         AND TL.CUSTOMER_NUMBER = HCA.ACCOUNT_NUMBER
         AND HCA.PARTY_ID = HPS.PARTY_ID
         AND HPS.PARTY_SITE_ID = HCP.OWNER_TABLE_ID
         AND HCP.PHONE_NUMBER IS NOT NULL
         AND TL.ORG_ID = 126
         --AND wnd.confirm_date IS NULL
         --AND tl.delivery_challan_number = 'DEL-251-025750'
         AND TO_DATE (WND.CONFIRM_DATE, 'DD/MM/RRRR HH12:MI:SSAM') BETWEEN TO_DATE (
                                                                              :P_STARTDATE,
                                                                              'DD/MM/RRRR HH12:MI:SSAM')
                                                                       AND TO_DATE (
                                                                              :P_ENDDATE,
                                                                              'DD/MM/RRRR HH12:MI:SSAM')
ORDER BY TL.DELIVERY_CHALLAN_NUMBER;