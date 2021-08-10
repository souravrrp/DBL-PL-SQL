/* Formatted on 8/5/2020 12:52:44 PM (QP5 v5.287) */
SELECT ORDER_BOOKED_ID,
       PHONE_NUMBER,
       --('Cus. No = ' + CUSTOMER_NUMBER + ', Cus. Name = ' + CUSTOMER_NAME+ ', Order No = ' + Cast(ORDER_NUMBER As Varchar(100)) + ', Order Qty = '+ Cast(ORDERED_QUANTITY As Varchar(100))+ ', UOM = ' + UOM + ',  Amount = '+ Cast(AMOUNT As Varchar(100))+ ', Booked Date = ' + Replace(Convert(varchar, BOOKED_DATE, 106),' ','-')) As SMSMessage

       (  'Dear Sir, Your order is confirmed.'
        + ' No='
        + CAST (ORDER_NUMBER AS VARCHAR (100))
        + ', Qty.= '
        + CAST (ORDERED_QUANTITY AS VARCHAR (100))
        + ', '
        + UOM
        + ', Total= '
        + CAST (AMOUNT AS VARCHAR (100))
        + '(BDT), Conf. Date= '
        + REPLACE (CONVERT (varchar, BOOKED_DATE, 106),' ','-')+', Regards, DBL Ceramics')As SMSMessage

                    From DCL_Order_Booked
                    where IS_SMSSend = 0 AND ORDER_BOOKED_ID = '" + dtSelect.Rows[j]["ORDER_BOOKED_ID"].ToString() + @"'