/* Formatted on 7/4/2020 3:40:06 PM (QP5 v5.287) */
DECLARE
   v_item_key   VARCHAR2 (100);

   CURSOR c_req_details
   IS
      SELECT prh.requisition_header_id,
             prh.org_id,
             prh.preparer_id,
             prh.segment1,
             pdt.document_subtype,
             pdt.document_type_code,
             prh.authorization_status
        FROM apps.po_requisition_headers_all prh,
             apps.po_document_types_all pdt
       WHERE     prh.type_lookup_code = pdt.document_subtype
             AND prh.org_id = pdt.org_id
             AND pdt.document_type_code = 'REQUISITION'
             AND NVL (authorization_status, 'INCOMPLETE') = 'INCOMPLETE'
             AND segment1 = '10231003437';      --ENTER The Requisition Number
BEGIN
   fnd_global.apps_initialize (user_id        => 5546,
                               resp_id        => 20707,
                               resp_appl_id   => 201);

   FOR p_rec IN c_req_details
   LOOP
      mo_global.init ('PO');
      mo_global.set_policy_context ('S', p_rec.org_id);

      SELECT    p_rec.requisition_header_id
             || '-'
             || TO_CHAR (po_wf_itemkey_s.NEXTVAL)
        INTO v_item_key
        FROM DUAL;

      DBMS_OUTPUT.put_line (
            'Calling po_reqapproval_init1.start_wf_process for requisition =>'
         || p_rec.segment1);

      po_reqapproval_init1.start_wf_process (
         ItemType                 => NULL,
         ItemKey                  => v_item_key,
         WorkflowProcess          => 'POAPPRV_TOP',
         ActionOriginatedFrom     => 'PO_FORM',
         DocumentID               => p_rec.requisition_header_id -- requisition_header_id
                                                                ,
         DocumentNumber           => p_rec.segment1      -- Requisition Number
                                                   ,
         PreparerID               => p_rec.preparer_id,
         DocumentTypeCode         => p_rec.document_type_code   -- REQUISITION
                                                             ,
         DocumentSubtype          => p_rec.document_subtype        -- PURCHASE
                                                           ,
         SubmitterAction          => 'APPROVE',
         forwardToID              => NULL,
         forwardFromID            => NULL,
         DefaultApprovalPathID    => NULL,
         Note                     => NULL,
         PrintFlag                => 'N',
         FaxFlag                  => 'N',
         FaxNumber                => NULL,
         EmailFlag                => 'N',
         EmailAddress             => NULL,
         CreateSourcingRule       => 'N',
         ReleaseGenMethod         => 'N',
         UpdateSourcingRule       => 'N',
         MassUpdateReleases       => 'N',
         RetroactivePriceChange   => 'N',
         OrgAssignChange          => 'N',
         CommunicatePriceChange   => 'N',
         p_Background_Flag        => 'N',
         p_Initiator              => NULL,
         p_xml_flag               => NULL,
         FpdsngFlag               => 'N',
         p_source_type_code       => NULL);

      COMMIT;

      DBMS_OUTPUT.put_line (
         'The Requisition which is Approved =>' || p_rec.segment1);
   END LOOP;
END;