/* Formatted on 7/19/2020 2:21:14 PM (QP5 v5.287) */
CREATE OR REPLACE PACKAGE XX_DOC_WF_PKG
AS
   PROCEDURE XX_create_DOC_WF (document_id     IN            VARCHAR2,
                               display_type    IN            VARCHAR2,
                               DOCUMENT        IN OUT NOCOPY VARCHAR2,
                               DOCUMENT_TYPE   IN OUT NOCOPY VARCHAR2);

   PROCEDURE XX_DOC_CALL (itemtype    IN     VARCHAR2,
                          ITEMKEY     IN     VARCHAR2,
                          actid       IN     NUMBER,
                          FUNCMODE    IN     VARCHAR2,
                          resultout      OUT VARCHAR2);
END;