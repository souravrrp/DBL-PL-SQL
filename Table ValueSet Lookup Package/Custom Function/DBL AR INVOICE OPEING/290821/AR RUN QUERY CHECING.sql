/* Formatted on 8/28/2021 3:49:36 PM (QP5 v5.287) */
SELECT APPS.XX_AR_PKG.GET_AR_OPEN_BAL (2095,
                                   131,
                                   105325,
                                   TO_DATE (TO_CHAR ('01-JUN-2021')),
                                   TO_DATE (TO_CHAR ('30-JUN-2021')))
          open_bal
  FROM DUAL