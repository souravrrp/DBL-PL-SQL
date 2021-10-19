/* Formatted on 10/19/2021 3:41:42 PM (QP5 v5.365) */
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