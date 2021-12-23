/* Formatted on 8/16/2020 10:07:34 AM (QP5 v5.287) */
PROCEDURE om_sms_response_into_stg_tbl (sms_text    VARCHAR2,
                                        ord_no      VARCHAR2,
                                        phone_no    VARCHAR2)
IS
   --v_booked_message_text   VARCHAR2 (500) := sms_text;
   --v_delivery_message_text   VARCHAR2 (500);

   CURSOR cur_res_stg
   IS
      SELECT *
        FROM XXDBL.XXDBL_OM_SMS_DATA_UPLOAD_STG
       WHERE     DELIVERED_FLAG IS NULL
             AND SENT_FLAG IS NULL
             AND ORDER_NUMBER = ord_no
             AND PHONE_NUMBER = phone_no;
BEGIN
   FOR ln_cur_res_stg IN cur_res_stg
   LOOP
      BEGIN
         UPDATE XXDBL.XXDBL_OM_SMS_DATA_UPLOAD_STG
            SET DELIVERED_FLAG = 'Y',
                SENT_FLAG = 'Y',
                MESSAGE_TEXT = sms_text
          WHERE     ORDER_NUMBER = ln_cur_res_stg.ORDER_NUMBER
                AND PHONE_NUMBER = ln_cur_res_stg.PHONE_NUMBER
                AND DELIVERED_FLAG IS NULL
                AND SENT_FLAG IS NULL;
      END;
   END LOOP;
END om_sms_response_into_stg_tbl;