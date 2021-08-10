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
    WHERE TRANSACTION_SOURCE_ID = &&PO_HEADER_ID;

13.SELECT * FROM MTL_TRANSACTION_ACCOUNTS
   WHERE TRANSACTION_ID IN
   ( SELECT TRANSACTION_ID FROM MTL_MATERIAL_TRANSACTIONS
      WHERE TRANSACTION_SOURCE_ID = &&PO_HEADER_ID )

14. SELECT * FROM AP_INVOICE_DISTRIBUTIONS_ALL
     WHERE PO_DISTRIBUTION_ID IN
         (SELECT PO_DISTRIBUTION_ID FROM PO_DISTRIBUTIONS_ALL
           WHERE PO_HEADER_ID  =&&PO_HEADER_ID );

15. SELECT * FROM AP_INVOICES_ALL
     WHERE INVOICE_ID IN
          (SELECT INVOICE_ID FROM AP_INVOICE_DISTRIBUTIONS_ALL
            WHERE PO_DISTRIBUTION_ID IN
            ( SELECT PO_DISTRIBUTION_ID FROM PO_DISTRIBUTIONS_ALL
               WHERE PO_HEADER_ID  =&&PO_HEADER_ID ));


/* --------------------------------------------------------------------
FOR ALL QUERIES FOLLOWING THIS PLS PICK UP THE ORG_ID FROM

SELECT ORG_ID FROM PO_HEADERS_ALL
WHERE PO_HEADER_ID = &PO_HEADER_ID;

AND USE THIS AS INPUT TO ALL QUERIES FOLLOWING WHERE EVER REQUIRED
--------------------------------------------------------------------*/

16. SELECT *
      FROM CST_RECONCILIATION_SUMMARY CRS
     WHERE CRS.OPERATING_UNIT_ID  = &org_id
       AND CRS.PO_DISTRIBUTION_ID in ( select pod.po_distribution_id
                                         from po_distributions_all pod
				      where pod.PO_HEADER_ID  =&&PO_HEADER_ID
                                      );

17. select *
      from po_accrual_write_offs_all
    where po_distribution_id in ( select pod.po_distribution_id
                                         from po_distributions_all pod
				      where pod.PO_HEADER_ID  =&&PO_HEADER_ID
                                      );

18. select *
      from cst_write_offs
      where po_distribution_id in ( select pod.po_distribution_id
                                         from po_distributions_all pod
				      where pod.PO_HEADER_ID  =&&PO_HEADER_ID
                                      );

19. SELECT *
      FROM CST_ACCRUAL_ACCOUNTS    CAA
     WHERE CAA.OPERATING_UNIT_ID   =&ORG_ID;

20. SELECT * FROM FINANCIALS_SYSTEM_PARAMS_ALL  FSP
     WHERE ORG_ID   =&ORG_ID;

21. SELECT *
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
       AND APPLICATION_ID           = 707 ;

22.SELECT XAH.GL_TRANSFER_STATUS_CODE,XAH.*
     FROM XLA_AE_HEADERS                  XAH
    WHERE XAH.APPLICATION_ID           =707
      AND AE_HEADER_ID   in (SELECT XDL.ae_header_id
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
     SELECT XDL.ae_header_id
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
       AND APPLICATION_ID           = 707
      )

23.SELECT *
  FROM XLA_AE_LINES                    XAL
 WHERE XAL.APPLICATION_ID           =   707
   AND AE_HEADER_ID    in (SELECT XDL.ae_header_id
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
     SELECT XDL.ae_header_id
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
       AND APPLICATION_ID           = 707
      )


24. SELECT ENT.*
      FROM XLA_TRANSACTION_ENTITIES_UPG  ENT,
           XLA_EVENTS                    EV,
           XLA_DISTRIBUTION_LINKS        A,
           RCV_RECEIVING_SUB_LEDGER      B
     WHERE A.APPLICATION_ID               = 707
       AND ENT.APPLICATION_ID             = 707
       AND EV.APPLICATION_ID              = 707
       AND ENT.ENTITY_CODE                = 'RCV_ACCOUNTING_EVENTS'
       AND ENT.LEDGER_ID                  = &ledger_id
       AND EV.ENTITY_ID                   = ENT.ENTITY_ID
       AND EV.EVENT_ID                    = A.EVENT_ID
       AND A.SOURCE_DISTRIBUTION_TYPE     = 'RCV_RECEIVING_SUB_LEDGER'
       AND ENT.SOURCE_ID_INT_1            = B.RCV_TRANSACTION_ID
       AND A.SOURCE_DISTRIBUTION_ID_NUM_1 = B.RCV_SUB_LEDGER_ID
       AND B.RCV_TRANSACTION_ID  IN (SELECT RT.TRANSACTION_ID
			    FROM RCV_TRANSACTIONS RT
                           WHERE RT.PO_HEADER_ID  = &&PO_HEADER_ID)


