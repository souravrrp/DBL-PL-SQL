/* Formatted on 1/30/2021 5:08:09 PM (QP5 v5.354) */
CREATE OR REPLACE FUNCTION XXDBL.xxdbl_fnc_get_item_cost (
    P_ORG      NUMBER,
    P_ITEM     NUMBER,
    P_PERIOD   VARCHAR2)
    RETURN NUMBER
IS
    v_txn_cst   NUMBER (15, 5);
    v_prd_cst   NUMBER (15, 5);
    v_opm       VARCHAR2 (2);
BEGIN
    -- CREATED BY : MD. ABDUL MAJID
    -- CREATION DATE : 01-feb-2012
    -- LAST UPDATE DATE :30-JAN-2020
    -- PURPOSE : CALCULATING ITEM COST BASED ON ORGANIZATION AND PERIOD
    -- CHANGE IMPACT : CHNAGE MAY IMPACT   MANY REPORT RELATED TO ITEM COST
    SELECT PROCESS_ENABLED_FLAG
      INTO V_OPM
      FROM INV.MTL_PARAMETERS
     WHERE ORGANIZATION_ID = P_ORG;

    IF V_OPM = 'N'                  --added  02-jan- 2014  fro CST org Costing
    THEN
        SELECT NVL (item_cost, 0)
          INTO v_prd_cst
          FROM apps.CST_ITEM_COST_DETAILS_V cst
         WHERE inventory_item_id = p_item AND organization_id = p_org;
    ELSE
        SELECT COST
          INTO v_prd_cst
          FROM (SELECT COUNT (ccd.inventory_item_id)     inventory_item_id,
                       SUM (ccd.cmpnt_cost)              cost
                  FROM APPS.cm_cldr_mst_v  ccm,
                       APPS.cm_cmpt_dtl    ccd,
                       APPS.cm_cldr_dtl    gp
                 WHERE     ccd.period_id = ccm.period_id
                       AND TO_CHAR (TO_DATE (gp.period_desc, 'MON-YY'),
                                    'MON-YY') =
                           P_PERIOD --UPDATE BY SOURAV ON 30-JAN-20 FOR PREVIOUS MONTH COST
                       --AND gp.calendar_code = ('DBLCOSTCAL' || TO_CHAR (TO_DATE (P_PERIOD, 'MON-YY'), 'YYYY'))
                       AND TO_CHAR (TO_DATE (ccm.period_desc, 'MON-YY'),
                                    'MON-YY') =
                           TO_CHAR (TO_DATE (gp.period_desc, 'MON-YY'),
                                    'MON-YY')
                       AND ccd.inventory_item_id = P_item
                       AND ccd.organization_id = P_org
                       AND TO_CHAR (TO_DATE (ccm.period_desc, 'MON-YY'),
                                    'MON-YY') =
                           P_period);
    END IF;

    IF v_prd_cst IS NULL
    THEN
        SELECT SUM (ccd.cmpnt_cost)
          INTO v_txn_cst
          FROM APPS.cm_cldr_mst_v ccm, APPS.cm_cmpt_dtl ccd
         WHERE     ccd.period_id = ccm.period_id
               AND ccd.inventory_item_id = P_item
               AND ccd.organization_id = P_org
               AND ccm.period_id =
                   (SELECT MAX (period_id)
                      FROM APPS.cm_cmpt_dtl
                     WHERE     inventory_item_id = P_item
                           AND organization_id = P_org);

        IF v_txn_cst IS NULL
        THEN
            SELECT   SUM (
                           rt.po_unit_price
                         * RT.QUANTITY
                         * currency_conversion_rate)
                   / SUM (RT.QUANTITY)
              INTO v_txn_cst
              FROM APPS.rcv_transactions  rt,
                   APPS.po_headers_all    ph,
                   APPS.po_lines_all      pla
             WHERE     rt.po_header_id = ph.po_header_id
                   AND ph.po_header_id = pla.po_header_id
                   AND rt.po_header_id = pla.po_header_id
                   AND rt.po_line_id = pla.po_line_id
                   AND pla.item_id = p_item
                   AND rt.organization_id = p_org
                   AND rt.transaction_type = 'DELIVER'
                   AND TO_CHAR (TO_DATE (TRUNC (rt.transaction_date)),
                                'MON-RR') =
                       P_PERIOD;
        END IF;
    ELSIF v_prd_cst IS NOT NULL
    THEN
        v_txn_cst := v_prd_cst;
    END IF;

    RETURN (v_txn_cst);
EXCEPTION
    WHEN OTHERS
    THEN
        RETURN (NULL);
END;
/