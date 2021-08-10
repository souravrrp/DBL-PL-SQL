/* Formatted on 8/23/2020 10:28:16 AM (QP5 v5.287) */
CREATE OR REPLACE PACKAGE BODY XX_DOC_WF_PKG
AS
   PROCEDURE XX_create_DOC_WF (document_id     IN            VARCHAR2,
                               DISPLAY_TYPE    IN            VARCHAR2,
                               DOCUMENT        IN OUT NOCOPY VARCHAR2,
                               document_type   IN OUT NOCOPY VARCHAR2)
   IS
      lv_details   VARCHAR2 (32767);
      V_ITEMKEY    VARCHAR2 (100);
      amount       NUMBER;

      CURSOR CUR_QUALITF
      IS
         SELECT PERSON_ID, TITLE
           FROM PER_QUALIFICATIONS
          WHERE PERSON_ID = 4426;
   BEGIN
      /* TABLE HEADER*/
      lv_details :=
            lv_details
         || ' < h4> '
         || 'Details of the Qualification of employee '
         || '</H4>'
         || '<table border = "1"> <tr>'
         || '<th> '
         || 'person id'
         || '</th>'
         || '<th>'
         || 'Title'
         || '</th>';

      FOR CUR_QUALITF_REC IN CUR_QUALITF
      LOOP
         /*TABLE BODY */
         lv_details :=
               lv_details
            || '<tr>'
            || '<td>'
            || CUR_QUALITF_REC.person_id
            || '</td>'
            || '<td>'
            || CUR_QUALITF_REC.TITLE
            || '</tr>';
      END LOOP;

      document := LV_DETAILS;

      /*We have to determine document_type which is nothing but the mime type
      document_type := ‘image/jpg; name=filename.jpg’;
      Depending on the extension of the document the MIME type is determined. For simplicity
      we are hard coding here*/
      --      document_type := ‘application/pdf;name=test.pdf’;  /* This syntax is used for PDF type of attachments */

      document_type := 'text/html';
   EXCEPTION
      WHEN OTHERS
      THEN
         document := '<H4>Error ' || SQLERRM || '</H4>';
   END;

   PROCEDURE XX_DOC_CALL (itemtype    IN     VARCHAR2,
                          ITEMKEY     IN     VARCHAR2,
                          actid       IN     NUMBER,
                          funcmode    IN     VARCHAR2,
                          resultout      OUT VARCHAR2)
   IS
      V_DOCUMENT_ID   CLOB;
      v_itemkey       NUMBER;
   BEGIN
      V_DOCUMENT_ID := 'PLSQL:XX_DOC_WF_PKG.XX_create_DOC_WF/' || ITEMKEY;

      /*Setting Value to the Document Type Attribute */

      wf_engine.setitemattrtext (itemtype   => itemtype,
                                 itemkey    => itemkey,
                                 ANAME      => 'BODY',
                                 avalue     => V_DOCUMENT_ID);
   END;
END xx_doc_wf_pkg;