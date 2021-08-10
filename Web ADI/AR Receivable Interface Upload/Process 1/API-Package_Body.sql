/* Formatted on 6/24/2020 2:29:24 PM (QP5 v5.287) */
DECLARE
   ln_trx_error_flag     CHAR (1) := 'V';
   ln_line_error_flag    CHAR (1) := 'V';
   ln_dist_error_flag    CHAR (1) := 'V';
   ln_org_id             NUMBER;
   ln_set_of_books_id    NUMBER;
   ln_chart_of_act_id    NUMBER;
   ln_batch_id           NUMBER;
   ln_batch_name         VARCHAR2 (40);
   ln_trx_cnt            NUMBER;
   ln_line_id            NUMBER;
   ln_dist_id            NUMBER;
   ln_cust_trx_type_id   NUMBER;
   ln_cust_id            NUMBER;
   ln_contact_id         NUMBER;
   ln_add_id             NUMBER;
   ln_term_id            NUMBER;
   ln_cnt_uom_code       NUMBER;
   ln_salesrep_id        NUMBER;
   ln_code_comb_id       NUMBER;
   ln_ln_no              NUMBER;
   ln_trx_no             VARCHAR2 (40);
   ln_sum_amt            NUMBER;
   ln_amt                NUMBER;
   ln_amt1               NUMBER;
   ln_trx_amt            NUMBER;
   ln_line_amt           NUMBER;
   ln_first_line_id      NUMBER;
   ln_line_total         NUMBER;
   ln_status             CHAR (1);
   ln_segment1           VARCHAR2 (10);
   ln_segment2           VARCHAR2 (10);
   ln_segment3           VARCHAR2 (10);
   ln_segment4           VARCHAR2 (10);
   ln_segment5           VARCHAR2 (10);

   CURSOR cur_hdr
   IS
      SELECT * FROM xxKK_header_tEmp;

   CURSOR cur_trx
   IS
      SELECT DISTINCT trx_number
        FROM xxKK_lines_tEmp;

   CURSOR cur_line (p_trx_number VARCHAR2)
   IS
      SELECT ROWID row_id, xx.*
        FROM xxKK_lines_tEmp xx
       WHERE trx_number = p_trx_number;

   CURSOR cur_dist (
      p_trx_number      VARCHAR2,
      p_line_nnumber    NUMBER)
   IS
      SELECT ROWID row_id, xd.*
        FROM xxkk_dist_temp xd
       WHERE     trx_number = p_trx_number
             AND line_number = p_line_nnumber
             AND acct_class != 'REC';
