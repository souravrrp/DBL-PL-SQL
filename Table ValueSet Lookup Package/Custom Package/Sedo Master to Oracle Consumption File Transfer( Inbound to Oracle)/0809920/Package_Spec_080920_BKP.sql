CREATE OR REPLACE PACKAGE APPS.XXDBL_SEDOMAST_INBOUND_PKG
AS
   /***********************************************************************************
   * $Header$
   * Program Name : XXDBL_SEDOMAST_INBOUND_PKG.pks
   * Language     : PL/SQL
   * Description  : Package for loading data from flatfile to
   *                staging table, validate and insert data into
   *                OPM base table in Oracle EBS using interface.
   * HISTORY
   *===================================================================================
   * Author                      Version                                  Date
   *===================================================================================
   * Titas Lahiri-PwC       1.0 - Initial Version                       08/JAN/2019
   ***********************************************************************************/
   --
   -- Define Global Spec Variables
   g_success                        CONSTANT   VARCHAR2(1) := 'S';
   g_fail                           CONSTANT   VARCHAR2(1) := 'E';
   g_default                        CONSTANT   VARCHAR2(1) := 'N';
   --
   -- Called from Conc. Program
   PROCEDURE main_prc     ( x_errbuff               OUT  VARCHAR2
                           ,x_retcode               OUT  VARCHAR2
                          );
   --
   -- Procedure ftp data
   PROCEDURE ftp_prc;
   --
   -- Procedure load data
   PROCEDURE load_prc
           (p_request_id                IN   NUMBER
           );
   --               Procedure Validate data
   PROCEDURE validate_prc(p_request_id                IN   NUMBER
           );
   --           
   -- Procedure Create Ingredient Line
   PROCEDURE create_line_prc
           (p_request_id              IN   NUMBER
           );
   --           
   -- Procedure Create Transaction
   PROCEDURE create_transaction_prc
           (p_request_id              IN   NUMBER
           );
              
   --
   -- Procedure show error records
   PROCEDURE show_errors
           (p_request_id                IN   NUMBER
           );
   --  
END XXDBL_SEDOMAST_INBOUND_PKG;
/
