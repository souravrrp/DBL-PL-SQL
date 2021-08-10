/* Formatted on 9/30/2020 10:14:53 AM (QP5 v5.287) */
  SELECT IOU_NUMBER,
         IOU_DATE,
         LEGAL_ENTITY,
         OPERATING_UNIT,
         OU_NAME,
         LOCATION_NAME,
         EMPLOYEE_NO,
         TRIM (
               PAPF.FIRST_NAME
            || ' '
            || PAPF.MIDDLE_NAMES
            || ' '
            || PAPF.LAST_NAME)
            AS FULL_NAME,
         ADVANCE_AMOUNT,
         REASON_FOR_ADVANCE,
         RETURN_DAYS,
         STATUS,
         --CREATED_BY,
         --CREATION_DATE,
         --LAST_UPDATED_BY,
         --LAST_UPDATE_DATE,
         PAYMENT_AMOUNT,
         PAYMENT_DATE,
         ADJUST_AMOUNT,
         ADJUST_DATE,
         BILL_AMOUNT APPROVED_BY
    FROM XXDBL.XXDBL_IOU_REQ_DTL IRD, APPS.PER_PEOPLE_F PAPF
   WHERE     1 = 1
         AND IRD.EMPLOYEE_NO = NVL (PAPF.EMPLOYEE_NUMBER, PAPF.NPW_NUMBER)
         AND ( :P_IOU_NUMBER IS NULL OR (IRD.IOU_NUMBER = :P_IOU_NUMBER))
         AND TRUNC (IRD.IOU_DATE) BETWEEN NVL ( :P_IOU_DATE_FROM,
                                               TRUNC (IRD.IOU_DATE))
                                      AND NVL ( :P_IOU_DATE_TO,
                                               TRUNC (IRD.IOU_DATE))
ORDER BY IOU_DATE, OU_NAME, IOU_NUMBER;