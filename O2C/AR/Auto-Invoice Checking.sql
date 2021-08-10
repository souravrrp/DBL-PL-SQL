/* Formatted on 7/20/2020 2:28:45 PM (QP5 v5.287) */
SELECT cust_acct.ACCOUNT_NUMBER customer_number,
       SUBSTR (party.PARTY_NAME, 1, 30) customer_name,
       SUBSTR (loc.ADDRESS1, 1, 30) address,
       site_uses.CUST_ACCT_SITE_ID address_id,
       site_uses.LOCATION,
       site_uses.SITE_USE_ID,
       site_uses.SITE_USE_CODE,
       NVL (TO_CHAR (site_uses.GL_ID_REC), 'NULL REC') gl_id_rec,
       DECODE (site_uses.SITE_USE_CODE,
               'BILL_TO', NVL (TO_CHAR (site_uses.GL_ID_REV), 'NULL REV'),
               'DRAWEE', 'NOT APPLICABLE')
          gl_id_rev,
       DECODE (
          site_uses.SITE_USE_CODE,
          'BILL_TO', NVL (TO_CHAR (site_uses.GL_ID_FREIGHT), 'NULL FREIGHT'),
          'DRAWEE', 'NOT APPLICABLE')
          gl_id_freight,
       DECODE (
          site_uses.SITE_USE_CODE,
          'BILL_TO', NVL (TO_CHAR (site_uses.GL_ID_CLEARING),
                          'NULL CLEARING'),
          'DRAWEE', 'NOT APPLICABLE')
          gl_id_clearing,
       DECODE (site_uses.SITE_USE_CODE,
               'BILL_TO', NVL (TO_CHAR (site_uses.GL_ID_TAX), 'NULL TAX'),
               'DRAWEE', 'NOT APPLICABLE')
          gl_id_tax,
       DECODE (
          site_uses.SITE_USE_CODE,
          'BILL_TO', NVL (TO_CHAR (site_uses.GL_ID_UNBILLED), 'NULL UNBILL'),
          'DRAWEE', 'NOT APPLICABLE')
          gl_id_unbill,
       DECODE (
          site_uses.SITE_USE_CODE,
          'BILL_TO', NVL (TO_CHAR (site_uses.GL_ID_UNEARNED), 'NULL UNEARN'),
          'DRAWEE', 'NOT APPLICABLE')
          gl_id_unearn,
       DECODE (
          site_uses.SITE_USE_CODE,
          'BILL_TO', 'NOT APPLICABLE',
          'DRAWEE', NVL (TO_CHAR (site_uses.GL_ID_UNPAID_REC),
                         'NULL UNPAID REC'))
          gl_id_unpaidrec,
       DECODE (
          site_uses.SITE_USE_CODE,
          'BILL_TO', 'NOT APPLICABLE',
          'DRAWEE', NVL (TO_CHAR (site_uses.GL_ID_REMITTANCE),
                         'NULL REMITTANCE'))
          gl_id_remittance,
       DECODE (
          site_uses.SITE_USE_CODE,
          'BILL_TO', 'NOT APPLICABLE',
          'DRAWEE', NVL (TO_CHAR (site_uses.GL_ID_FACTOR), 'NULL FACTOR'))
          gl_id_factor
  FROM HZ_PARTIES PARTY,
       HZ_PARTY_SITES PARTY_SITE,
       HZ_CUST_ACCOUNTS_ALL CUST_ACCT,
       HZ_LOCATIONS LOC,
       HZ_CUST_ACCT_SITES_ALL ACCT_SITES,
       HZ_CUST_SITE_USES_ALL SITE_USES
 WHERE     party_site.LOCATION_ID = loc.LOCATION_ID
       AND party.PARTY_ID = cust_acct.PARTY_ID
       AND cust_acct.CUST_ACCOUNT_ID = acct_sites.CUST_ACCOUNT_ID
       AND acct_sites.CUST_ACCT_SITE_ID = site_uses.CUST_ACCT_SITE_ID
       AND party_site.PARTY_SITE_ID = acct_sites.PARTY_SITE_ID
       AND site_uses.SITE_USE_CODE IN ('BILL_TO', 'DRAWEE')
       AND site_uses.STATUS = 'A'
       AND (   (    site_uses.SITE_USE_CODE = 'BILL_TO'
                AND (   site_uses.GL_ID_REC IS NULL
                     OR site_uses.GL_ID_REV IS NULL
                     OR site_uses.GL_ID_FREIGHT IS NULL
                     OR site_uses.GL_ID_CLEARING IS NULL
                     OR site_uses.GL_ID_TAX IS NULL
                     OR site_uses.GL_ID_UNBILLED IS NULL
                     OR site_uses.GL_ID_UNEARNED IS NULL))
            OR (    site_uses.SITE_USE_CODE = 'DRAWEE'
                AND (   site_uses.GL_ID_REC IS NULL
                     OR site_uses.GL_ID_UNPAID_REC IS NULL
                     OR site_uses.GL_ID_REMITTANCE IS NULL
                     OR site_uses.GL_ID_FACTOR IS NULL)))
       AND EXISTS
              (SELECT 'x'
                 FROM RA_ACCOUNT_DEFAULTS_ALL a,
                      RA_ACCOUNT_DEFAULT_SEGMENTS s
                WHERE     s.GL_DEFAULT_ID = a.GL_DEFAULT_ID
                      AND s.CONSTANT IS NULL
                      AND s.TABLE_NAME = 'RA_SITE_USES');