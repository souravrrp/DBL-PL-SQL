/* Formatted on 3/23/2021 4:09:29 PM (QP5 v5.287) */
SELECT *
  FROM apps.hz_parties hp, apps.hz_party_sites hps
 WHERE     1 = 1
       AND hp.party_id = hps.party_id
       AND (   :p_cust_name IS NULL
            OR (UPPER (hp.party_name) LIKE UPPER ('%' || :p_cust_name || '%')));


  SELECT *
    FROM apps.hz_party_sites hps
   WHERE 1 = 1
ORDER BY party_site_id DESC;