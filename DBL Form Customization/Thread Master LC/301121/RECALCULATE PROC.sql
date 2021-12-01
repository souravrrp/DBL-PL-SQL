/* Formatted on 11/30/2021 3:41:05 PM (QP5 v5.365) */
PROCEDURE update_lc_pi_value
IS
    --l_pi_number   VARCHAR2 (240);
    l_pi_act_val   NUMBER;

    CURSOR cur_lc_pi_val IS
        SELECT mll1.pi_number l_pi_number, mll1.pi_value l_pi_value
          FROM xxdbl_master_lc_headers mlh, xxdbl_master_lc_line1 mll1
         WHERE     mlh.master_lc_header_id = mll1.master_lc_header_id(+)
               AND mlh.master_lc_header_id =
                   :xxdbl_master_lc_headers.master_lc_header_id;
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
                UPDATE xxdbl.xxdbl_master_lc_line1 pl
                   SET pl.PI_VALUE = l_pi_act_val
                 WHERE pl.mll1.pi_number = cur_lc_pi_upd.l_pi_number;

                COMMIT;
            END IF;
        END;
    END LOOP;
END;