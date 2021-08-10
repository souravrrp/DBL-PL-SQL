/* Formatted on 9/6/2020 5:01:34 PM (QP5 v5.287) */
DECLARE
   l_return_status   VARCHAR2 (1);
   l_msg_count       NUMBER;
   l_msg_data        VARCHAR2 (240);
   cash_receipt_id   NUMBER := '285875';
   customer_trx_id   NUMBER := '663894';
   l_count           NUMBER;
   l_msg_data_out    VARCHAR2 (240);
   l_mesg            VARCHAR2 (240);
   p_count           NUMBER;
BEGIN
   fnd_global.apps_initialize (0, 20678, 222);

   mo_global.set_policy_context ('S', 126);

   ar_receipt_api_pub.Apply (
      p_api_version        => 1.0,
      p_init_msg_list      => FND_API.G_TRUE,
      p_commit             => FND_API.G_TRUE,
      p_validation_level   => FND_API.G_VALID_LEVEL_FULL,
      p_cash_receipt_id    => cash_receipt_id,
      p_customer_trx_id    => customer_trx_id,
      x_return_status      => l_return_status,
      x_msg_count          => l_msg_count,
      x_msg_data           => l_msg_data);
   DBMS_OUTPUT.put_line ('Status ' || l_return_status);
   DBMS_OUTPUT.put_line ('Message count ' || l_msg_count);

   IF l_msg_count = 1
   THEN
      DBMS_OUTPUT.put_line ('l_msg_data ' || l_msg_data);
   ELSIF l_msg_count > 1
   THEN
      LOOP
         p_count := p_count + 1;
         l_msg_data := FND_MSG_PUB.Get (FND_MSG_PUB.G_NEXT, FND_API.G_FALSE);

         IF l_msg_data IS NULL
         THEN
            EXIT;
         END IF;

         DBMS_OUTPUT.put_line ('Message' || p_count || '.' || l_msg_data);
      END LOOP;
   END IF;
END;