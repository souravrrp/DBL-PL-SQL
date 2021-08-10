select
*
from
AR_CUSTOMER_PROFILE_CLASSES_V;


SELECT CPC.ROWID ROW_ID,
          CPC.PROFILE_CLASS_ID CUSTOMER_PROFILE_CLASS_ID,
          CPC.LAST_UPDATED_BY LAST_UPDATED_BY,
          CPC.LAST_UPDATE_DATE LAST_UPDATE_DATE,
          CPC.LAST_UPDATE_LOGIN LAST_UPDATE_LOGIN,
          CPC.CREATED_BY CREATED_BY,
          CPC.CREATION_DATE CREATION_DATE,
          CPC.NAME PROFILE_CLASS_NAME,
          CPC.DESCRIPTION PROFILE_CLASS_DESCRIPTION,
          CPC.STATUS STATUS,
          CPC.COLLECTOR_ID COLLECTOR_ID,
          COL.NAME COLLECTOR_NAME,
          CPC.CREDIT_CHECKING CREDIT_CHECKING,
          CPC.TOLERANCE TOLERANCE,
          CPC.INTEREST_CHARGES INTEREST_CHARGES,
          CPC.CHARGE_ON_FINANCE_CHARGE_FLAG CHARGE_ON_FINANCE_CHARGE_FLAG,
          CPC.INTEREST_PERIOD_DAYS INTEREST_PERIOD_DAYS,
          CPC.DISCOUNT_TERMS DISCOUNT_TERMS,
          CPC.DISCOUNT_GRACE_DAYS DISCOUNT_GRACE_DAYS,
          CPC.STATEMENTS STATEMENTS,
          CPC.STATEMENT_CYCLE_ID STATEMENT_CYCLE_ID,
          CYC.NAME STATEMENT_CYCLE_NAME,
          CPC.CREDIT_BALANCE_STATEMENTS CREDIT_BALANCE_STATEMENTS,
          CPC.STANDARD_TERMS STANDARD_TERMS,
          TERM.NAME STANDARD_TERMS_NAME,
          CPC.OVERRIDE_TERMS OVERRIDE_TERMS,
          CPC.PAYMENT_GRACE_DAYS PAYMENT_GRACE_DAYS,
          CPC.DUNNING_LETTERS DUNNING_LETTERS,
          CPC.DUNNING_LETTER_SET_ID DUNNING_LETTER_SET_ID,
          DUN_SET.NAME DUNNING_LETTER_SET_NAME,
          CPC.AUTOCASH_HIERARCHY_ID AUTOCASH_HIERARCHY_ID,
          HIER.HIERARCHY_NAME AUTOCASH_HIERARCHY_NAME,
          CPC.COPY_METHOD COPY_METHOD,
          CPC.AUTO_REC_INCL_DISPUTED_FLAG AUTO_REC_INCL_DISPUTED_FLAG,
          CPC.TAX_PRINTING_OPTION TAX_PRINTING_OPTION,
          ARPT_SQL_FUNC_UTIL.get_lookup_meaning ('TAX_PRINTING_OPTION',
                                                 CPC.TAX_PRINTING_OPTION)
             TAX_PRINTING_OPTION_MEANING,
          CPC.GROUPING_RULE_ID GROUPING_RULE_ID,
          CPC.REQUEST_ID REQUEST_ID,
          GRP.NAME GROUPING_RULE_NAME,
          NVL (CPC.CONS_INV_FLAG, 'N') CONS_INV_FLAG,
          CPC.CONS_INV_TYPE CONS_INV_TYPE,
          INITCAP (CPC.CONS_INV_TYPE) CONS_INV_TYPE_MEANING,
          CPC.CONS_BILL_LEVEL,
          INITCAP (CPC.CONS_BILL_LEVEL) BILL_LEVEL_MEANING,
          CPC.ATTRIBUTE_CATEGORY ATTRIBUTE_CATEGORY,
          CPC.ATTRIBUTE1 ATTRIBUTE1,
          CPC.ATTRIBUTE2 ATTRIBUTE2,
          CPC.ATTRIBUTE3 ATTRIBUTE3,
          CPC.ATTRIBUTE4 ATTRIBUTE4,
          CPC.ATTRIBUTE5 ATTRIBUTE5,
          CPC.ATTRIBUTE6 ATTRIBUTE6,
          CPC.ATTRIBUTE7 ATTRIBUTE7,
          CPC.ATTRIBUTE8 ATTRIBUTE8,
          CPC.ATTRIBUTE9 ATTRIBUTE9,
          CPC.ATTRIBUTE10 ATTRIBUTE10,
          CPC.ATTRIBUTE11 ATTRIBUTE11,
          CPC.ATTRIBUTE12 ATTRIBUTE12,
          CPC.ATTRIBUTE13 ATTRIBUTE13,
          CPC.ATTRIBUTE14 ATTRIBUTE14,
          CPC.ATTRIBUTE15 ATTRIBUTE15,
          CPC.JGZZ_ATTRIBUTE_CATEGORY JGZZ_ATTRIBUTE_CATEGORY,
          CPC.JGZZ_ATTRIBUTE1 JGZZ_ATTRIBUTE1,
          CPC.JGZZ_ATTRIBUTE2 JGZZ_ATTRIBUTE2,
          CPC.JGZZ_ATTRIBUTE3 JGZZ_ATTRIBUTE3,
          CPC.JGZZ_ATTRIBUTE4 JGZZ_ATTRIBUTE4,
          CPC.JGZZ_ATTRIBUTE5 JGZZ_ATTRIBUTE5,
          CPC.JGZZ_ATTRIBUTE6 JGZZ_ATTRIBUTE6,
          CPC.JGZZ_ATTRIBUTE7 JGZZ_ATTRIBUTE7,
          CPC.JGZZ_ATTRIBUTE8 JGZZ_ATTRIBUTE8,
          CPC.JGZZ_ATTRIBUTE9 JGZZ_ATTRIBUTE9,
          CPC.JGZZ_ATTRIBUTE10 JGZZ_ATTRIBUTE10,
          CPC.JGZZ_ATTRIBUTE11 JGZZ_ATTRIBUTE11,
          CPC.JGZZ_ATTRIBUTE12 JGZZ_ATTRIBUTE12,
          CPC.JGZZ_ATTRIBUTE13 JGZZ_ATTRIBUTE13,
          CPC.JGZZ_ATTRIBUTE14 JGZZ_ATTRIBUTE14,
          CPC.JGZZ_ATTRIBUTE15 JGZZ_ATTRIBUTE15,
          CPC.GLOBAL_ATTRIBUTE_CATEGORY GLOBAL_ATTRIBUTE_CATEGORY,
          CPC.GLOBAL_ATTRIBUTE1 GLOBAL_ATTRIBUTE1,
          CPC.GLOBAL_ATTRIBUTE2 GLOBAL_ATTRIBUTE2,
          CPC.GLOBAL_ATTRIBUTE3 GLOBAL_ATTRIBUTE3,
          CPC.GLOBAL_ATTRIBUTE4 GLOBAL_ATTRIBUTE4,
          CPC.GLOBAL_ATTRIBUTE5 GLOBAL_ATTRIBUTE5,
          CPC.GLOBAL_ATTRIBUTE6 GLOBAL_ATTRIBUTE6,
          CPC.GLOBAL_ATTRIBUTE7 GLOBAL_ATTRIBUTE7,
          CPC.GLOBAL_ATTRIBUTE8 GLOBAL_ATTRIBUTE8,
          CPC.GLOBAL_ATTRIBUTE9 GLOBAL_ATTRIBUTE9,
          CPC.GLOBAL_ATTRIBUTE10 GLOBAL_ATTRIBUTE10,
          CPC.GLOBAL_ATTRIBUTE11 GLOBAL_ATTRIBUTE11,
          CPC.GLOBAL_ATTRIBUTE12 GLOBAL_ATTRIBUTE12,
          CPC.GLOBAL_ATTRIBUTE13 GLOBAL_ATTRIBUTE13,
          CPC.GLOBAL_ATTRIBUTE14 GLOBAL_ATTRIBUTE14,
          CPC.GLOBAL_ATTRIBUTE15 GLOBAL_ATTRIBUTE15,
          CPC.GLOBAL_ATTRIBUTE16 GLOBAL_ATTRIBUTE16,
          CPC.GLOBAL_ATTRIBUTE17 GLOBAL_ATTRIBUTE17,
          CPC.GLOBAL_ATTRIBUTE18 GLOBAL_ATTRIBUTE18,
          CPC.GLOBAL_ATTRIBUTE19 GLOBAL_ATTRIBUTE19,
          CPC.GLOBAL_ATTRIBUTE20 GLOBAL_ATTRIBUTE20,
          CPC.AUTOCASH_HIERARCHY_ID_FOR_ADR AUTOCASH_HIERARCHY_ID_FOR_ADR,
          HIER_ADR.HIERARCHY_NAME AUTOCASH_HIERARCHY_NAME_ADR,
          CPC.LOCKBOX_MATCHING_OPTION LOCKBOX_MATCHING_OPTION,
          ARPT_SQL_FUNC_UTIL.get_lookup_meaning ('ARLPLB_MATCHING_OPTION',
                                                 CPC.LOCKBOX_MATCHING_OPTION)
             LOCKBOX_MATCHING_OPTION_NAME,
          CPC.REVIEW_CYCLE,
          ARPT_SQL_FUNC_UTIL.get_lookup_meaning ('PERIODIC_REVIEW_CYCLE',
                                                 CPC.REVIEW_CYCLE),
          CPC.CREDIT_ANALYST_ID,
          CA.PARTY_NAME,
          CPC.CREDIT_CLASSIFICATION,
          arpt_sql_func_util.get_lookup_meaning (
             'AR_CMGT_CREDIT_CLASSIFICATION',
             CPC.CREDIT_CLASSIFICATION)
             credit_classification_meaning,
          cpc.late_charge_calculation_trx late_charge_calculation_trx,
          ARPT_SQL_FUNC_UTIL.get_lookup_meaning (
             'AR_MANDATORY_LATE_CHARGES',
             cpc.late_charge_calculation_trx)
             late_charge_calculation_trx_m,
          cpc.credit_items_flag credit_items_flag,
          ARPT_SQL_FUNC_UTIL.get_lookup_meaning ('YES/NO',
                                                 cpc.credit_items_flag)
             credit_items_flag_m,
          cpc.disputed_transactions_flag disputed_transactions_flag,
          ARPT_SQL_FUNC_UTIL.get_lookup_meaning (
             'YES/NO',
             cpc.disputed_transactions_flag)
             disputed_transactions_flag_m,
          cpc.late_charge_type late_charge_type,
          ARPT_SQL_FUNC_UTIL.get_lookup_meaning ('AR_LATE_CHARGE_TYPE',
                                                 cpc.late_charge_type)
             late_charge_type_m,
          cpc.late_charge_term_id late_charge_term_id,
          late_term.name late_term_name,
          cpc.interest_calculation_period interest_calculation_period,
          ARPT_SQL_FUNC_UTIL.get_lookup_meaning (
             'AR_CALCULATION_PERIOD',
             cpc.interest_calculation_period)
             interest_calculation_period_m,
          cpc.hold_charged_invoices_flag hold_charged_invoices_flag,
          ARPT_SQL_FUNC_UTIL.get_lookup_meaning (
             'YES/NO',
             cpc.hold_charged_invoices_flag)
             hold_charged_invoices_flag_m,
          cpc.message_text_id message_text_id,
          arm.name message_text_name,
          arm.text message_text_text,
          cpc.multiple_interest_rates_flag multiple_interest_rates_flag,
          ARPT_SQL_FUNC_UTIL.get_lookup_meaning (
             'YES/NO',
             cpc.multiple_interest_rates_flag)
             multiple_interest_rates_flag_m,
          cpc.charge_begin_date charge_begin_date,
          ARPT_SQL_FUNC_UTIL.get_lookup_meaning (
             'AR_FORMULAE',
             CPC.CHARGE_ON_FINANCE_CHARGE_FLAG)
             charge_on_finance_charge_flagm,
          cpc.automatch_set_id automatch_set_id
     FROM HZ_CUST_PROFILE_CLASSES CPC,
          AR_COLLECTORS COL,
          AR_STATEMENT_CYCLES CYC,
          RA_TERMS TERM,
          AR_DUNNING_LETTER_SETS DUN_SET,
          AR_AUTOCASH_HIERARCHIES HIER,
          AR_AUTOCASH_HIERARCHIES HIER_ADR,
          RA_GROUPING_RULES GRP,
          HZ_PARTIES CA,
          RA_TERMS late_term,
          ar_standard_text arm
    WHERE     COL.COLLECTOR_ID = CPC.COLLECTOR_ID
          AND CYC.STATEMENT_CYCLE_ID(+) = CPC.STATEMENT_CYCLE_ID
          AND TERM.TERM_ID(+) = CPC.STANDARD_TERMS
          AND DUN_SET.DUNNING_LETTER_SET_ID(+) = CPC.DUNNING_LETTER_SET_ID
          AND HIER.AUTOCASH_HIERARCHY_ID(+) = CPC.AUTOCASH_HIERARCHY_ID
          AND GRP.GROUPING_RULE_ID(+) = CPC.GROUPING_RULE_ID
          AND CPC.AUTOCASH_HIERARCHY_ID_FOR_ADR =
                 HIER_ADR.AUTOCASH_HIERARCHY_ID(+)
          AND CPC.CREDIT_ANALYST_ID = CA.PARTY_ID(+)
          AND cpc.late_charge_term_id = LATE_TERM.TERM_ID(+)
          AND cpc.message_text_id = arm.standard_text_id(+);