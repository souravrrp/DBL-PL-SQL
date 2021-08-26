/* Formatted on 8/26/2021 10:46:52 AM (QP5 v5.287) */
CREATE OR REPLACE PACKAGE BODY APPS.xxdbl_mview_dtld_pkg
IS
   -- CREATED BY : SOURAV PAUL
   -- CREATION DATE : 21-JUN-2021
   -- LAST UPDATE DATE :08-AUG-2021
   -- PURPOSE : MATERIALIAZED VIEW DATA LOAD

   FUNCTION run_mview_dataload_func_p (p_mview VARCHAR2)
      RETURN NUMBER
   IS
      x_mview_name   VARCHAR2 (2000);
      x_return_val   NUMBER := 0;
   BEGIN
      --------------------------------------------------------------------------
      ----------XXDBL_INV_CON_RPT_MV MVIEW DATALOAD--------------------------
      --------------------------------------------------------------------------
      IF p_mview = 'XXDBL_INV_CON_RPT_MV'
      THEN
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
      ELSIF p_mview = 'XXDBL_INV_ITEM_CST_RPT_MV'
      THEN
         BEGIN
            x_mview_name := 'XXDBL_INV_ITEM_CST_RPT_MV';
            DBMS_MVIEW.refresh ('APPS.XXDBL_INV_ITEM_CST_RPT_MV',
                                method           => 'C',
                                ATOMIC_REFRESH   => FALSE);
            COMMIT;
            fnd_file.put_line (
               fnd_file.LOG,
               'Successfully Refresh the Materialized View :' || x_mview_name);
         END;
      ELSIF p_mview = 'XXDBL_GL_DTL_STAT_SUM_MV'
      THEN
         BEGIN
            x_mview_name := 'XXDBL_GL_DTL_STAT_SUM_MV';
            DBMS_MVIEW.refresh ('APPS.XXDBL_GL_DTL_STAT_SUM_MV',
                                method           => 'C',
                                ATOMIC_REFRESH   => FALSE);
            --SYS.DBMS_SYNC_REFRESH.REGISTER_MVIEWS ('XXDBL_GL_DTL_STAT_SUM_MV');
            COMMIT;
            fnd_file.put_line (
               fnd_file.LOG,
               'Successfully Refresh the Materialized View :' || x_mview_name);
         END;
      ELSIF p_mview = 'XXDBLCL_SALES_ORDER_DTL_MV'
      THEN
         BEGIN
            x_mview_name := 'XXDBLCL_SALES_ORDER_DTL_MV';
            DBMS_MVIEW.REFRESH ('APPS.XXDBLCL_SALES_ORDER_DTL_MV',
                                METHOD           => 'C',
                                ATOMIC_REFRESH   => FALSE);
            COMMIT;
            fnd_file.put_line (
               fnd_file.LOG,
               'Successfully Refresh the Materialized View :' || x_mview_name);
         END;
      END IF;

      RETURN x_return_val;
   EXCEPTION
      WHEN OTHERS
      THEN
         RETURN NULL;
   END;

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



   PROCEDURE run_mview_dataload_conc_p (ERRBUF       OUT VARCHAR2,
                                        RETCODE      OUT VARCHAR2,
                                        MVIEW     IN     VARCHAR2)
   IS
      L_Retcode     NUMBER;
      CONC_STATUS   BOOLEAN;
      l_error       VARCHAR2 (100);
   BEGIN
      fnd_file.put_line (fnd_file.LOG, 'Parameter received');


      L_Retcode := run_mview_dataload_func_p (MVIEW);

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
   END run_mview_dataload_conc_p;
END xxdbl_mview_dtld_pkg;
/