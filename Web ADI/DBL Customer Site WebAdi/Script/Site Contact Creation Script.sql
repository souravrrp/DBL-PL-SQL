/* Formatted on 5/19/2021 10:52:45 AM (QP5 v5.287) */
DECLARE
   CURSOR c
   IS
      SELECT *
        FROM xxdbl.xxdbl_cust_creation_tbl a
       WHERE a.cust_id = 1000011;

   p_contact_point_rec   HZ_CONTACT_POINT_V2PUB.CONTACT_POINT_REC_TYPE;
   p_phone_rec           HZ_CONTACT_POINT_V2PUB.phone_rec_type;
   p_edi_rec_type        HZ_CONTACT_POINT_V2PUB.edi_rec_type;
   p_email_rec_type      HZ_CONTACT_POINT_V2PUB.email_rec_type;
   p_telex_rec_type      HZ_CONTACT_POINT_V2PUB.telex_rec_type;
   p_web_rec_type        HZ_CONTACT_POINT_V2PUB.web_rec_type;

   --ln_party_id           NUMBER := lp_party_id;

   x_contact_point_id    NUMBER;
   x_return_status       VARCHAR2 (2000);
   x_msg_count           NUMBER;
   x_msg_data            VARCHAR2 (2000);
BEGIN
   MO_GLOBAL.INIT ('AR');
   MO_GLOBAL.SET_POLICY_CONTEXT ('S', 126);
   FND_GLOBAL.APPS_INITIALIZE (5958,
                               20678,
                               222,
                               0);
   p_contact_point_rec.contact_point_type := 'PHONE';
   p_contact_point_rec.owner_table_name := 'HZ_PARTY_SITES';
   --p_contact_point_rec.owner_table_id := 407602; --<value for party_id from step 8>
   p_contact_point_rec.owner_table_id := 329748;
   p_contact_point_rec.created_by_module := 'HZ_CPUI';
   p_phone_rec.Phone_number := '213941';
   p_phone_rec.phone_line_type := 'GEN';

   HZ_CONTACT_POINT_V2PUB.create_contact_point ('T',
                                                p_contact_point_rec,
                                                p_edi_rec_type,
                                                p_email_rec_type,
                                                p_phone_rec,
                                                p_telex_rec_type,
                                                p_web_rec_type,
                                                x_contact_point_id,
                                                x_return_status,
                                                x_msg_count,
                                                x_msg_data);


   DBMS_OUTPUT.put_line ('***************************');
   DBMS_OUTPUT.put_line ('Output information ....');
   DBMS_OUTPUT.put_line ('x_contact_point_id: ' || x_contact_point_id);
   DBMS_OUTPUT.put_line ('x_return_status: ' || x_return_status);
   DBMS_OUTPUT.put_line ('x_msg_count: ' || x_msg_count);
   DBMS_OUTPUT.put_line ('x_msg_data: ' || x_msg_data);
   DBMS_OUTPUT.put_line ('***************************');
END;