/* Formatted on 5/22/2021 12:43:06 PM (QP5 v5.287) */
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

   PROCEDURE import_data_from_web_adi (P_UNIT_NAME            VARCHAR2,
                                       P_CUSTOMER_NAME        VARCHAR2,
                                       P_CUSTOMER_TYPE        VARCHAR2,
                                       P_CUSTOMER_CATEGORY    VARCHAR2,
                                       P_ATTRIBUTE1           VARCHAR2,
                                       P_ATTRIBUTE2           VARCHAR2,
                                       P_ATTRIBUTE3           VARCHAR2,
                                       P_ATTRIBUTE4           VARCHAR2,
                                       P_ADDRESS1             VARCHAR2,
                                       P_ADDRESS2             VARCHAR2,
                                       P_ADDRESS3             VARCHAR2,
                                       P_ADDRESS4             VARCHAR2,
                                       P_POSTAL_CODE          VARCHAR2,
                                       P_TERRITORRY           VARCHAR2,
                                       P_DEMAND_CLASS         VARCHAR2,
                                       P_PAYMENT_TERM         VARCHAR2,
                                       P_SALESPERSON          VARCHAR2,
                                       P_GL_ACCOUNT           VARCHAR2)
   IS
      ---------------------Parameter-------------------

      l_operating_unit       NUMBER;
      p_attribute_category   VARCHAR2 (30 BYTE) := 'Additional Information';
      l_unit_name            VARCHAR2 (240 BYTE);
      l_customer_number      VARCHAR2 (240 BYTE);
      l_customer_category    VARCHAR2 (30 BYTE);
      l_salesperson          NUMBER;
      l_buyer                VARCHAR2 (30 BYTE);
      l_territory            NUMBER;
      l_demand_class         VARCHAR2 (30 BYTE);
      l_payment_term         VARCHAR2 (15 BYTE);
      l_gl_id_rec            NUMBER;
      --------------------------------------------

      l_error_message        VARCHAR2 (3000);
      l_error_code           VARCHAR2 (3000);
   ---------------------------------------------
   BEGIN
      /*
      --------------------------------------------------
      ----------Validate Existing Customer-----------------
      --------------------------------------------------

      BEGIN
         SELECT customer_number
           INTO l_customer_number
           FROM apps.ar_customers ac
          WHERE UPPER (ac.customer_name) LIKE
                   UPPER ('%' || p_customer_name || '%');

         IF ( (l_customer_number IS NULL) OR (l_customer_number = 0))
         THEN
            IF l_customer_number > 240
            THEN
               l_error_message :=
                     l_error_message
                  || ','
                  || 'Please ensure the Customer length is lesser than 240 characters';
               l_error_code := 'E';
            ELSIF (l_customer_number > 0)
            THEN
               l_error_message :=
                     l_error_message
                  || ','
                  || 'This Customer-'
                  || l_customer_number
                  || ' exists in System. Please create for another name.';
               l_error_code := 'E';
            END IF;
         END IF;
      END;
      */



      /*
      BEGIN
         SELECT customer_number
           INTO l_customer_number
           FROM apps.ar_customers ac
          WHERE UPPER (ac.customer_name) LIKE
                   UPPER ('%' || p_customer_name || '%');

         IF ( (l_customer_number IS NULL) OR (l_customer_number = 0))
         THEN
            IF l_customer_number > 240
            THEN
               l_error_message :=
                     l_error_message
                  || ','
                  || 'Please ensure the Customer length is lesser than 240 characters';
               l_error_code := 'E';
            ELSIF (l_customer_number > 0)
            THEN
               l_error_message :=
                     l_error_message
                  || ','
                  || 'This Customer-'
                  || l_customer_number
                  || ' exists in System. Please create for another name.';
               l_error_code := 'E';
            END IF;
         END IF;
      END;
      */



      --------------------------------------------------
      ----------Validate Oraganization------------------
      --------------------------------------------------
      BEGIN
         SELECT hou.organization_id, hou.name
           INTO l_operating_unit, l_unit_name
           FROM hr_organization_units hou
          WHERE hou.name = p_unit_name;
      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
            l_error_message :=
               l_error_message || ',' || 'Please enter correct Unit Name.';
            l_error_code := 'E';
      END;


      --------------------------------------------------
      ----------Validate Territory-----------------
      --------------------------------------------------
      BEGIN
         SELECT territory_id
           INTO l_territory
           FROM ra_territories rt
          WHERE    segment1
                || '.'
                || segment2
                || '.'
                || segment3
                || '.'
                || segment4 = p_territorry;
      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
            l_error_message :=
                  l_error_message
               || ','
               || 'Please enter correct Territory combination.';
            l_error_code := 'E';
      END;


      --------------------------------------------------
      ----------Validate Demand Class-------------------
      --------------------------------------------------
      BEGIN
         SELECT lookup_code
           INTO l_demand_class
           FROM fnd_lookup_values_vl flv
          WHERE     1 = 1
                AND flv.lookup_type = 'DEMAND_CLASS'
                AND enabled_flag = 'Y'
                AND lookup_code = p_demand_class;
      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
            l_error_message :=
               l_error_message || ',' || 'Please enter correct Demand Class.';
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


      --------------------------------------------------
      ----------Validate Payment Terms-------------------
      --------------------------------------------------
      BEGIN
         SELECT rt.term_id
           INTO l_payment_term
           FROM ra_terms rt
          WHERE rt.name = P_PAYMENT_TERM;
      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
            l_error_message :=
                  l_error_message
               || ','
               || 'Please enter correct Payment Terms.';
            l_error_code := 'E';
      END;

      --------------------------------------------------
      ----------Validate GL Code-------------------
      --------------------------------------------------
      BEGIN
         SELECT code_combination_id
           INTO l_gl_id_rec
           FROM apps.gl_code_combinations_kfv gcc
          WHERE gcc.concatenated_segments = p_gl_account;
      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
            l_error_message :=
               l_error_message || ',' || 'Please enter correct GL Code.';
            l_error_code := 'E';
      END;


      --------------------------------------------------
      ----------Validate Customer Category-------------------
      --------------------------------------------------
      BEGIN
         SELECT LOOKUP_CODE
           INTO l_customer_category
           FROM FND_LOOKUP_VALUES_VL FLV
          WHERE     FLV.LOOKUP_TYPE = 'CUSTOMER_CATEGORY'
                AND ENABLED_FLAG = 'Y'
                AND FLV.LOOKUP_CODE = UPPER (p_customer_category);
      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
            l_error_message :=
                  l_error_message
               || ','
               || 'Please enter correct Customer category.';
            l_error_code := 'E';
      END;

      --------------------------------------------------
      ----------Validate Customer Category-------------------
      --------------------------------------------------
      BEGIN
         SELECT LOOKUP_CODE
           INTO l_buyer
           FROM FND_LOOKUP_VALUES_VL FLV
          WHERE     FLV.LOOKUP_TYPE = 'SALES_CHANNEL'
                AND ENABLED_FLAG = 'Y'
                AND FLV.LOOKUP_CODE = UPPER ('MWW');
      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
            l_error_message :=
               l_error_message || ',' || 'Please enter correct Buyer.';
            l_error_code := 'E';
      END;

      --------------------------------------------------------------------------------------------------------------
      --------Condition to show error if any of the above validation picks up a data entry error--------------------
      --------Condition to insert data into custom staging table if the data passes all above validations-----------
      --------------------------------------------------------------------------------------------------------------



      IF l_error_code = 'E'
      THEN
         raise_application_error (-20101, l_error_message);
      ELSIF NVL (l_error_code, 'A') <> 'E'
      THEN
         INSERT INTO xxdbl.xxdbl_cust_creation_tbl (cust_id,
                                                    creation_date,
                                                    created_by,
                                                    unit_name,
                                                    operating_unit,
                                                    customer_name,
                                                    customer_type,
                                                    customer_category,
                                                    attribute_category,
                                                    attribute1,
                                                    attribute2,
                                                    attribute3,
                                                    attribute4,
                                                    address1,
                                                    address2,
                                                    address3,
                                                    address4,
                                                    postal_code,
                                                    payment_term,
                                                    demand_class,
                                                    territory,
                                                    salesperson,
                                                    buyer,
                                                    gl_id_rec)
              VALUES (TRIM (LPAD (xxdbl_cust_creation_s.NEXTVAL, 7, '0')),
                      SYSDATE,
                      p_user_id,
                      l_unit_name,
                      l_operating_unit,
                      p_customer_name,
                      NVL (p_customer_type, 'R'),
                      l_customer_category,
                      p_attribute_category,
                      p_attribute1,
                      p_attribute2,
                      p_attribute3,
                      p_attribute4,
                      p_address1,
                      p_address2,
                      p_address3,
                      p_address4,
                      p_postal_code,
                      l_payment_term,
                      l_demand_class,
                      l_territory,
                      l_salesperson,
                      l_buyer,
                      l_gl_id_rec);

         COMMIT;
      END IF;
   END import_data_from_web_adi;
END xxdbl_om_order_upld_pkg;
/