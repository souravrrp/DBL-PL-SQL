/* Formatted on 1/23/2021 4:14:46 PM (QP5 v5.287) */
-------------------------------Transactions--------------------------------------------------

SELECT RCTL.*
  FROM APPS.RA_CUSTOMER_TRX_ALL RCT, APPS.RA_CUSTOMER_TRX_LINES_ALL RCTL
 WHERE     1 = 1
       AND RCT.CUSTOMER_TRX_ID = RCTL.CUSTOMER_TRX_ID --AND RCTA.TRX_NUMBER=417045211
       --AND RCTLA.ORG_ID = 84
       --AND TO_CHAR (RCTA.TRX_DATE, 'MON-RR') = 'NOV-18'
       --AND TO_CHAR(RCTA.TRX_DATE,'MON-RR')='NOV-18'
       --AND RCTA.SOLD_TO_CUSTOMER_ID='816188'
       --AND ROWNUM <= 3
       AND ( :P_TRX_NUMBER IS NULL OR (RCT.TRX_NUMBER = :P_TRX_NUMBER));

---------------------------------------Batch -------------------------------------------------

SELECT BAT.ORG_ID,
       BAT.NAME BATCH_NUMBER,
       BAT.CREATED_BY CREATED_BY,
       BAT.CREATION_DATE,
       BAT.LAST_UPDATED_BY UPDATED_BY,
       BAT.LAST_UPDATE_DATE UPDATE_DATE,
       BAT.GL_DATE,
       BAT.*
  FROM APPS.AR_BATCHES_ALL BAT
 --     ,RA_CUSTOMER_TRX_ALL CT
 WHERE 1 = 1                                          --     AND BAT.BATCH_ID=
            AND NAME = 7934 AND ORG_ID = '83';

SELECT BAT.ORG_ID,
       BAT.NAME BATCH_NUMBER,
       BAT.CREATED_BY CREATED_BY,
       BAT.CREATION_DATE,
       BAT.LAST_UPDATED_BY UPDATED_BY,
       BAT.LAST_UPDATE_DATE UPDATE_DATE,
       BAT.GL_DATE,
       A.CUSTOMER_NUMBER,
       A.CUSTOMER_NAME,
       ICR.STATUS BATCH_STATUS,
       ICR.*
  FROM APPS.AR_INTERIM_CASH_RECEIPTS_ALL ICR,
       APPS.AR_BATCHES_ALL BAT,
       APPS.XXAKG_AR_CUSTOMER_SITE_V A
 WHERE     1 = 1
       AND ICR.ORG_ID = A.ORG_ID
       AND A.SHIP_TO_ORG_ID = ICR.SITE_USE_ID
       AND ICR.PAY_FROM_CUSTOMER = A.CUSTOMER_ID
       AND BAT.BATCH_ID = ICR.BATCH_ID
       AND BAT.ORG_ID = ICR.ORG_ID
       AND BAT.NAME = 44256
       AND BAT.ORG_ID = '85';

------------------------Cash Receipt---------------------------------------------------------

SELECT ' ' ztime,
       ' ' zutime,
       '100170' zid,
       CR.DOCUMENT_NUMBER xcrnnum,
       NVL (CH.GL_DATE, CR.GL_DATE) xdate,
       CUST.ATTRIBUTE7 xcus,
       ' ' xcuspo,
       ' ' xdatecuspo,
       ' ' xdiv,
       'NUL' xsec,
       ' ' xproj,
       'Confirmed' xstatusdor,
       ' ' xcitem,
       'BDT' xcur,
       1.00 xexch,
       (NVL (CH.ACCTD_AMOUNT, CR.FUNCTIONAL_AMOUNT)) xtotamt,
       ' ' xvoucher,
       ' ' zemail,
       ' ' xemail,
       CR.REMIT_BANK_NAME xdesc01,
       CR.REMIT_BANK_ACCOUNT_NUM xdesc02,
       ' ' xdesc03,
       SUBSTR (CBA.SECONDARY_ACCOUNT_REFERENCE, 1, 7) xaccdr,
       CBA.SECONDARY_ACCOUNT_REFERENCE xsubdr,
       'Subaccount' xaccsource,
       'Bank' xaccusage,
       ' ' xallocation,
       0 xbalance
  --select distinct CR.REMIT_BANK_ACCOUNT_NUM,CR.REMIT_BANK_ACCOUNT_NAME,CR.REMIT_BANK_NAME,--CR.REMIT_BANK_NAME||'-'||CR.REMIT_BANK_ACCOUNT_NUM ACCOUNT_NAME,CR.*--,
  --apps.XXAKG_CE_PKG.GET_ASSET_CODE_FROM_ACCOUNT_ID (CR.REMIT_BANK_ACCOUNT_ID) Account_Code --count(CR.DOCUMENT_NUMBER)
  FROM APPS.XXAKG_AR_CASH_RECEIPTS_V CR,
       APPS.AR_CASH_RECEIPT_HISTORY_ALL CH,
       APPS.CE_BANK_ACCOUNTS CBA,
       APPS.HZ_CUST_ACCOUNTS CUST
 WHERE     CR.CASH_RECEIPT_ID = CH.CASH_RECEIPT_ID
       AND NVL (CH.CURRENT_RECORD_FLAG, 'N') = 'Y'
       AND NVL (CH.GL_DATE, CR.GL_DATE) >= '01-JUL-2017'
       AND NVL (CH.GL_DATE, CR.GL_DATE) <= '30-JUN-2018'
       AND NVL (STATE, 'AKG') <> 'REVERSED'
       AND CH.ORG_ID = '85'
       AND CR.REMIT_BANK_NAME NOT IN
              ('AP-AR  Netting Bank', 'CC-29902001914')
       --          AND CR.REMIT_BANK_ACCOUNT_NUM = 'STD-2030155672041'--'CC-29902001914'
       AND CR.CUSTOMER_NUMBER = CUST.ACCOUNT_NUMBER
       --          AND BB.BRANCH_PARTY_ID(+) = CBA.BANK_BRANCH_ID
       AND CR.REMIT_BANK_ACCOUNT_ID = CBA.BANK_ACCOUNT_ID(+);