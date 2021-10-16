/* Formatted on 10/11/2021 10:54:08 AM (QP5 v5.365) */
  SELECT *
    FROM XXDBL.XXDBL_YRN_TYPE_DATA
   WHERE     1 = 1
         AND YRN_TYPE IN ('Combed ', 'Carded ')
         AND item_code IN
                 ('YRN24S100OCM53499912',
                  'YRN40S100MOC530B1225',
                  'YRN08S100RES53499913')
ORDER BY ITEM_CODE