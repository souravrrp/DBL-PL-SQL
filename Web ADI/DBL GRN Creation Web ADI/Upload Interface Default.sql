/* Formatted on 10/19/2021 3:59:35 PM (QP5 v5.365) */
/* Formatted on 10/19/2021 4:05:07 PM (QP5 v5.365) */
BEGIN
    INSERT INTO RCV_HEADERS_INTERFACE (HEADER_INTERFACE_ID,
                                       GROUP_ID,
                                       PROCESSING_STATUS_CODE,
                                       RECEIPT_SOURCE_CODE,
                                       TRANSACTION_TYPE,
                                       AUTO_TRANSACT_CODE,
                                       LAST_UPDATE_DATE,
                                       LAST_UPDATED_BY,
                                       LAST_UPDATE_LOGIN,
                                       CREATION_DATE,
                                       CREATED_BY,
                                       VENDOR_ID,
                                       VENDOR_SITE_ID,
                                       SHIP_TO_ORGANIZATION_ID,
                                       EXPECTED_RECEIPT_DATE,
                                       EMPLOYEE_ID,
                                       VALIDATION_FLAG,
                                       ORG_ID)
         VALUES (RCV_HEADERS_INTERFACE_S.NEXTVAL,        --HEADER_INTERFACE_ID
                 RCV_INTERFACE_GROUPS_S.NEXTVAL,                    --GROUP_ID
                 'PENDING',                           --PROCESSING_STATUS_CODE
                 'VENDOR',                               --RECEIPT_SOURCE_CODE
                 'NEW',                                     --TRANSACTION_TYPE
                 'RECEIVE',                               --AUTO_TRANSACT_CODE
                 SYSDATE,                                   --LAST_UPDATE_DATE
                 0,                                          --LAST_UPDATED_BY
                 0,                                        --LAST_UPDATE_LOGIN
                 SYSDATE,                                      --CREATION_DATE
                 0,                                               --CREATED_BY
                 &vendor_id,                                       --VENDOR_ID
                 &vendor_site_id,                             --VENDOR_SITE_ID
                 &to_org_id,                         --SHIP_TO_ORGANIZATION_ID
                 SYSDATE,                              --EXPECTED_RECEIPT_DATE
                 &employee_id,                                   --EMPLOYEE_ID
                 'Y',                                        --VALIDATION_FLAG
                 &operating_unit                              --OPERATING_UNIT
                                );

    INSERT INTO RCV_TRANSACTIONS_INTERFACE (INTERFACE_TRANSACTION_ID,
                                            GROUP_ID,
                                            LAST_UPDATE_DATE,
                                            LAST_UPDATED_BY,
                                            CREATION_DATE,
                                            CREATED_BY,
                                            LAST_UPDATE_LOGIN,
                                            TRANSACTION_TYPE,
                                            TRANSACTION_DATE,
                                            PROCESSING_STATUS_CODE,
                                            PROCESSING_MODE_CODE,
                                            TRANSACTION_STATUS_CODE,
                                            INTERFACE_SOURCE_CODE,
                                            AUTO_TRANSACT_CODE,
                                            RECEIPT_SOURCE_CODE,
                                            TO_ORGANIZATION_ID,
                                            SOURCE_DOCUMENT_CODE,
                                            PO_HEADER_ID,
                                            PO_LINE_ID,
                                            HEADER_INTERFACE_ID,
                                            DOCUMENT_NUM,
                                            DOCUMENT_LINE_NUM,
                                            VALIDATION_FLAG,
                                            AMOUNT)
        SELECT RCV_TRANSACTIONS_INTERFACE_S.NEXTVAL, --INTERFACE_TRANSACTION_ID
               RCV_INTERFACE_GROUPS_S.CURRVAL,                      --GROUP_ID
               SYSDATE,                                     --LAST_UPDATE_DATE
               0,                                            --LAST_UPDATED_BY
               SYSDATE,                                        --CREATION_DATE
               0,                                                 --CREATED_BY
               0,                                          --LAST_UPDATE_LOGIN
               'RECEIVE',                                   --TRANSACTION_TYPE
               SYSDATE,                                     --TRANSACTION_DATE
               'PENDING',                             --PROCESSING_STATUS_CODE
               'BATCH',                                 --PROCESSING_MODE_CODE
               'PENDING',                            --TRANSACTION_STATUS_CODE
               'FLO',                                  --INTERFACE_SOURCE_CODE
               'DELIVER',                                 --AUTO_TRANSACT_CODE
               'VENDOR',                                 --RECEIPT_SOURCE_CODE
               &to_org_id,                                --TO_ORGANIZATION_ID
               'PO',                                    --SOURCE_DOCUMENT_CODE
               &po_header_id,                                   --PO_HEADER_ID
               &po_line_id,                                       --PO_LINE_ID
               RCV_HEADERS_INTERFACE_S.CURRVAL,          --HEADER_INTERFACE_ID
               &document_num,                                   --DOCUMENT_NUM
               1,                                          --DOCUMENT_LINE_NUM
               'Y',                                          --VALIDATION_FLAG
               &amount                                                --AMOUNT
          FROM DUAL;
