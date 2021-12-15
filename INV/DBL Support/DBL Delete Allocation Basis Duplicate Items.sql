/* Formatted on 12/14/2021 3:01:15 PM (QP5 v5.374) */
------------------------------------all duplicate rows--------------------------

SELECT alloc_code, COUNT (a.line_no) no_of_line
    FROM gl_aloc_bas a, apps.mtl_system_items_kfv b, gl_aloc_mst c
   WHERE     a.inventory_item_id = b.inventory_item_id
         AND a.organization_id = b.organization_id
         AND a.organization_id = 150
         AND a.alloc_id = c.alloc_id
         --AND alloc_code = :p_alloc_code                    --'FD-DEPRECIATION'
         AND ( :p_alloc_code IS NULL OR (alloc_code = UPPER ( :p_alloc_code)))
         --AND alloc_code LIKE 'FD-DEPRECIATION%'
         --AND concatenated_segments LIKE 'NATFCOT0100S-95521%'
         AND a.line_no NOT IN
                 (  SELECT MIN (LINE_NO)
                      FROM gl_aloc_bas            a,
                           apps.mtl_system_items_kfv b,
                           gl_aloc_mst            c
                     WHERE     a.inventory_item_id = b.inventory_item_id
                           AND a.organization_id = b.organization_id
                           AND a.organization_id = 150
                           AND a.alloc_id = c.alloc_id
                           --AND alloc_code = :p_alloc_code  --'FD-DEPRECIATION'
                           AND ( :p_alloc_code IS NULL OR (alloc_code = UPPER ( :p_alloc_code)))
                           --AND alloc_code LIKE 'FD-DEPRECIATION%'
                           --AND concatenated_segments LIKE 'NATFCOT0100S-95521%'
                           AND a.delete_mark = 0
                  GROUP BY row_id)
         AND a.delete_mark = 0
GROUP BY alloc_code;


----------------------------------delete script---------------------------------

DELETE FROM
    gl_aloc_bas aaa
      WHERE EXISTS
                (SELECT 1
                   FROM gl_aloc_bas                a,
                        apps.mtl_system_items_kfv  b,
                        gl_aloc_mst                c
                  WHERE     a.inventory_item_id = b.inventory_item_id
                        AND a.organization_id = b.organization_id
                        AND a.organization_id = 150
                        AND a.alloc_id = c.alloc_id
                        AND alloc_code = :p_alloc_code     --'FD-DEPRECIATION'
                        AND aaa.line_no = a.line_no
                        AND aaa.alloc_id = a.alloc_id
                        AND a.line_no NOT IN
                                (  SELECT MIN (LINE_NO)
                                     FROM gl_aloc_bas              a,
                                          apps.mtl_system_items_kfv b,
                                          gl_aloc_mst              c
                                    WHERE     a.inventory_item_id =
                                              b.inventory_item_id
                                          AND a.organization_id =
                                              b.organization_id
                                          AND a.organization_id = 150
                                          AND a.alloc_id = c.alloc_id
                                          AND alloc_code = :p_alloc_code --'FD-DEPRECIATION'
                                          AND a.delete_mark = 0
                                 GROUP BY row_id)
                        AND a.delete_mark = 0);

--------------------------No of Duplicate rows----------------------------------

  SELECT row_id,
         alloc_code,
         concatenated_segments,
         COUNT (concatenated_segments)     no_of_segments
    FROM gl_aloc_bas a, apps.mtl_system_items_kfv b, gl_aloc_mst c
   WHERE     a.inventory_item_id = b.inventory_item_id
         AND a.organization_id = b.organization_id
         AND a.organization_id = 150
         AND a.alloc_id = c.alloc_id
         --and alloc_code = :p_alloc_code
         --AND alloc_code LIKE 'FD-DEPRECIATION%' --'ST-DEPRECIATION' -- 'YD-DEPRECIATION%'
         --and concatenated_segments like 'ft%'
         AND a.delete_mark = 0
GROUP BY row_id, alloc_code, concatenated_segments
  HAVING COUNT (concatenated_segments) > 1;

--------------------------minimum rows------------------------------------------

  SELECT MIN (a.line_no), row_id
    FROM gl_aloc_bas a, apps.mtl_system_items_kfv b, gl_aloc_mst c
   WHERE     a.inventory_item_id = b.inventory_item_id
         AND a.organization_id = b.organization_id
         AND a.organization_id = 150
         AND a.alloc_id = c.alloc_id
         AND alloc_code LIKE 'FD-DEPRECIATION%'
         AND concatenated_segments LIKE 'NATFCOT0100S-95521%'
         AND a.delete_mark = 0
GROUP BY row_id;