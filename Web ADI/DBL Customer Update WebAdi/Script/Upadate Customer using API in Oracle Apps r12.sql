--Detail PLSQL script using API to update customer in oracle apps r12

DECLARE
p_cust_account_rec      HZ_CUST_ACCOUNT_V2PUB.CUST_ACCOUNT_REC_TYPE;
p_object_version_number NUMBER;
x_return_status         VARCHAR2(2000);
x_msg_count             NUMBER;
x_msg_data              VARCHAR2(2000);

BEGIN
-- Setting the Profile Values --
mo_global.init('AR');
fnd_global.apps_initialize ( user_id      => 3344443
                            ,resp_id      => 334443
                            ,resp_appl_id => 222);
mo_global.set_policy_context('S',85);

p_cust_account_rec.cust_account_id := 3443333;
p_cust_account_rec.account_name    := 'Updated Customer Name';
p_object_version_number            := 1;

HZ_CUST_ACCOUNT_V2PUB.UPDATE_CUST_ACCOUNT
                  (
                    p_init_msg_list         => FND_API.G_TRUE,
                    p_cust_account_rec      => p_cust_account_rec,
                    p_object_version_number => p_object_version_number,
                    x_return_status         => x_return_status,
                    x_msg_count             => x_msg_count,
                    x_msg_data              => x_msg_data
                          );


IF  x_return_status = fnd_api.g_ret_sts_success THEN
    COMMIT;
    DBMS_OUTPUT.PUT_LINE('Customer is Updated Successful');
     
ELSE
    DBMS_OUTPUT.put_line ('Customer Update got failed:'||x_msg_data);
    
    ROLLBACK;
    
    FOR i IN 1 .. x_msg_count
    LOOP
    
      x_msg_data := fnd_msg_pub.get( p_msg_index => i, p_encoded => 'F');
      dbms_output.put_line( i|| ') '|| x_msg_data);
      
    END LOOP;
END IF;
END;


--------------------------------------------------------------------------------

DECLARE
   p_init_msg_list           VARCHAR2 (250) := FND_API.G_FALSE;
   p_cust_site_use_rec       hz_cust_account_site_v2pub.CUST_SITE_USE_REC_TYPE;
   p_object_version_number   NUMBER (10) := 3; --Pass the Same Object version for avaliable in thein HZ_CUST_SITE_USE_ID else error  hz_cust_site_uses cannot be locked as it has been updated by another use
   x_return_status           VARCHAR2 (1000);
   x_msg_count               NUMBER (10);
   x_msg_data                VARCHAR2 (1000);
BEGIN
   FND_GLOBAL.APPS_INITIALIZE (5149, 20678, 222);
   MO_GLOBAL.SET_POLICY_CONTEXT ('S', 81);

   P_CUST_SITE_USE_REC.site_use_id := 2279;
   P_CUST_SITE_USE_REC.status := 'A';
   P_CUST_SITE_USE_REC.cust_acct_site_id := 1349;
   P_CUST_SITE_USE_REC.SITE_USE_CODE := 'SHIP_TO';
--    P_CUST_SITE_USE_REC.GL_ID_TAX := '01-000-000-990201-000-000-0000';
   P_CUST_SITE_USE_REC.TAX_REFERENCE := '123456789';
   P_CUST_SITE_USE_REC.CREATED_BY_MODULE := 'TCA_V2_API';
   P_CUST_SITE_USE_REC.TAX_CODE := 'Zero';
   --   p_object_version_number := NULL;

   hz_cust_account_site_v2pub.update_cust_site_use (
      p_init_msg_list           => 'T',
      p_cust_site_use_rec       => P_CUST_SITE_USE_REC,
      p_object_version_number   => p_object_version_number,
      x_return_status           => x_return_status,
      x_msg_count               => x_msg_count,
      x_msg_data                => x_msg_data);

   DBMS_OUTPUT.put_line ('x_return_status' ||':'|| x_return_status);
   DBMS_OUTPUT.put_line ('x_msg_data' || ':'||x_msg_data);
EXCEPTION
   WHEN OTHERS
   THEN
      DBMS_OUTPUT.put_line ('Error' || SQLCODE || SQLERRM);
END;
/