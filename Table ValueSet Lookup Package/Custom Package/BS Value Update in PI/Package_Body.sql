/* Formatted on 11/29/2021 5:33:08 PM (QP5 v5.365) */
CREATE OR REPLACE PACKAGE BODY apps.xxdbl_employee_update
IS
    PROCEDURE update_pi_bs_value
    IS
        --l_bill_stat_number   VARCHAR2 (240);
        l_bs_act_value   NUMBER;
        l_bs_act_qty     NUMBER;

        CURSOR cur_pi_bs_val IS
            SELECT pl.bill_stat_number     l_bill_stat_number,
                   pl.VALUE                l_bs_value,
                   pl.quantity             l_bs_qty
              FROM xxdbl_proforma_headers ph, xxdbl_proforma_lines pl
             WHERE     ph.proforma_header_id = pl.proforma_header_id(+)
                   AND ph.proforma_header_id =
                       :xxdbl_proforma_headers.proforma_header_id;
    BEGIN
        FOR cur_pi_bs_upd IN cur_pi_bs_val
        LOOP
            BEGIN
                SELECT SUM (bsl.VALUE), SUM (bsl.QUANTITY)
                  INTO l_bs_act_value, l_bs_act_qty
                  FROM xxdbl_bill_stat_headers bsh, xxdbl_bill_stat_lines bsl
                 WHERE     1 = 1
                       AND bsh.bill_stat_header_id = bsl.bill_stat_header_id
                       AND bsh.bill_stat_number =
                           cur_pi_bs_upd.l_bill_stat_number;

                IF    l_bs_act_value <> cur_pi_bs_upd.l_bs_value
                   OR l_bs_act_qty <> cur_pi_bs_upd.l_bs_qty
                THEN
                    UPDATE xxdbl.xxdbl_proforma_lines pl
                       SET pl.VALUE = l_bs_act_value,
                           pl.QUANTITY = l_bs_act_qty
                     WHERE pl.bill_stat_number =
                           cur_pi_bs_upd.l_bill_stat_number;

                    COMMIT;
                END IF;
            END;
        END LOOP;
    END;
END xxdbl_employee_update;
/