DECLARE
----------------------------Local Variables---------------------------
   l_enabled_flag             VARCHAR2 (2);
   l_summary_flag             VARCHAR2 (2);
   l_who_type                 FND_FLEX_LOADER_APIS.WHO_TYPE;
   l_user_id                  NUMBER                := FND_GLOBAL.USER_ID;
   l_login_id                 NUMBER                := FND_GLOBAL.LOGIN_ID;
   l_value_set_name           FND_FLEX_VALUE_SETS.FLEX_VALUE_SET_NAME%TYPE;
   l_value_set_value          FND_FLEX_VALUES.FLEX_VALUE%TYPE;
BEGIN
 
   l_value_set_name             :='VALUE_SET_NAME';
   l_value_set_value            :='VALUE_SET_VALUE';
   l_enabled_flag               := 'Y';
   l_summary_flag               := 'N';
   l_who_type.created_by        := l_user_id;
   l_who_type.creation_date     := SYSDATE;
   l_who_type.last_updated_by   := l_user_id;
   l_who_type.last_update_date  := SYSDATE;
   l_who_type.last_update_login := l_login_id;
 
     fnd_flex_loader_apis.up_value_set_value
                  (p_upload_phase               => 'BEGIN',
                   p_upload_mode                => NULL,
                   p_custom_mode                => 'FORCE',
                   p_flex_value_set_name        => l_value_set_name,
                   p_parent_flex_value_low      => NULL,
                   p_flex_value                 => l_value_set_value,
                   p_owner                      => NULL,
                   p_last_update_date           => TO_CHAR(SYSDATE, 'YYYY/MM/DD HH24:MI:SS'),
                   p_enabled_flag               => l_enabled_flag,
                   p_summary_flag               => l_summary_flag,
                   p_start_date_active          => TO_CHAR(SYSDATE, 'YYYY/MM/DD HH24:MI:SS'),
                   p_end_date_active            => NULL,
                   p_parent_flex_value_high     => NULL,
                   p_rollup_flex_value_set_name => NULL,
                   p_rollup_hierarchy_code      => NULL,
                   p_hierarchy_level            => NULL,
                   p_compiled_value_attributes  => NULL,
                   p_value_category             => 'VALUE_SET_NAME',
                   p_attribute1                 => '40912',
                   p_attribute2                 => NULL,
                   p_attribute3                 => NULL,
                   p_attribute4                 => NULL,
                   p_attribute5                 => NULL,
                   p_attribute6                 => NULL,
                   p_attribute7                 => NULL,
                   p_attribute8                 => NULL,
                   p_attribute9                 => NULL,
                   p_attribute10                => NULL,
                   p_attribute11                => NULL,
                   p_attribute12                => NULL,
                   p_attribute13                => NULL,
                   p_attribute14                => NULL,
                   p_attribute15                => NULL,
                   p_attribute16                => NULL,
                   p_attribute17                => NULL,
                   p_attribute18                => NULL,
                   p_attribute19                => NULL,
                   p_attribute20                => NULL,
                   p_attribute21                => NULL,
                   p_attribute22                => NULL,
                   p_attribute23                => NULL,
                   p_attribute24                => NULL,
                   p_attribute25                => NULL,
                   p_attribute26                => NULL,
                   p_attribute27                => NULL,
                   p_attribute28                => NULL,
                   p_attribute29                => NULL,
                   p_attribute30                => NULL,
                   p_attribute31                => NULL,
                   p_attribute32                => NULL,
                   p_attribute33                => NULL,
                   p_attribute34                => NULL,
                   p_attribute35                => NULL,
                   p_attribute36                => NULL,
                   p_attribute37                => NULL,
                   p_attribute38                => NULL,
                   p_attribute39                => NULL,
                   p_attribute40                => NULL,
                   p_attribute41                => NULL,
                   p_attribute42                => NULL,
                   p_attribute43                => NULL,
                   p_attribute44                => NULL,
                   p_attribute45                => NULL,
                   p_attribute46                => NULL,
                   p_attribute47                => NULL,
                   p_attribute48                => NULL,
                   p_attribute49                => NULL,
                   P_ATTRIBUTE50                => NULL,
                   p_flex_value_meaning         => l_value_set_value,
                   p_description                => NULL
                   );
      COMMIT;
 
   EXCEPTION
      WHEN OTHERS
      THEN
         DBMS_OUTPUT.PUT_LINE('Error is ' || SUBSTR (SQLERRM, 1, 1000));
   END;