/* Formatted on 12/29/2020 11:11:58 AM (QP5 v5.287) */
DECLARE
   l_button                      NUMBER;
   l_xxdbl_master_lc_headers_s   NUMBER;
   l_xxdbl_master_lc_line1_s     NUMBER;
   l_xxdbl_master_lc_line2_s     NUMBER;
   l_user_id                     NUMBER := fnd_global.user_id;
   l_date                        DATE := SYSDATE;
   l_login_id                    NUMBER := fnd_global.login_id;
   l_count                       NUMBER := 0;
   l_amd_no                      NUMBER := 0;
BEGIN
   :SYSTEM.message_level := 25;
   COMMIT_FORM;
   :SYSTEM.message_level := 0;
   GO_ITEM ('XXDBL_MASTER_LC_HEADERS.CUSTOMER_NAME');

   IF :xxdbl_master_lc_headers.master_lc_status NOT IN
         ('CONFIRMED', 'AMENDED')
   THEN
      fnd_message.set_string ('You can only Amend Confirm LC.');
      fnd_message.error;
      xx_enable_disable;
      RAISE form_trigger_failure;
   ELSE
      l_button := 2;
      fnd_message.set_string ('Are you sure to Amend the Master LC Form');
      l_button := fnd_message.question ('Yes', 'No', NULL);
      SET_BLOCK_PROPERTY ('XXDBL_MASTER_LC_HEADERS',
                          update_allowed,
                          property_true);

      IF l_button = 1
      THEN
         BEGIN
            SELECT COUNT (1)
              INTO l_count
              FROM xxdbl_comm_inv_headers
             WHERE     attribute4 =
                          :xxdbl_master_lc_headers.master_lc_header_id
                   AND comm_inv_status != 'CANCELLED';
         EXCEPTION
            WHEN OTHERS
            THEN
               l_count := 0;
         END;

         l_count := 0;

         IF l_count > 0
         THEN
            xx_enable_disable;
            fnd_message.set_string (
               'This LC is already assign to Commercial Invoice, you can not Amend the same.');
            fnd_message.error;
            RAISE form_trigger_failure;
         ELSE
            BEGIN
               SELECT MAX (NVL (xmlh1.amd_no, 0))
                 INTO l_amd_no
                 FROM xxdbl_master_lc_headers xmlh1
                WHERE     xmlh1.internal_doc_number =
                             :xxdbl_master_lc_headers.internal_doc_number
                      AND master_lc_status != 'CANCELLED';
            EXCEPTION
               WHEN OTHERS
               THEN
                  l_amd_no := 0;
            END;

            IF :xxdbl_master_lc_headers.amd_no <> l_amd_no
            THEN
               xx_enable_disable;
               fnd_message.set_string (
                  'This is not Latest Master LC, please select latest Master LC.');
               fnd_message.error;
               RAISE form_trigger_failure;
            ELSE
               BEGIN
                  SELECT MAX (NVL (xmlh1.amd_no, 0))
                    INTO l_amd_no
                    FROM xxdbl_master_lc_headers xmlh1
                   WHERE xmlh1.internal_doc_number =
                            :xxdbl_master_lc_headers.internal_doc_number;
               EXCEPTION
                  WHEN OTHERS
                  THEN
                     l_amd_no := 0;
               END;

               /*:xxdbl_master_lc_headers.amd_no :=
                                           :xxdbl_master_lc_headers.amd_no + 1;*/
               SELECT   GREATEST ( :xxdbl_master_lc_headers.amd_no, l_amd_no)
                      + 1
                 INTO :xxdbl_master_lc_headers.amd_no
                 FROM DUAL;

               :xxdbl_master_lc_headers.master_lc_status := 'UNDER AMENDEMENT';
               :xxdbl_master_lc_headers.attribute6 := SYSDATE;
               :xxdbl_master_lc_headers.attribute7 := SYSDATE;

               FOR rec_hdr
                  IN (SELECT *
                        FROM xxdbl_master_lc_headers
                       WHERE master_lc_header_id =
                                :xxdbl_master_lc_headers.master_lc_header_id)
               LOOP
                  SELECT xxdbl_master_lc_headers_s.NEXTVAL
                    INTO l_xxdbl_master_lc_headers_s
                    FROM DUAL;

                  INSERT
                    INTO xxdbl_master_lc_headers (master_lc_header_id,
                                                  master_lc_number,
                                                  master_lc_status,
                                                  internal_doc_number,
                                                  master_lc_received_date,
                                                  org_id,
                                                  ou_name,
                                                  customer_number,
                                                  customer_name,
                                                  customer_id,
                                                  bank_name,
                                                  bank_address,
                                                  bin_number,
                                                  tin_number,
                                                  irc_number,
                                                  erc_number,
                                                  attribute1,
                                                  attribute2,
                                                  attribute3,
                                                  attribute4,
                                                  attribute5,
                                                  attribute6,
                                                  attribute7,
                                                  attribute8,
                                                  attribute9,
                                                  attribute10,
                                                  attribute11,
                                                  attribute12,
                                                  attribute13,
                                                  attribute14,
                                                  attribute15,
                                                  attribute16,
                                                  attribute17,
                                                  attribute18,
                                                  attribute19,
                                                  attribute20,
                                                  last_update_date,
                                                  last_updated_by,
                                                  creation_date,
                                                  created_by,
                                                  last_update_login,
                                                  lc_expire_number,
                                                  lc_expire_date,
                                                  lc_shipment_date,
                                                  lc_value,
                                                  exp_number,
                                                  exp_date,
                                                  remarks,
                                                  amd_no,
                                                  MPI_NUMBER,
                                                  LC_RCV_DATE,
                                                  LC_TYPE,
                                                  CH_REQ_DATE,
                                                  LC_RCV_FRM_BANK_DT,
                                                  EXP_EXPIRE_DATE,
                                                  UP_NUMBER,
                                                  UP_DATE,
                                                  UD_IP_NO,
                                                  UD_IP_RCV_DT,
                                                  UD_IP_HND_OVR_DT,
                                                  UD_IP_ISSUE_DT,
                                                  UD_IP_EXP_DT,
                                                  UD_ISSUE_DT,
                                                  BILL_ENTRY_NO,
                                                  BILL_ENTRY_DT,
                                                  INFO_REMARKS)
                  VALUES (l_xxdbl_master_lc_headers_s,
                          rec_hdr.master_lc_number,
                          rec_hdr.master_lc_status,
                          rec_hdr.internal_doc_number,
                          rec_hdr.master_lc_received_date,
                          rec_hdr.org_id,
                          rec_hdr.ou_name,
                          rec_hdr.customer_number,
                          rec_hdr.customer_name,
                          rec_hdr.customer_id,
                          rec_hdr.bank_name,
                          rec_hdr.bank_address,
                          rec_hdr.bin_number,
                          rec_hdr.tin_number,
                          rec_hdr.irc_number,
                          rec_hdr.erc_number,
                          rec_hdr.attribute1,
                          rec_hdr.attribute2,
                          rec_hdr.attribute3,
                          rec_hdr.attribute4,
                          rec_hdr.attribute5,
                          rec_hdr.attribute6,
                          rec_hdr.attribute7,
                          rec_hdr.attribute8,
                          rec_hdr.attribute9,
                          rec_hdr.attribute10,
                          rec_hdr.attribute11,
                          rec_hdr.attribute12,
                          rec_hdr.attribute13,
                          rec_hdr.attribute14,
                          rec_hdr.attribute15,
                          rec_hdr.attribute16,
                          rec_hdr.attribute17,
                          rec_hdr.attribute18,
                          rec_hdr.attribute19,
                          rec_hdr.attribute20,
                          l_date,
                          l_user_id,
                          l_date,
                          l_user_id,
                          l_login_id,
                          rec_hdr.lc_expire_number,
                          rec_hdr.lc_expire_date,
                          rec_hdr.lc_shipment_date,
                          rec_hdr.lc_value,
                          rec_hdr.exp_number,
                          rec_hdr.exp_date,
                          rec_hdr.remarks,
                          rec_hdr.amd_no,
                          rec_hdr.MPI_NUMBER,
                          rec_hdr.LC_RCV_DATE,
                          rec_hdr.LC_TYPE,
                          rec_hdr.CH_REQ_DATE,
                          rec_hdr.LC_RCV_FRM_BANK_DT,
                          rec_hdr.EXP_EXPIRE_DATE,
                          rec_hdr.UP_NUMBER,
                          rec_hdr.UP_DATE,
                          rec_hdr.UD_IP_NO,
                          rec_hdr.UD_IP_RCV_DT,
                          rec_hdr.UD_IP_HND_OVR_DT,
                          rec_hdr.UD_IP_ISSUE_DT,
                          rec_hdr.UD_IP_EXP_DT,
                          rec_hdr.UD_ISSUE_DT,
                          rec_hdr.BILL_ENTRY_NO,
                          rec_hdr.BILL_ENTRY_DT,
                          rec_hdr.INFO_REMARKS);

                  UPDATE xxdbl_comm_inv_headers
                     SET attribute4 = l_xxdbl_master_lc_headers_s
                   WHERE attribute4 =
                            :xxdbl_master_lc_headers.master_lc_header_id;

                  FOR rec_line1
                     IN (SELECT *
                           FROM xxdbl_master_lc_line1
                          WHERE master_lc_header_id =
                                   rec_hdr.master_lc_header_id)
                  LOOP
                     SELECT xxdbl_master_lc_line1_s.NEXTVAL
                       INTO l_xxdbl_master_lc_line1_s
                       FROM DUAL;

                     INSERT INTO xxdbl_master_lc_line1 (master_lc_header_id,
                                                        master_lc_line1_id,
                                                        pi_number,
                                                        pi_id,
                                                        pi_date,
                                                        pi_currency,
                                                        pi_value,
                                                        attribute1,
                                                        attribute2,
                                                        attribute3,
                                                        attribute4,
                                                        attribute5,
                                                        attribute6,
                                                        attribute7,
                                                        attribute8,
                                                        attribute9,
                                                        attribute10,
                                                        attribute11,
                                                        attribute12,
                                                        attribute13,
                                                        attribute14,
                                                        attribute15,
                                                        attribute16,
                                                        attribute17,
                                                        attribute18,
                                                        attribute19,
                                                        attribute20,
                                                        last_update_date,
                                                        last_updated_by,
                                                        creation_date,
                                                        created_by,
                                                        last_update_login)
                          VALUES (l_xxdbl_master_lc_headers_s,
                                  l_xxdbl_master_lc_line1_s,
                                  rec_line1.pi_number,
                                  rec_line1.pi_id,
                                  rec_line1.pi_date,
                                  rec_line1.pi_currency,
                                  rec_line1.pi_value,
                                  rec_line1.attribute1,
                                  rec_line1.attribute2,
                                  rec_line1.attribute3,
                                  rec_line1.attribute4,
                                  rec_line1.attribute5,
                                  rec_line1.attribute6,
                                  rec_line1.attribute7,
                                  rec_line1.attribute8,
                                  rec_line1.attribute9,
                                  rec_line1.attribute10,
                                  rec_line1.attribute11,
                                  rec_line1.attribute12,
                                  rec_line1.attribute13,
                                  rec_line1.attribute14,
                                  rec_line1.attribute15,
                                  rec_line1.attribute16,
                                  rec_line1.attribute17,
                                  rec_line1.attribute18,
                                  rec_line1.attribute19,
                                  rec_line1.attribute20,
                                  l_date,
                                  l_user_id,
                                  l_date,
                                  l_user_id,
                                  l_login_id);
                  END LOOP;                                  -- rec_line1 Loop

                  DELETE xxdbl_master_lc_line1
                   WHERE     1 = 1
                         AND master_lc_header_id =
                                :xxdbl_master_lc_headers.master_lc_header_id;

                  FOR rec_line2
                     IN (SELECT *
                           FROM xxdbl_master_lc_line2
                          WHERE master_lc_header_id =
                                   rec_hdr.master_lc_header_id)
                  LOOP
                     SELECT xxdbl_master_lc_line2_s.NEXTVAL
                       INTO l_xxdbl_master_lc_line2_s
                       FROM DUAL;

                     INSERT INTO xxdbl_master_lc_line2 (master_lc_header_id,
                                                        master_lc_line2_id,
                                                        lc_number,
                                                        master_lc_date,
                                                        bin_number,
                                                        tin_number,
                                                        irc_number,
                                                        erc_number,
                                                        attribute1,
                                                        attribute2,
                                                        attribute3,
                                                        attribute4,
                                                        attribute5,
                                                        attribute6,
                                                        attribute7,
                                                        attribute8,
                                                        attribute9,
                                                        attribute10,
                                                        attribute11,
                                                        attribute12,
                                                        attribute13,
                                                        attribute14,
                                                        attribute15,
                                                        attribute16,
                                                        attribute17,
                                                        attribute18,
                                                        attribute19,
                                                        attribute20,
                                                        last_update_date,
                                                        last_updated_by,
                                                        creation_date,
                                                        created_by,
                                                        last_update_login,
                                                        buyers_po,
                                                        lacf_number,
                                                        remarks)
                          VALUES (l_xxdbl_master_lc_headers_s,
                                  l_xxdbl_master_lc_line2_s,
                                  rec_line2.lc_number,
                                  rec_line2.master_lc_date,
                                  rec_line2.bin_number,
                                  rec_line2.tin_number,
                                  rec_line2.irc_number,
                                  rec_line2.erc_number,
                                  rec_line2.attribute1,
                                  rec_line2.attribute2,
                                  rec_line2.attribute3,
                                  rec_line2.attribute4,
                                  rec_line2.attribute5,
                                  rec_line2.attribute6,
                                  rec_line2.attribute7,
                                  rec_line2.attribute8,
                                  rec_line2.attribute9,
                                  rec_line2.attribute10,
                                  rec_line2.attribute11,
                                  rec_line2.attribute12,
                                  rec_line2.attribute13,
                                  rec_line2.attribute14,
                                  rec_line2.attribute15,
                                  rec_line2.attribute16,
                                  rec_line2.attribute17,
                                  rec_line2.attribute18,
                                  rec_line2.attribute19,
                                  rec_line2.attribute20,
                                  l_date,
                                  l_user_id,
                                  l_date,
                                  l_user_id,
                                  l_login_id,
                                  rec_line2.buyers_po,
                                  rec_line2.lacf_number,
                                  rec_line2.remarks);
                  END LOOP;                                  -- rec_line2 Loop
               END LOOP;                                       -- rec_hdr Loop

               :SYSTEM.message_level := 25;
               COMMIT_FORM;
               :SYSTEM.message_level := 0;
               GO_ITEM ('XXDBL_MASTER_LC_LINE1.PI_NUMBER');
               EXECUTE_QUERY;
               GO_ITEM ('XXDBL_MASTER_LC_HEADERS.CUSTOMER_NAME');
               xx_enable_disable;
            END IF;
         END IF;
      END IF;
   END IF;
END;