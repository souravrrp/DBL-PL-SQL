CREATE OR REPLACE PACKAGE BODY APPS.xxdbl_mview_dtld_pkg
IS
   -- CREATED BY : SOURAV PAUL
   -- CREATION DATE : 21-JUN-2021
   -- LAST UPDATE DATE :21-JUN-2021
   -- PURPOSE : MATERIALIAZED VIEW DATA LOAD
   FUNCTION run_mview_dataload_func
      RETURN NUMBER
   IS
      x_return_status   VARCHAR2 (2000);
      x_msg_count       NUMBER;
      x_msg_data        VARCHAR2 (2000);
      l_return_val      NUMBER;
   BEGIN
      --------------------------------------------------------------------------
      ----------XXDBL_INV_CON_RPT_MVIEW MVIEW DATALOAD--------------------------
      --------------------------------------------------------------------------
      BEGIN
         DBMS_MVIEW.refresh ('APPS.XXDBL_INV_CON_RPT_MVIEW',
                             method           => 'C',
                             ATOMIC_REFRESH   => FALSE);
         COMMIT;
      END;

      RETURN 0;
   EXCEPTION
      WHEN OTHERS
      THEN
         RETURN NULL;
   END;


   PROCEDURE run_mview_dataload_conc (ERRBUF    OUT VARCHAR2,
                                      RETCODE   OUT VARCHAR2)
   IS
      L_Retcode     NUMBER;
      CONC_STATUS   BOOLEAN;
      l_error       VARCHAR2 (100);
   BEGIN
      fnd_file.put_line (fnd_file.LOG, 'Parameter received');


      L_Retcode := run_mview_dataload_func;

      IF L_Retcode = 0
      THEN
         RETCODE := 'Success';
         CONC_STATUS :=
            FND_CONCURRENT.SET_COMPLETION_STATUS ('NORMAL', 'Completed');
         fnd_file.put_line (fnd_file.LOG, 'Status :' || RETCODE);
      ELSIF L_Retcode = 1
      THEN
         RETCODE := 'Warning';
         CONC_STATUS :=
            FND_CONCURRENT.SET_COMPLETION_STATUS ('WARNING', 'Warning');
         fnd_file.put_line (fnd_file.LOG, 'Status :' || RETCODE);
      ELSIF L_Retcode = 2
      THEN
         RETCODE := 'Error';
         CONC_STATUS :=
            FND_CONCURRENT.SET_COMPLETION_STATUS ('ERROR', 'Error');
         fnd_file.put_line (fnd_file.LOG, 'Status :' || RETCODE);
      END IF;
   EXCEPTION
      WHEN OTHERS
      THEN
         l_error := 'error while executing the procedure ' || SQLERRM;
         errbuf := l_error;
         RETCODE := 1;
         fnd_file.put_line (fnd_file.LOG, 'Status :' || L_Retcode);
   END run_mview_dataload_conc;

   PROCEDURE run_mview_dataload_proc
   IS
      l_error_message   VARCHAR2 (3000);
      l_error_code      VARCHAR2 (3000);
   BEGIN
      --------------------------------------------------------------------------
      ----------XXDBL_INV_CON_RPT_MVIEW MVIEW DATALOAD--------------------------
      --------------------------------------------------------------------------
      BEGIN
         DBMS_MVIEW.refresh ('APPS.XXDBL_INV_CON_RPT_MVIEW',
                             method           => 'C',
                             ATOMIC_REFRESH   => FALSE);
         COMMIT;
      END;
   END run_mview_dataload_proc;
END xxdbl_mview_dtld_pkg;
/
