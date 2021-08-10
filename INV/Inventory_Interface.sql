/* Formatted on 10/3/2020 2:37:44 PM (QP5 v5.287) */
-------------------------------------------------------------------------------
-----------------------------(Material Transactions)

SELECT * FROM MTL_TRANSACTIONS_INTERFACE;



-------------------------------(IF Lots ARE used)

SELECT * FROM APPS.MTL_TRANSACTIONS_LOT_INTERFACE;



-------------------------------(IF Serial Nos. ARE used)

SELECT * FROM MTL_SERIAL_NUMBERS_INTERFACE;



---------------------------------(Material Reservations)

SELECT * FROM MTL_RESERVATIONS_INTERFACE;



---------------------------------(PO Receiving transactions)

  SELECT *
    FROM RCV_TRANSACTIONS_INTERFACE
ORDER BY CREATION_DATE DESC;



-------------------------------(Discrete Jobs )

SELECT * FROM WIP_JOB_SCHEDULE_INTERFACE;



-------------------------------(Discrete JOB Details)

SELECT * FROM WIP_JOB_DTLS_INTERFACE;



---------------------------------(WIP MOVE transactions INTERFACE)

SELECT * FROM WIP_MOVE_TXN_INTERFACE;



--------------------------------(WIP MOVE transactions INTERFACE)

SELECT * FROM WIP_SERIAL_MOVE_INTERFACE;



-------------------------------(IF Serial Nos. ARE used)

SELECT * FROM WIP_SERIAL_MOVE_INTERFACE;



-------------------------------(WIP RESOURCE TRANSACTION INTERFACE)

SELECT * FROM WIP_TIME_ENTRY_INTERFACE;



-------------------------------(IN CASE OF Average COST UPDATE transactions)

SELECT * FROM MTL_TXN_COST_DET_INTERFACE;