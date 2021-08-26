/* Formatted on 6/22/2021 10:54:16 AM (QP5 v5.287) */
CREATE OR REPLACE PACKAGE BODY APPS.xxdbl_mview_dtld_pkg
IS
   -- CREATED BY : SOURAV PAUL
   -- CREATION DATE : 21-JUN-2021
   -- LAST UPDATE DATE :21-JUN-2021
   -- PURPOSE : MATERIALIAZED VIEW DATA LOAD
   FUNCTION run_mview_dataload_func
      RETURN NUMBER
   IS
      x_mview_name   VARCHAR2 (2000);
      x_return_val   NUMBER := 0;
   BEGIN
      --------------------------------------------------------------------------
      ----------XXDBL_INV_CON_RPT_MV MVIEW DATALOAD--------------------------
      --------------------------------------------------------------------------
      BEGIN
         x_mview_name := 'XXDBL_INV_CON_RPT_MV';
         DBMS_MVIEW.refresh ('APPS.XXDBL_INV_CON_RPT_MV',
                             method           => 'C',
                             ATOMIC_REFRESH   => FALSE);
         COMMIT;
         fnd_file.put_line (
            fnd_file.LOG,
            'Successfully Refresh the Materialized View :' || x_mview_name);
      END;

      RETURN x_return_val;
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
         fnd_file.put_line (fnd_file.LOG,
                            'Concurrent Program Status :' || RETCODE);
      ELSIF L_Retcode = 1
      THEN
         RETCODE := 'Warning';
         CONC_STATUS :=
            FND_CONCURRENT.SET_COMPLETION_STATUS ('WARNING', 'Warning');
         fnd_file.put_line (fnd_file.LOG,
                            'Concurrent Program Status :' || RETCODE);
      ELSIF L_Retcode = 2
      THEN
         RETCODE := 'Error';
         CONC_STATUS :=
            FND_CONCURRENT.SET_COMPLETION_STATUS ('ERROR', 'Error');
         fnd_file.put_line (fnd_file.LOG,
                            'Concurrent Program Status :' || RETCODE);
      END IF;
   EXCEPTION
      WHEN OTHERS
      THEN
         l_error := 'error while executing the procedure ' || SQLERRM;
         errbuf := l_error;
         RETCODE := 1;
         fnd_file.put_line (fnd_file.LOG,
                            'Concurrent Program Status :' || L_Retcode);
   END run_mview_dataload_conc;

   PROCEDURE run_mview_dataload_proc
   IS
      x_mview_name   VARCHAR2 (2000);
   BEGIN
      --------------------------------------------------------------------------
      ----------XXDBL_INV_CON_RPT_MV MVIEW DATALOAD--------------------------
      --------------------------------------------------------------------------
      BEGIN
         x_mview_name := 'XXDBL_INV_CON_RPT_MV';
         DBMS_MVIEW.refresh ('APPS.XXDBL_INV_CON_RPT_MV',
                             method           => 'C',
                             ATOMIC_REFRESH   => FALSE);
         COMMIT;
         fnd_file.put_line (
            fnd_file.LOG,
            'Successfully Refresh the Materialized View :' || x_mview_name);
      END;
   END run_mview_dataload_proc;
END xxdbl_mview_dtld_pkg;
/