/* Formatted on 2/16/2022 3:36:07 PM (QP5 v5.374) */
BEGIN
    INSERT INTO ra_interface_lines_all (interface_line_id,
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
                                        inventory_item_id,
                                        uom_code,
                                        quantity,
                                        unit_selling_price,
                                        amount,
                                        description,
                                        conversion_type,
                                        conversion_rate,
                                        conversion_date,
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
                                        primary_salesrep_id)
         VALUES (2464567,                               --> interface_line_id,
                 'DBLCL Imported CM',                   --> batch_source_name,
                 1,                                           --> line_number,
                 'LINE',                                        --> line_type,
                 'Credit Memo',                        --> cust_trx_type_name,
                 3009,                                   --> cust_trx_type_id,
                 '5-JAN-2022',                                     --> trx_date,
                 '5-JAN-2022',                                      --> gl_date,
                 'BDT',                                     --> currency_code,
                 5,                                               --> term_id,
                 2633,                       --> orig_system_bill_customer_id,
                 2633,                      --> orig_system_bill_customer_ref,
                 5727,                        --> orig_system_bill_address_id,
                 5727,                       --> orig_system_bill_address_ref,
                 2633,                       --> orig_system_ship_customer_id,
                 5727,                        --> orig_system_ship_address_id,
                 2633,                       --> orig_system_sold_customer_id,
                 NULL,                                  --> inventory_item_id,
                 NULL,                                           --> uom_code,
                 5,                                              --> quantity,
                 10,                                   --> unit_selling_price,
                 -10,                                              --> amount,
                 'Custom Interface Upload Invoice',           --> description,
                 'User',                                    --> conversion_type,
                 NULL,                                    --> conversion_rate,
                 NULL,                                    --> conversion_date,
                 126,                                              --> org_id,
                 2079,                                    --> set_of_books_id,
                 152,                                     --> organization_id,
                 NULL,                                          --> fob_point,
                 SYSDATE,                                --> last_update_date,
                 5958,              --fnd_global.user_id, --> last_updated_by,
                 SYSDATE,                                   --> creation_date,
                 5958,                                         --> created_by,
                 0,                                       -->last_update_login
                 'Y',                                        --> taxable_flag,
                 'N',                            --> amount_includes_tax_flag,
                 1035,                                         -->territory_id
                 'Bangladesh',                           -->territory_segment1
                 'Rangpur',                              -->territory_segment2
                 'Rangpur',                              -->territory_segment3
                 'Rangpur',                              -->territory_segment3
                 100013054                              -->primary_salesrep_id
                          );

    COMMIT;

    INSERT INTO ra_interface_distributions_all (interface_distribution_id,
                                                interface_line_id,
                                                account_class,
                                                amount,
                                                code_combination_id,
                                                PERCENT,
                                                org_id,
                                                last_update_date,
                                                last_updated_by,
                                                creation_date,
                                                created_by,
                                                last_update_login)
         VALUES (2252558,                          --interface_distribution_id
                 2464567,                                --> interface_line_id
                 'REV',                                       -->account_class
                 -50,                                                -->amount
                 30156,                                 -->code_combination_id
                 100,                                               -->PERCENT
                 126,                                                -->org_id
                 SYSDATE,                                  -->last_update_date
                 5958,                                      -->last_updated_by
                 SYSDATE,                                     -->creation_date
                 5958,                                           -->created_by
                 0                                        -->last_update_login
                  );


    COMMIT;
END;