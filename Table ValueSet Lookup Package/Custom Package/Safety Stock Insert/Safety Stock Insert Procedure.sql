/* Formatted on 10/29/2020 10:22:31 AM (QP5 v5.287) */
SELECT mss.safety_stock_quantity,mss.*
  FROM mtl_safety_stocks mss
  
  
  BEGIN
        MTL_SAFETY_STOCKS_PKG.INSERT_SAFETY_STOCKS( l_org_id--org_id NUMBER,
                                                   ,l_item_id--item_id NUMBER,
                                                   ,null--ss_code NUMBER,
                                                   ,null--forc_name VARCHAR2,
                                                   ,null--ss_percent NUMBER,
                                                   ,null--srv_level NUMBER,
                                                   ,effectivity_date--ss_date DATE,
                                                   ,Safety_Stock_Quantity--ss_qty NUMBER,
                                                   ,null--login_id NUMBER,
                                                   ,fnd_global.user_id --user_id NUMBER)
                                                   );
        dbms_output.put_line('l_item_id');                                              
        dbms_output.put_line('l_org_id');
        END;
