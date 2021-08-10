 PLS ENTER THE PO_NUMBER HERE AND USE THE PO_HEADER_ID IN SQLS BELOW:

  SELECT PO_HEADER_ID
    FROM PO_HEADERS_ALL
   WHERE SEGMENT1 ='&PO_NUMBER';

 /*-----------------------------------------------------------------
      DATA FROM PO TABLES
 -------------------------------------------------------------------*/

 1. SELECT * FROM PO_HEADERS_ALL
    WHERE   PO_HEADER_ID  =&&PO_HEADER_ID

 2. SELECT * FROM PO_LINES_ALL
     WHERE   PO_HEADER_ID  =&&PO_HEADER_ID

 3. SELECT * FROM PO_LINE_LOCATIONS_ALL
    WHERE    PO_HEADER_ID  =&&PO_HEADER_ID

 4. SELECT * FROM PO_DISTRIBUTIONS_ALL
     WHERE   PO_HEADER_ID  =&&PO_HEADER_ID

 5. SELECT * FROM PO_RELEASES_ALL
    WHERE    PO_HEADER_ID =&&PO_HEADER_ID;

 /*-----------------------------------------------------------------
      DATA FROM RECEVING TABLES AND INVENTORY TABLES
 -------------------------------------------------------------------*/

 6. SELECT * FROM RCV_SHIPMENT_HEADERS
     WHERE    SHIPMENT_HEADER_ID     IN
     (SELECT SHIPMENT_HEADER_ID  FROM RCV_SHIPMENT_LINES
     WHERE PO_HEADER_ID       =&&PO_HEADER_ID );

 7. SELECT * FROM RCV_SHIPMENT_LINES
    WHERE PO_HEADER_ID       =&&PO_HEADER_ID;

 8. SELECT * FROM RCV_TRANSACTIONS
    WHERE    PO_HEADER_ID    =&&PO_HEADER_ID;

 9.  SELECT * FROM RCV_ACCOUNTING_EVENTS
     WHERE PO_HEADER_ID    =&&PO_HEADER_ID;

 10 SELECT * FROM RCV_RECEIVING_SUB_LEDGER
     WHERE RCV_TRANSACTION_ID IN
       (SELECT TRANSACTION_ID FROM RCV_TRANSACTIONS
         WHERE PO_HEADER_ID    =&&PO_HEADER_ID);

 11. SELECT * FROM RCV_SUB_LEDGER_DETAILS
     WHERE   RCV_TRANSACTION_ID IN
     (SELECT TRANSACTION_ID FROM RCV_TRANSACTIONS
      WHERE    PO_HEADER_ID    =&&PO_HEADER_ID);

 12. SELECT * FROM MTL_MATERIAL_TRANSACTIONS
     WHERE TRANSACTION_SOURCE_ID = &&PO_HEADER_ID
     UNION 
     SELECT * 
      FROM mtl_material_transactions 
     WHERE transaction_action_id = 24 
      AND trx_source_line_id IN 
         ( SELECT transaction_id FROM RCV_TRANSACTIONS
    WHERE    PO_HEADER_ID    =&&PO_HEADER_ID
     );

 13.SELECT * FROM MTL_TRANSACTION_ACCOUNTS
    WHERE TRANSACTION_ID IN
    ( SELECT TRANSACTION_ID FROM MTL_MATERIAL_TRANSACTIONS
       WHERE TRANSACTION_SOURCE_ID = &&PO_HEADER_ID )
    UNION 
    SELECT * 
     FROM MTL_TRANSACTION_ACCOUNTS
     WHERE TRANSACTION_ID IN
      (SELECT transaction_id 
        FROM mtl_material_transactions 
        WHERE transaction_action_id = 24
	  AND trx_source_line_id IN 
           ( SELECT transaction_id FROM RCV_TRANSACTIONS
             WHERE    PO_HEADER_ID    =&&PO_HEADER_ID
            )
       );

