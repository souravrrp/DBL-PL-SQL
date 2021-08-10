/* Formatted on 8/23/2020 10:41:58 AM (QP5 v5.287) */
CREATE OR REPLACE PACKAGE xxdbl_po_req_wf_pkg
AS
   PROCEDURE xxdbl_create_wf_doc (document_id     IN            VARCHAR2,
                                  display_type    IN            VARCHAR2,
                                  document        IN OUT NOCOPY VARCHAR2,
                                  document_type   IN OUT NOCOPY VARCHAR2);
END xxdbl_po_req_wf_pkg;
/

SHOW ERRORS;
EXIT;