/* Formatted on 7/18/2021 5:53:38 PM (QP5 v5.287) */
DECLARE
   p_cust_id                 NUMBER := '1000004';
   --p_cust_account_id         NUMBER := '231440';
   --L_Retcode                 NUMBER;
   --CONC_STATUS               BOOLEAN;
   --l_error                   VARCHAR2 (100);
   l_object_version_number   NUMBER;

   CURSOR c
   IS
      SELECT *
        FROM xxdbl.xxdbl_cust_creation_tbl a
       WHERE a.cust_id = p_cust_id;

   p_cust_account_rec        HZ_CUST_ACCOUNT_V2PUB.CUST_ACCOUNT_REC_TYPE;
   p_object_version_number   NUMBER;
   x_return_status           VARCHAR2 (2000);
   x_msg_count               NUMBER;
   x_msg_data                VARCHAR2 (2000);
BEGIN
   FOR i IN c
   LOOP
      -- Setting the Context --
      mo_global.init ('AR');
      MO_GLOBAL.SET_POLICY_CONTEXT ('S', i.operating_unit);
      FND_GLOBAL.APPS_INITIALIZE (5958,
                                  20678,
                                  222,
                                  0);
      fnd_global.set_nls_context ('AMERICAN');

      SELECT object_version_number
        INTO l_object_version_number
        FROM hz_cust_accounts
       WHERE cust_account_id = i.cust_account_id;

      -- Initializing the Mandatory API parameters
      p_cust_account_rec.cust_account_id := i.cust_account_id;
      p_cust_account_rec.attribute_category := i.attribute_category;
      p_cust_account_rec.attribute1 := i.attribute1;
      p_cust_account_rec.attribute2 := i.attribute2;
      p_cust_account_rec.attribute3 := i.attribute3;
      p_cust_account_rec.attribute4 := i.attribute4;
      p_object_version_number := l_object_version_number;

      DBMS_OUTPUT.PUT_LINE (
         'Calling the API hz_cust_account_v2pub.update_cust_account');

      HZ_CUST_ACCOUNT_V2PUB.UPDATE_CUST_ACCOUNT (
         p_init_msg_list           => FND_API.G_TRUE,
         p_cust_account_rec        => p_cust_account_rec,
         p_object_version_number   => p_object_version_number,
         x_return_status           => x_return_status,
         x_msg_count               => x_msg_count,
         x_msg_data                => x_msg_data);

      IF x_return_status = fnd_api.g_ret_sts_success
      THEN
         COMMIT;
         DBMS_OUTPUT.PUT_LINE ('Updation of Customer Account is Successful ');
         DBMS_OUTPUT.PUT_LINE ('Output information ....');
         DBMS_OUTPUT.put_line (
            'Object Version Number =' || p_object_version_number);
      ELSE
         DBMS_OUTPUT.put_line (
            'Updation of Customer Account got failed:' || x_msg_data);
         ROLLBACK;

         FOR i IN 1 .. x_msg_count
         LOOP
            x_msg_data := fnd_msg_pub.get (p_msg_index => i, p_encoded => 'F');
            DBMS_OUTPUT.put_line (i || ') ' || x_msg_data);
         END LOOP;
      END IF;
   END LOOP;

   DBMS_OUTPUT.PUT_LINE ('Completion of API');
END;
/