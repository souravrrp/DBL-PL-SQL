/* Formatted on 3/25/2021 3:27:54 PM (QP5 v5.287) */
DECLARE
   p_location_rec    HZ_LOCATION_V2PUB.LOCATION_REC_TYPE;
   x_return_status   VARCHAR2 (2000);
   x_msg_count       NUMBER;
   x_msg_data        VARCHAR2 (2000);
   x_ver_number      NUMBER;
BEGIN
   p_location_rec.location_id := 1000002012675;
   p_location_rec.address1 := 'Address2';
   x_ver_number := 1;     --&lt; version_number obtained from prior select (a)

   hz_location_v2pub.update_location ('T',
                                      p_location_rec,
                                      x_ver_number,
                                      x_return_status,
                                      x_msg_count,
                                      x_msg_data);

   DBMS_OUTPUT.put_line ('***************************');
   DBMS_OUTPUT.put_line ('Output information ....');
   DBMS_OUTPUT.put_line ('x_p_version: ' || x_ver_number);
   DBMS_OUTPUT.put_line ('x_return_status: ' || x_return_status);
   DBMS_OUTPUT.put_line ('x_msg_count: ' || x_msg_count);
   DBMS_OUTPUT.put_line ('x_msg_data: ' || x_msg_data);
   DBMS_OUTPUT.put_line ('***************************');
END;