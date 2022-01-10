/* Formatted on 9/23/2020 2:10:29 PM (QP5 v5.287) */
SELECT  dbms_lob.substr( long_text, 4000, 1) CLOB_TEXT,
      adf.*
      ,dlt.*
  FROM FND_ATTACHED_DOCS_FORM_VL adf, fnd_documents_long_text dlt
 WHERE     1 = 1
       AND adf.MEDIA_ID = dlt.MEDIA_ID
       AND adf.DATATYPE_NAME = 'Long Text'
       AND adf.FUNCTION_NAME='PO_CLM_ATTACHMENTS'
       AND TO_CHAR (adf.CREATION_DATE, 'DD-MON-RRRR') = '23-SEP-2020'
       AND PK1_VALUE='362393';

SELECT * FROM fnd_documents_long_text;


SELECT FD.document_id DOCUMENT_ID,
       FDT.media_id MEDIA_ID,
       FD.datatype_id DATATYPE_ID,
       C.category_id CATEGORY_ID,
       FAD.entity_name ENTITY_NAME,
       FAD.pk1_value PK1_VALUE,
       DECODE (FDD.name, 'SHORT_TEXT', FDST.short_text, NULL) SHORT_TEXT --short text atttachment
                                                                        ,
       FDLT.long_text LONG_TEXT                         --long text attachment
                               ,
       ROWNUM TRX_LINE
  FROM fnd_documents_short_text FDST,
       fnd_documents_long_text FDLT,
       fnd_attached_documents FAD,
       FND_DOCUMENT_CATEGORIES_TL CL,
       FND_DOCUMENT_CATEGORIES C,
       fnd_document_datatypes FDD,
       fnd_documents FD,
       fnd_documents_tl FDT,
       po_headers PH
 WHERE     FDST.media_id(+) = FDT.media_id
       AND FDLT.media_id(+) = FDT.media_id
       AND FDT.LANGUAGE = USERENV ('LANG')
       AND FDT.document_id = FAD.document_id
       AND FD.document_id = FAD.document_id
       AND FD.datatype_id = FDD.datatype_id
       AND FDD.LANGUAGE = USERENV ('LANG')
       --for category
       AND FD.CATEGORY_ID = C.CATEGORY_ID
       AND C.CATEGORY_ID = CL.CATEGORY_ID
       AND CL.LANGUAGE = USERENV ('LANG')
       --For transaction
       AND FAD.entity_name = 'PO_HEADERS'
       AND FAD.pk1_value = po_header_id
       AND FAD.pk1_value = :poh_po_header_id
       
       
         SELECT
        FAD.SEQ_NUM "Seq Number",
        FDAT.USER_NAME "Data Type",
        FDCT.USER_NAME "Category User Name",
        FAD.ATTACHED_DOCUMENT_ID "Attached Document Id",
        FDET.USER_ENTITY_NAME "User Entity",
        FD.DOCUMENT_ID "Document Id",
        FAD.ENTITY_NAME "Entity Name",
        FD.MEDIA_ID "Media Id",
        FD.URL "Url",
        FDT.TITLE "Title",
        FDLT.LONG_TEXT "Attachment Text"
FROM
        FND_DOCUMENT_DATATYPES FDAT,
        FND_DOCUMENT_ENTITIES_TL FDET,
        FND_DOCUMENTS_TL FDT,
        FND_DOCUMENTS FD,
        FND_DOCUMENT_CATEGORIES_TL FDCT,
        FND_ATTACHED_DOCUMENTS   FAD,
        FND_DOCUMENTS_LONG_TEXT FDLT
WHERE
        FD.DOCUMENT_ID          = FAD.DOCUMENT_ID
        AND FDT.DOCUMENT_ID     = FD.DOCUMENT_ID
        AND FDCT.CATEGORY_ID    = FD.CATEGORY_ID
        AND FD.DATATYPE_ID      = FDAT.DATATYPE_ID
        AND FAD.ENTITY_NAME     = FDET.DATA_OBJECT_CODE
        AND FDLT.MEDIA_ID       = FD.MEDIA_ID
        AND FDAT.NAME           = 'LONG_TEXT'