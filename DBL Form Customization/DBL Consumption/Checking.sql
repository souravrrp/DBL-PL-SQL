SELECT xxcd.*, xxcd.ROWID xx_rowid
  FROM xxdbl_consumption_dtl xxcd
 WHERE NVL (xxcd.confirm_flag, 'N') = 'N'
       AND NVL (xxcd.attribute2, 'N') = 'N'
       
       UPDATE xxdbl_consumption_dtl xxcd
   SET attribute2 = 'Y'
 WHERE CONSUMPTION_DTL_ID IN (1420)