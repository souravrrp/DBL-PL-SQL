/* Formatted on 10/21/2021 11:03:03 AM (QP5 v5.365) */
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
                 793,                                --&vendor_id, --VENDOR_ID
                 3170,                     --&vendor_site_id, --VENDOR_SITE_ID
                 153,                  --&to_org_id, --SHIP_TO_ORGANIZATION_ID
                 SYSDATE,                              --EXPECTED_RECEIPT_DATE
                 384,                            --&employee_id, --EMPLOYEE_ID
                 'Y',                                        --VALIDATION_FLAG
                 126                        --&operating_unit --OPERATING_UNIT
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
               'RCV',                          --'FLO',--INTERFACE_SOURCE_CODE
               'DELIVER',                                 --AUTO_TRANSACT_CODE
               'VENDOR',                                 --RECEIPT_SOURCE_CODE
               153,                         --&to_org_id, --TO_ORGANIZATION_ID
               'PO',                                    --SOURCE_DOCUMENT_CODE
               422627,                         --&po_header_id, --PO_HEADER_ID
               579896,                             --&po_line_id, --PO_LINE_ID
               RCV_HEADERS_INTERFACE_S.CURRVAL,          --HEADER_INTERFACE_ID
               20113009408,                    --&document_num, --DOCUMENT_NUM
               1,                                          --DOCUMENT_LINE_NUM
               'Y',                                          --VALIDATION_FLAG
               10                                           --&amount --AMOUNT
          FROM DUAL;
END;