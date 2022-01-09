/* Formatted on 1/5/2022 5:38:50 PM (QP5 v5.374) */
ALTER TABLE xxdbl.xxdbl_om_sms_data_upload_stg
    ADD (CORRESPONDING_DEALER_PHONE VARCHAR2 (150 BYTE),
         SRS_PHONE VARCHAR2 (150 BYTE));