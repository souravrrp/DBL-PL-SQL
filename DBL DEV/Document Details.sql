/* Formatted on 9/5/2020 11:00:19 AM (QP5 v5.287) */
SELECT PH.SEGMENT1 PO_NUMBER,
       --SUM(DBMS_LOB.GETLENGTH(fl.file_data)) SIZE_BYTES,
       ATT.FILE_NAME,
       ATT.CREATION_DATE,
       ATT.entity_name,
       ATT.SEQ_NUM,
       ATT.CATEGORY_DESCRIPTION,
       ATT.DATATYPE_NAME
  FROM FND_ATTACHED_DOCS_FORM_VL ATT, po_headers_all ph, fnd_lobs fl
 WHERE     function_name = DECODE (0, 1, NULL, 'PO_POXPOEPO')
       AND TO_NUMBER (PH.PO_HEADER_ID) = TO_NUMBER (pk1_value)
       AND TO_NUMBER (att.media_id) = TO_NUMBER (fl.file_id)
       AND (   (entity_name = 'PO_HEAD' AND pk2_value = '0')
            OR (entity_name IN ('PO_HEADERS')));