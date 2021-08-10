/* Formatted on 6/23/2020 9:55:06 AM (QP5 v5.287) */
CREATE OR REPLACE PROCEDURE XXCRT_ARINV (P_DATE              DATE,
                                         P_BILLING_ID        NUMBER,
                                         P_CUSTOMER_ID       NUMBER,
                                         W_TRX_NUMBER    OUT VARCHAR2,
                                         W_STATUS        OUT VARCHAR2,
                                         W_MESSAGE       OUT VARCHAR2)
AS
   L_CNT                     VARCHAR2 (100);
   P_RESULT                  VARCHAR2 (300);
   --P_DATE                    DATE := TRUNC(SYSDATE) +1;
   l_batch_source_id         NUMBER := 1003;                  --Source ???????
   l_cust_trx_type_id        NUMBER := 1001;                 --type_id ???????
   v_customer_id             NUMBER := P_CUSTOMER_ID;             --8173483;--
   --L_CUSTOMER_TRX_ID         NUMBER := P_CUSTOMER_TRX_ID;--8777389;--
   v_user_id                 NUMBER := 26055; --FND_PROFILE.VALUE('USER_ID'); --2605;
   v_resp_id                 NUMBER := 506035; --FND_PROFILE.VALUE('RESP_ID');--52328;
   v_resp_appl_id            NUMBER := 222;         --fnd_global.resp_appl_id;
   v_org_id                  NUMBER := 1452; --FND_PROFILE.VALUE('ORG_ID');--1930;
   v_date                    DATE := P_DATE;
   v_trx_number              NUMBER;
   l_return_status           VARCHAR2 (1);
   l_msg_count               NUMBER;
   l_msg_data                VARCHAR2 (2000);
   l_batch_id                NUMBER;
   l_batch_source_rec        ar_invoice_api_pub.batch_source_rec_type;
   l_trx_header_tbl          ar_invoice_api_pub.trx_header_tbl_type;
   l_trx_lines_tbl           ar_invoice_api_pub.trx_line_tbl_type;
   l_trx_dist_tbl            ar_invoice_api_pub.trx_dist_tbl_type;
   l_trx_salescredits_tbl    ar_invoice_api_pub.trx_salescredits_tbl_type;
   l_trx_contingencies_tbl   ar_invoice_api_pub.trx_contingencies_tbl_type;
   trx_header_id             NUMBER;
   trx_line_id               NUMBER;
   trx_dist_id               NUMBER;
   v_line                    NUMBER := 1;
   v_line_count              NUMBER := 0;
   v_price_total             NUMBER := 0;

   l_currency_code           VARCHAR2 (100) := 'AED';
   l_site_use_id             NUMBER;
   L_EXIST                   VARCHAR2 (100);
   L_MEMO_LINE_ID            NUMBER;

   --W_TRX_NUMBER VARCHAR2 (100);
   --W_STATUS VARCHAR2 (100);
   --W_MESSAGE VARCHAR2 (100);
   --LIST_ERRORS VARCHAR2 (100);

   CURSOR list_errors
   IS
      SELECT trx_header_id,
             trx_line_id,
             trx_salescredit_id,
             trx_dist_id,
             trx_contingency_id,
             error_message,
             invalid_value
        FROM ar_trx_errors_gt;

   CURSOR cbatch
   IS
      SELECT customer_trx_id
        FROM ra_customer_trx_all
       WHERE batch_id = l_batch_id;

   CURSOR cvalidtxn
   IS
      SELECT trx_header_id
        FROM ar_trx_header_gt
       WHERE trx_header_id NOT IN (SELECT trx_header_id
                                     FROM ar_trx_errors_gt);

   CURSOR HEADER_DETAILS
   IS
      --custom table storing the details of header info
      SELECT *
        FROM XX_BILLING_SYS_R
       WHERE BILLING_ID = P_BILLING_ID;

   CURSOR line_items
   IS
      --custom table storing the details of line info
      SELECT MEMO_LINE_ID,
             UNIT_SELLING_PRICE PRICE,
             QUANTITY_INVOICED QTY,
             UOM_CODE,
             GL_ID,
             DESCRIPTION NAME
        FROM XX_BILLING_SYS_LINES RCL
       WHERE RCL.BILLING_ID = P_BILLING_ID;
