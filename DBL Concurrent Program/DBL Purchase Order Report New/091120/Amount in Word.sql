/* Formatted on 11/9/2020 4:17:34 PM (QP5 v5.287) */
FUNCTION CF_PAY_INWORDFormula
   RETURN CHAR
IS
   V_PAY_AMT   VARCHAR2 (200);
BEGIN
      --V_PAY_AMT := apps.XX_COM_PKG.AMOUNT_IN_WORD ( :CS_total_amount);
      /*
      IF :CURRENCY_CODE='BDT' THEN 
      V_PAY_AMT:=apps.XX_COM_PKG.AMOUNT_IN_WORD(:CS_total_amount);
      ELSE
      NULL;
      END IF;
      */
      
      IF :CURRENCY_CODE='BDT' THEN 
      V_PAY_AMT:=apps.XX_COM_PKG.AMOUNT_IN_WORD(:CS_total_amount);
      ELSIF :CURRENCY_CODE='USD' THEN 
      V_PAY_AMT := replace(replace (APPS.XX_COM_PKG.AMOUNT_IN_WORD(:CS_total_amount),'Taka','Dollar'),'Paisa','Cents'); 
      ELSIF :CURRENCY_CODE='EUR' THEN 
      V_PAY_AMT := replace(replace (APPS.XX_COM_PKG.AMOUNT_IN_WORD(:CS_total_amount),'Taka','Dollar'),'Paisa','Cents'); 
      ELSIF :CURRENCY_CODE='INR' THEN 
      V_PAY_AMT := replace(replace (APPS.XX_COM_PKG.AMOUNT_IN_WORD(:CS_total_amount),'Taka','Rupee'),'Paisa','Paisa'); 
      ELSIF :CURRENCY_CODE='JPY' THEN 
      V_PAY_AMT := replace(replace (APPS.XX_COM_PKG.AMOUNT_IN_WORD(:CS_total_amount),'Taka','Yen'),'Paisa','Sen'); 
      ELSIF :CURRENCY_CODE='GBP' THEN 
      V_PAY_AMT := replace(replace (APPS.XX_COM_PKG.AMOUNT_IN_WORD(:CS_total_amount),'Taka','Pound'),'Paisa','Penny'); 
      ELSIF :CURRENCY_CODE='SGD' THEN 
      V_PAY_AMT := replace(replace (APPS.XX_COM_PKG.AMOUNT_IN_WORD(:CS_total_amount),'Taka','Dollar'),'Paisa','Cents'); 
      ELSIF :CURRENCY_CODE='CHF' THEN 
      V_PAY_AMT := replace(replace (APPS.XX_COM_PKG.AMOUNT_IN_WORD(:CS_total_amount),'Taka','Franc'),'Paisa','Centime'); 
      ELSE
      NULL;
      END IF;
      
      V_PAY_AMT := replace(replace (APPS.XX_COM_PKG.AMOUNT_IN_WORD(:CS_total_amount),'Taka','Dollar'),'Paisa','Cents'); 
      
   RETURN (V_PAY_AMT);
END;