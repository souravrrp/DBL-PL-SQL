/* Formatted on 1/13/2021 11:04:30 AM (QP5 v5.287) */
SELECT cil.*
  FROM xxdbl_comm_inv_headers cih, xxdbl_comm_inv_lines cil
 WHERE     1 = 1
       AND cih.comm_inv_header_id = cil.comm_inv_header_id
       --AND comm_inv_number IN ('eco/2019/CI000028')
       AND ( :p_ci_number IS NULL OR (cih.comm_inv_number = :p_ci_number))
       --AND ( :p_lc_number IS NULL OR (cih.ATTRIBUTE3 = :p_lc_number))
       AND ( :p_b2b_lc_number IS NULL OR (cih.attribute1 = :p_b2b_lc_number))
       AND ( :p_pi_number IS NULL OR (cil.pi_number = :p_pi_number));


--------------------------------------------------------------------------------

SELECT *
  FROM xxdbl_comm_inv_headers cih
 WHERE     1 = 1
       AND ( :p_ci_number IS NULL OR (cih.comm_inv_number = :p_ci_number))
       --and comm_inv_number in ('eco/2019/ci000028')
       and ( :p_lc_number is null or (cih.attribute3 = :p_lc_number))
       AND ( :p_b2b_lc_number IS NULL OR (cih.attribute1 = :p_b2b_lc_number));

SELECT *
  FROM xxdbl_comm_inv_lines cil
 WHERE     1 = 1
       AND EXISTS
              (SELECT 1
                 FROM xxdbl_comm_inv_headers cih
                WHERE     cih.comm_inv_header_id = cil.comm_inv_header_id
                      AND (   :p_ci_number IS NULL
                           OR (cih.comm_inv_number = :p_ci_number)))
       --and comm_inv_header_id is not null
       --and comm_inv_line_id is null
       AND ( :p_pi_number IS NULL OR (cil.pi_number = :p_pi_number));

SELECT * FROM apps.xxdbl_return_order_details;