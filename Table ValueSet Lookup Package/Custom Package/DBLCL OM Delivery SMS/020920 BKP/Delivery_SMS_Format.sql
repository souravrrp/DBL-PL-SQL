Select ORDER_DELIVERY_ID, PHONE_NUMBER, 
                    --('Challan No = ' + DELIVERY_CHALLAN_NUMBER + ', Order No = ' + ORDER_NUMBER+ ', CTN = '+ Cast(SECONDARY_QUANTITY_CTN As Varchar(100)) + ', SFT = '+ Cast(PRIMARY_QUANTITY_SFT As Varchar(100))+ ', Driver Name = '+ DRIVER_NAME
                    --+ ', Driver Cont No = '+ DRIVER_CONTACT_NO + ', Delivery Date = ' + Replace(Convert(varchar, CONFIRM_DATE, 106),' ','-')) As SMSMessage                    

                    --('Dear Sir, Your order is delivered.' + ' No=' + Cast(ORDER_NUMBER As Varchar(100)) +', '+ Cast(PRIMARY_QUANTITY_SFT As Varchar(100))+ ', Cha. No= ' + DELIVERY_CHALLAN_NUMBER + ', Driver Name= '+ DRIVER_NAME +', No= '+ DRIVER_CONTACT_NO + ', Del. Date= ' + Replace(Convert(varchar, CONFIRM_DATE, 106),' ','-')+', Regards, DBL Ceramics') As SMSMessage

('Dear Sir, Your order is delivered.' + ' No=' + Cast(ORDER_NUMBER As Varchar(100)) +', '+ Cast(PRIMARY_QUANTITY_SFT As Varchar(100))+ ', Driver Name= '+ DRIVER_NAME +', No= '+ DRIVER_CONTACT_NO + ', Veh. No= '+ VEHICLE_NO + ', Del. Date= ' + Replace(Convert(varchar, CONFIRM_DATE, 106),' ','-')+', Regards, DBL Ceramics') As SMSMessage

                    From DCL_Order_Delivery 
                    where IS_SMSSend = 0 AND ORDER_DELIVERY_ID = '" + dtSelect.Rows[j]["ORDER_DELIVERY_ID"].ToString() + @"'
                    --AND DELIVERY_CHALLAN_NUMBER = '" + dtSelect.Rows[j]["DELIVERY_CHALLAN_NUMBER"].ToString() + @"'