14. SELECT * 
      FROM mtl_cst_txn_cost_details 
     WHERE transaction_id IN 
         ( SELECT TRANSACTION_ID FROM MTL_MATERIAL_TRANSACTIONS
       WHERE TRANSACTION_SOURCE_ID = &&PO_HEADER_ID )
     UNION 
    SELECT * 
      FROM MTL_cst_txn_cost_details 
      WHERE TRANSACTION_ID IN
       (SELECT transaction_id 
          FROM mtl_material_transactions 
           WHERE transaction_action_id = 24
	      AND trx_source_line_id IN 
               ( SELECT transaction_id FROM RCV_TRANSACTIONS
                  WHERE    PO_HEADER_ID    =&&PO_HEADER_ID
                )
        );

15. SELECT * 
  FROM mtl_cst_actual_cost_details 
 WHERE transaction_id IN 
         ( SELECT TRANSACTION_ID FROM MTL_MATERIAL_TRANSACTIONS
       WHERE TRANSACTION_SOURCE_ID = &&PO_HEADER_ID )
    UNION 
   SELECT * 
FROM MTL_cst_actual_cost_details
    WHERE TRANSACTION_ID IN
(SELECT transaction_id 
      FROM mtl_material_transactions 
     WHERE transaction_action_id = 24
     AND trx_source_line_id IN 
         ( SELECT transaction_id FROM RCV_TRANSACTIONS
    WHERE    PO_HEADER_ID    =&&PO_HEADER_ID
     )
 );

16. SELECT * 
       FROM cst_lc_adj_transactions 
     WHERE rcv_transaction_id IN 
    ( SELECT transaction_id FROM RCV_TRANSACTIONS
    WHERE    PO_HEADER_ID    =&&PO_HEADER_ID
     );

17. SELECT * 
      FROM cst_lc_adj_interface 
     WHERE rcv_transaction_id IN 
    ( SELECT transaction_id FROM RCV_TRANSACTIONS
    WHERE    PO_HEADER_ID    =&&PO_HEADER_ID
     );
     
18. select * from cst_lc_adj_interface_errors
     where transaction_id in 
      ( SELECT transaction_id 
         FROM cst_lc_adj_interface 
         WHERE rcv_transaction_id IN 
              ( SELECT transaction_id FROM RCV_TRANSACTIONS
                  WHERE    PO_HEADER_ID    =&&PO_HEADER_ID
               )
        );      

19. SELECT * FROM AP_INVOICE_DISTRIBUTIONS_ALL
      WHERE PO_DISTRIBUTION_ID IN
          (SELECT PO_DISTRIBUTION_ID FROM PO_DISTRIBUTIONS_ALL
            WHERE PO_HEADER_ID  =&&PO_HEADER_ID );

20. SELECT * FROM AP_INVOICES_ALL
      WHERE INVOICE_ID IN
           (SELECT INVOICE_ID FROM AP_INVOICE_DISTRIBUTIONS_ALL
             WHERE PO_DISTRIBUTION_ID IN
             ( SELECT PO_DISTRIBUTION_ID FROM PO_DISTRIBUTIONS_ALL
                WHERE PO_HEADER_ID  =&&PO_HEADER_ID ));

