CREATE OR REPLACE PROCEDURE APPS.xxdbl_recp_rout_thread_assign (
   p_formula_no    IN       VARCHAR2,
   x_out_message   OUT      VARCHAR2
)
IS
   CURSOR rout_ass_curr (p_formula_no_cur IN VARCHAR2)
   IS
      SELECT   mp.organization_id AS org_id, fu.user_id AS user_id,
               ffm.formula_id AS formula_id, ffm.formula_no AS form_no,
               ffm.formula_vers AS formu_vers, grb.recipe_no AS rcp_no,
               grb.recipe_version AS rcp_vers,
               UPPER (xfus.routing_no) AS routing_no,
               grb.recipe_id AS rcp_id
          FROM mtl_parameters mp,
               xxdbl_thread_formula_upd_stg xfus,
               fnd_user fu,
               fm_form_mst ffm,
               gmd_recipes_b grb
         WHERE mp.organization_code = xfus.owner_organization_code
           AND fu.user_name = UPPER (xfus.owner_code)
           AND ffm.formula_no = p_formula_no_cur
           AND ffm.formula_id =
                  (SELECT formula_id
                     FROM fm_form_mst
                    WHERE formula_no = xfus.formula_no
                      AND formula_vers =
                             (SELECT MAX (formula_vers)
                                FROM fm_form_mst
                               WHERE formula_no = xfus.formula_no
                                 AND owner_organization_id =
                                                            mp.organization_id))
           AND grb.formula_id = ffm.formula_id
           AND ffm.formula_status =
                  DECODE (xfus.formula_status,
                          'Approved for General Use', 700,
                          700
                         )
           AND xfus.owner_organization_code = '193'
      GROUP BY mp.organization_id,
               fu.user_id,
               ffm.formula_id,
               ffm.formula_no,
               ffm.formula_vers,
               grb.recipe_no,
               grb.recipe_version,
               xfus.routing_no,
               grb.recipe_id;

   tbl_recipe_hdr     gmd_recipe_header.recipe_tbl;
   tbl_hdr_flex       gmd_recipe_header.recipe_update_flex;
   lv_status_hdr      VARCHAR2 (200);
   lv_msg_cnt         NUMBER;
   lv_msg_data        VARCHAR2 (3999);
   lv_msg_index_out   VARCHAR2 (100);
   l_verify_flag      VARCHAR2 (3)                         := 'Y';
   l_msg_cnt          NUMBER;
   l_msg_lst          VARCHAR2 (3999);
   l_ret_status       VARCHAR2 (200);
   l_routing_ver      NUMBER                               := -1;
