/* Formatted on 8/11/2021 2:46:19 PM (QP5 v5.287) */
CREATE OR REPLACE PACKAGE BODY apps.xxdbl_email_delivery_pkg
IS
   -- CREATED BY : SOURAV PAUL
   -- CREATION DATE : 05-AUG-2020
   -- LAST UPDATE DATE :22-OCT-2020
   -- PURPOSE : EMAIL DATA UPLOAD INTO STAGING TABLE
   PROCEDURE iou_email_status_update (p_mail_status    VARCHAR2,
                                      p_iou_req_id     NUMBER)
   IS
   --PURPOSE : UPDATE IOU EMAIL STATUS UPDATE

   BEGIN
      UPDATE xxdbl.xxdbl_iou_req_dtl ird
         SET ird.mail_status = p_mail_status
       WHERE ird.iou_req_id = p_iou_req_id;

      COMMIT;
   EXCEPTION
      WHEN NO_DATA_FOUND
      THEN
         raise_application_error (
            -20001,
               'An error was encountered - '
            || SQLCODE
            || ' -ERROR- '
            || SQLERRM);
   END iou_email_status_update;
END xxdbl_email_delivery_pkg;
/