25. SELECT EV.*
      FROM XLA_TRANSACTION_ENTITIES_UPG  ENT,
           XLA_EVENTS                    EV,
           XLA_DISTRIBUTION_LINKS        A,
           RCV_RECEIVING_SUB_LEDGER      B
     WHERE A.APPLICATION_ID               = 707
       AND ENT.APPLICATION_ID             = 707
       AND EV.APPLICATION_ID              = 707
       AND ENT.ENTITY_CODE                = 'RCV_ACCOUNTING_EVENTS'
       AND ENT.LEDGER_ID                  = &ledger_id
       AND EV.ENTITY_ID                   = ENT.ENTITY_ID
       AND EV.EVENT_ID                    = A.EVENT_ID
       AND A.SOURCE_DISTRIBUTION_TYPE     = 'RCV_RECEIVING_SUB_LEDGER'
       AND ENT.SOURCE_ID_INT_1            = B.RCV_TRANSACTION_ID
       AND A.SOURCE_DISTRIBUTION_ID_NUM_1 = B.RCV_SUB_LEDGER_ID
       AND B.RCV_TRANSACTION_ID           IN (SELECT RT.TRANSACTION_ID
			    FROM RCV_TRANSACTIONS RT
                           WHERE RT.PO_HEADER_ID  = &&PO_HEADER_ID)

26. SELECT *
      FROM XLA_DISTRIBUTION_LINKS          XDL
     WHERE XDL.SOURCE_DISTRIBUTION_ID_NUM_1
                IN ( select aida.invoice_distribution_id
		      from AP_INVOICE_DISTRIBUTIONS_ALL aida
                    WHERE aida.PO_DISTRIBUTION_ID IN
         (SELECT pod.PO_DISTRIBUTION_ID FROM PO_DISTRIBUTIONS_ALL pod
           WHERE pod.PO_HEADER_ID  =&&PO_HEADER_ID )
		    )
       AND APPLICATION_ID           = 200
       AND SOURCE_DISTRIBUTION_TYPE in ('AP_INV_DIST','AP_PMT_DIST','AP_PREPAY');

27. SELECT XAH.GL_TRANSFER_STATUS_CODE,XAH.*
     FROM XLA_AE_HEADERS                  XAH
    WHERE XAH.APPLICATION_ID           =200
      AND AE_HEADER_ID in (SELECT XDL.ae_header_id
      FROM XLA_DISTRIBUTION_LINKS          XDL
     WHERE XDL.SOURCE_DISTRIBUTION_ID_NUM_1
                IN ( select aida.invoice_distribution_id
		      from AP_INVOICE_DISTRIBUTIONS_ALL aida
                    WHERE aida.PO_DISTRIBUTION_ID IN
         (SELECT pod.PO_DISTRIBUTION_ID FROM PO_DISTRIBUTIONS_ALL pod
           WHERE pod.PO_HEADER_ID  =&&PO_HEADER_ID )
		    )
       AND APPLICATION_ID           = 200
       AND SOURCE_DISTRIBUTION_TYPE in ('AP_INV_DIST','AP_PMT_DIST','AP_PREPAY')
      )

28. SELECT *
  FROM XLA_AE_LINES                    XAL
 WHERE XAL.APPLICATION_ID           =   200
   AND AE_HEADER_ID  in (SELECT XDL.ae_header_id
      FROM XLA_DISTRIBUTION_LINKS          XDL
     WHERE XDL.SOURCE_DISTRIBUTION_ID_NUM_1
                IN ( select aida.invoice_distribution_id
		      from AP_INVOICE_DISTRIBUTIONS_ALL aida
                    WHERE aida.PO_DISTRIBUTION_ID IN
         (SELECT pod.PO_DISTRIBUTION_ID FROM PO_DISTRIBUTIONS_ALL pod
           WHERE pod.PO_HEADER_ID  =&&PO_HEADER_ID )
		    )
       AND APPLICATION_ID           = 200
       AND SOURCE_DISTRIBUTION_TYPE in ('AP_INV_DIST','AP_PMT_DIST','AP_PREPAY')
      )
