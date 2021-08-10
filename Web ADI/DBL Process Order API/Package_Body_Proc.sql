/* Formatted on 5/23/2021 11:41:22 AM (QP5 v5.287) */
CREATE OR REPLACE PACKAGE BODY APPS.xxdbl_om_order_upld_pkg
IS
   -- CREATED BY : SOURAV PAUL
   -- CREATION DATE : 19-MAY-2021
   -- LAST UPDATE DATE :19-MAY-2021
   -- PURPOSE : ORDER UPLOAD WEB ADI

   FUNCTION check_error_log_to_import_data
      RETURN NUMBER
   IS
      CURSOR c
      IS
         SELECT *
           FROM xxdbl.xxdbl_om_order_upld_stg
          WHERE status IS NULL;


      -------------------
      l_count                        NUMBER;
      l_api_version_number           NUMBER := 1;
      l_return_status                VARCHAR2 (2000);
      l_msg_count                    NUMBER;
      l_msg_data                     VARCHAR2 (2000);
      l_msg_index                    NUMBER;
      API_ERROR                      EXCEPTION;
      X_DEBUG_FILE                   VARCHAR2 (100);
      p_init_msg_list                VARCHAR2 (10) := FND_API.G_FALSE;
      p_return_values                VARCHAR2 (10) := FND_API.G_FALSE;
      p_action_commit                VARCHAR2 (10) := FND_API.G_FALSE;
      l_header_rec                   OE_ORDER_PUB.Header_Rec_Type;
      l_line_tbl                     OE_ORDER_PUB.Line_Tbl_Type;
      l_action_request_tbl           OE_ORDER_PUB.Request_Tbl_Type;
      l_header_adj_tbl               OE_ORDER_PUB.Header_Adj_Tbl_Type;
      l_line_adj_tbl                 OE_ORDER_PUB.line_adj_tbl_Type;
      l_header_scr_tbl               OE_ORDER_PUB.Header_Scredit_Tbl_Type;
      l_line_scredit_tbl             OE_ORDER_PUB.Line_Scredit_Tbl_Type;
      l_request_rec                  OE_ORDER_PUB.Request_Rec_Type;
      /***OUT VARIABLES FOR PROCESS_ORDER API***************************/
      l_header_rec_out               oe_order_pub.header_rec_type;
      l_header_val_rec_out           oe_order_pub.header_val_rec_type;
      l_header_adj_tbl_out           oe_order_pub.header_adj_tbl_type;
      l_header_adj_val_tbl_out       oe_order_pub.header_adj_val_tbl_type;
      l_header_price_att_tbl_out     oe_order_pub.header_price_att_tbl_type;
      l_header_adj_att_tbl_out       oe_order_pub.header_adj_att_tbl_type;
      l_header_adj_assoc_tbl_out     oe_order_pub.header_adj_assoc_tbl_type;
      l_header_scredit_tbl_out       oe_order_pub.header_scredit_tbl_type;
      l_header_scredit_val_tbl_out   oe_order_pub.header_scredit_val_tbl_type;
      l_line_tbl_out                 oe_order_pub.line_tbl_type;
      l_line_val_tbl_out             oe_order_pub.line_val_tbl_type;
      l_line_adj_tbl_out             oe_order_pub.line_adj_tbl_type;
      l_line_adj_val_tbl_out         oe_order_pub.line_adj_val_tbl_type;
      l_line_price_att_tbl_out       oe_order_pub.line_price_att_tbl_type;
      l_line_adj_att_tbl_out         oe_order_pub.line_adj_att_tbl_type;
      l_line_adj_assoc_tbl_out       oe_order_pub.line_adj_assoc_tbl_type;
      l_line_scredit_tbl_out         oe_order_pub.line_scredit_tbl_type;
      l_line_scredit_val_tbl_out     oe_order_pub.line_scredit_val_tbl_type;
      l_lot_serial_tbl_out           oe_order_pub.lot_serial_tbl_type;
      l_lot_serial_val_tbl_out       oe_order_pub.lot_serial_val_tbl_type;
      l_action_request_tbl_out       oe_order_pub.request_tbl_type;
   BEGIN
      FOR i IN c
      LOOP
         BEGIN
            DBMS_OUTPUT.ENABLE (1000000);


            --MO_GLOBAL.SET_POLICY_CONTEXT ('S', 126);   ----–>Vision Operations
            --FND_GLOBAL.APPS_INITIALIZE (5958, 53292, 660); --(1318, 21623, 660); ----–>User,Resp,Appl
            MO_GLOBAL.INIT ('ONT');
            MO_GLOBAL.SET_POLICY_CONTEXT ('S', i.operating_unit);
            FND_GLOBAL.APPS_INITIALIZE (p_user_id,
                                        p_responsibility_id,
                                        p_respappl_id,
                                        0);

            OE_MSG_PUB.INITIALIZE;
            OE_DEBUG_PUB.INITIALIZE;
            X_DEBUG_FILE := OE_DEBUG_PUB.SET_DEBUG_MODE ('FILE');
            OE_DEBUG_PUB.SETDEBUGLEVEL (5);

            DBMS_OUTPUT.put_line (' ===============================');
            DBMS_OUTPUT.put_line ('Start Order Creation Process');
            DBMS_OUTPUT.put_line ('===============================');

            ----–> Header Records
            l_header_rec := OE_ORDER_PUB.G_MISS_HEADER_REC;
            l_header_rec.operation := OE_GLOBALS.G_OPR_CREATE;
            l_header_rec.ordered_date := SYSDATE;
            l_header_rec.sold_from_org_id := i.sold_from_org_id;        --126;
            l_header_rec.sold_to_org_id := i.sold_to_org_id; --2660; --–1006; ----–>Computer Service and Rentals(1006)
            l_header_rec.order_type_id := i.order_type_id;             --1002;
            l_header_rec.price_list_id := i.price_list_id; --54178;               ----–>Corporate
            l_header_rec.pricing_date := SYSDATE;
            l_header_rec.salesrep_id := i.salesperson;            --100002052;
            l_header_rec.order_source_id := 0;                 ----–>Corporate
            l_header_rec.freight_terms_code := 'COMPANY'; --–h1.frieght_code;– 'DHL';
            --l_header_rec.freight_carrier_code := 'COMPANY'; --–h1.frieght_code;– 'DHL';

            --–> Line Records
            L_LINE_TBL (1) := OE_ORDER_PUB.G_MISS_LINE_REC;
            L_LINE_TBL (1).OPERATION := OE_GLOBALS.G_OPR_CREATE;
            l_line_tbl (1).header_id := l_header_rec_out.header_id;
            l_line_tbl (1).line_type_id := i.line_type_id; -- 1001;   --h1.line_type_id; -- 1421;
            l_line_tbl (1).price_list_id := i.price_list_id; --54178;               --–>Corporate
            l_line_tbl (1).inventory_item_id := i.inventory_item_id; --188961;            --–>AS54888
            l_line_tbl (1).ordered_quantity := i.order_qty; --5;                        --–3;
            l_line_tbl (1).ship_from_org_id := i.ship_from_org_id; --152; --–207; --–8583; --–9324; --–h1.ship_from_org_id; --– 207;
            l_line_tbl (1).ship_to_org_id := i.ship_to_org_id; --93198;              --–1026; --–>
            l_line_tbl (1).salesrep_id := i.salesperson;          --100002052;
            l_line_tbl (1).freight_terms_code := i.freight_terms_code; --'COMPANY'; --–h1.frieght_code;– 'DHL';
            --l_line_tbl (1).freight_carrier_code := 'COMPANY'; --–h1.frieght_code;– 'DHL';
            --l_line_tbl(1).tax_code := 'Location';
            --l_line_tbl (1).shipping_method_code := 'DHL'; --–h1.shiping_code; --– 'DHL';

            --–>INITIALIZE ACTION REQUEST RECORD
            l_action_request_tbl (1) := OE_ORDER_PUB.G_MISS_REQUEST_REC;
            l_action_request_tbl (1).request_type := oe_globals.g_book_order;
            l_action_request_tbl (1).entity_code := oe_globals.g_entity_header;

            --–> Calling the API
            OE_ORDER_PUB.PROCESS_ORDER (
               p_api_version_number       => 1.0,
               p_init_msg_list            => fnd_api.g_false,
               p_return_values            => fnd_api.g_false,
               p_action_commit            => fnd_api.g_false,
               x_return_status            => l_return_status,
               x_msg_count                => l_msg_count,
               x_msg_data                 => l_msg_data,
               p_header_rec               => l_header_rec,
               p_line_tbl                 => l_line_tbl,
               p_action_request_tbl       => l_action_request_tbl,
               --— OUT PARAMETERS
               x_header_rec               => l_header_rec_out,
               x_header_val_rec           => l_header_val_rec_out,
               x_header_adj_tbl           => l_header_adj_tbl_out,
               x_header_adj_val_tbl       => l_header_adj_val_tbl_out,
               x_header_price_att_tbl     => l_header_price_att_tbl_out,
               x_header_adj_att_tbl       => l_header_adj_att_tbl_out,
               x_header_adj_assoc_tbl     => l_header_adj_assoc_tbl_out,
               x_header_scredit_tbl       => l_header_scredit_tbl_out,
               x_header_scredit_val_tbl   => l_header_scredit_val_tbl_out,
               x_line_tbl                 => l_line_tbl_out,
               x_line_val_tbl             => l_line_val_tbl_out,
               x_line_adj_tbl             => l_line_adj_tbl_out,
               x_line_adj_val_tbl         => l_line_adj_val_tbl_out,
               x_line_price_att_tbl       => l_line_price_att_tbl_out,
               x_line_adj_att_tbl         => l_line_adj_att_tbl_out,
               x_line_adj_assoc_tbl       => l_line_adj_assoc_tbl_out,
               x_line_scredit_tbl         => l_line_scredit_tbl_out,
               x_line_scredit_val_tbl     => l_line_scredit_val_tbl_out,
               x_lot_serial_tbl           => l_lot_serial_tbl_out,
               x_lot_serial_val_tbl       => l_lot_serial_val_tbl_out,
               x_action_request_tbl       => l_action_request_tbl_out);
            COMMIT;

            IF l_return_status = FND_API.G_RET_STS_SUCCESS
            THEN
               DBMS_OUTPUT.put_line (
                     'Oracle Order is Created, Order Header ID : '
                  || l_header_rec_out.header_id
                  --|| 'Oracle Order is Created, Order Line ID : ' || l_line_tbl_out.line_id
                  || ', Order Number Is : '
                  || l_header_rec_out.order_number);

               DBMS_OUTPUT.put_line (
                     'Sales Order is Created And Order Number Is : '
                  || l_header_rec_out.order_number);

               --DBMS_OUTPUT.put_line ('the order is' || v_order);
               DBMS_OUTPUT.put_line ('============================');
               DBMS_OUTPUT.put_line ('Order Creation is Comleted');
               DBMS_OUTPUT.put_line ('============================');

               --------Update Staging Table after upload order
               UPDATE xxdbl.xxdbl_om_order_upld_stg
                  SET status = 'Y'
                WHERE status IS NULL AND om_order_id = i.om_order_id;

               COMMIT;
            ELSE
               DBMS_OUTPUT.put_line ('Order Creation Status Failure');

               RAISE API_ERROR;

               ROLLBACK;
            END IF;
         --–> HANDLE EXCEPTIONS
         EXCEPTION
            WHEN API_ERROR
            THEN
               FOR i IN 1 .. l_msg_count
               LOOP
                  BEGIN
                     OE_MSG_PUB.GET (p_msg_index       => i,
                                     p_encoded         => Fnd_Api.G_FALSE,
                                     p_data            => l_msg_data,
                                     p_msg_index_out   => l_msg_index);

                     DBMS_OUTPUT.put_line ('message is: ' || l_msg_data);

                     DBMS_OUTPUT.put_line (
                        'message index is: ' || l_msg_index);
                  END;
               END LOOP;
            WHEN OTHERS
            THEN
               FOR i IN 1 .. l_msg_count
               LOOP
                  OE_MSG_PUB.GET (p_msg_index       => i,
                                  p_encoded         => Fnd_Api.G_FALSE,
                                  p_data            => l_msg_data,
                                  p_msg_index_out   => l_msg_index);

                  DBMS_OUTPUT.put_line ('message is: ' || l_msg_data);

                  DBMS_OUTPUT.put_line ('message index is: ' || l_msg_index);
               END LOOP;
         END;
      END LOOP;

      COMMIT;
      RETURN 0;
   END;


   PROCEDURE process_data_from_stg_tbl (ERRBUF    OUT VARCHAR2,
                                        RETCODE   OUT VARCHAR2)
   IS
      L_Retcode     NUMBER;
      CONC_STATUS   BOOLEAN;
      l_error       VARCHAR2 (100);
   BEGIN
      fnd_file.put_line (fnd_file.LOG, 'Parameter received');


      L_Retcode := check_error_log_to_import_data;

      IF L_Retcode = 0
      THEN
         RETCODE := 'Success';
         CONC_STATUS :=
            FND_CONCURRENT.SET_COMPLETION_STATUS ('NORMAL', 'Completed');
         fnd_file.put_line (fnd_file.LOG, 'Status :' || L_Retcode);
      ELSIF L_Retcode = 1
      THEN
         RETCODE := 'Warning';
         CONC_STATUS :=
            FND_CONCURRENT.SET_COMPLETION_STATUS ('WARNING', 'Warning');
      ELSIF L_Retcode = 2
      THEN
         RETCODE := 'Error';
         CONC_STATUS :=
            FND_CONCURRENT.SET_COMPLETION_STATUS ('ERROR', 'Error');
      END IF;
   EXCEPTION
      WHEN OTHERS
      THEN
         l_error := 'error while executing the procedure ' || SQLERRM;
         errbuf := l_error;
         RETCODE := 1;
         fnd_file.put_line (fnd_file.LOG, 'Status :' || L_Retcode);
   END process_data_from_stg_tbl;

   PROCEDURE import_data_from_web_adi (p_customer_number    VARCHAR2,
                                       p_order_type         VARCHAR2,
                                       p_item_code          VARCHAR2,
                                       p_quantity           NUMBER,
                                       p_cust_po_number     VARCHAR2)
   IS
      ---------------------Parameter-------------------

      l_operating_unit     NUMBER;
      l_order_type_id      NUMBER;
      l_currency_code      VARCHAR2 (3 BYTE);
      l_price_list_id      NUMBER;
      l_organization_id    NUMBER;
      l_line_type_id       NUMBER;
      l_unit_name          VARCHAR2 (240 BYTE);
      --------------------------------------------
      l_item_id            NUMBER;
      l_uom_code           VARCHAR2 (10);
      l_item_description   VARCHAR2 (500);
      ----------------------------------------------
      l_quantity           NUMBER;
      ----------------------------------------------
      --l_freight_terms_code   VARCHAR2 (30);
      ----------------------------------------------
      --l_bill_to_site_id      NUMBER;
      --l_ship_to_site_id      NUMBER;
      -----------------------------------------------
      l_sold_to_org_id     NUMBER;
      l_ship_to_org_id     NUMBER;

      l_salesperson        NUMBER;
      --------------------------------------------

      l_error_message      VARCHAR2 (3000);
      l_error_code         VARCHAR2 (3000);
   ---------------------------------------------
   BEGIN
      --------------------------------------------------
      ----------Validate Order Type---------------------
      --------------------------------------------------
      BEGIN
         SELECT ott.transaction_type_id,
                ott.currency_code,
                ott.price_list_id,
                ott.warehouse_id,
                ott.org_id,
                ott.context,
                owla.line_type_id
           INTO l_order_type_id,
                l_currency_code,
                l_price_list_id,
                l_organization_id,
                l_operating_unit,
                l_unit_name,
                l_line_type_id
           FROM oe_transaction_types ott, oe_wf_line_assign_v owla
          WHERE     1 = 1
                AND ott.transaction_type_id = owla.order_type_id
                AND ott.name = p_order_type
                AND owla.end_date_active IS NULL
                AND ott.end_date_active IS NULL;
      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
            l_error_message :=
               l_error_message || ',' || 'Please enter correct Order Type.';
            l_error_code := 'E';
      END;



      --------------------------------------------------
      ----------Select Customer Bill TO Info------------
      --------------------------------------------------

      BEGIN
         SELECT ca.cust_account_id
           INTO l_sold_to_org_id
           FROM hz_cust_accounts ca
          WHERE ca.account_number = p_customer_number;
      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
            l_error_message :=
                  l_error_message
               || ','
               || 'Please enter correct customer number';
            l_error_code := 'E';
      END;


      --------------------------------------------------
      ----------Select Customer Ship TO Info------------
      --------------------------------------------------

      BEGIN
         SELECT csua.site_use_id, sal.salesrep_id
           INTO l_ship_to_org_id, l_salesperson
           FROM hz_cust_accounts ca,
                hz_cust_acct_sites_all casa,
                hz_cust_site_uses_all csua,
                jtf_rs_salesreps sal
          WHERE     ca.cust_account_id = casa.cust_account_id
                AND casa.cust_acct_site_id = csua.cust_acct_site_id
                AND csua.site_use_code = 'SHIP_TO'
                AND csua.primary_flag = 'Y'
                AND ca.status = 'A'
                AND csua.status = 'A'
                AND ca.account_number = p_customer_number
                AND casa.org_id = l_operating_unit
                AND csua.primary_salesrep_id = sal.salesrep_id(+);
      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
            l_error_message :=
                  l_error_message
               || ','
               || 'Please enter correct customer ship to address.';
            l_error_code := 'E';
      END;

      ----------------------------------------
      ----------Validate Item Info------------
      ----------------------------------------

      BEGIN
         SELECT msi.inventory_item_id, msi.primary_uom_code, msi.description
           INTO l_item_id, l_uom_code, l_item_description
           FROM apps.mtl_system_items_b msi
          WHERE     segment1 = p_item_code
                AND organization_id = l_organization_id
                AND enabled_flag = 'Y';
      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
            l_error_message :=
               l_error_message || ',' || 'Please enter correct Item Info.';
            l_error_code := 'E';
      END;

      ----------------------------------------
      ----------Count Total Quantity----------
      ----------------------------------------

      BEGIN
         SELECT NVL (p_quantity, 1) INTO l_quantity FROM DUAL;
      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
            l_error_message :=
                  l_error_message
               || ','
               || 'Please enter correct Quantity info.';
            l_error_code := 'E';
      END;



      /*
      --------------------------------------------------
      ----------Validate Freight Terms------------------
      --------------------------------------------------
      BEGIN
         SELECT FLV.LOOKUP_CODE
           INTO l_freight_terms_code
           FROM APPS.FND_LOOKUP_VALUES FLV
          WHERE     FLV.LANGUAGE = USERENV ('LANG')
                AND FLV.VIEW_APPLICATION_ID = 660
                AND UPPER (FLV.LOOKUP_TYPE) = (UPPER ('FREIGHT_TERMS'))
                AND ENABLED_FLAG = 'Y';
      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
            l_error_message :=
               l_error_message || ',' || 'Please enter correct Unit Name.';
            l_error_code := 'E';
      END;



      --------------------------------------------------
      ----------Validate Demand Class-------------------
      --------------------------------------------------
      BEGIN
         SELECT sal.salesrep_id
           INTO l_salesperson
           FROM jtf_rs_salesreps sal, hr.per_all_people_f papf
          WHERE     1 = 1
                AND sal.person_id = papf.person_id
                AND TRUNC (SYSDATE) BETWEEN TRUNC (papf.effective_start_date)
                                        AND TRUNC (papf.effective_end_date)
                AND NVL (papf.current_emp_or_apl_flag, 'Y') = 'Y'
                AND NVL (papf.employee_number, papf.npw_number) =
                       P_SALESPERSON
                AND sal.org_id = l_operating_unit;
      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
            l_error_message :=
                  l_error_message
               || ','
               || 'Please enter correct Employee for Sales Person.';
            l_error_code := 'E';
      END;
      */



      --------------------------------------------------------------------------------------------------------------
      --------Condition to show error if any of the above validation picks up a data entry error--------------------
      --------Condition to insert data into custom staging table if the data passes all above validations-----------
      --------------------------------------------------------------------------------------------------------------



      IF l_error_code = 'E'
      THEN
         raise_application_error (-20101, l_error_message);
      ELSIF NVL (l_error_code, 'A') <> 'E'
      THEN
         INSERT INTO xxdbl.xxdbl_om_order_upld_stg (om_order_id,
                                                    creation_date,
                                                    created_by,
                                                    unit_name,
                                                    operating_unit,
                                                    customer_number,
                                                    --bill_to_site_id,
                                                    --ship_to_site_id,
                                                    sold_from_org_id,
                                                    sold_to_org_id,
                                                    salesperson,
                                                    --price_list_name,
                                                    price_list_id,
                                                    --order_type,
                                                    order_type_id,
                                                    cust_po_number,
                                                    --freight_terms_code,
                                                    line_type_id,
                                                    ship_from_org_id,
                                                    ship_to_org_id,
                                                    item_code,
                                                    inventory_item_id,
                                                    order_qty)
                 VALUES (
                           TRIM (
                              LPAD (XXDBL.XXDBL_OM_ORDER_UPD_S.NEXTVAL,
                                    7,
                                    '0')),
                           SYSDATE,
                           TRIM (p_user_id),
                           TRIM (l_unit_name),
                           TRIM (l_operating_unit),
                           TRIM (p_customer_number),
                           --TRIM (bill_to_site_id),
                           --TRIM (ship_to_site_id),
                           TRIM (l_operating_unit),
                           TRIM (l_sold_to_org_id),
                           TRIM (l_salesperson),
                           --TRIM (price_list_name),
                           TRIM (l_price_list_id),
                           --TRIM (p_order_type),
                           TRIM (l_order_type_id),
                           TRIM (p_cust_po_number),
                           --TRIM (freight_terms_code),
                           TRIM (l_line_type_id),
                           TRIM (l_organization_id),
                           TRIM (l_ship_to_org_id),
                           TRIM (p_item_code),
                           TRIM (l_item_id),
                           TRIM (l_quantity));

         COMMIT;
      END IF;
   END import_data_from_web_adi;
END xxdbl_om_order_upld_pkg;
/