21. SELECT XDL.*
      FROM XLA_DISTRIBUTION_LINKS          XDL
     WHERE XDL.SOURCE_DISTRIBUTION_ID_NUM_1
                IN (SELECT to_char(RRSL.RCV_SUB_LEDGER_ID)
                      FROM RCV_RECEIVING_SUB_LEDGER RRSL
                      WHERE RRSL.RCV_TRANSACTION_ID IN
                          (SELECT RT.TRANSACTION_ID
			    FROM RCV_TRANSACTIONS RT
                           WHERE RT.PO_HEADER_ID  = &&PO_HEADER_ID)
		    )
       AND SOURCE_DISTRIBUTION_TYPE = 'RCV_RECEIVING_SUB_LEDGER'
       AND APPLICATION_ID           = 707
     UNION
    SELECT XDL.*
      FROM XLA_DISTRIBUTION_LINKS          XDL
     WHERE XDL.SOURCE_DISTRIBUTION_ID_NUM_1
                IN ( select aida.invoice_distribution_id
		      from AP_INVOICE_DISTRIBUTIONS_ALL aida
                    WHERE aida.PO_DISTRIBUTION_ID IN
         (SELECT pod.PO_DISTRIBUTION_ID FROM PO_DISTRIBUTIONS_ALL pod
           WHERE pod.PO_HEADER_ID  =&&PO_HEADER_ID )
		    )
       AND APPLICATION_ID           = 200
     UNION 
     SELECT XDL.*
      FROM XLA_DISTRIBUTION_LINKS          XDL
     WHERE XDL.SOURCE_DISTRIBUTION_ID_NUM_1
                IN (SELECT to_char(MTA.INV_SUB_LEDGER_ID)
                      FROM mtl_transaction_accounts mta
                      WHERE TRANSACTION_ID IN
                 (SELECT transaction_id 
                   FROM mtl_material_transactions 
                  WHERE transaction_action_id = 24
		   AND trx_source_line_id IN 
                   ( SELECT transaction_id FROM RCV_TRANSACTIONS
                      WHERE    PO_HEADER_ID    =&&PO_HEADER_ID )
                    )
                  )
       AND SOURCE_DISTRIBUTION_TYPE = 'MTL_TRANSACTION_ACCOUNTS'
       AND APPLICATION_ID           = 707
      UNION
     SELECT XDL.*
      FROM XLA_DISTRIBUTION_LINKS          XDL
     WHERE XDL.SOURCE_DISTRIBUTION_ID_NUM_1
                IN (SELECT to_char(MTA.INV_SUB_LEDGER_ID)
                      FROM mtl_transaction_accounts mta
                      WHERE TRANSACTION_ID IN
                 (SELECT transaction_id 
                   FROM mtl_material_transactions 
                  WHERE rcv_transaction_id IN 
                   ( SELECT transaction_id FROM RCV_TRANSACTIONS
                      WHERE    PO_HEADER_ID    =&&PO_HEADER_ID )
                    )
                  )
       AND SOURCE_DISTRIBUTION_TYPE = 'MTL_TRANSACTION_ACCOUNTS'
       AND APPLICATION_ID           = 707;