END;

BEGIN
    fnd_request.submit_request (application   => 'PO',
                                program       => 'RVCTP',
                                description   => NULL,
                                start_time    => SYSDATE,
                                sub_request   => FALSE,
                                argument1     => 'BATCH',
                                argument2     => l_group_id);
END;

BEGIN
    INSERT INTO RCV_HEADERS_INTERFACE (HEADER_INTERFACE_ID,
                                       GROUP_ID,
                                       PROCESSING_STATUS_CODE,
                                       RECEIPT_SOURCE_CODE,
                                       TRANSACTION_TYPE,
                                       LAST_UPDATE_DATE,
                                       LAST_UPDATED_BY,
                                       LAST_UPDATE_LOGIN,
                                       CUSTOMER_ID,
                                       EXPECTED_RECEIPT_DATE,
                                       VALIDATION_FLAG)
        SELECT RCV_HEADERS_INTERFACE_S.NEXTVAL,          --HEADER_INTERFACE_ID
               RCV_INTERFACE_GROUPS_S.NEXTVAL,                      --GROUP_ID
               'PENDING',                             --PROCESSING_STATUS_CODE
               'CUSTOMER',                               --RECEIPT_SOURCE_CODE
               'NEW',                                       --TRANSACTION_TYPE
               SYSDATE,                                     --LAST_UPDATE_DATE
               1318,                                --USER_ID--LAST_UPDATED_BY
               0,                                          --LAST_UPDATE_LOGIN
               40073,                                            --CUSTOMER_ID
               SYSDATE,                                --EXPECTED_RECEIPT_DATE
               'Y'                                           --VALIDATION_FLAG
          FROM DUAL;

    INSERT INTO RCV_TRANSACTIONS_INTERFACE (INTERFACE_TRANSACTION_ID,
                                            GROUP_ID,
                                            HEADER_INTERFACE_ID,
                                            LAST_UPDATE_DATE,
                                            LAST_UPDATED_BY,
                                            CREATION_DATE,
                                            CREATED_BY,
                                            TRANSACTION_TYPE,
                                            TRANSACTION_DATE,
                                            PROCESSING_STATUS_CODE,
                                            PROCESSING_MODE_CODE,
                                            TRANSACTION_STATUS_CODE,
                                            QUANTITY,
                                            UNIT_OF_MEASURE,
                                            INTERFACE_SOURCE_CODE,
                                            ITEM_ID,
                                            EMPLOYEE_ID,
                                            AUTO_TRANSACT_CODE,
                                            RECEIPT_SOURCE_CODE,
                                            TO_ORGANIZATION_ID,
                                            SOURCE_DOCUMENT_CODE,
                                            DESTINATION_TYPE_CODE,
                                            DELIVER_TO_LOCATION_ID,
                                            SUBINVENTORY,
                                            EXPECTED_RECEIPT_DATE,
                                            OE_ORDER_HEADER_ID,
                                            OE_ORDER_LINE_ID,
                                            CUSTOMER_ID,
                                            CUSTOMER_SITE_ID,
                                            VALIDATION_FLAG)
         VALUES (RCV_TRANSACTIONS_INTERFACE_S.NEXTVAL, --INTERFACE_TRANSACTION_ID
                 RCV_INTERFACE_GROUPS_S.CURRVAL,                    --GROUP_ID
                 RCV_HEADERS_INTERFACE_S.CURRVAL,        --HEADER_INTERFACE_ID
                 SYSDATE,                                   --LAST_UPDATE_DATE
                 1318,                                       --LAST_UPDATED_BY
                 SYSDATE,                                      --CREATION_DATE
                 1318,                                            --CREATED_BY
                 'RECEIVE',                                 --TRANSACTION_TYPE
                 SYSDATE,                                   --TRANSACTION_DATE
                 'PENDING',                           --PROCESSING_STATUS_CODE
                 'BATCH',                               --PROCESSING_MODE_CODE
                 'PENDING',                            --TRANSACTION_MODE_CODE
                 1,                                                 --QUANTITY
                 'Each',                                     --UNIT_OF_MEASURE
                 'RCV',                                --INTERFACE_SOURCE_CODE
                 149,                                                --ITEM_ID
                 25,                                             --EMPLOYEE_ID
                 'DELIVER',                               --AUTO_TRANSACT_CODE
                 'CUSTOMER',                             --RECEIPT_SOURCE_CODE
                 204,                                     --TO_ORGANIZATION_ID
                 'RMA',                                 --SOURCE_DOCUMENT_CODE
                 'INVENTORY',                          --DESTINATION_TYPE_CODE
                 204,                                 --DELIVER_TO_LOCATION_ID
                 'Stores',                                      --SUBINVENTORY
                 SYSDATE,                              --EXPECTED_RECEIPT_DATE
                 99442,                                   --OE_ORDER_HEADER_ID
                 200068,                                    --OE_ORDER_LINE_ID
                 40073,                                          --CUSTOMER_ID
                 10144,                                     --CUSTOMER_SITE_ID
                 'Y');
END;