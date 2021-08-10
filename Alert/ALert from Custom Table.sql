--------------------------------Step-1: Register the Table----------------------
BEGIN
   ad_dd.register_table (p_appl_short_name   => 'SQLAP', --Application name in which you want to register
                         p_tab_name          => 'XXDBL_IOU_REQ_DTL', --Table Name
                         p_tab_type          => 'T', -- T for Transaction data , S for seeded data
                         p_next_extent       => 512,            -- default 512
                         p_pct_free          => 10,              -- Default 10
                         p_pct_used          => 70                --Default 70
                                                  );
   COMMIT;
END;

----------------------------Step-2: Create Custom Table--------------------------


CREATE TABLE xxdbl.xxdbl_temp_tbl
(
   seq_no       NUMBER,
   col_name     VARCHAR2 (240),
   col_type     VARCHAR2 (240),
   col_width    NUMBER,
   table_name   VARCHAR2 (240)
);


CREATE OR REPLACE SYNONYM appsro.xxdbl_temp_tbl FOR xxdbl.xxdbl_temp_tbl;

CREATE OR REPLACE SYNONYM apps.xxdbl_temp_tbl FOR xxdbl.xxdbl_temp_tbl;

-----------------------------------Step-3: Register the Column------------------

DECLARE
   CURSOR C_IOU_DTLS
   IS
      SELECT *
        FROM xxdbl.xxdbl_temp_tbl
       WHERE table_name = 'XXDBL_IOU_REQ_DTL';
BEGIN
   BEGIN
      mo_global.init ('SQLAP');
      mo_global.set_policy_context ('S', 81);
      fnd_global.apps_initialize (fnd_profile.VALUE ('5958'), fnd_profile.VALUE ('20456'), fnd_profile.VALUE ('160'));
      COMMIT;
   END;


   FOR y IN C_IOU_DTLS
   LOOP
      ad_dd.register_column (p_appl_short_name   => 'SQLAP',
                             p_tab_name          => 'XXDBL_IOU_REQ_DTL',
                             p_col_name          => TRIM (y.COL_NAME),
                             p_col_seq           => TRIM (y.SEQ_NO),
                             p_col_type          => TRIM (y.COL_TYPE),
                             p_col_width         => TRIM (y.COL_WIDTH),
                             p_nullable          => 'Y',
                             p_translate         => 'N',
                             p_precision         => NULL,
                             p_scale             => NULL);
      COMMIT;
   END LOOP;
END;