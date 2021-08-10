— R12 – PO – SAMPLE SCRIPT TO APPROVE PURCHASE ORDER
DECLARE
v_item_key VARCHAR2(100);

Cursor c_po_details is

SELECT
pha.po_header_id,
pha.org_id,
pha.segment1,
pha.agent_id,
pdt.document_subtype,
pdt.document_type_code,
pha.authorization_status
FROM apps.po_headers_all pha, apps.po_document_types_all pdt
WHERE pha.type_lookup_code = pdt.document_subtype
AND pha.org_id = pdt.org_id
AND pdt.document_type_code = ‘PO’
AND authorization_status in (‘INCOMPLETE’, ‘REQUIRES REAPPROVAL’)
AND segment1 = ‘11170000860’; — Enter the Purchase Order Number
BEGIN
fnd_global.apps_initialize (user_id => 2083,
resp_id => 20707,
resp_appl_id => 201);
FOR p_rec IN c_po_details
LOOP

mo_global.init (p_rec.document_type_code);
mo_global.set_policy_context (‘S’, p_rec.org_id);

SELECT p_rec.po_header_id ‘-‘ to_char(po_wf_itemkey_s.NEXTVAL)
INTO v_item_key FROM dual;
dbms_output.put_line (‘ Calling po_reqapproval_init1.start_wf_process for po_id=>’ p_rec.segment1);

po_reqapproval_init1.start_wf_process(
ItemType => ‘POAPPRV’
, ItemKey => v_item_key
, WorkflowProcess => ‘POAPPRV_TOP’
, ActionOriginatedFrom => ‘PO_FORM’
, DocumentID => p_rec.po_header_id — po_header_id
, DocumentNumber => p_rec.segment1 — Purchase Order Number
, PreparerID => p_rec.agent_id — Buyer/Preparer_id
, DocumentTypeCode => p_rec.document_type_code–‘PO’
, DocumentSubtype => p_rec.document_subtype –‘STANDARD’
, SubmitterAction => ‘APPROVE’
, forwardToID => NULL
, forwardFromID => NULL
, DefaultApprovalPathID => NULL
, Note => NULL
, PrintFlag => ‘N’
, FaxFlag => ‘N’
, FaxNumber => NULL
, EmailFlag => ‘N’
, EmailAddress => NULL
, CreateSourcingRule => ‘N’
, ReleaseGenMethod => ‘N’
, UpdateSourcingRule => ‘N’
, MassUpdateReleases => ‘N’
, RetroactivePriceChange => ‘N’
, OrgAssignChange => ‘N’
, CommunicatePriceChange => ‘N’
, p_Background_Flag => ‘N’
, p_Initiator => NULL
, p_xml_flag => NULL
, FpdsngFlag => ‘N’
, p_source_type_code => NULL);
commit;

DBMS_OUTPUT.PUT_LINE (‘The PO which is Approved Now =>’ p_rec.segment1);
END LOOP;
END;

— R12 – PO – SAMPLE SCRIPT TO APPROVE BLANKET PURCHASE AGREEMENT

DECLARE

v_item_key VARCHAR2(100);

Cursor c_po_details is
SELECT
pha.po_header_id,
pha.org_id,
pha.segment1,
pha.agent_id,
pdt.document_subtype,
pdt.document_type_code,
pha.authorization_status,
pha.approved_flag,
pha.wf_item_type,
pha.wf_item_key
FROM apps.po_headers_all pha, apps.po_document_types_all pdt
WHERE pha.type_lookup_code = pdt.document_subtype
AND pha.org_id = pdt.org_id
AND pdt.document_type_code = ‘PA’
AND authorization_status in (‘INCOMPLETE’, ‘REQUIRES REAPPROVAL’)
AND segment1 = ‘11170000021’; — Enter the BPA Number

BEGIN

fnd_global.apps_initialize (user_id => 2083,
resp_id => 20707,
resp_appl_id => 201);

FOR p_rec IN c_po_details

LOOP
mo_global.init (‘PO’);
mo_global.set_policy_context (‘S’, p_rec.org_id);

SELECT p_rec.po_header_id ‘-‘ to_char(po_wf_itemkey_s.NEXTVAL)
INTO v_item_key FROM dual;

dbms_output.put_line (‘Calling po_reqapproval_init1.start_wf_process for po_id=>’ p_rec.segment1);

po_reqapproval_init1.start_wf_process(
ItemType => ‘POAPPRV’
, ItemKey => v_item_key
, WorkflowProcess => ‘POAPPRV_TOP’
, ActionOriginatedFrom => ‘PO_FORM’
, DocumentID => p_rec.po_header_id — po_header_id
, DocumentNumber => p_rec.segment1 — Purchase Order Number
, PreparerID => p_rec.agent_id — Buer/Preparer_id
, DocumentTypeCode => p_rec.document_type_code–‘PA’
, DocumentSubtype => p_rec.document_subtype –‘BLANKET’
, SubmitterAction => ‘APPROVE’
, forwardToID => NULL
, forwardFromID => NULL
, DefaultApprovalPathID => NULL
, Note => NULL
, PrintFlag => ‘N’
, FaxFlag => ‘N’
, FaxNumber => NULL
, EmailFlag => ‘N’
, EmailAddress => NULL
, CreateSourcingRule => ‘N’
, ReleaseGenMethod => ‘N’
, UpdateSourcingRule => ‘N’
, MassUpdateReleases => ‘N’
, RetroactivePriceChange => ‘N’
, OrgAssignChange => ‘N’
, CommunicatePriceChange => ‘N’
, p_Background_Flag => ‘N’
, p_Initiator => NULL
, p_xml_flag => NULL
, FpdsngFlag => ‘N’
, p_source_type_code => NULL);
commit;
dbms_output.put_line (‘The BPA which is Approved Now =>’ p_rec.segment1);

END LOOP;
END;