--end of cursors
BEGIN
   BEGIN
      SELECT ra_customer_trx_s.NEXTVAL INTO trx_header_id FROM DUAL;
   END;

   BEGIN
      SELECT c.site_use_id
        INTO l_site_use_id
        FROM hz_cust_accounts a,
             hz_cust_acct_sites_all b,
             hz_cust_site_uses_all c,
             hz_party_sites d,
             hz_locations e
       WHERE     a.cust_account_id = b.cust_account_id
             AND b.cust_acct_site_id = c.cust_acct_site_id
             AND b.party_site_id = d.party_site_id
             AND d.location_id = e.location_id
             AND c.site_use_code = 'BILL_TO'
             AND c.status = 'A'
             AND b.org_id = c.org_id
             AND b.org_id = v_org_id
             AND a.cust_account_id = P_customer_id;                  --8173483
   EXCEPTION
      WHEN OTHERS
      THEN
         DBMS_OUTPUT.PUT_LINE ('ERROR IN SITE--22');
   END;


   FOR H IN HEADER_DETAILS
   LOOP
      fnd_global.apps_initialize (v_user_id, v_resp_id, v_resp_appl_id);
      mo_global.init ('AR');
      mo_global.set_policy_context ('S', v_org_id);
      xla_security_pkg.set_security_context (v_resp_appl_id);
      DBMS_OUTPUT.put_line ('l_cust_trx_type_id' || l_cust_trx_type_id);
      DBMS_OUTPUT.put_line ('bill_to_customer_id' || p_customer_id);
      DBMS_OUTPUT.put_line ('l_site_use_id' || l_site_use_id);
      l_trx_header_tbl (1).trx_header_id := trx_header_id;
      l_trx_header_tbl (1).bill_to_customer_id := v_customer_id;
      l_trx_header_tbl (1).cust_trx_type_id := l_cust_trx_type_id;
      l_trx_header_tbl (1).trx_date := TRUNC (p_date);
      l_trx_header_tbl (1).gl_date := TRUNC (p_date);
      l_trx_header_tbl (1).trx_currency := l_Currency_Code;
      l_trx_header_tbl (1).primary_salesrep_id := -3;
      l_trx_header_tbl (1).org_id := v_org_id;
      l_trx_header_tbl (1).comments :=
         'Test from plsql Comments' || ' ' || SYSDATE;
      l_trx_header_tbl (1).INTERFACE_HEADER_CONTEXT :=
         h.INTERFACE_HEADER_CONTEXT;
      l_trx_header_tbl (1).INTERFACE_HEADER_ATTRIBUTE1 :=
         h.INTERFACE_HEADER_ATTRIBUTE1;
      l_trx_header_tbl (1).INTERFACE_HEADER_ATTRIBUTE2 :=
         h.INTERFACE_HEADER_ATTRIBUTE2;
      l_trx_header_tbl (1).INTERFACE_HEADER_ATTRIBUTE3 :=
         h.INTERFACE_HEADER_ATTRIBUTE3;
      l_trx_header_tbl (1).INTERFACE_HEADER_ATTRIBUTE4 :=
         h.INTERFACE_HEADER_ATTRIBUTE4;
      l_trx_header_tbl (1).INTERFACE_HEADER_ATTRIBUTE5 :=
         h.INTERFACE_HEADER_ATTRIBUTE5;
      l_trx_header_tbl (1).INTERFACE_HEADER_ATTRIBUTE6 :=
         h.INTERFACE_HEADER_ATTRIBUTE6;
      l_trx_header_tbl (1).INTERFACE_HEADER_ATTRIBUTE7 :=
         h.INTERFACE_HEADER_ATTRIBUTE7;

      l_trx_header_tbl (1).INTERFACE_HEADER_ATTRIBUTE12 :=
         h.INTERFACE_HEADER_ATTRIBUTE12; --TO_CHAR(fnd_conc_date.string_to_date(h.INTERFACE_HEADER_ATTRIBUTE13) + 1,'yyyy/mm/dd hh:mi:ss');--'2019/01/01 00:00:00';

      l_trx_header_tbl (1).INTERFACE_HEADER_ATTRIBUTE13 :=
         h.INTERFACE_HEADER_ATTRIBUTE13; --TO_CHAR(ADD_MONTHS(fnd_conc_date.string_to_date(h.INTERFACE_HEADER_ATTRIBUTE13),12) ,'yyyy/mm/dd hh:mi:ss');--'2019/05/13 00:00:00';
      l_trx_header_tbl (1).INTERFACE_HEADER_ATTRIBUTE14 :=
         h.INTERFACE_HEADER_ATTRIBUTE14;
      --l_trx_header_tbl(1).attribute11:=p_Source;
      --l_trx_header_tbl(1).attribute12:=p_trx_number;
      --l_trx_header_tbl(1).attribute13:=TRUNC(SYSDATE);
      --l_trx_header_tbl(1).attribute14:=TRUNC(P_Expiration_Date);
      --l_trx_header_tbl(1).attribute15:=p_Accounting_Rule;
      --l_trx_header_tbl(1).attribute10:=p_Sub_Service;
      --l_trx_header_tbl(1).attribute7:=NVL(substr(p_business_name,0,60),'-');
      l_trx_header_tbl (1).trx_class := 'INV';
      l_trx_header_tbl (1).bill_to_site_use_id := l_site_use_id;
      l_trx_header_tbl (1).term_id := 1000;
      l_batch_source_rec.batch_source_id := l_batch_source_id;
   END LOOP;

   FOR i IN line_items
   LOOP
      BEGIN
         v_line_count := v_line_count + v_line;
         --v_price_total := v_price_total + (i.price * i.qty);
         l_trx_lines_tbl (v_line_count).trx_header_id := trx_header_id;
         l_trx_lines_tbl (v_line_count).trx_line_id :=
            ra_customer_trx_lines_s.NEXTVAL;                  --trx_line_id_v;
         l_trx_lines_tbl (v_line_count).line_number := v_line_count;
         l_trx_lines_tbl (v_line_count).description := i.name;
         l_trx_lines_tbl (v_line_count).quantity_invoiced := i.qty;
         l_trx_lines_tbl (v_line_count).unit_selling_price := i.price;
         l_trx_lines_tbl (v_line_count).line_type := 'LINE';
         --l_trx_lines_tbl (1).tax_exempt_flag := 'E';
         --l_trx_lines_tbl (1).TAX_EXEMPT_REASON_CODE := 'E';
         --l_trx_lines_tbl (1).TAX_EXEMPT_REASON_CODE_MEANING := 'E';
         l_trx_lines_tbl (v_line_count).memo_line_id := i.memo_line_id;
         --   l_trx_lines_tbl (1).TAX_PRECEDENCE := 10;
         --   l_trx_lines_tbl (1).TAX_RATE := 10;
         l_trx_dist_tbl (v_line_count).trx_dist_id :=
            ra_cust_trx_line_gl_dist_s.NEXTVAL;
         l_trx_dist_tbl (v_line_count).trx_line_id :=
            ra_customer_trx_lines_s.CURRVAL;
         l_trx_dist_tbl (v_line_count).account_class := 'REV';
         l_trx_dist_tbl (v_line_count).PERCENT := 100;
         l_trx_dist_tbl (v_line_count).code_combination_id := i.gl_id;
      --DBMS_OUTPUT.put_line ('i value  ->' || i);
      --DBMS_OUTPUT.put_line ('line-   ' || i || ' Amt = ' || i.price);
      --DBMS_OUTPUT.put_line ('REV ID   ' || i || '  = ' || i.gl_id);
      END;
   END LOOP;

   --END;

   fnd_global.apps_initialize (v_user_id, v_resp_id, v_resp_appl_id);
   mo_global.set_policy_context ('S', v_org_id);

   AR_INVOICE_API_PUB.create_single_invoice (
      p_api_version            => 1.0,
      P_INIT_MSG_LIST          => FND_API.G_FALSE,
      P_COMMIT                 => FND_API.G_FALSE,
      p_batch_source_rec       => l_batch_source_rec,
      p_trx_header_tbl         => l_trx_header_tbl,
      p_trx_lines_tbl          => l_trx_lines_tbl,
      p_trx_dist_tbl           => l_trx_dist_tbl,
      p_trx_salescredits_tbl   => l_trx_salescredits_tbl,
      x_customer_trx_id        => l_customer_trx_id,
      x_return_status          => l_return_status,
      x_msg_count              => l_msg_count,
      x_msg_data               => l_msg_data);
   COMMIT;
   DBMS_OUTPUT.put_line ('l_return_status-' || l_return_status);
   DBMS_OUTPUT.put_line ('l_customer_trx_id-' || l_customer_trx_id);
   DBMS_OUTPUT.put_line ('l_msg_count -' || l_msg_count);

   IF l_customer_trx_id > 0
   THEN
      BEGIN
         SELECT TRX_NUMBER
           INTO W_TRX_Number
           FROM ra_customer_trx
          WHERE customer_trx_id = l_customer_trx_id;
      END;

      W_Status := 'Success';
      W_Message := 'Invoice is Created-> ID = ' || l_customer_trx_id;
      DBMS_OUTPUT.put_line (W_Status);
      DBMS_OUTPUT.put_line (W_Message);
      DBMS_OUTPUT.put_line ('Generated Oracle Txn Number-->' || W_TRX_Number);
   END IF;

   IF    l_return_status = fnd_api.g_ret_sts_error
      OR l_return_status = fnd_api.g_ret_sts_unexp_error
   THEN
      NULL;
   ELSE
      SELECT COUNT (*) INTO l_cnt FROM ar_trx_errors_gt;

      IF l_cnt = 0
      THEN
         NULL;
      ELSE
         NULL;

         FOR i IN list_errors
         LOOP
            NULL;
         END LOOP;
      END IF;
   END IF;

   COMMIT;
END;