22. SELECT XAH.*
     FROM XLA_AE_HEADERS                  XAH
    WHERE XAH.APPLICATION_ID           =707
      AND XAH.event_id IN 
      ( SELECT EV.event_id
      FROM APPS.XLA_TRANSACTION_ENTITIES_UPG  ENT,
           XLA_EVENTS                    EV
     WHERE ENT.APPLICATION_ID             = 707
       AND EV.APPLICATION_ID              = 707
       AND ENT.ENTITY_CODE                = 'RCV_ACCOUNTING_EVENTS'
       AND EV.ENTITY_ID                   = ENT.ENTITY_ID
       AND (NVL(ENT.SOURCE_ID_INT_1,'-99'),ENT.ledger_id) IN 
            (SELECT RT.TRANSACTION_ID,cav.ledger_id
		FROM RCV_TRANSACTIONS RT,
		     rcv_accounting_events rae,
		     cst_acct_info_v cav
             WHERE RT.PO_HEADER_ID  = &&PO_HEADER_ID
	       AND rae.organization_id = cav.organization_id
	       AND rae.rcv_transaction_id = rt.transaction_id)
      ) 
     UNION
     SELECT XAH.*
     FROM XLA_AE_HEADERS                  XAH
    WHERE XAH.APPLICATION_ID           =707
      AND XAH.event_id IN 
      ( SELECT EV.event_id
      FROM APPS.XLA_TRANSACTION_ENTITIES_UPG  ENT,
           XLA_EVENTS                    EV
     WHERE ENT.APPLICATION_ID             = 707
       AND EV.APPLICATION_ID              = 707
       AND ENT.ENTITY_CODE                = 'MTL_ACCOUNTING_EVENTS'
       AND EV.ENTITY_ID                   = ENT.ENTITY_ID
       AND (NVL(ENT.SOURCE_ID_INT_1,'-99'),ENT.ledger_id) IN 
            (SELECT mmt.TRANSACTION_ID,cav.ledger_id
		FROM RCV_TRANSACTIONS RT,
		     cst_acct_info_v cav,
		     mtl_material_transactions mmt
             WHERE RT.PO_HEADER_ID  = &&PO_HEADER_ID
	       AND mmt.organization_id = cav.organization_id
	       AND mmt.trx_source_line_id = rt.transaction_id
	       AND mmt.transaction_action_id = 24)
      ) 
      UNION
      SELECT XAH.*
     FROM XLA_AE_HEADERS                  XAH
    WHERE XAH.APPLICATION_ID           =707
      AND XAH.event_id IN 
      ( SELECT EV.event_id
      FROM APPS.XLA_TRANSACTION_ENTITIES_UPG  ENT,
           XLA_EVENTS                    EV
     WHERE ENT.APPLICATION_ID             = 707
       AND EV.APPLICATION_ID              = 707
       AND ENT.ENTITY_CODE                = 'MTL_ACCOUNTING_EVENTS'
       AND EV.ENTITY_ID                   = ENT.ENTITY_ID
       AND (NVL(ENT.SOURCE_ID_INT_1,'-99'),ENT.ledger_id) IN 
            (SELECT mmt.TRANSACTION_ID,cav.ledger_id
		FROM RCV_TRANSACTIONS RT,
		     cst_acct_info_v cav,
		     mtl_material_transactions mmt
             WHERE RT.PO_HEADER_ID  = &&PO_HEADER_ID
	       AND mmt.organization_id = cav.organization_id
	       AND mmt.rcv_transaction_id = rt.transaction_id)
      ) ;

23. SELECT xal.*
  FROM XLA_AE_LINES                    XAL
 WHERE XAL.APPLICATION_ID           =   707
   AND xal.AE_HEADER_ID  IN 
   ( SELECT XAH.ae_header_id
     FROM XLA_AE_HEADERS                  XAH
    WHERE XAH.APPLICATION_ID           =707
      AND XAH.event_id IN 
      ( SELECT EV.event_id
      FROM APPS.XLA_TRANSACTION_ENTITIES_UPG  ENT,
           XLA_EVENTS                    EV
     WHERE ENT.APPLICATION_ID             = 707
       AND EV.APPLICATION_ID              = 707
       AND ENT.ENTITY_CODE                = 'RCV_ACCOUNTING_EVENTS'
       AND EV.ENTITY_ID                   = ENT.ENTITY_ID
       AND (NVL(ENT.SOURCE_ID_INT_1,'-99'),ENT.ledger_id) IN 
            (SELECT RT.TRANSACTION_ID,cav.ledger_id
		FROM RCV_TRANSACTIONS RT,
		     rcv_accounting_events rae,
		     cst_acct_info_v cav
             WHERE RT.PO_HEADER_ID  = &&PO_HEADER_ID
	       AND rae.organization_id = cav.organization_id
	       AND rae.rcv_transaction_id = rt.transaction_id)
      ) 
    )
    UNION
    SELECT xal.*
  FROM XLA_AE_LINES                    XAL
 WHERE XAL.APPLICATION_ID           =   707
   AND xal.AE_HEADER_ID  IN 
   ( SELECT XAH.ae_header_id
     FROM XLA_AE_HEADERS                  XAH
    WHERE XAH.APPLICATION_ID           =707
      AND XAH.event_id IN 
      ( SELECT EV.event_id
      FROM APPS.XLA_TRANSACTION_ENTITIES_UPG  ENT,
           XLA_EVENTS                    EV
     WHERE ENT.APPLICATION_ID             = 707
       AND EV.APPLICATION_ID              = 707
       AND ENT.ENTITY_CODE                = 'MTL_ACCOUNTING_EVENTS'
       AND EV.ENTITY_ID                   = ENT.ENTITY_ID
       AND (NVL(ENT.SOURCE_ID_INT_1,'-99'),ENT.ledger_id) IN 
                        (SELECT mmt.TRANSACTION_ID,cav.ledger_id
		FROM RCV_TRANSACTIONS RT,
		     cst_acct_info_v cav,
		     mtl_material_transactions mmt
             WHERE RT.PO_HEADER_ID  = &&PO_HEADER_ID
	       AND mmt.organization_id = cav.organization_id
	       AND mmt.trx_source_line_id = rt.transaction_id
	       AND mmt.transaction_action_id = 24 )
      ) 
    )
   UNION
   SELECT xal.*
  FROM XLA_AE_LINES                    XAL
 WHERE XAL.APPLICATION_ID           =   707
   AND xal.AE_HEADER_ID  IN 
   ( SELECT XAH.ae_header_id
     FROM XLA_AE_HEADERS                  XAH
    WHERE XAH.APPLICATION_ID           =707
      AND XAH.event_id IN 
      ( SELECT EV.event_id
      FROM APPS.XLA_TRANSACTION_ENTITIES_UPG  ENT,
           XLA_EVENTS                    EV
     WHERE ENT.APPLICATION_ID             = 707
       AND EV.APPLICATION_ID              = 707
       AND ENT.ENTITY_CODE                = 'MTL_ACCOUNTING_EVENTS'
       AND EV.ENTITY_ID                   = ENT.ENTITY_ID
       AND (NVL(ENT.SOURCE_ID_INT_1,'-99'),ENT.ledger_id) IN 
                        (SELECT mmt.TRANSACTION_ID,cav.ledger_id
		FROM RCV_TRANSACTIONS RT,
		     cst_acct_info_v cav,
		     mtl_material_transactions mmt
             WHERE RT.PO_HEADER_ID  = &&PO_HEADER_ID
	       AND mmt.organization_id = cav.organization_id
	       AND mmt.rcv_transaction_id = rt.transaction_id)
      ) 
    );