BEGIN
   fnd_global.apps_initialize (user_id           => 1130,
                               resp_id           => 22882,
                               resp_appl_id      => 552
                              );

   FOR rt_asn IN rout_ass_curr (p_formula_no)
   LOOP
      DBMS_OUTPUT.put_line ('Routing Number : ' || rt_asn.routing_no);

      BEGIN
         SELECT NVL (MAX (routing_vers), -1)
           INTO l_routing_ver
           FROM gmd_routings_b
          WHERE routing_no = rt_asn.routing_no
          and ROUTING_STATUS = 700;

         DBMS_OUTPUT.put_line (   'Routing Version : '
                               || rt_asn.routing_no
                               || '  exist '
                               || l_routing_ver
                              );
      EXCEPTION
         WHEN OTHERS
         THEN
            l_routing_ver := -1;
            x_out_message :=
                 'Routing Number : ' || rt_asn.routing_no || ' doesnot exist';
            fnd_file.put_line (fnd_file.LOG,
                                  'Routing Number : '
                               || rt_asn.routing_no
                               || ' doesnot exist'
                              );
            DBMS_OUTPUT.put_line (   'Routing Number : '
                                  || rt_asn.routing_no
                                  || ' doesnot exist'
                                 );
      END;

      IF l_routing_ver > 0
      THEN
         tbl_recipe_hdr (1).recipe_id := rt_asn.rcp_id;
         tbl_recipe_hdr (1).recipe_no := rt_asn.rcp_no;
         tbl_recipe_hdr (1).recipe_version := rt_asn.rcp_vers;
         tbl_recipe_hdr (1).routing_vers := l_routing_ver;
         tbl_recipe_hdr (1).routing_no := rt_asn.routing_no;
         tbl_recipe_hdr (1).owner_organization_id := rt_asn.org_id;
         tbl_recipe_hdr (1).owner_id := rt_asn.user_id;
         tbl_hdr_flex (1).attribute_category := NULL;
         tbl_hdr_flex (1).attribute1 := NULL;
         tbl_hdr_flex (1).attribute2 := NULL;
         tbl_hdr_flex (1).attribute3 := NULL;
         tbl_hdr_flex (1).attribute4 := NULL;
         tbl_hdr_flex (1).attribute5 := NULL;
         tbl_hdr_flex (1).attribute6 := NULL;
         tbl_hdr_flex (1).attribute7 := NULL;
         tbl_hdr_flex (1).attribute8 := NULL;
         tbl_hdr_flex (1).attribute9 := NULL;
         tbl_hdr_flex (1).attribute10 := NULL;
         tbl_hdr_flex (1).attribute11 := NULL;
         tbl_hdr_flex (1).attribute12 := NULL;
         tbl_hdr_flex (1).attribute13 := NULL;
         tbl_hdr_flex (1).attribute14 := NULL;
         tbl_hdr_flex (1).attribute15 := NULL;
         tbl_hdr_flex (1).attribute16 := NULL;
         tbl_hdr_flex (1).attribute17 := NULL;
         tbl_hdr_flex (1).attribute18 := NULL;
         tbl_hdr_flex (1).attribute19 := NULL;
         tbl_hdr_flex (1).attribute20 := NULL;
         tbl_hdr_flex (1).attribute21 := NULL;
         tbl_hdr_flex (1).attribute22 := NULL;
         tbl_hdr_flex (1).attribute23 := NULL;
         tbl_hdr_flex (1).attribute24 := NULL;
         tbl_hdr_flex (1).attribute25 := NULL;
         tbl_hdr_flex (1).attribute26 := NULL;
         tbl_hdr_flex (1).attribute27 := NULL;
         tbl_hdr_flex (1).attribute28 := NULL;
         tbl_hdr_flex (1).attribute29 := NULL;
         tbl_hdr_flex (1).attribute30 := NULL;
         --dbms_output.put_line('UPDATE_RECIPE_HEADER api starts here ');
         gmd_recipe_header.update_recipe_header
                                      (p_api_version             => 2.0,
                                       p_init_msg_list           => fnd_api.g_false,
                                       p_commit                  => fnd_api.g_true,
                                       p_called_from_forms       => 'NO',
                                       p_recipe_header_tbl       => tbl_recipe_hdr,
                                       x_return_status           => lv_status_hdr,
                                       x_msg_count               => lv_msg_cnt,
                                       x_msg_data                => lv_msg_data,
                                       p_recipe_update_flex      => tbl_hdr_flex
                                      );

         --dbms_output.put_line('UPDATE_RECIPE_HEADER completed with status code : '||lv_status_hdr||' for recipe number : '||RT_ASN.RCP_NO);
         IF NVL (lv_status_hdr, 'E') <> 'S'
         THEN
            DBMS_OUTPUT.put_line
                ('After Calling gmd_recipe_header.update_recipe_header Error');
            l_verify_flag := 'N';

            FOR cr_err_rec IN 1 .. lv_msg_cnt
            LOOP
               fnd_msg_pub.get (p_msg_index          => cr_err_rec,
                                p_encoded            => fnd_api.g_false,
                                p_data               => lv_msg_data,
                                p_msg_index_out      => lv_msg_index_out
                               );
               fnd_file.put_line (fnd_file.LOG,
                                     CHR (10)
                                  || lv_status_hdr
                                  || '- Routing assignment fails: '
                                  || lv_msg_data
                                  || '-'
                                  || lv_msg_index_out
                                 );
               DBMS_OUTPUT.put_line (   CHR (10)
                                     || lv_status_hdr
                                     || '- Routing assignment fails: '
                                     || lv_msg_data
                                     || '-'
                                     || lv_msg_index_out
                                    );

               IF x_out_message IS NULL
               THEN
                  x_out_message :=
                        lv_status_hdr
                     || '- Routing assignment fails: '
                     || lv_msg_data
                     || '-'
                     || lv_msg_index_out;
               ELSE
                  x_out_message :=
                        x_out_message
                     || CHR (10)
                     || lv_status_hdr
                     || '- Routing assignment fails: '
                     || lv_msg_data
                     || '-'
                     || lv_msg_index_out;
               END IF;
            /*    dbms_output.put_line (lv_status_hdr
                                  || '- Routing assignment fails: '
                                  || lv_msg_data
                                  || '-'
                                  || lv_msg_index_out
                                 );
                */
            END LOOP;
         ELSE
            DBMS_OUTPUT.put_line ('Else Part');
            gmd_status_pub.modify_status (p_api_version         => 1.0,
                                          p_init_msg_list       => TRUE,
                                          p_entity_name         => 'Recipe',
                                          p_entity_id           => rt_asn.rcp_id
                                                                                -- Recipe ID
            ,
                                          p_entity_no           => NULL
                                                                       -- Recipe_no
            ,
                                          p_entity_version      => NULL
                                                                       -- Recipe_vers
            ,
                                          p_to_status           => '700'
                                                                        -- Change To status
            ,
                                          p_ignore_flag         => FALSE,
                                          x_message_count       => l_msg_cnt,
                                          x_message_list        => l_msg_lst,
                                          x_return_status       => l_ret_status
                                         );

            IF NVL (l_ret_status, 'E') = 'S'
            THEN
               DBMS_OUTPUT.put_line ('gmd_status_pub.modify_status: Success');
            --dbms_output.put_line('Recipe status 700 updation competes with status code : '||l_ret_status||' for recipe number : '||RT_ASN.RCP_NO);
            ELSE
               IF x_out_message IS NULL
               THEN
                  x_out_message := 'gmd_status_pub.modify_status: Error';
               ELSE
                  x_out_message :=
                        x_out_message
                     || CHR (10)
                     || 'gmd_status_pub.modify_status: Error';
               END IF;

               DBMS_OUTPUT.put_line ('gmd_status_pub.modify_status: Error');
            END IF;
         END IF;
      END IF;
   END LOOP;
EXCEPTION
   WHEN OTHERS
   THEN
      DBMS_OUTPUT.put_line ('Error in XXDBL_RECP_ROUT_THREAD_ASSIGN');
END xxdbl_recp_rout_thread_assign;
/
