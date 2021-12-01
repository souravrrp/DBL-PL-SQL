/* Formatted on 11/30/2021 3:39:27 PM (QP5 v5.365) */
DECLARE
    --l_pi_number   VARCHAR2 (240);
    l_pi_act_val   NUMBER;

    CURSOR cur_lc_pi_val IS
        SELECT mll1.pi_number l_pi_number, mll1.pi_value l_pi_value
          FROM xxdbl_master_lc_headers mlh, xxdbl_master_lc_line1 mll1
         WHERE     mlh.master_lc_header_id = mll1.master_lc_header_id(+)
               AND mlh.master_lc_header_id = 1;
BEGIN
    FOR cur_lc_pi_upd IN cur_lc_pi_val
    LOOP
        BEGIN
            SELECT SUM (pl.VALUE)
              INTO l_pi_act_val
              FROM xxdbl_proforma_headers ph, xxdbl_proforma_lines pl
             WHERE     ph.proforma_header_id = pl.proforma_header_id(+)
                   AND ph.proforma_number = cur_lc_pi_upd.l_pi_number;

            IF l_pi_act_val <> cur_lc_pi_upd.l_pi_value
            THEN
                DBMS_OUTPUT.put_line ('Please update the PI BS Value');
            ELSE
                DBMS_OUTPUT.put_line ('No Change');
            END IF;
        END;
    END LOOP;
END;