/* Formatted on 9/12/2020 2:50:02 PM (QP5 v5.287) */
CREATE OR REPLACE PACKAGE xxdbl_emp_wf_doc_pkg
AS
   PROCEDURE xx_create_wf_doc (document_id     IN            VARCHAR2,
                               display_type    IN            VARCHAR2,
                               document        IN OUT NOCOPY VARCHAR2,
                               document_type   IN OUT NOCOPY VARCHAR2);
END xxdbl_emp_wf_doc_pkg;
/

SHOW ERRORS;
EXIT;