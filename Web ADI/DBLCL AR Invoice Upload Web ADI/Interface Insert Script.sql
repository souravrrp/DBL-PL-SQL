/* Formatted on 2/9/2022 10:16:39 AM (QP5 v5.374) */
DECLARE
    L_RETURN_STATUS       VARCHAR2 (1);
    p_responsibility_id   NUMBER := apps.fnd_global.resp_id;
    p_respappl_id         NUMBER := apps.fnd_global.resp_appl_id;
    p_user_id             NUMBER := apps.fnd_global.user_id;
    p_org_id              NUMBER := apps.fnd_global.org_id;
    p_login_id            NUMBER := apps.fnd_global.login_id;

    CURSOR cur_stg IS
        SELECT *
          FROM xxdbl.xxdbl_cer_ar_intrf_stg
         WHERE FLAG IS NULL;
BEGIN
    FOR ln_cur_stg IN cur_stg
    LOOP
        BEGIN
            INSERT INTO ra_interface_lines_all (
                            interface_line_id,
                            batch_source_name,
                            line_number,
                            line_type,
                            cust_trx_type_name,
                            cust_trx_type_id,
                            trx_date,
                            gl_date,
                            currency_code,
                            term_id,
                            orig_system_bill_customer_id,
                            orig_system_bill_customer_ref,
                            orig_system_bill_address_id,
                            orig_system_bill_address_ref,
                            orig_system_ship_customer_id,
                            orig_system_ship_address_id,
                            orig_system_sold_customer_id,
                            -- sales_order,
                            inventory_item_id,
                            uom_code,
                            quantity,
                            unit_selling_price,
                            amount,
                            description,
                            conversion_type,
                            conversion_rate,
                            conversion_date,
                            --interface_line_context,
                            --interface_line_attribute1,
                            --interface_line_attribute2,
                            --interface_line_attribute3,
                            --interface_line_attribute4,
                            --interface_line_attribute5,
                            org_id,
                            set_of_books_id,
                            warehouse_id,
                            fob_point,
                            last_update_date,
                            last_updated_by,
                            creation_date,
                            created_by,
                            last_update_login,
                            taxable_flag,
                            amount_includes_tax_flag,
                            territory_id,
                            territory_segment1,
                            territory_segment2,
                            territory_segment3,
                            territory_segment4,
                            --invoicing_rule_id,
                            --accounting_rule_id,
                            --accounting_rule_duration
                            primary_salesrep_id)
                 VALUES (ra_customer_trx_lines_s.NEXTVAL, --> interface_line_id,
                         ln_cur_stg.BATCH_SOURCE_NAME,  --> batch_source_name,
                         ln_cur_stg.LINE_NUMBER,              --> line_number,
                         'LINE',                                --> line_type,
                         ln_cur_stg.TRX_TYPE,          --> cust_trx_type_name,
                         ln_cur_stg.CUST_TRX_TYPE_ID,    --> cust_trx_type_id,
                         ln_cur_stg.TRX_DATE,                    --> trx_date,
                         ln_cur_stg.GL_DATE,                      --> gl_date,
                         ln_cur_stg.CURRENCY_CODE,          --> currency_code,
                         ln_cur_stg.TERM_ID,                      --> term_id,
                         ln_cur_stg.CUSTOMER_ID, --> orig_system_bill_customer_id,
                         ln_cur_stg.CUSTOMER_ID, --> orig_system_bill_customer_ref,
                         ln_cur_stg.BILL_TO_SITE_ID, --> orig_system_bill_address_id,
                         ln_cur_stg.BILL_TO_SITE_ID, --> orig_system_bill_address_ref,
                         ln_cur_stg.CUSTOMER_ID, --> orig_system_ship_customer_id,
                         ln_cur_stg.SHIP_TO_SITE_ID, --> orig_system_ship_address_id,
                         ln_cur_stg.CUSTOMER_ID, --> orig_system_sold_customer_id,
                         -- 66500,                          --> sales_order,
                         ln_cur_stg.ITEM_ID,            --> inventory_item_id,
                         ln_cur_stg.UOM_CODE,                    --> uom_code,
                         ln_cur_stg.QUANTITY,                    --> quantity,
                         ln_cur_stg.UNIT_SELLING_PRICE, --> unit_selling_price,
                         ln_cur_stg.AMOUNT,                        --> amount,
                         ln_cur_stg.DESCRIPTION, --'Custom Interface Upload Invoice', --> description,
                         ln_cur_stg.EXCHANGE_RATE_TYPE,   --> conversion_type,
                         ln_cur_stg.EXCHANGE_RATE,        --> conversion_rate,
                         ln_cur_stg.EXCHANGE_DATE,        --> conversion_date,
                         --'DBL_IC_INVOICE',     --> interface_line_context,
                         --'XXDBLCL2',        --> interface_line_attribute1,
                         --ln_cur_stg.TRX_DATE, --> interface_line_attribute2,
                         --'XXDBLCL3',        --> interface_line_attribute3,
                         --'XXDBLCL4',        --> interface_line_attribute4,
                         --'XXDBLCL5',        --> interface_line_attribute5,
                         ln_cur_stg.OPERATING_UNIT,                --> org_id,
                         ln_cur_stg.SET_OF_BOOKS,         --> set_of_books_id,
                         ln_cur_stg.ORGANIZATION_ID,      --> organization_id,
                         NULL,                                  --> fob_point,
                         SYSDATE,                        --> last_update_date,
                         p_user_id, --fnd_global.user_id, --> last_updated_by,
                         SYSDATE,                           --> creation_date,
                         p_user_id,                            --> created_by,
                         p_login_id,                      -->last_update_login
                         'Y',                                --> taxable_flag,
                         'N',                    --> amount_includes_tax_flag,
                         ln_cur_stg.territory_id,              -->territory_id
                         ln_cur_stg.t_segment1,          -->territory_segment1
                         ln_cur_stg.t_segment2,          -->territory_segment2
                         ln_cur_stg.t_segment3,          -->territory_segment3
                         ln_cur_stg.t_segment4,          -->territory_segment3
                         --2,                                  --> invoicing_rule_id,
                         --1,                                 --> accounting_rule_id,
                         --NULL                          --> accounting_rule_duration
                         ln_cur_stg.salesrep_id         -->primary_salesrep_id
                                               );

            COMMIT;

            INSERT INTO ra_interface_distributions_all (
                            interface_distribution_id,
                            interface_line_id,
                            account_class,
                            amount,
                            code_combination_id,
                            PERCENT,
                            --interface_line_context,
                            --interface_line_attribute1,
                            --interface_line_attribute2,
                            --interface_line_attribute3,
                            --interface_line_attribute4,
                            --interface_line_attribute5,
                            org_id,
                            last_update_date,
                            last_updated_by,
                            creation_date,
                            created_by,
                            last_update_login)
                 VALUES (ra_cust_trx_line_gl_dist_s.NEXTVAL, --interface_distribution_id
                         ra_customer_trx_lines_s.CURRVAL, --> interface_line_id
                         'REV',                               -->account_class
                         ln_cur_stg.AMOUNT,                          -->amount
                         ln_cur_stg.CODE_COMBINATION_ID, -->code_combination_id
                         100,                                       -->PERCENT
                         --'DBL_IC_INVOICE',       -->interface_line_context
                         --'XXDBLCL2',        --> interface_line_attribute1,
                         --ln_cur_stg.TRX_DATE, --> interface_line_attribute2,
                         --'XXDBLCL3',        --> interface_line_attribute3,
                         --'XXDBLCL4',        --> interface_line_attribute4,
                         --'XXDBLCL5',        --> interface_line_attribute5,
                         ln_cur_stg.OPERATING_UNIT,                  -->org_id
                         SYSDATE,                          -->last_update_date
                         p_user_id,                         -->last_updated_by
                         SYSDATE,                             -->creation_date
                         p_user_id,                              -->created_by
                         p_login_id                       -->last_update_login
                                   );


            COMMIT;

            IF    L_RETURN_STATUS = FND_API.G_RET_STS_ERROR
               OR L_RETURN_STATUS = FND_API.G_RET_STS_UNEXP_ERROR
            THEN
                DBMS_OUTPUT.PUT_LINE ('unexpected errors found!');
                FND_FILE.put_line (
                    FND_FILE.LOG,
                    '--------------Unexpected errors found!--------------------');
            ELSE
                UPDATE apps.xxdbl_cer_ar_intrf_stg
                   SET FLAG = 'Y'
                 WHERE     FLAG IS NULL
                       AND SL_NO = ln_cur_stg.SL_NO
                       AND LINE_NUMBER = ln_cur_stg.LINE_NUMBER;

                COMMIT;
            END IF;
        EXCEPTION
            WHEN OTHERS
            THEN
                FND_FILE.put_line (
                    FND_FILE.LOG,
                    'Error while inserting records in lines table' || SQLERRM);
        END;
    END LOOP;
END;