24. SELECT ENT.*
      FROM APPS.XLA_TRANSACTION_ENTITIES_UPG  ENT,
           XLA_EVENTS                    EV
     WHERE ENT.APPLICATION_ID             = 707
       AND EV.APPLICATION_ID              = 707
       AND ENT.ENTITY_CODE                = 'RCV_ACCOUNTING_EVENTS'
       AND EV.ENTITY_ID                   = ENT.ENTITY_ID
       AND (NVL(ENT.SOURCE_ID_INT_1,'-99'),ENT.ledger_id) IN 
            (SELECT RT.TRANSACTION_ID,cav.ledger_id
		FROM RCV_TRANSACTIONS RT,
		     rcv_accounting_events rae,
		     cst_acct_info_v cav
             WHERE RT.PO_HEADER_ID  = &&PO_HEADER_ID
	       AND rae.organization_id = cav.organization_id
	       AND rae.rcv_transaction_id = rt.transaction_id)
     UNION 
     SELECT ENT.*
      FROM APPS.XLA_TRANSACTION_ENTITIES_UPG  ENT,
           XLA_EVENTS                    EV
     WHERE ENT.APPLICATION_ID             = 707
       AND EV.APPLICATION_ID              = 707
       AND ENT.ENTITY_CODE                = 'MTL_ACCOUNTING_EVENTS'
       AND EV.ENTITY_ID                   = ENT.ENTITY_ID
       AND (NVL(ENT.SOURCE_ID_INT_1,'-99'),ENT.ledger_id) IN 
                        (SELECT mmt.TRANSACTION_ID,cav.ledger_id
		FROM RCV_TRANSACTIONS RT,
		     cst_acct_info_v cav,
		     mtl_material_transactions mmt
             WHERE RT.PO_HEADER_ID  = &&PO_HEADER_ID
	       AND mmt.organization_id = cav.organization_id
	       AND mmt.trx_source_line_id = rt.transaction_id
	       AND mmt.transaction_action_id = 24 )
      UNION
      SELECT ENT.*
      FROM APPS.XLA_TRANSACTION_ENTITIES_UPG  ENT,
           XLA_EVENTS                    EV
     WHERE ENT.APPLICATION_ID             = 707
       AND EV.APPLICATION_ID              = 707
       AND ENT.ENTITY_CODE                = 'MTL_ACCOUNTING_EVENTS'
       AND EV.ENTITY_ID                   = ENT.ENTITY_ID
       AND (NVL(ENT.SOURCE_ID_INT_1,'-99'),ENT.ledger_id) IN 
                        (SELECT mmt.TRANSACTION_ID,cav.ledger_id
		FROM RCV_TRANSACTIONS RT,
		     cst_acct_info_v cav,
		     mtl_material_transactions mmt
             WHERE RT.PO_HEADER_ID  = &&PO_HEADER_ID
	       AND mmt.organization_id = cav.organization_id
	       AND mmt.rcv_transaction_id = rt.transaction_id);


