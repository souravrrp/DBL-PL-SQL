SELECT RH.TRAN_TYPE,
       RH.TRAN_DATE,
       RH.CHALLAN_NO,
       RH.ATTRIBUTE6 As VEHICLE_NO,       
       RL.CUSTOMER_NAME,
       RL.CUSTOMER_PO,
       RL.SALES_ORDNO As SALES_ORDER,
       RL.BUYER_NO,
       RL.STYLE_NO,
       RL.ITEM_CODE,
       RL.ATTRIBUTE5 As UNIT_OF_MEASUREMENT,
       RL.LOT_NUMBER,
       RL.QTY,
       RL.ATTRIBUTE7 As YARN_COUNT,
       RH.TRAN_STATUS
  FROM xxdbl.XXDBL_RECV_HDR RH, xxdbl.XXDBL_RECV_DTL RL
 WHERE RH.RECV_HDR_ID = RL.RECV_HDR_ID
AND TO_DATE(RH.TRAN_DATE,'DD/MM/RRRR hh12:mi:ssAM') BETWEEN TO_DATE (
                                                      :p_StartDate,
                                                      'DD/MM/RRRR hh12:mi:ssAM')
                                               AND TO_DATE (
                                                      :p_EndDate,
                                                      'DD/MM/RRRR hh12:mi:ssAM')
