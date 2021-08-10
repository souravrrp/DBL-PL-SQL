SELECT   order_number, header_id
    FROM (SELECT *
            FROM (SELECT order_number, order_id header_id, order_line_id
                    FROM xxdbl_bs_main_order_line_v
                   WHERE 1 = 1
                     AND sold_to_org_id = :xxdbl_bill_stat_headers.customer_id
                     AND :xxdbl_bill_stat_headers.bill_stat_status = 'NEW'
                  UNION ALL
                  SELECT order_number, order_id header_id, order_line_id
                    FROM xxdbl_bs_return_order_line_v
                   WHERE 1 = 1
                     AND sold_to_org_id = :xxdbl_bill_stat_headers.customer_id
                     AND :xxdbl_bill_stat_headers.bill_stat_status NOT IN
                                                         ('NEW', 'CANCELLED'))
           WHERE 1 = 1
             AND EXISTS (
                    SELECT 'X'
                      FROM DUAL
                     WHERE xxdbl_shiping_tran_crp_pkg.get_split_line_exists
                                                                (header_id,
                                                                 order_line_id
                                                                ) = 0))
GROUP BY order_number, header_id
ORDER BY order_number, header_id