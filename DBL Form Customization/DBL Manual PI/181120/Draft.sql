/* Formatted on 11/19/2020 12:31:47 PM (QP5 v5.287) */
DECLARE
   v_mpi_seq             NUMBER;
   v_mpi_number          VARCHAR2 (11);

   v_org                 NUMBER;
   p_responsibility_id   NUMBER := apps.fnd_global.resp_id;
   p_respappl_id         NUMBER := apps.fnd_global.resp_appl_id;
   p_user_id             NUMBER := apps.fnd_global.user_id;
   p_org_id              NUMBER := apps.fnd_global.org_id;
BEGIN
   fnd_standard.set_who;
   :xxdbl_manual_pi_header.manual_pi_id :=
      xx_com_pkg.get_sequence_value ('XXDBL_MANUAL_PI_HEADER',
                                     'MANUAL_PI_ID');

   SELECT XXDBL.XXDBL_MANUAL_PI_S.NEXTVAL INTO v_mpi_seq FROM DUAL;


   SELECT 'MPI-' || v_mpi_seq
     INTO v_mpi_number
     FROM DUAL;

   :xxdbl_manual_pi_header.manual_pi_number := v_mpi_number;
   :xxdbl_manual_pi_header.status := 'NEW';
--set_item_property ('xxdbl_manual_pi_header.manual_pi_number', update_allowed, property_false);
END;


---------------------------------------------------------------------------------------

DECLARE
   v_confirm   NUMBER;
BEGIN
   IF     :xxdbl_manual_pi_header.manual_pi_id IS NOT NULL
      AND :xxdbl_manual_pi_header.manual_pi_id = 'NEW'
   THEN
      SET_ALERT_PROPERTY ('ALT_CONFIRM',
                          alert_message_text,
                          'Do You Want to Comfirm PI ?');

      v_confirm := SHOW_ALERT ('ALT_CONFIRM');

      IF v_confirm = alert_button1
      THEN
         :xxdbl_manual_pi_header.status := 'CONFIRMED';
         SET_BLOCK_PROPERTY ('XXDBL_MANUAL_PI_HEADER',
                             update_allowed,
                             property_false);
         SET_BLOCK_PROPERTY ('XXDBL_MANUAL_PI_HEADER',
                             insert_allowed,
                             property_false);
         SET_BLOCK_PROPERTY ('XXDBL_MANUAL_PI_HEADER',
                             delete_allowed,
                             property_false);

         --COMMIT;
         EXECUTE_QUERY;
         GO_BLOCK ('XXDBL_MANUAL_PI_HEADER');
      END IF;
   ELSE
      SET_ALERT_PROPERTY ('ALT_CONFIRM',
                          alert_message_text,
                          'Manual PI is already Comfirmed !!!');
   END IF;
END;


--------------------------------------------------------------------------------


BEGIN
   fnd_standard.set_who;

   IF :XXDBL_MANUAL_PI_HEADER.STATUS = 'NEW'
   THEN
      SET_ITEM_PROPERTY ('XXDBL_IOU_REQ_DTL.IOU_NUMBER',
                         UPDATE_ALLOWED,
                         PROPERTY_FALSE);
   END IF;


   IF :XXDBL_MANUAL_PI_HEADER.STATUS = 'CONFIRMED'
   THEN
      SET_BLOCK_PROPERTY ('XXDBL_MANUAL_PI_HEADER',
                             update_allowed,
                             property_false);
         SET_BLOCK_PROPERTY ('XXDBL_MANUAL_PI_HEADER',
                             insert_allowed,
                             property_false);
         SET_BLOCK_PROPERTY ('XXDBL_MANUAL_PI_HEADER',
                             delete_allowed,
                             property_false);

         SET_ITEM_PROPERTY ('XXDBL_MANUAL_PI_HEADER.CONFIRM', ENABLED, property_false);
         
         SET_BLOCK_PROPERTY ('XXDBL_MANUAL_PI_LINE',
                             update_allowed,
                             property_false);
         SET_BLOCK_PROPERTY ('XXDBL_MANUAL_PI_LINE',
                             insert_allowed,
                             property_false);
         SET_BLOCK_PROPERTY ('XXDBL_MANUAL_PI_LINE',
                             delete_allowed,
                             property_false);
   END IF;
END;



---------------------------------------------------------------------------------


/* Formatted on 11/22/2020 12:10:51 PM (QP5 v5.287) */
DECLARE
   v_con_to_kg             NUMBER;
BEGIN
   SELECT apps.inv_convert.inv_um_convert (
             :xxdbl_manual_pi_line.inventory_item_id,
             NULL,
             NVL ( :xxdbl_manual_pi_line.quantity, 0),
             :xxdbl_manual_pi_line.quantity,
             'KG',
             NULL,
             NULL)*NVL(:xxdbl_manual_pi_line.net_weight,1)
     INTO v_con_to_kg
     FROM DUAL;

   :xxdbl_manual_pi_line.net_weight := v_con_to_kg;
END;