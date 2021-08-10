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