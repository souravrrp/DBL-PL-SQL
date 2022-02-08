/* Formatted on 1/22/2022 10:58:29 AM (QP5 v5.374) */
-- a. Turn on DBMS_OUTPUT to display messages on screen
SET SERVEROUTPUT ON SIZE 1000000

-- b. Declaration section

DECLARE
    l_return_status          VARCHAR2 (1);
    l_msg_count              NUMBER;
    l_msg_data               VARCHAR2 (2000);
    l_batch_id               NUMBER;
    l_batch_source_rec       ar_invoice_api_pub.batch_source_rec_type;
    l_trx_header_tbl         ar_invoice_api_pub.trx_header_tbl_type;
    l_trx_lines_tbl          ar_invoice_api_pub.trx_line_tbl_type;
    l_trx_dist_tbl           ar_invoice_api_pub.trx_dist_tbl_type;
    l_trx_salescredits_tbl   ar_invoice_api_pub.trx_salescredits_tbl_type;
    l_trx_created            NUMBER;
    l_cnt                    NUMBER;

    CURSOR cbatch IS
        SELECT customer_trx_id
          FROM ra_customer_trx_all
         WHERE batch_id = l_batch_id;

    CURSOR list_errors IS
        SELECT trx_header_id,
               trx_line_id,
               trx_salescredit_id,
               trx_dist_id,
               trx_contingency_id,
               error_message,
               invalid_value
          FROM ar_trx_errors_gt;
BEGIN
    -- c. Set the applications context
    mo_global.init ('AR');
    mo_global.set_policy_context ('S', '126');
    fnd_global.apps_initialize (5958,
                                51456,
                                222,
                                0);

    -- d. Populate batch source information.
    l_batch_source_rec.batch_source_id := 1009;

    -- e. Populate header information for first invoice
    l_trx_header_tbl (1).trx_header_id := 101;
    l_trx_header_tbl (1).bill_to_customer_id := 2660;
    l_trx_header_tbl (1).cust_trx_type_id := 3009;

    -- f. Populate lines information for first invoice
    l_trx_lines_tbl (1).trx_header_id := 101;
    l_trx_lines_tbl (1).trx_line_id := 401;
    l_trx_lines_tbl (1).line_number := 1;
    l_trx_lines_tbl (1).description := 'Product Description 1';
    l_trx_lines_tbl (1).quantity_invoiced := 1;
    l_trx_lines_tbl (1).unit_selling_price := -150;
    l_trx_lines_tbl (1).line_type := 'LINE';


    -- Populate Distribution Information
    l_trx_dist_tbl (1).trx_dist_id := 601;
    l_trx_dist_tbl (1).trx_header_id := 101;
    l_trx_dist_tbl (1).trx_LINE_ID := 401;
    --l_trx_dist_tbl (1).ACCOUNT_CLASS := 'REV';
    l_trx_dist_tbl (1).AMOUNT := -150;                                  --150;
    l_trx_dist_tbl (1).CODE_COMBINATION_ID := 30156;                 --195346;

    -- k. Call the invoice api to create multiple invoices in a batch.
    AR_INVOICE_API_PUB.create_invoice (
        p_api_version            => 1.0,
        p_batch_source_rec       => l_batch_source_rec,
        p_trx_header_tbl         => l_trx_header_tbl,
        p_trx_lines_tbl          => l_trx_lines_tbl,
        p_trx_dist_tbl           => l_trx_dist_tbl,
        p_trx_salescredits_tbl   => l_trx_salescredits_tbl,
        x_return_status          => l_return_status,
        x_msg_count              => l_msg_count,
        x_msg_data               => l_msg_data);

    -- l. check for errors
    IF    l_return_status = fnd_api.g_ret_sts_error
       OR l_return_status = fnd_api.g_ret_sts_unexp_error
    THEN
        DBMS_OUTPUT.put_line ('FAILURE: Unexpected errors were raised!');
    ELSE
        -- m. check batch/invoices created
        SELECT DISTINCT batch_id
          INTO l_batch_id
          FROM ar_trx_header_gt;

        IF l_batch_id IS NOT NULL
        THEN
            DBMS_OUTPUT.put_line (
                   'SUCCESS: Created batch_id = '
                || l_batch_id
                || ' containing the following customer_trx_id:');

            FOR c IN cBatch
            LOOP
                DBMS_OUTPUT.put_line (' ' || c.customer_trx_id);
            END LOOP;
        END IF;
    END IF;

    -- n. Within the batch, check if some invoices raised errors
    SELECT COUNT (*) INTO l_cnt FROM ar_trx_errors_gt;

    IF l_cnt > 0
    THEN
        DBMS_OUTPUT.put_line ('FAILURE: Errors encountered, see list below:');

        FOR i IN list_errors
        LOOP
            DBMS_OUTPUT.put_line (
                '----------------------------------------------------');
            DBMS_OUTPUT.put_line (
                'Header ID = ' || TO_CHAR (i.trx_header_id));
            DBMS_OUTPUT.put_line ('Line ID = ' || TO_CHAR (i.trx_line_id));
            DBMS_OUTPUT.put_line (
                'Sales Credit ID = ' || TO_CHAR (i.trx_salescredit_id));
            DBMS_OUTPUT.put_line ('Dist Id = ' || TO_CHAR (i.trx_dist_id));
            DBMS_OUTPUT.put_line (
                'Contingency ID = ' || TO_CHAR (i.trx_contingency_id));
            DBMS_OUTPUT.put_line (
                'Message = ' || SUBSTR (i.error_message, 1, 80));
            DBMS_OUTPUT.put_line (
                'Invalid Value = ' || SUBSTR (i.invalid_value, 1, 80));
            DBMS_OUTPUT.put_line (
                '----------------------------------------------------');
        END LOOP;
    END IF;
END;
/