25. SELECT EV.*
      FROM APPS.XLA_TRANSACTION_ENTITIES_UPG  ENT,
           XLA_EVENTS                    EV
     WHERE ENT.APPLICATION_ID             = 707
       AND EV.APPLICATION_ID              = 707
       AND ENT.ENTITY_CODE                = 'RCV_ACCOUNTING_EVENTS'
       AND EV.ENTITY_ID                   = ENT.ENTITY_ID
       AND (NVL(ENT.SOURCE_ID_INT_1,'-99'),ENT.ledger_id) IN 
            (SELECT RT.TRANSACTION_ID,cav.ledger_id
		FROM RCV_TRANSACTIONS RT,
		     rcv_accounting_events rae,
		     cst_acct_info_v cav
             WHERE RT.PO_HEADER_ID  = &&PO_HEADER_ID
	       AND rae.organization_id = cav.organization_id
	       AND rae.rcv_transaction_id = rt.transaction_id)
     UNION
      SELECT EV.*
      FROM APPS.XLA_TRANSACTION_ENTITIES_UPG  ENT,
           XLA_EVENTS                    EV
     WHERE ENT.APPLICATION_ID             = 707
       AND EV.APPLICATION_ID              = 707
       AND ENT.ENTITY_CODE                = 'MTL_ACCOUNTING_EVENTS'
       AND EV.ENTITY_ID                   = ENT.ENTITY_ID
       AND (NVL(ENT.SOURCE_ID_INT_1,'-99'),ENT.ledger_id) IN 
                        (SELECT mmt.TRANSACTION_ID,cav.ledger_id
		FROM RCV_TRANSACTIONS RT,
		     cst_acct_info_v cav,
		     mtl_material_transactions mmt
             WHERE RT.PO_HEADER_ID  = &&PO_HEADER_ID
	       AND mmt.organization_id = cav.organization_id
	       AND mmt.trx_source_line_id = rt.transaction_id
	       AND mmt.transaction_action_id = 24 )
      UNION
       SELECT EV.*
      FROM APPS.XLA_TRANSACTION_ENTITIES_UPG  ENT,
           XLA_EVENTS                    EV
     WHERE ENT.APPLICATION_ID             = 707
       AND EV.APPLICATION_ID              = 707
       AND ENT.ENTITY_CODE                = 'MTL_ACCOUNTING_EVENTS'
       AND EV.ENTITY_ID                   = ENT.ENTITY_ID
       AND (NVL(ENT.SOURCE_ID_INT_1,'-99'),ENT.ledger_id) IN 
                        (SELECT mmt.TRANSACTION_ID,cav.ledger_id
		FROM RCV_TRANSACTIONS RT,
		     cst_acct_info_v cav,
		     mtl_material_transactions mmt
             WHERE RT.PO_HEADER_ID  = &&PO_HEADER_ID
	       AND mmt.organization_id = cav.organization_id
	       AND mmt.rcv_transaction_id = rt.transaction_id);