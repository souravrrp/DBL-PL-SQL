/* Formatted on 12/20/2020 2:15:20 PM (QP5 v5.287) */
DECLARE
   l_mpi_status   VARCHAR2 (100 BYTE)
      := validate_manual_pi ( :XXDBL_PROFORMA_HEADERS.MANUAL_PI_NO);
BEGIN
   IF l_mpi_status = 'CLOSED'
   THEN
      SET_ITEM_PROPERTY ('XXDBL_PROFORMA_HEADERS.MANUAL_PI_NO',
                         update_allowed,
                         property_false);
   ELSE
      SET_ITEM_PROPERTY ('XXDBL_PROFORMA_HEADERS.MANUAL_PI_NO',
                         update_allowed,
                         property_ture);
   END IF;
END;

DECLARE
   l_mpi_status   VARCHAR2 (100 BYTE)
      := validate_manual_pi ( :XXDBL_PROFORMA_HEADERS.MANUAL_PI_NO);
BEGIN
   IF l_mpi_status = 'CLOSED'
   THEN
      SET_ITEM_PROPERTY ('XXDBL_PROFORMA_HEADERS.MANUAL_PI_NO',
                         ENABLED,
                         property_false);
   ELSE
      SET_ITEM_PROPERTY ('XXDBL_PROFORMA_HEADERS.MANUAL_PI_NO',
                         ENABLED,
                         property_true);
   END IF;
END;

/* Formatted on 12/20/2020 2:09:14 PM (QP5 v5.287) */
FUNCTION validate_manual_pi (p_mpi_no VARCHAR2)
   RETURN VARCHAR
IS
   l_status   VARCHAR2 (100 BYTE);
BEGIN
   SELECT status
     INTO l_status
     FROM xxdbl.xxdbl_manual_pi_header
    WHERE MANUAL_PI_NUMBER = p_mpi_no;

   RETURN l_status;
EXCEPTION
   WHEN OTHERS
   THEN
      RETURN 0;
END;