BEGIN
   FOR ln_cur_hdr IN cur_hdr
   LOOP
      --Validate organization Name
      BEGIN
         SELECT organization_id
           INTO ln_org_id
           FROM hr_all_organization_units
          WHERE name = ln_cur_hdr.org_name;
      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
            ln_line_error_flag := 'I';
            FND_FILE.put_line (
               FND_FILE.LOG,
               'Invalid Organization Name:' || ln_cur_hdr.org_name);
         WHEN OTHERS
         THEN
            FND_FILE.put_line (FND_FILE.LOG, SQLERRM);
      END;

      --Validate SOB Name
      BEGIN
         SELECT set_of_books_id, chart_of_accounts_id
           INTO ln_set_of_books_id, ln_chart_of_act_id
           FROM gl_sets_of_books
          WHERE name = ln_cur_hdr.set_of_books_desc;
      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
            ln_line_error_flag := 'I';
            FND_FILE.put_line (
               FND_FILE.LOG,
               'Invalid Set of Books:' || ln_cur_hdr.set_of_books_desc);
         WHEN OTHERS
         THEN
            FND_FILE.put_line (FND_FILE.LOG, SQLERRM);
      END;

      --Validate Batch Source Name
      BEGIN
         SELECT batch_source_id, name
           INTO ln_batch_id, ln_batch_name
           FROM ra_batch_sources
          WHERE name = ln_cur_hdr.batch_source_name;
      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
            ln_line_error_flag := 'I';
            FND_FILE.put_line (
               FND_FILE.LOG,
               'Invalid Batch Source:' || ln_cur_hdr.batch_source_name);
         WHEN OTHERS
         THEN
            FND_FILE.put_line (FND_FILE.LOG, SQLERRM);
      END;

      --update header table
      BEGIN
         UPDATE xxkk_header_temp
            SET rec_status = ln_line_error_flag;
      END;
   END LOOP;

   --Distinct Transaction Loop begins
   FOR ln_cur_trx IN cur_trx
   LOOP
      --Validate Transaction Number
      ln_trx_error_flag := 'V';

      SELECT COUNT (1)
        INTO ln_trx_cnt
        FROM ra_customer_trx
       WHERE trx_number = ln_cur_trx.trx_number;

      IF ln_trx_cnt = 1
      THEN
         ln_trx_error_flag := 'I';
         FND_FILE.put_line (
            FND_FILE.LOG,
            'Invoice Already Exist:' || ln_cur_trx.trx_number);
      END IF;

      ln_first_line_id := NULL;
      ln_trx_amt := 0;

      -- Validating Lines
      FOR ln_cur_line IN cur_line (ln_cur_trx.trx_number)
      LOOP
         ln_line_error_flag := 'V';
         ln_line_amt := 0;

         SELECT XKK_LINES_SEQ.NEXTVAL INTO ln_line_id FROM DUAL;

         IF ln_first_line_id IS NULL
         THEN
            ln_first_line_id := ln_line_id;
         END IF;

         BEGIN
            SELECT cust_trx_type_id
              INTO ln_cust_trx_type_id
              FROM ra_cust_trx_types ctt
             WHERE ctt.name = ln_cur_line.trx_type;
         EXCEPTION
            WHEN NO_DATA_FOUND
            THEN
               ln_line_error_flag := 'I';
               ln_trx_error_flag := 'I';
               FND_FILE.put_line (
                  FND_FILE.LOG,
                  'This trx type doesnot exist' || ln_cur_line.trx_type);
            WHEN OTHERS
            THEN
               FND_FILE.put_line (FND_FILE.LOG, SQLERRM);
         END;

         --Validate Customer ID
         BEGIN
            SELECT customer_id
              INTO ln_cust_id
              FROM ra_customers
             WHERE orig_system_reference = ln_cur_line.customer;
         EXCEPTION
            WHEN NO_DATA_FOUND
            THEN
               ln_line_error_flag := 'I';
               ln_trx_error_flag := 'I';
               FND_FILE.put_line (
                  FND_FILE.LOG,
                  'Invalid Customer:' || ln_cur_line.customer);
            WHEN OTHERS
            THEN
               FND_FILE.put_line (FND_FILE.LOG, SQLERRM);
         END;

         -- Validate Contact ID
         BEGIN
            SELECT contact_id
              INTO ln_contact_id
              FROM ra_contacts
             WHERE orig_system_reference = ln_cur_line.contact;
         EXCEPTION
            WHEN NO_DATA_FOUND
            THEN
               ln_line_error_flag := 'I';
               ln_trx_error_flag := 'I';
               FND_FILE.put_line (FND_FILE.LOG, 'This contact doesnot exist
:'                                                || ln_cur_line.contact);
            WHEN OTHERS
            THEN
               FND_FILE.put_line (FND_FILE.LOG, SQLERRM);
         END;

         -- Validate AddreSs
         BEGIN
            SELECT address_id
              INTO ln_add_id
              FROM ra_addresses
             WHERE orig_system_reference = ln_cur_line.address;
         EXCEPTION
            WHEN NO_DATA_FOUND
            THEN
               ln_line_error_flag := 'I';
               ln_trx_error_flag := 'I';
               FND_FILE.put_line (FND_FILE.LOG, 'This address doesnot exist
:'                                                || ln_cur_line.address);
            WHEN OTHERS
            THEN
               FND_FILE.put_line (FND_FILE.LOG, SQLERRM);
         END;

         -- Validate Term
         BEGIN
            SELECT term_id
              INTO ln_term_id
              FROM ra_terms
             WHERE name = ln_cur_line.term;
         EXCEPTION
            WHEN NO_DATA_FOUND
            THEN
               ln_line_error_flag := 'I';
               ln_trx_error_flag := 'I';
               FND_FILE.put_line (FND_FILE.LOG, 'This term doesnot exist
:'                                                || ln_cur_line.term);
            WHEN OTHERS
            THEN
               FND_FILE.put_line (FND_FILE.LOG, SQLERRM);
         END;

         -- Validate UOM
         SELECT COUNT (uom_code)
           INTO ln_cnt_uom_code
           FROM mtl_units_of_measure uom
          WHERE uom.uom_code = ln_cur_line.uom;

         IF ln_cnt_uom_code = 0
         THEN
            ln_line_error_flag := 'I';
            ln_trx_error_flag := 'I';
            FND_FILE.put_line (FND_FILE.LOG, 'The UOM Doesnot exist');
         END IF;

         -- Validate Sales Rep
         BEGIN
            SELECT salesrep_id
              INTO ln_salesrep_id
              FROM ra_salesreps rp
             WHERE name = ln_cur_line.sales_rep;
         EXCEPTION
            WHEN NO_DATA_FOUND
            THEN
               ln_line_error_flag := 'I';
               ln_trx_error_flag := 'I';
               FND_FILE.put_line (FND_FILE.LOG,
                                  'This Sales Rep doesnot exist
:'                                  || ln_cur_line.sales_rep);
            WHEN OTHERS
            THEN
               FND_FILE.put_line (FND_FILE.LOG, SQLERRM);
         END;

         ln_line_amt := ln_line_amt + ln_cur_line.amount;

         UPDATE xxkk_lines_temp
            SET int_line_id = ln_line_id,
                cust_trx_type_id = ln_cust_trx_type_id,
                customer_id = ln_cust_id,
                address_id = ln_add_id,
                contact_id = ln_contact_id,
                term_id = ln_term_id,
                salesrep_id = ln_salesrep_id,
                rec_status = ln_line_error_flag,
                conv_rate = 1 / 40,
                org_id = ln_org_id
          WHERE ROWID = ln_cur_line.row_id;

         -- Validate Distributions
         ln_line_total := 0;

         FOR ln_cur_dist
            IN cur_dist (ln_cur_line.trx_number, ln_cur_line.line_number)
         LOOP
            ln_dist_error_flag := 'V';

            -- Get the distribution line sequence value
            SELECT xkk_dist_seq.NEXTVAL INTO ln_dist_id FROM DUAL;

            --Validate Code combination and get combination id
            BEGIN
               SELECT code_combination_id
                 INTO ln_code_comb_id
                 FROM gl_code_combinations
                WHERE     segment1 = ln_cur_dist.segment1
                      AND segment2 = ln_cur_dist.segment2
                      AND segment3 = ln_cur_dist.segment3
                      AND segment4 = ln_cur_dist.segment4
                      AND segment5 = ln_cur_dist.segment5
                      AND chart_of_accounts_id = ln_chart_of_act_id;
            EXCEPTION
               WHEN NO_DATA_FOUND
               THEN
                  ln_line_error_flag := 'I';
                  ln_dist_error_flag := 'I';
                  ln_trx_error_flag := 'I';
                  FND_FILE.put_line (
                     FND_FILE.LOG,
                        'The Segment Combinations are not
Valid :'
                     || ln_cur_dist.segment1
                     || ln_cur_dist.segment2
                     || ln_cur_dist.segment3
                     || ln_cur_dist.segment4
                     || ln_cur_dist.segment5);
               WHEN OTHERS
               THEN
                  FND_FILE.put_line (FND_FILE.LOG, SQLERRM);
            END;

            --Update Dist Table with status flag and ids
            UPDATE xxkk_dist_temp
               SET int_line_id = ln_line_id,
                   int_dist_id = ln_dist_id,
                   code_combination_id = ln_code_comb_id,
                   accted_amount = ln_cur_dist.amount,
                   rec_status = ln_dist_error_flag,
                   org_id = ln_org_id
             WHERE ROWID = ln_cur_dist.row_id;

            ln_line_total := ln_line_total + ln_cur_dist.amount;
         END LOOP;

         --End of Distribution Loop
         ln_trx_amt := ln_trx_amt + ln_line_amt;

         --Validating Line amount with total distribution amount
         IF (ln_line_amt = ln_line_total)
         THEN
            FND_FILE.put_line (
               FND_FILE.LOG,
                  'With this Line
#'
               || ln_cur_line.line_number
               || ',Dist Amount matches with the amount in lines
table for Transaction#'
               || ln_cur_line.trx_number);
         ELSE
            ln_line_error_flag := 'I';
            ln_trx_error_flag := 'I';
            FND_FILE.put_line (
               FND_FILE.LOG,
                  'With this Line
#'
               || ln_cur_line.line_number
               || ',Dist Amount doesnt matches with the amount in
lines table for Transaction#'
               || ln_cur_line.trx_number);
         END IF;
      END LOOP;                                           -- End of Lines Loop

      -- Validate Receivable Amount with Transaction Amount
      ln_dist_error_flag := 'V';

      BEGIN
         SELECT segment1,
                segment2,
                segment3,
                segment4,
                segment5,
                amount
           INTO ln_segment1,
                ln_segment2,
                ln_segment3,
                ln_segment4,
                ln_segment5,
                ln_amt
           FROM xxkk_dist_temp
          WHERE trx_number = ln_cur_trx.trx_number AND acct_class = 'REC';

         -- Get Combination ID
         SELECT code_combination_id
           INTO ln_code_comb_id
           FROM gl_code_combinations
          WHERE     segment1 = ln_segment1
                AND segment2 = ln_segment2
                AND segment3 = ln_segment3
                AND segment4 = ln_segment4
                AND segment5 = ln_segment5
                AND chart_of_accounts_id = ln_chart_of_act_id;

         IF ln_amt = ln_trx_amt
         THEN
            FND_FILE.put_line (FND_FILE.LOG, 'Rec Amount matches Transaction
Amount for Trx Number :'                       || ln_cur_trx.trx_number);
         ELSE
            ln_trx_error_flag := 'I';
            ln_dist_error_flag := 'I';
            FND_FILE.put_line (FND_FILE.LOG,
                               'Rec Amount doesnt match with Transaction
Amount for Trx Number :'         || ln_cur_trx.trx_number);
         END IF;

         UPDATE xxkk_dist_temp
            SET int_line_id = ln_first_line_id,
                int_dist_id = Xkk_dist_seq.NEXTVAL,
                code_combination_id = ln_code_comb_id,
                rec_status = ln_dist_error_flag,
                org_id = ln_org_id,
                ACCTED_AMOUNT = LN_AMT
          WHERE trx_number = ln_cur_trx.trx_number AND acct_class = 'REC';
      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
            ln_trx_error_flag := 'I';
            ln_dist_error_flag := 'I';
            FND_FILE.put_line (FND_FILE.LOG, 'Invalid Combination ID');
         WHEN OTHERS
         THEN
            ln_trx_error_flag := 'I';
            ln_dist_error_flag := 'I';
            FND_FILE.put_line (FND_FILE.LOG, SQLERRM);
      END;

      --Update Lines and Dist Tables for Valid and Invalid Transactions
      UPDATE xxkk_lines_temp
         SET rec_status = ln_trx_error_flag
       WHERE trx_number = ln_cur_trx.trx_number;

      UPDATE xxkk_dist_temp
         SET rec_status = ln_trx_error_flag
       WHERE trx_number = ln_cur_trx.trx_number;

      COMMIT;
   END LOOP;                                        -- End of Transaction Loop

   -- Only if the transaction status flag is 'V' then insert values to interface tables
   BEGIN
      INSERT INTO ra_interface_lines_all (org_id,
                                          interface_line_context,
                                          interface_line_attribute1,
                                          interface_line_attribute2,
                                          interface_line_attribute3,
                                          set_of_books_id,
                                          batch_source_name,
                                          line_type,
                                          description,
                                          currency_code,
                                          amount,
                                          term_id,
                                          orig_system_bill_customer_id,
                                          orig_system_ship_customer_id,
                                          orig_system_sold_customer_id,
                                          orig_system_bill_contact_id,
                                          orig_system_ship_contact_id,
                                          orig_system_bill_address_id,
                                          orig_system_ship_address_id,
                                          conversion_type,
                                          conversion_rate,
                                          trx_date,
                                          gl_date,
                                          original_gl_date,
                                          line_number,
                                          trx_number,
                                          quantity,
                                          unit_selling_price,
                                          tax_code,
                                          tax_exempt_flag,
                                          uom_code,
                                          cust_trx_type_id,
                                          primary_salesrep_id,
                                          interface_line_id)
         (SELECT org_id,
                 'XXII_INVOICE_IMPORT',
                 'BANGALORE' || ' ' || trx_number,
                 TO_CHAR (SYSDATE, 'YYYY/mm/dd'),
                 line_number,
                 ln_set_of_books_id,
                 ln_batch_name,
                 line_type,
                 description,
                 curr_code,
                 amount,
                 term_id,
                 customer_id,
                 customer_id,
                 customer_id,
                 contact_id,
                 contact_id,
                 address_id,
                 address_id,
                 'User',
                 conv_rate,
                 trx_date,
                 trx_date,
                 trx_date,
                 line_number,
                 trx_number,
                 qty,
                 amount * 1,
                 'Exempt',
                 tax_ex,
                 uom,
                 cust_trx_type_id,
                 salesrep_id,
                 int_line_id
            FROM xxkk_lines_temp
           WHERE rec_status = 'V');
   EXCEPTION
      WHEN OTHERS
      THEN
         FND_FILE.put_line (FND_FILE.LOG, 'Error while inserting
records in lines table'                     || SQLERRM);
   END;

   BEGIN
      INSERT INTO ra_interface_distributions_all (org_id,
                                                  interface_line_id,
                                                  interface_distribution_id,
                                                  interface_line_context,
                                                  interface_line_attribute1,
                                                  interface_line_attribute2,
                                                  interface_line_attribute3,
                                                  interface_line_attribute6,
                                                  interface_line_attribute8,
                                                  account_class,
                                                  amount,
                                                  acctd_amount,
                                                  percent,
                                                  code_combination_id)
         (SELECT org_id,
                 int_line_id,
                 int_dist_id,
                 'XXII_INVOICE_IMPORT',
                 'BANGALORE' || ' ' || trx_number,
                 TO_CHAR (SYSDATE, 'YYYY/mm/dd'),
                 line_number,
                 line_number,
                 amt_type,
                 acct_class,
                 amount,
                 accted_amount,
                 percent,
                 CODE_COMBINATION_ID
            FROM xxkk_dist_temp
           WHERE rec_status = 'V');
   EXCEPTION
      WHEN OTHERS
      THEN
         FND_FILE.put_line (FND_FILE.LOG, 'Error while inserting
records in Dist table'                      || SQLERRM);
   END;
EXCEPTION
   WHEN OTHERS
   THEN
      FND_FILE.put_line (FND_FILE.LOG, 'Error: ' || SQLERRM);
END;
/