/* Formatted on 8/27/2020 5:40:34 PM (QP5 v5.287) */
PROCEDURE kf_nom_dsr_req_amt_dtls (document_id     IN            VARCHAR2,
                                   display_type    IN            VARCHAR2,
                                   document        IN OUT NOCOPY CLOB,
                                   document_type   IN OUT NOCOPY VARCHAR2)
IS
   CURSOR C_NOM_EMP_DTLS (
      C_NOM_REQ_ID    NUMBER)
   IS
      SELECT PAPF.PERSON_ID, PAPF.employee_number, PAPF.full_name
        FROM PER_ALL_PEOPLE_F PAPF, XXKFUPM01.KF_HR_BS_NOM_EMP_DTLS NOM_EMP
       WHERE     PAPF.EMPLOYEE_NUMBER = NOM_EMP.EMPLOYEE_NUMBER
             AND NOM_EMP.BS_TRIP_NOM_REQ_ID = C_NOM_REQ_ID
             AND TRUNC (SYSDATE) BETWEEN PAPF.EFFECTIVE_START_DATE
                                     AND PAPF.EFFECTIVE_END_DATE;

   L_DOCUMENT           VARCHAR2 (6000) := '';
   P_ITEMTYPE           VARCHAR2 (100) := 'KF_BT_NM';
   P_ITEMKEY            NUMBER := document_id;
   L_NM_PROJECT_ID      NUMBER;
   L_NM_REQUEST_ID      NUMBER;
   L_VC_PER_DIEM_TYPE   VARCHAR2 (100);
   L_NM_TRAVEL_DAYS     NUMBER;
   L_NM_TRAVEL_AMT      NUMBER;
   L_NM_REQUESTED_AMT   NUMBER;
   L_NM_MISC_AMT        NUMBER;
BEGIN
   L_NM_PROJECT_ID :=
      WF_ENGINE.GETITEMATTRNUMBER (ITEMTYPE   => P_ITEMTYPE,
                                   ITEMKEY    => P_ITEMKEY,
                                   ANAME      => 'PROJECT_ID');
   L_NM_REQUEST_ID :=
      WF_ENGINE.GETITEMATTRNUMBER (ITEMTYPE   => P_ITEMTYPE,
                                   ITEMKEY    => P_ITEMKEY,
                                   ANAME      => 'KF_REQUEST_ID');
   L_VC_PER_DIEM_TYPE :=
      wf_engine.getitemattrtext (ITEMTYPE   => P_ITEMTYPE,
                                 ITEMKEY    => P_ITEMKEY,
                                 ANAME      => 'KF_PA_SSO_A_PER_DIEM_TYPE');
   L_NM_TRAVEL_AMT :=
      WF_ENGINE.GETITEMATTRNUMBER (
         ITEMTYPE   => P_ITEMTYPE,
         ITEMKEY    => P_ITEMKEY,
         ANAME      => 'KF_PA_DSR_CORRECTED_TRAVEL_AMT');
   L_NM_MISC_AMT :=
      WF_ENGINE.GETITEMATTRNUMBER (
         ITEMTYPE   => P_ITEMTYPE,
         ITEMKEY    => P_ITEMKEY,
         ANAME      => 'KF_PA_DSR_CORRECTED_MISC_AMT');
   L_NM_TRAVEL_DAYS :=
      WF_ENGINE.GETITEMATTRNUMBER (ITEMTYPE   => P_ITEMTYPE,
                                   ITEMKEY    => P_ITEMKEY,
                                   ANAME      => 'KF_PA_DSR_CO_A_DAYS');
   -- Project Budget, Actual and Commitment Details: --
   L_DOCUMENT := L_DOCUMENT || '<font size="4"><table border="1"><tr>';
   L_DOCUMENT := L_DOCUMENT || '<th align="center"> Emplyoee Name</th>';
   L_DOCUMENT := L_DOCUMENT || '<th align="center"> Expenditure Type</th>';

   L_DOCUMENT := L_DOCUMENT || '
                          <th align="center"> Requested Amount </th>';

   L_DOCUMENT := L_DOCUMENT || '</tr>';
   wf_notification.writetoclob (document, L_DOCUMENT);
   L_DOCUMENT := '';

   FOR I IN C_NOM_EMP_DTLS (L_NM_REQUEST_ID)
   LOOP
      L_NM_REQUESTED_AMT :=
           NVL (L_NM_TRAVEL_DAYS, 0)
         * NVL (
              APPS.KF_PA_PROJECT_DETAILS_PKG.KF_PA_PERDIEM_RATE_F (
                 L_NM_PROJECT_ID,
                 I.PERSON_ID,
                 L_VC_PER_DIEM_TYPE),
              0);
      L_NM_REQUESTED_AMT := L_NM_REQUESTED_AMT + NVL (L_NM_MISC_AMT, 0);
      L_DOCUMENT := L_DOCUMENT || '<TR>';
      L_DOCUMENT := L_DOCUMENT || '<TD>' || I.FULL_NAME || '</TD>';
      L_DOCUMENT := L_DOCUMENT || '<TD>Per Diem </TD>';
      L_DOCUMENT :=
         L_DOCUMENT || '<TD>' || NVL (L_NM_REQUESTED_AMT, 0) || '</TD>';
      L_DOCUMENT := L_DOCUMENT || '</TR>';
      L_DOCUMENT := L_DOCUMENT || '<TR>';
      L_DOCUMENT := L_DOCUMENT || '<TD>' || I.FULL_NAME || '</TD>';
      L_DOCUMENT := L_DOCUMENT || '<TD>Travel </TD>';
      L_DOCUMENT :=
         L_DOCUMENT || '<TD>' || NVL (L_NM_TRAVEL_AMT, 0) || '</TD>';
      L_DOCUMENT := L_DOCUMENT || '</TR>';

      wf_notification.writetoclob (document, L_DOCUMENT);
      L_DOCUMENT := '';
   END LOOP;

   L_DOCUMENT := L_DOCUMENT || '</table>';

   L_DOCUMENT := L_DOCUMENT || '
                          </font>';
   wf_notification.writetoclob (document, L_DOCUMENT);
   L_DOCUMENT := '';
END kf_nom_dsr_req_amt_dtls;