function CF_1Formula return Number is V_OPEN_BAL NUMBER:=0;
begin
  SELECT (SUM (LOAN_TAKEN)) - (NVL (SUM (LOAN_ADJUSTED), 0))
     INTO 
     V_OPEN_BAL
     FROM (SELECT PAPF.EMPLOYEE_NUMBER,
                  (   PAPF.FIRST_NAME
                   || ' '
                   || PAPF.MIDDLE_NAMES
                   || ' '
                   || PAPF.LAST_NAME)
                     AS EMPLOYEE_NAME,
                  PEEVF.EFFECTIVE_START_DATE START_DATE,
                  TO_NUMBER (PEEVF.SCREEN_ENTRY_VALUE) LOAN_TAKEN,
                  0 LOAN_ADJUSTED
             FROM APPS.PAY_ELEMENT_TYPES_F PETF,
                  APPS.PAY_ELEMENT_LINKS_F PELF,
                  APPS.PAY_ELEMENT_ENTRIES_F PEEF,
                  APPS.PER_ALL_ASSIGNMENTS_F PAAF,
                  APPS.PER_ALL_PEOPLE_F PAPF,
                  APPS.PER_JOBS PJ,
                  APPS.HR_ALL_ORGANIZATION_UNITS HAOU,
                  APPS.PAY_PAYROLLS_F PPF,
                  APPS.PAY_ELEMENT_ENTRY_VALUES_F PEEVF,
                  APPS.PAY_INPUT_VALUES_F PIVF
            WHERE     1 = 1
                  AND PJ.JOB_ID(+) = PAAF.JOB_ID
                  AND PPF.PAYROLL_ID = PAAF.PAYROLL_ID
                  AND HAOU.ORGANIZATION_ID = PAAF.ORGANIZATION_ID
                  AND PAAF.BUSINESS_GROUP_ID = 81
                  AND PETF.ELEMENT_NAME = 'Total Advance Adjustment'
                  AND PEEVF.EFFECTIVE_START_DATE >= '31-May-2018'
                  AND PAPF.PERSON_ID = NVL ( (:EMPLOYEE_NUMBER), PAPF.PERSON_ID)
                  AND TO_CHAR (PEEVF.EFFECTIVE_START_DATE, 'MON-YY') <= TO_CHAR ((:FROM_DATE), 'MON-YY')
                  AND PAPF.PERSON_ID = PAAF.PERSON_ID
                  AND PELF.ELEMENT_TYPE_ID = PETF.ELEMENT_TYPE_ID
                  AND PEEF.ELEMENT_TYPE_ID = PETF.ELEMENT_TYPE_ID
                  AND PAAF.ASSIGNMENT_ID = PEEF.ASSIGNMENT_ID
                  AND TRUNC (SYSDATE) BETWEEN TRUNC (
                                                 PAAF.EFFECTIVE_START_DATE)
                                          AND TRUNC (PAAF.EFFECTIVE_END_DATE)
                  AND PAPF.PERSON_ID = PAAF.PERSON_ID
                  AND PAPF.CURRENT_EMP_OR_APL_FLAG = 'Y'
                  AND TRUNC (SYSDATE) BETWEEN TRUNC (
                                                 PAPF.EFFECTIVE_START_DATE)
                                          AND TRUNC (PAPF.EFFECTIVE_END_DATE)
                  AND PEEVF.ELEMENT_ENTRY_ID = PEEF.ELEMENT_ENTRY_ID
                  AND PIVF.INPUT_VALUE_ID = PEEVF.INPUT_VALUE_ID
           UNION ALL
           SELECT DISTINCT
                  PAPF.EMPLOYEE_NUMBER,
                  (   PAPF.FIRST_NAME
                   || ' '
                   || PAPF.MIDDLE_NAMES
                   || ' '
                   || PAPF.LAST_NAME)
                     AS EMPLOYEE_NAME,
                  PPA.EFFECTIVE_DATE AS START_DATE,
                  0,
                  PC.COSTED_VALUE DEBIT
             FROM APPS.PER_PEOPLE_F PAPF,
                  APPS.PER_ASSIGNMENTS_F PAAF,
                  APPS.PAY_ASSIGNMENT_ACTIONS PAV,
                  APPS.PAY_PAYROLL_ACTIONS PPA,
                  APPS.PAY_COSTS PC,
                  APPS.PAY_COST_ALLOCATION_KEYFLEX PCA,
                  APPS.PAY_ELEMENT_TYPES_F PET,
                  APPS.PAY_RUN_RESULTS PRR,
                  APPS.PAY_RUN_RESULT_VALUES PRRV
            WHERE     PAPF.PERSON_ID = PAAF.PERSON_ID
                  AND PAAF.ASSIGNMENT_ID = PAV.ASSIGNMENT_ID
                  AND PAAF.PRIMARY_FLAG = 'Y'
                  AND PET.ELEMENT_NAME = 'Monthly Advance Adjustment'
                  AND PAPF.PERSON_ID =(:EMPLOYEE_NUMBER)
                  AND PAV.PAYROLL_ACTION_ID = PPA.PAYROLL_ACTION_ID
                  AND PAV.ASSIGNMENT_ACTION_ID = PC.ASSIGNMENT_ACTION_ID
                  AND PC.COST_ALLOCATION_KEYFLEX_ID = PCA.COST_ALLOCATION_KEYFLEX_ID
                  AND PET.ELEMENT_TYPE_ID = PRR.ELEMENT_TYPE_ID
                  AND PRR.RUN_RESULT_ID = PRRV.RUN_RESULT_ID
                  AND PC.RUN_RESULT_ID = PRRV.RUN_RESULT_ID
                  AND PC.INPUT_VALUE_ID = PRRV.INPUT_VALUE_ID
                  AND TO_CHAR (PPA.EFFECTIVE_DATE, 'MON-YY') <= TO_CHAR ((:FROM_DATE), 'MON-YY')
                  AND PAPF.EFFECTIVE_END_DATE =
                         (SELECT MAX (EFFECTIVE_END_DATE)
                            FROM APPS.PER_PEOPLE_F
                           WHERE PERSON_ID = PAPF.PERSON_ID)
                  AND PAAF.EFFECTIVE_END_DATE =
                         (SELECT MAX (EFFECTIVE_END_DATE)
                            FROM APPS.PER_ASSIGNMENTS_F
                           WHERE ASSIGNMENT_ID = PAAF.ASSIGNMENT_ID));

   RETURN V_OPEN_BAL;
END;