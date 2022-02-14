/* Formatted on 2/10/2022 10:47:25 AM (QP5 v5.374) */
/*=======================================================================+
 |  Copyright (c) 1993 Oracle Corporation Redwood Shores, California, USA|
 |                          All rights reserved.                         |
 +=======================================================================+
 | DESCRIPTION                                                           |
 |      PL/SQL to create On Account credit memo                          |
 +=======================================================================*/
SET SERVEROUTPUT ON SIZE 100000

DECLARE
    l_return_status          VARCHAR2 (1);
    l_msg_count              NUMBER;
    l_msg_data               VARCHAR2 (2000);
    l_batch_source_rec       ar_invoice_api_pub.batch_source_rec_type;
    l_trx_header_tbl         ar_invoice_api_pub.trx_header_tbl_type;
    l_trx_lines_tbl          ar_invoice_api_pub.trx_line_tbl_type;
    l_trx_dist_tbl           ar_invoice_api_pub.trx_dist_tbl_type;
    l_trx_salescredits_tbl   ar_invoice_api_pub.trx_salescredits_tbl_type;
    l_cust_trx_id            NUMBER;
    l_cnt                    NUMBER := 0;
BEGIN
    /*------------------------------------+
    |  Setting global initialization      |
    +------------------------------------*/

    fnd_global.apps_initialize (5958, 51456, 222);
    MO_GLOBAL.init ('AR');
    /*------------------------------------+
    |  Setting value to headers parameters|
    +------------------------------------*/
    l_batch_source_rec.batch_source_id := 16039;                          --1;
    l_trx_header_tbl (1).trx_header_id := 102;
    l_trx_header_tbl (1).trx_date := SYSDATE;
    l_trx_header_tbl (1).trx_currency := 'BDT';
    l_trx_header_tbl (1).cust_trx_type_id := 3009; -- 2;         --Credit Memo trx type
    l_trx_header_tbl (1).bill_to_customer_id := 2633;
    --l_trx_header_tbl(1).term_id := 5;  --Not needed for CMs
    l_trx_header_tbl (1).finance_charges := 'N';
    l_trx_header_tbl (1).status_trx := 'OP';
    l_trx_header_tbl (1).printing_option := 'NOT';
    /*------------------------------------+
    | Setting values to line parameters   |
    +------------------------------------*/
    l_trx_lines_tbl (1).trx_header_id := 102;
    l_trx_lines_tbl (1).trx_line_id := 202;
    l_trx_lines_tbl (1).line_number := 1;
    l_trx_lines_tbl (1).description := 'test';
    l_trx_lines_tbl (1).quantity_invoiced := 1;
    l_trx_lines_tbl (1).unit_selling_price := -200;           --Negative value
    l_trx_lines_tbl (1).line_type := 'LINE';
    /*------------------------------------+
    |  Calling to the API       |
    +------------------------------------*/
    AR_INVOICE_API_PUB.create_invoice (
        p_api_version            => 1.0,
        p_commit                 => 'T',
        p_batch_source_rec       => l_batch_source_rec,
        p_trx_header_tbl         => l_trx_header_tbl,
        p_trx_lines_tbl          => l_trx_lines_tbl,
        p_trx_dist_tbl           => l_trx_dist_tbl,
        p_trx_salescredits_tbl   => l_trx_salescredits_tbl,
        x_return_status          => l_return_status,
        x_msg_count              => l_msg_count,
        x_msg_data               => l_msg_data);

    COMMIT;

    /*------------------------------------+
    |  Error handling                     |
    +------------------------------------*/
    IF    l_return_status = fnd_api.g_ret_sts_error
       OR l_return_status = fnd_api.g_ret_sts_unexp_error
    THEN
        DBMS_OUTPUT.put_line ('l_return_status ' || l_return_status);
        DBMS_OUTPUT.put_line ('unexpected errors found!');
    ELSE
        -- Check whether any record exist in error table
        SELECT COUNT (*) INTO l_cnt FROM ar_trx_errors_gt;

        IF l_cnt = 0
        THEN
            DBMS_OUTPUT.put_line ('Invoice(s) suceessfully created!');
            DBMS_OUTPUT.put_line (
                'Batch ID: ' || ar_invoice_api_pub.g_api_outputs.batch_id);
        ELSE
            DBMS_OUTPUT.put_line (
                'Transaction not Created, Please check ar_trx_errors_gt table');
        END IF;
    END IF;
END;
/
