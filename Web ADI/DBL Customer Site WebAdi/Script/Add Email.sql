/* Formatted on 5/19/2021 10:59:49 AM (QP5 v5.287) */
DECLARE
   lv_init_msg_list            VARCHAR2 (200) DEFAULT fnd_api.g_true;
   lv_return_status            VARCHAR2 (200);
   ln_msg_count                NUMBER;
   lv_msg_data                 VARCHAR2 (2000);
   lv_msg                      VARCHAR2 (2000);
   ln_contact_point_id         NUMBER;
   ln_object_version_number    NUMBER;
   lr_contact_point_rec_type   hz_contact_point_v2pub.contact_point_rec_type;
   lr_email_rec_type           hz_contact_point_v2pub.email_rec_type;
BEGIN
   lr_contact_point_rec_type.actual_content_source :=
      hz_contact_point_v2pub.g_miss_content_source_type;
   lr_contact_point_rec_type.contact_point_type := 'EMAIL';
   lr_contact_point_rec_type.created_by_module := 'TCA_V2_API';
   lr_contact_point_rec_type.primary_flag := 'N';
   lr_contact_point_rec_type.owner_table_name := 'HZ_PARTIES';
   lr_contact_point_rec_type.owner_table_id := 407602;
   lr_email_rec_type.email_format := 'MAILTEXT';
   lr_email_rec_type.email_address := 'test@share.com';

   hz_contact_point_v2pub.create_email_contact_point (
      p_init_msg_list       => lv_init_msg_list,
      p_contact_point_rec   => lr_contact_point_rec_type,
      p_email_rec           => lr_email_rec_type,
      x_contact_point_id    => ln_contact_point_id,
      x_return_status       => lv_return_status,
      x_msg_count           => ln_msg_count,
      x_msg_data            => lv_msg_data);
   DBMS_OUTPUT.put_line ('API Status: ' || lv_return_status);

   IF (lv_return_status <> 'S')
   THEN
      DBMS_OUTPUT.put_line ('ERROR :' || lv_msg_data);
   END IF;

   DBMS_OUTPUT.put_line ('Create Email is completed');
   COMMIT;
EXCEPTION
   WHEN OTHERS
   THEN
      DBMS_OUTPUT.put_line ('Error:' || SQLERRM);
      ROLLBACK;
END;