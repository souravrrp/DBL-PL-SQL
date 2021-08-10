CREATE OR REPLACE PACKAGE BODY APPS.xxdbl_dm_customer_pkg
IS
   PROCEDURE create_customer (
      p_customer_name         VARCHAR2,
      p_customer_type         VARCHAR2,
      p_cust_alias            VARCHAR2,
      p_cust_number           VARCHAR2,
      p_category              VARCHAR2,
      x_party_id        OUT   NUMBER,
      x_party_number    OUT   VARCHAR2,
      x_profile_id      OUT   NUMBER,
      x_error_message   OUT   VARCHAR2
   )
   IS
      l_organization_rec    hz_party_v2pub.organization_rec_type;
      l_party_rec           hz_party_v2pub.party_rec_type;
      -- Variables to store values of out parameters for debugging purposes.
      x_return_status       VARCHAR2 (2000);
      x_msg_count           NUMBER;
      x_msg_data            VARCHAR2 (2000);
      -- Constant variables.
      g_created_by_module   VARCHAR2 (30)                        := 'HZ_CPUI';
      v_error_msg           VARCHAR2 (4000);
      l_msg_index_out       NUMBER;
   BEGIN
      l_organization_rec.organization_name := p_customer_name;
      --l_organization_rec.organization_name_phonetic := p_jp_customer_name;
      l_organization_rec.created_by_module := g_created_by_module;
      l_organization_rec.organization_type := p_category;
      l_organization_rec.known_as := p_cust_alias;
      l_organization_rec.organization_name_phonetic := p_cust_number;
      l_organization_rec.party_rec.category_code := p_category;
      -- Constant
      hz_party_v2pub.create_organization
                                   (p_init_msg_list         => fnd_api.g_false,
                                    p_organization_rec      => l_organization_rec,
                                    x_return_status         => x_return_status,
                                    x_msg_count             => x_msg_count,
                                    x_msg_data              => x_msg_data,
                                    x_party_id              => x_party_id,
                                    x_party_number          => x_party_number,
                                    x_profile_id            => x_profile_id
                                   );

      --fnd_file.put_line (fnd_file.LOG,'x_return_status: ' || x_return_status);
      IF x_return_status <> 'S'
      THEN
         IF x_msg_count = 1
         THEN
            v_error_msg := x_msg_data;
         ELSIF NVL (x_msg_count, 0) > 1
         THEN
            FOR i IN 1 .. x_msg_count
            LOOP
               fnd_msg_pub.get (p_msg_index          => i,
                                p_data               => x_msg_data,
                                p_msg_index_out      => l_msg_index_out
                               );
               v_error_msg := NVL (v_error_msg, ' ') || x_msg_data || ' ';
            END LOOP;

            v_error_msg := TRIM (v_error_msg);
         END IF;
      ELSE
         COMMIT;
      END IF;

      x_error_message := v_error_msg;
   END;

   PROCEDURE update_customer (
      p_customer_name               VARCHAR2,
      p_jp_customer_name            VARCHAR2,
      p_party_number       IN OUT   VARCHAR2,
      x_party_id           OUT      NUMBER,
      x_profile_id         OUT      NUMBER,
      x_error_message      OUT      VARCHAR2
   )
   IS
      l_organization_rec              hz_party_v2pub.organization_rec_type;
      -- Variables to store values of out parameters for debugging purposes.
      x_return_status                 VARCHAR2 (2000);
      x_msg_count                     NUMBER;
      x_msg_data                      VARCHAR2 (2000);
      --x_profile_id                    NUMBER;
      l_party_object_version_number   NUMBER;
      -- Constant variables.
      g_created_by_module             VARCHAR2 (30)              := 'HZ_CPUI';
      l_party_id                      NUMBER;
      l_party_number                  VARCHAR2 (100);
      l_profile_id                    NUMBER;
      l_cust_account_id               NUMBER;
      v_error_msg                     VARCHAR2 (4000);
      l_msg_index_out                 NUMBER;
   BEGIN
      l_organization_rec.organization_name := p_customer_name;
      l_organization_rec.organization_name_phonetic := p_jp_customer_name;

      BEGIN
         SELECT party_id,
                party_number,
                orig_system_reference,
                created_by_module,
                object_version_number
           INTO l_organization_rec.party_rec.party_id,
                l_organization_rec.party_rec.party_number,
                l_organization_rec.party_rec.orig_system_reference,
                l_organization_rec.created_by_module,
                l_party_object_version_number
           FROM hz_parties
          WHERE party_number = p_party_number;
      EXCEPTION
         WHEN OTHERS
         THEN
            l_organization_rec.party_rec.party_id := NULL;
            v_error_msg := 'No Party Exists';
      END;

      hz_party_v2pub.update_organization
              (p_init_msg_list                    => fnd_api.g_false,
               p_organization_rec                 => l_organization_rec,
               p_party_object_version_number      => l_party_object_version_number,
               x_profile_id                       => x_profile_id,
               x_return_status                    => x_return_status,
               x_msg_count                        => x_msg_count,
               x_msg_data                         => x_msg_data
              );
      x_party_id := l_organization_rec.party_rec.party_id;

      --fnd_file.put_line (fnd_file.LOG,'x_return_status: ' || x_return_status);
      --fnd_file.put_line (fnd_file.LOG,'x_return_status: ' || x_profile_id);
      IF x_return_status <> 'S'
      THEN
         IF x_msg_count = 1
         THEN
            v_error_msg := x_msg_data;
         ELSIF NVL (x_msg_count, 0) > 1
         THEN
            FOR i IN 1 .. x_msg_count
            LOOP
               fnd_msg_pub.get (p_msg_index          => i,
                                p_data               => x_msg_data,
                                p_msg_index_out      => l_msg_index_out
                               );
               v_error_msg := NVL (v_error_msg, ' ') || x_msg_data || ' ';
            END LOOP;

            v_error_msg := TRIM (v_error_msg);
         END IF;
      END IF;

      x_error_message := v_error_msg;
   END;

   FUNCTION create_location (
      p_address1      VARCHAR2,
      p_address2      VARCHAR2,
      p_address3      VARCHAR2,
      p_address4      VARCHAR2,
      p_city          VARCHAR2,
      p_postal_code   VARCHAR2,
      p_state         VARCHAR2,
      p_country       VARCHAR2,
      p_county        VARCHAR2,
      p_province      VARCHAR2,
      p_div_dff       VARCHAR2
   )
      RETURN NUMBER
   IS
      l_location_rec        hz_location_v2pub.location_rec_type;
      x_location_id         NUMBER;
      -- Variables to store values of out parameters for debugging purposes.
      x_return_status       VARCHAR2 (2000);
      x_msg_count           NUMBER;
      x_msg_data            VARCHAR2 (2000);
      -- Constant variables.
      g_created_by_module   VARCHAR2 (30)                       := 'HZ_CPUI';
      v_error_msg           VARCHAR2 (4000);
      l_msg_index_out       NUMBER;
   BEGIN
      -- Populate p_location_rec
      l_location_rec.country := p_country;
      l_location_rec.address1 := p_address1;
      l_location_rec.address2 := p_address2;
      l_location_rec.address3 := p_address3;
      l_location_rec.address4 := p_address4;
      l_location_rec.city := p_city;
      l_location_rec.postal_code := p_postal_code;
      l_location_rec.state := p_state;
      l_location_rec.county := p_county;
      l_location_rec.province := p_province;
      l_location_rec.address_style := 'XX_SSGIL_BD_GEOG';
      l_location_rec.address_lines_phonetic := p_div_dff;
      --l_location_rec.short_description := p_short_description;
      l_location_rec.created_by_module := g_created_by_module;
      -- Create location
      hz_location_v2pub.create_location (p_init_msg_list      => fnd_api.g_false,
                                         p_location_rec       => l_location_rec,
                                         x_location_id        => x_location_id,
                                         x_return_status      => x_return_status,
                                         x_msg_count          => x_msg_count,
                                         x_msg_data           => x_msg_data
                                        );

      --fnd_file.put_line (fnd_file.LOG,'x_return_status: ' || x_return_status);
      IF x_return_status <> 'S'
      THEN
         IF x_msg_count = 1
         THEN
            v_error_msg := x_msg_data;
         ELSIF NVL (x_msg_count, 0) > 1
         THEN
            FOR i IN 1 .. x_msg_count
            LOOP
               fnd_msg_pub.get (p_msg_index          => i,
                                p_data               => x_msg_data,
                                p_msg_index_out      => l_msg_index_out
                               );
               v_error_msg :=
                  SUBSTR (NVL (v_error_msg, ' ') || x_msg_data || ' ', 1,
                          4000);
            END LOOP;

            v_error_msg := TRIM (v_error_msg);
         END IF;
      END IF;

      RETURN x_location_id;
   END;

   PROCEDURE create_account (
      p_account_name                VARCHAR2,
      p_party_id                    NUMBER,
      p_party_number                VARCHAR2,
      p_cust_type                   VARCHAR2,
      p_category_code               VARCHAR2,
      p_profile_id                  NUMBER,
      p_attribute1                  VARCHAR2,
      p_attribute2                  VARCHAR2,
      p_customer_class_code         VARCHAR2,                           -- New
      p_cust_account_id       OUT   NUMBER,
      p_account_number        OUT   VARCHAR2,
      x_error_message         OUT   VARCHAR2
   )
   IS
      l_party_rec              hz_party_v2pub.party_rec_type;
      l_organization_rec       hz_party_v2pub.organization_rec_type;
      l_cust_account_rec       hz_cust_account_v2pub.cust_account_rec_type;
      l_customer_profile_rec   hz_customer_profile_v2pub.customer_profile_rec_type;
      x_party_number           VARCHAR2 (2000);
      x_profile_id             NUMBER;
      -- Variables to store values of out parameters for debugging purposes.
      x_return_status          VARCHAR2 (2000);
      x_msg_count              NUMBER;
      x_msg_data               VARCHAR2 (2000);
      -- Constant variables.
      g_created_by_module      VARCHAR2 (30)                     := 'HZ_CPUI';
      -- Temporary variables
      t_party_id               NUMBER;
      v_error_msg              VARCHAR2 (4000);
      l_msg_index_out          NUMBER;
   BEGIN
      -- Supply the party_id generated from create_organization api to the p_organization_rec.party_rec.party_id
      -- item in order to link the Customer Account to the Organization.
      l_organization_rec.party_rec.party_id := p_party_id;
      -- Populate p_cust_account_rec
      l_cust_account_rec.account_name := p_account_name;
      l_organization_rec.party_rec.category_code := p_category_code;
      l_cust_account_rec.created_by_module := g_created_by_module;
      --
      -- Class Code
      l_cust_account_rec.customer_class_code := p_customer_class_code;
      l_cust_account_rec.customer_type := p_cust_type;
      --
      --
      --l_cust_account_rec.attribute1 := p_attribute1;
      --l_cust_account_rec.attribute2 := p_attribute2;
      --l_cust_account_rec.attribute_category := p_attribute2;
      -- Create Customer Account
      hz_cust_account_v2pub.create_cust_account
                           (p_init_msg_list             => fnd_api.g_false,
                            p_cust_account_rec          => l_cust_account_rec,
                            p_organization_rec          => l_organization_rec,
                            p_customer_profile_rec      => l_customer_profile_rec,
                            p_create_profile_amt        => fnd_api.g_false,
                            x_cust_account_id           => p_cust_account_id,
                            x_account_number            => p_account_number,
                            x_party_id                  => t_party_id,
                            x_party_number              => x_party_number,
                            x_profile_id                => x_profile_id,
                            x_return_status             => x_return_status,
                            x_msg_count                 => x_msg_count,
                            x_msg_data                  => x_msg_data
                           );

      -- Print log to buffer.
      --fnd_file.put_line (fnd_file.LOG,'x_return_status: ' || x_return_status);

      --fnd_file.put_line (fnd_file.LOG,'x_msg_count: ' || x_msg_count);
      --fnd_file.put_line (fnd_file.LOG,'x_msg_data: ' || x_msg_data);
      IF x_return_status <> 'S'
      THEN
         IF x_msg_count = 1
         THEN
            v_error_msg := x_msg_data;
         ELSIF NVL (x_msg_count, 0) > 1
         THEN
            FOR i IN 1 .. x_msg_count
            LOOP
               fnd_msg_pub.get (p_msg_index          => i,
                                p_data               => x_msg_data,
                                p_msg_index_out      => l_msg_index_out
                               );
               v_error_msg := NVL (v_error_msg, ' ') || x_msg_data || ' ';
            END LOOP;

            v_error_msg := TRIM (v_error_msg);
         END IF;
      END IF;

      x_error_message := v_error_msg;
   END;

   PROCEDURE create_party_site (
      p_party_id                  NUMBER,
      p_address1                  VARCHAR2,
      p_address2                  VARCHAR2,
      p_address3                  VARCHAR2,
      p_address4                  VARCHAR2,
      p_city                      VARCHAR2,
      p_postal_code               VARCHAR2,
      p_state                     VARCHAR2,
      p_country                   VARCHAR2,
      p_county                    VARCHAR2,
      p_province                  VARCHAR2,
      p_attribute1                VARCHAR2,
      p_site_name                 VARCHAR2,
      p_div_dff                   VARCHAR2,
      p_ship_loc_dff              VARCHAR2,
      x_party_site_id       OUT   NUMBER,
      x_party_site_number   OUT   NUMBER,
      x_error_message       OUT   VARCHAR2
   )
   IS
      l_party_site_rec      hz_party_site_v2pub.party_site_rec_type;
      -- Variables to store values of out parameters for debugging purposes.
      x_return_status       VARCHAR2 (2000);
      x_msg_count           NUMBER;
      x_msg_data            VARCHAR2 (2000);
      -- Constant variables.
      g_created_by_module   VARCHAR2 (30)                        := 'HZ_CPUI';
      v_error_msg           VARCHAR2 (4000);
      l_msg_index_out       NUMBER;
   BEGIN
      -- Populate p_party_site_rec
      l_party_site_rec.party_id := p_party_id;
      l_party_site_rec.addressee := p_ship_loc_dff;
      l_party_site_rec.location_id :=
         create_location (p_address1,
                          p_address2,
                          p_address3,
                          p_address4,
                          p_city,
                          p_postal_code,
                          p_state,
                          p_country,
                          p_county,
                          p_province,
                          p_div_dff
                         );
      l_party_site_rec.created_by_module := g_created_by_module;

      IF p_site_name IS NOT NULL
      THEN
         l_party_site_rec.party_site_name := p_site_name;
      ELSE
         l_party_site_rec.party_site_name := NULL;
      END IF;

      --   l_party_site_rec.attribute1 := p_attribute1;
         -- Create party site
      hz_party_site_v2pub.create_party_site
                                  (p_init_msg_list          => fnd_api.g_false,
                                   p_party_site_rec         => l_party_site_rec,
                                   x_party_site_id          => x_party_site_id,
                                   x_party_site_number      => x_party_site_number,
                                   x_return_status          => x_return_status,
                                   x_msg_count              => x_msg_count,
                                   x_msg_data               => x_msg_data
                                  );

      -- Print log to buffer.
      --fnd_file.put_line (fnd_file.LOG,'x_return_status: ' || x_return_status);

      --fnd_file.put_line (fnd_file.LOG,'x_msg_count: ' || x_msg_count);
      --fnd_file.put_line (fnd_file.LOG,'x_msg_data: ' || x_msg_data);
      IF x_return_status <> 'S'
      THEN
         IF x_msg_count = 1
         THEN
            v_error_msg := x_msg_data;
         ELSIF NVL (x_msg_count, 0) > 1
         THEN
            FOR i IN 1 .. x_msg_count
            LOOP
               fnd_msg_pub.get (p_msg_index          => i,
                                p_data               => x_msg_data,
                                p_msg_index_out      => l_msg_index_out
                               );
               v_error_msg :=
                  SUBSTR (NVL (v_error_msg, ' ') || x_msg_data || ' ', 1,
                          4000);
            END LOOP;

            v_error_msg := TRIM (v_error_msg);
         END IF;
      ELSE
         COMMIT;
      END IF;

      x_error_message := v_error_msg;
   END;

   PROCEDURE create_customer_site (
      p_cust_account_id                NUMBER,
      p_party_site_id                  NUMBER,
      l_org_id                         NUMBER,
      p_territory                      VARCHAR2,
      p_customer_category_code         VARCHAR2,                        -- New
      x_cust_acct_site_id        OUT   NUMBER,
      x_error_message            OUT   VARCHAR2
   )
   IS
      l_cust_acct_site_rec   hz_cust_account_site_v2pub.cust_acct_site_rec_type;
      -- Variables to store values of out parameters for debugging purposes.
      x_return_status        VARCHAR2 (2000);
      x_msg_count            NUMBER;
      x_msg_data             VARCHAR2 (2000);
      -- Constant variables.
      g_created_by_module    VARCHAR2 (30)                       := 'HZ_CPUI';
      v_error_msg            VARCHAR2 (10000);
      l_msg_index_out        NUMBER;
   BEGIN
      -- Populate p_cust_acct_site_rec
      l_cust_acct_site_rec.cust_account_id := p_cust_account_id;
      l_cust_acct_site_rec.party_site_id := p_party_site_id;
      l_cust_acct_site_rec.created_by_module := g_created_by_module;
      l_cust_acct_site_rec.org_id := l_org_id;
      l_cust_acct_site_rec.territory := p_territory;
      --
      -- Category
      l_cust_acct_site_rec.customer_category_code := p_customer_category_code;
      --
      -- Create Customer Account Site
      hz_cust_account_site_v2pub.create_cust_acct_site
                               (p_init_msg_list           => fnd_api.g_false,
                                p_cust_acct_site_rec      => l_cust_acct_site_rec,
                                x_cust_acct_site_id       => x_cust_acct_site_id,
                                x_return_status           => x_return_status,
                                x_msg_count               => x_msg_count,
                                x_msg_data                => x_msg_data
                               );

      -- Print log to buffer.
      --fnd_file.put_line (fnd_file.LOG,'x_return_status: ' || x_return_status);

      --fnd_file.put_line (fnd_file.LOG,'x_msg_count: ' || x_msg_count);
      --fnd_file.put_line (fnd_file.LOG,'x_msg_data: ' || x_msg_data);
      IF x_return_status <> 'S'
      THEN
         IF x_msg_count = 1
         THEN
            v_error_msg := x_msg_data;
         ELSIF NVL (x_msg_count, 0) > 1
         THEN
            FOR i IN 1 .. x_msg_count
            LOOP
               fnd_msg_pub.get (p_msg_index          => i,
                                p_data               => x_msg_data,
                                p_msg_index_out      => l_msg_index_out
                               );
               v_error_msg := NVL (v_error_msg, ' ') || x_msg_data || ' ';
            END LOOP;

            v_error_msg := TRIM (v_error_msg);
         END IF;
      END IF;

      x_error_message := v_error_msg;
   END;

   PROCEDURE create_customer_site_uses (
      p_cust_acct_site_id           NUMBER,
      p_site_use                    VARCHAR2,
      p_site_name                   VARCHAR2,
      p_payment_term_id             NUMBER,
      p_tax_code                    VARCHAR2,
      p_gl_account_id               NUMBER,
      p_org_id                      NUMBER,
      p_salesrep_id                 NUMBER,
      p_territory_id                NUMBER,
      p_bill_to_site_use_id         NUMBER,
      p_oe_type                     VARCHAR2,
      p_price_list                  VARCHAR2,
      p_frt_term                    VARCHAR2,
      x_site_use_id           OUT   NUMBER,
      x_error_message         OUT   VARCHAR2
   )
   IS
      l_cust_site_use_rec      hz_cust_account_site_v2pub.cust_site_use_rec_type;
      l_customer_profile_rec   hz_customer_profile_v2pub.customer_profile_rec_type;
      -- Variables to store values of out parameters for debugging purposes.
      x_return_status          VARCHAR2 (2000);
      x_msg_count              NUMBER;
      x_msg_data               VARCHAR2 (2000);
      -- Constant variables.
      g_created_by_module      VARCHAR2 (30)                     := 'HZ_CPUI';
      v_error_msg              VARCHAR2 (10000);
      l_msg_index_out          NUMBER;
      ln_oe_type_id            NUMBER                                 := NULL;
      ln_price_list_id         NUMBER                                 := NULL;
   BEGIN
        -- Populate p_cust_site_use_rec
       -- ln_oe_type_id := NULL;
       -- ln_oe_type_id :=
       --          apps.xxdbl_dm_customer_pkg.order_type_fn (p_oe_type, p_org_id);
       -- fnd_file.put_line (fnd_file.LOG, 'OE TYPE ID: ' || ln_oe_type_id);
      --  ln_price_list_id := NULL;
      --  ln_price_list_id :=
       --                 apps.xxdbl_dm_customer_pkg.price_list_fn (p_price_list);
       -- fnd_file.put_line (fnd_file.LOG, 'PRICE LIST ID: ' || ln_price_list_id);
      l_cust_site_use_rec.primary_flag := 'Y';
      l_cust_site_use_rec.org_id := p_org_id;
      l_cust_site_use_rec.status := 'A';
      l_cust_site_use_rec.site_use_code := p_site_use;
      l_cust_site_use_rec.LOCATION := SUBSTR (p_site_name, 1, 39);
      l_cust_site_use_rec.cust_acct_site_id := p_cust_acct_site_id;
      l_cust_site_use_rec.created_by_module := g_created_by_module;
      l_cust_site_use_rec.payment_term_id := p_payment_term_id;
      l_cust_site_use_rec.tax_code := p_tax_code;
      l_cust_site_use_rec.gl_id_rec := p_gl_account_id;
      l_cust_site_use_rec.gl_id_rev := p_gl_account_id;
      l_cust_site_use_rec.gl_id_tax := p_gl_account_id;
      l_cust_site_use_rec.gl_id_freight := p_gl_account_id;
      l_cust_site_use_rec.gl_id_clearing := p_gl_account_id;
      l_cust_site_use_rec.gl_id_unbilled := p_gl_account_id;
      l_cust_site_use_rec.gl_id_unearned := p_gl_account_id;
      l_cust_site_use_rec.primary_salesrep_id := p_salesrep_id;
      l_cust_site_use_rec.territory_id := p_territory_id;
      l_cust_site_use_rec.bill_to_site_use_id := p_bill_to_site_use_id;
      l_cust_site_use_rec.order_type_id := ln_oe_type_id;
      l_cust_site_use_rec.price_list_id := ln_price_list_id;
      l_cust_site_use_rec.freight_term := LTRIM (RTRIM (p_frt_term));
      -- Create Customer Account Site Use
      hz_cust_account_site_v2pub.create_cust_site_use
                           (p_init_msg_list             => fnd_api.g_false,
                            p_cust_site_use_rec         => l_cust_site_use_rec,
                            p_customer_profile_rec      => l_customer_profile_rec,
                            p_create_profile            => '',
                            p_create_profile_amt        => '',
                            x_site_use_id               => x_site_use_id,
                            x_return_status             => x_return_status,
                            x_msg_count                 => x_msg_count,
                            x_msg_data                  => x_msg_data
                           );

      -- Print log to buffer.
      --fnd_file.put_line (fnd_file.LOG,'x_return_status: ' || x_return_status);
      --fnd_file.put_line (fnd_file.LOG,'x_msg_count: ' || x_msg_count);
      --fnd_file.put_line (fnd_file.LOG,'x_msg_data: ' || x_msg_data);
      IF x_return_status <> 'S'
      THEN
         IF x_msg_count = 1
         THEN
            v_error_msg := x_msg_data;
         --fnd_file.put_line (fnd_file.LOG,'v_error_msg: ' || v_error_msg);
         ELSIF NVL (x_msg_count, 0) > 1
         THEN
            FOR i IN 1 .. x_msg_count
            LOOP
               fnd_msg_pub.get (p_msg_index          => i,
                                p_data               => x_msg_data,
                                p_msg_index_out      => l_msg_index_out
                               );
               v_error_msg := NVL (v_error_msg, ' ') || x_msg_data || ' ';
            END LOOP;

            v_error_msg := TRIM (v_error_msg);
         END IF;
      END IF;

      x_error_message := v_error_msg;
   END;

   PROCEDURE create_cust_profile (
      p_cust_acct_id              IN       NUMBER,
      p_site_use_id               IN       NUMBER,
      x_cust_account_profile_id   OUT      NUMBER,
      x_error_message             OUT      VARCHAR2
   )
   AS
      x_return_status          VARCHAR2 (200);
      x_msg_count              NUMBER;
      x_msg_data               VARCHAR2 (200);
      l_customer_profile_rec   hz_customer_profile_v2pub.customer_profile_rec_type;
      l_lastest_cust_acct_id   NUMBER;
      v_error_msg              VARCHAR2 (4000);
      l_msg_index_out          NUMBER;
   BEGIN
      l_customer_profile_rec.cust_account_id := p_cust_acct_id;
      l_customer_profile_rec.site_use_id := p_site_use_id;
      l_customer_profile_rec.credit_checking := 'Y';
      --l_customer_profile_rec.statement_cycle_id := p_statment_cycle_id;
      l_customer_profile_rec.created_by_module := 'HZ_CPUI';
      hz_customer_profile_v2pub.create_customer_profile
                     (p_customer_profile_rec         => l_customer_profile_rec,
                      p_create_profile_amt           => fnd_api.g_false,
                      x_cust_account_profile_id      => x_cust_account_profile_id,
                      x_return_status                => x_return_status,
                      x_msg_count                    => x_msg_count,
                      x_msg_data                     => x_msg_data
                     );

      --fnd_file.put_line (fnd_file.LOG,'x_return_status: ' || x_return_status);
      --fnd_file.put_line (fnd_file.LOG,'x_return_status: ' || x_cust_account_profile_id);
      IF x_return_status <> 'S'
      THEN
         IF x_msg_count = 1
         THEN
            v_error_msg := x_msg_data;
         ELSIF NVL (x_msg_count, 0) > 1
         THEN
            FOR i IN 1 .. x_msg_count
            LOOP
               fnd_msg_pub.get (p_msg_index          => i,
                                p_data               => x_msg_data,
                                p_msg_index_out      => l_msg_index_out
                               );
               v_error_msg := NVL (v_error_msg, ' ') || x_msg_data || ' ';
            END LOOP;

            v_error_msg := TRIM (v_error_msg);
         END IF;
      END IF;

      x_error_message := v_error_msg;
   END create_cust_profile;

   PROCEDURE update_cust_profile (
      p_cust_acct_id              IN       NUMBER,
      p_site_use_id               IN       NUMBER,
      p_profile_class_id          IN       NUMBER,
      p_cust_account_profile_id   IN       NUMBER,
      x_object_version_number     IN OUT   NUMBER,
      x_error_message             OUT      VARCHAR2
   )
   AS
      x_return_status               VARCHAR2 (200);
      x_msg_count                   NUMBER;
      x_msg_data                    VARCHAR2 (200);
      l_customer_profile_rec_type   hz_customer_profile_v2pub.customer_profile_rec_type;
      l_cust_account_profile_id     NUMBER;
      l_object_version_number       NUMBER;
      l_profile_class_id            NUMBER;
      v_error_msg                   VARCHAR2 (4000);
      l_msg_index_out               NUMBER;
   BEGIN
      l_customer_profile_rec_type.cust_account_profile_id :=
                                                    p_cust_account_profile_id;
      l_customer_profile_rec_type.profile_class_id := p_profile_class_id;
      l_customer_profile_rec_type.site_use_id := p_site_use_id;
      --DBMS_OUTPUT.put_line
      --   ('Calling the API hz_customer_profile_v2pub.update_customer_profile');
      --fnd_file.put_line (fnd_file.LOG,'p_profile_class_id' || p_profile_class_id);
      hz_customer_profile_v2pub.update_customer_profile
                      (p_init_msg_list              => fnd_api.g_true,
                       p_customer_profile_rec       => l_customer_profile_rec_type,
                       p_object_version_number      => x_object_version_number,
                       x_return_status              => x_return_status,
                       x_msg_count                  => x_msg_count,
                       x_msg_data                   => x_msg_data
                      );

      --fnd_file.put_line (fnd_file.LOG,'x_return_status: ' || x_return_status);
      --fnd_file.put_line (fnd_file.LOG,   'l_object_version_number: '
      --                      || x_object_version_number
      --                     );
      IF x_return_status <> 'S'
      THEN
         IF x_msg_count = 1
         THEN
            v_error_msg := x_msg_data;
         ELSIF NVL (x_msg_count, 0) > 1
         THEN
            FOR i IN 1 .. x_msg_count
            LOOP
               fnd_msg_pub.get (p_msg_index          => i,
                                p_data               => x_msg_data,
                                p_msg_index_out      => l_msg_index_out
                               );
               v_error_msg := NVL (v_error_msg, ' ') || x_msg_data || ' ';
            END LOOP;

            v_error_msg := TRIM (v_error_msg);
         END IF;
      END IF;

      x_error_message := v_error_msg;
   END;

   PROCEDURE customer_profile_amt (
      p_cust_account_id              NUMBER,
      p_site_use_id                  NUMBER,
      p_profile_id                   NUMBER,
      p_currency                     VARCHAR2,
      p_global_credit_limit          NUMBER,
      p_bill_to_credit_limit         NUMBER,
      x_cust_act_prof_amt_id   OUT   NUMBER,
      x_error_message          OUT   VARCHAR2
   )
   IS
      --l_organization_rec              hz_party_v2pub.organization_rec_type;
      -- Variables to store values of out parameters for debugging purposes.
      v_customer_profile_amt   hz_customer_profile_v2pub.cust_profile_amt_rec_type;
      x_return_status          VARCHAR2 (2000);
      x_msg_count              NUMBER;
      x_msg_data               VARCHAR2 (2000);
      v_error_msg              VARCHAR2 (4000);
      l_msg_index_out          NUMBER;
   BEGIN
      v_customer_profile_amt.cust_account_profile_id := p_profile_id;
      v_customer_profile_amt.cust_account_id := p_cust_account_id;
      v_customer_profile_amt.site_use_id := p_site_use_id;
      v_customer_profile_amt.currency_code := p_currency;
      --  v_customer_profile_amt.trx_credit_limit := p_bill_to_credit_limit;
      v_customer_profile_amt.overall_credit_limit := p_global_credit_limit;
      v_customer_profile_amt.min_dunning_amount := 0;
      v_customer_profile_amt.min_statement_amount := 0;
      v_customer_profile_amt.created_by_module := 'HZ_CPUI';
      hz_customer_profile_v2pub.create_cust_profile_amt
                       (p_init_msg_list                 => 'T',
                        p_check_foreign_key             => fnd_api.g_true,
                        p_cust_profile_amt_rec          => v_customer_profile_amt,
                        x_cust_acct_profile_amt_id      => x_cust_act_prof_amt_id,
                        x_return_status                 => x_return_status,
                        x_msg_count                     => x_msg_count,
                        x_msg_data                      => x_msg_data
                       );

      --fnd_file.put_line (fnd_file.LOG,'x_return_status: ' || x_return_status);
      --fnd_file.put_line (fnd_file.LOG,'x_return_status: ' || x_cust_act_prof_amt_id);
      IF x_return_status <> 'S'
      THEN
         IF x_msg_count = 1
         THEN
            v_error_msg := x_msg_data;
         ELSIF NVL (x_msg_count, 0) > 1
         THEN
            FOR i IN 1 .. x_msg_count
            LOOP
               fnd_msg_pub.get (p_msg_index          => i,
                                p_data               => x_msg_data,
                                p_msg_index_out      => l_msg_index_out
                               );
               v_error_msg :=
                  SUBSTR (NVL (v_error_msg, ' ') || x_msg_data || ' ', 1,
                          4000);
            END LOOP;

            v_error_msg := TRIM (v_error_msg);
         END IF;
      END IF;

      x_error_message := v_error_msg;
   END;

   FUNCTION create_person (p_first_name VARCHAR2, p_last_name VARCHAR2)
      RETURN NUMBER
   IS
      l_create_person_rec   hz_party_v2pub.person_rec_type;
      l_party_id            NUMBER;
      l_party_number        VARCHAR2 (2000);
      l_profile_id          NUMBER;
      -- Variables to store values of out parameters for debugging purposes.
      x_return_status       VARCHAR2 (2000);
      x_msg_count           NUMBER;
      x_msg_data            VARCHAR2 (2000);
      -- Constant variables.
      g_created_by_module   VARCHAR2 (30)                  := 'HZ_CPUI';
      v_error_msg           VARCHAR2 (4000);
      l_msg_index_out       NUMBER;
   BEGIN
      l_create_person_rec.person_last_name := p_last_name;
      l_create_person_rec.person_first_name := p_first_name;
      l_create_person_rec.created_by_module := g_created_by_module;
      hz_party_v2pub.create_person (p_init_msg_list      => fnd_api.g_false,
                                    p_person_rec         => l_create_person_rec,
                                    x_party_id           => l_party_id,
                                    x_party_number       => l_party_number,
                                    x_profile_id         => l_profile_id,
                                    x_return_status      => x_return_status,
                                    x_msg_count          => x_msg_count,
                                    x_msg_data           => x_msg_data
                                   );

      -- Print log to buffer.
      --fnd_file.put_line (fnd_file.LOG,'x_return_status: ' || x_return_status);

      --fnd_file.put_line (fnd_file.LOG,'x_msg_count: ' || x_msg_count);
      --fnd_file.put_line (fnd_file.LOG,'x_msg_data: ' || x_msg_data);
      IF x_return_status <> 'S'
      THEN
         IF x_msg_count = 1
         THEN
            v_error_msg := x_msg_data;
         ELSIF NVL (x_msg_count, 0) > 1
         THEN
            FOR i IN 1 .. x_msg_count
            LOOP
               fnd_msg_pub.get (p_msg_index          => i,
                                p_data               => x_msg_data,
                                p_msg_index_out      => l_msg_index_out
                               );
               v_error_msg := NVL (v_error_msg, ' ') || x_msg_data || ' ';
            END LOOP;

            v_error_msg := TRIM (v_error_msg);
         END IF;
      END IF;

      RETURN l_party_id;
   END;

   PROCEDURE create_customer_contact (
      p_first_name             VARCHAR2,
      p_last_name              VARCHAR2,
      p_exp_compliance         VARCHAR2,
      p_executive              VARCHAR2,
      p_party_id               NUMBER,
      p_party_rel_id     OUT   NUMBER,
      x_error_message    OUT   VARCHAR2
   )
   IS
      l_org_contact_rec     hz_party_contact_v2pub.org_contact_rec_type;
      l_org_contact_id      NUMBER;
      l_party_id            NUMBER;
      l_party_number        VARCHAR2 (2000);
      -- Variables to store values of out parameters for debugging purposes.
      x_return_status       VARCHAR2 (2000);
      x_msg_count           NUMBER;
      x_msg_data            VARCHAR2 (2000);
      -- Constant variables.
      g_created_by_module   VARCHAR2 (30)                        := 'HZ_CPUI';
      v_error_msg           VARCHAR2 (4000);
      l_msg_index_out       NUMBER;
   BEGIN
---THIS IS THE SUBJECT ID (PERSON INFO)
      l_org_contact_rec.party_rel_rec.subject_id :=
                                    create_person (p_first_name, p_last_name);
      l_org_contact_rec.party_rel_rec.attribute2 := p_exp_compliance;
      l_org_contact_rec.party_rel_rec.attribute3 := p_executive;
      l_org_contact_rec.party_rel_rec.subject_type := 'PERSON';
      l_org_contact_rec.party_rel_rec.subject_table_name := 'HZ_PARTIES';
---THIS IS THE OBJECT ID (ORGANIZATION INFO)
      l_org_contact_rec.party_rel_rec.object_id := p_party_id;
      l_org_contact_rec.party_rel_rec.object_type := 'ORGANIZATION';
      l_org_contact_rec.party_rel_rec.object_table_name := 'HZ_PARTIES';
      l_org_contact_rec.party_rel_rec.relationship_code := 'CONTACT_OF';
      l_org_contact_rec.party_rel_rec.relationship_type := 'CONTACT';
      l_org_contact_rec.created_by_module := g_created_by_module;
      hz_party_contact_v2pub.create_org_contact
                                     (p_init_msg_list        => 'T',
                                      p_org_contact_rec      => l_org_contact_rec,
                                      x_org_contact_id       => l_org_contact_id,
                                      x_party_rel_id         => l_party_id,
                                      x_party_id             => p_party_rel_id,
                                      x_party_number         => l_party_number,
                                      x_return_status        => x_return_status,
                                      x_msg_count            => x_msg_count,
                                      x_msg_data             => x_msg_data
                                     );

      -- Print log to buffer.
      --fnd_file.put_line (fnd_file.LOG,'Create_customer_contact ');
      --fnd_file.put_line (fnd_file.LOG,'x_return_status: ' || x_return_status);

      --fnd_file.put_line (fnd_file.LOG,'x_msg_count: ' || x_msg_count);
      --fnd_file.put_line (fnd_file.LOG,'x_msg_data: ' || x_msg_data);
      IF x_return_status <> 'S'
      THEN
         IF x_msg_count = 1
         THEN
            v_error_msg := x_msg_data;
         ELSIF NVL (x_msg_count, 0) > 1
         THEN
            FOR i IN 1 .. x_msg_count
            LOOP
               fnd_msg_pub.get (p_msg_index          => i,
                                p_data               => x_msg_data,
                                p_msg_index_out      => l_msg_index_out
                               );
               v_error_msg :=
                  SUBSTR (NVL (v_error_msg, ' ') || x_msg_data || ' ', 1,
                          4000);
            END LOOP;

            v_error_msg := TRIM (v_error_msg);
         END IF;
      END IF;

      x_error_message := v_error_msg;
   END;

   PROCEDURE create_customer_contact_role (
      p_cust_account_id              NUMBER,
      p_cust_acct_site_id            NUMBER,
      p_party_id                     NUMBER,
      p_exp_compliance               VARCHAR2,
      p_executive                    VARCHAR2,
      p_cust_account_role_id   OUT   NUMBER,
      x_error_message          OUT   VARCHAR2
   )
   IS
      l_customer_rec        hz_cust_account_role_v2pub.cust_account_role_rec_type;
      l_role_resp_rec       hz_cust_account_role_v2pub.role_responsibility_rec_type;
      -- Variables to store values of out parameters for debugging purposes.
      x_return_status       VARCHAR2 (2000);
      x_msg_count           NUMBER;
      x_msg_data            VARCHAR2 (2000);
      -- Constant variables.
      g_created_by_module   VARCHAR2 (30)                        := 'HZ_CPUI';
      v_error_msg           VARCHAR2 (4000);
      l_msg_index_out       NUMBER;
      l_responsibility_id   NUMBER;
   BEGIN
      l_customer_rec.party_id := p_party_id;
      l_customer_rec.cust_account_id := p_cust_account_id;
      l_customer_rec.cust_acct_site_id := p_cust_acct_site_id;
      l_customer_rec.attribute2 := p_exp_compliance;
      l_customer_rec.attribute3 := p_executive;
      l_customer_rec.primary_flag := 'N';
      l_customer_rec.role_type := 'CONTACT';
      l_customer_rec.created_by_module := g_created_by_module;
      hz_cust_account_role_v2pub.create_cust_account_role
                           (p_init_msg_list              => fnd_api.g_false,
                            p_cust_account_role_rec      => l_customer_rec,
                            x_cust_account_role_id       => p_cust_account_role_id,
                            x_return_status              => x_return_status,
                            x_msg_count                  => x_msg_count,
                            x_msg_data                   => x_msg_data
                           );

      -- Print log to buffer.
      --fnd_file.put_line (fnd_file.LOG,'Role x_return_status: ' || x_return_status);

      --fnd_file.put_line (fnd_file.LOG,'x_msg_count: ' || x_msg_count);
      --fnd_file.put_line (fnd_file.LOG,'x_msg_data: ' || x_msg_data);
      IF x_return_status <> 'S'
      THEN
         IF x_msg_count = 1
         THEN
            v_error_msg := x_msg_data;
         ELSIF NVL (x_msg_count, 0) > 1
         THEN
            FOR i IN 1 .. x_msg_count
            LOOP
               fnd_msg_pub.get (p_msg_index          => i,
                                p_data               => x_msg_data,
                                p_msg_index_out      => l_msg_index_out
                               );
               v_error_msg :=
                  SUBSTR (NVL (v_error_msg, ' ') || x_msg_data || ' ', 1,
                          4000);
            END LOOP;

            v_error_msg := TRIM (v_error_msg);
         END IF;
      END IF;

      l_role_resp_rec.responsibility_id := p_cust_account_role_id;
      l_role_resp_rec.cust_account_role_id := p_cust_account_role_id;
      l_role_resp_rec.responsibility_type := 'BILL_TO';
      l_role_resp_rec.primary_flag := 'N';
      --orig_system_reference                   VARCHAR2(240),
      l_role_resp_rec.created_by_module := g_created_by_module;
      --l_role_resp_rec.application_id := 222;
      hz_cust_account_role_v2pub.create_role_responsibility
                                (p_init_msg_list                => fnd_api.g_false,
                                 p_role_responsibility_rec      => l_role_resp_rec,
                                 x_responsibility_id            => l_responsibility_id,
                                 x_return_status                => x_return_status,
                                 x_msg_count                    => x_msg_count,
                                 x_msg_data                     => x_msg_data
                                );

      --fnd_file.put_line (fnd_file.LOG,'Role Resp x_return_status: ' || x_return_status);
      IF x_return_status <> 'S'
      THEN
         IF x_msg_count = 1
         THEN
            v_error_msg := x_msg_data;
         ELSIF NVL (x_msg_count, 0) > 1
         THEN
            FOR i IN 1 .. x_msg_count
            LOOP
               fnd_msg_pub.get (p_msg_index          => i,
                                p_data               => x_msg_data,
                                p_msg_index_out      => l_msg_index_out
                               );
               v_error_msg :=
                  SUBSTR (NVL (v_error_msg, ' ') || x_msg_data || ' ', 1,
                          4000);
            END LOOP;

            v_error_msg := TRIM (v_error_msg);
         END IF;
      END IF;

      x_error_message := v_error_msg;
   END;

   PROCEDURE create_customer_contact_email (
      p_party_site_id            NUMBER,
      p_email                    VARCHAR2,
      x_contact_point_id   OUT   NUMBER,
      x_error_message      OUT   VARCHAR2
   )
   IS
      l_contact_point_rec   hz_contact_point_v2pub.contact_point_rec_type;
      l_email_rec           hz_contact_point_v2pub.email_rec_type;
      -- Variables to store values of out parameters for debugging purposes.
      x_return_status       VARCHAR2 (2000);
      x_msg_count           NUMBER;
      x_msg_data            VARCHAR2 (2000);
      -- Constant variables.
      g_created_by_module   VARCHAR2 (30)                        := 'HZ_CPUI';
      v_error_msg           VARCHAR2 (4000);
      l_msg_index_out       NUMBER;
   BEGIN
      -- Populate p_contact_point_rec and p_email_rec
      l_contact_point_rec.contact_point_type := 'EMAIL';
      l_contact_point_rec.owner_table_name := 'HZ_PARTIES';
      l_contact_point_rec.owner_table_id := p_party_site_id;
      l_contact_point_rec.contact_point_purpose := 'BUSINESS';
      l_contact_point_rec.created_by_module := g_created_by_module;
      l_email_rec.email_address := p_email;
      hz_contact_point_v2pub.create_contact_point
                                 (p_init_msg_list          => fnd_api.g_false,
                                  p_contact_point_rec      => l_contact_point_rec,
                                  p_email_rec              => l_email_rec,
--p_phone_rec => l_phone_rec,
                                  x_contact_point_id       => x_contact_point_id,
                                  x_return_status          => x_return_status,
                                  x_msg_count              => x_msg_count,
                                  x_msg_data               => x_msg_data
                                 );

      -- Print log to buffer.
      --fnd_file.put_line (fnd_file.LOG,'x_return_status: ' || x_return_status);

      --fnd_file.put_line (fnd_file.LOG,'x_msg_count: ' || x_msg_count);
      --fnd_file.put_line (fnd_file.LOG,'x_msg_data: ' || x_msg_data);
      IF x_return_status <> 'S'
      THEN
         IF x_msg_count = 1
         THEN
            v_error_msg := x_msg_data;
         ELSIF NVL (x_msg_count, 0) > 1
         THEN
            FOR i IN 1 .. x_msg_count
            LOOP
               fnd_msg_pub.get (p_msg_index          => i,
                                p_data               => x_msg_data,
                                p_msg_index_out      => l_msg_index_out
                               );
               v_error_msg :=
                  SUBSTR (NVL (v_error_msg, ' ') || x_msg_data || ' ', 1,
                          4000);
            END LOOP;

            v_error_msg := TRIM (v_error_msg);
         END IF;
      END IF;

      x_error_message := v_error_msg;
   END;

   PROCEDURE create_customer_contact_mobile (
      p_party_site_id            NUMBER,
      p_mobile_number            VARCHAR2,
      x_contact_point_id   OUT   NUMBER,
      x_error_message      OUT   VARCHAR2
   )
   IS
      l_contact_point_rec   hz_contact_point_v2pub.contact_point_rec_type;
      l_phone_rec           hz_contact_point_v2pub.phone_rec_type;
      -- Variables to store values of out parameters for debugging purposes.
      x_return_status       VARCHAR2 (2000);
      x_msg_count           NUMBER;
      x_msg_data            VARCHAR2 (2000);
      -- Constant variables.
      g_created_by_module   VARCHAR2 (30)                        := 'HZ_CPUI';
      v_error_msg           VARCHAR2 (4000);
      l_msg_index_out       NUMBER;
   BEGIN
      -- Populate p_contact_point_rec and p_email_rec
      l_contact_point_rec.contact_point_type := 'PHONE';
      l_contact_point_rec.owner_table_name := 'HZ_PARTIES';
      l_contact_point_rec.owner_table_id := p_party_site_id;
      l_contact_point_rec.contact_point_purpose := 'BUSINESS';
      l_contact_point_rec.created_by_module := g_created_by_module;
      l_phone_rec.raw_phone_number := p_mobile_number;
      l_phone_rec.phone_line_type := 'MOBILE';
      hz_contact_point_v2pub.create_contact_point
                                 (p_init_msg_list          => fnd_api.g_false,
                                  p_contact_point_rec      => l_contact_point_rec,
                                  p_phone_rec              => l_phone_rec,
                                  x_contact_point_id       => x_contact_point_id,
                                  x_return_status          => x_return_status,
                                  x_msg_count              => x_msg_count,
                                  x_msg_data               => x_msg_data
                                 );

      -- Print log to buffer.
      --fnd_file.put_line (fnd_file.LOG,'x_return_status: ' || x_return_status);

      --fnd_file.put_line (fnd_file.LOG,'x_msg_count: ' || x_msg_count);
      --fnd_file.put_line (fnd_file.LOG,'x_msg_data: ' || x_msg_data);
      IF x_return_status <> 'S'
      THEN
         IF x_msg_count = 1
         THEN
            v_error_msg := x_msg_data;
         ELSIF NVL (x_msg_count, 0) > 1
         THEN
            FOR i IN 1 .. x_msg_count
            LOOP
               fnd_msg_pub.get (p_msg_index          => i,
                                p_data               => x_msg_data,
                                p_msg_index_out      => l_msg_index_out
                               );
               v_error_msg :=
                  SUBSTR (NVL (v_error_msg, ' ') || x_msg_data || ' ', 1,
                          4000);
            END LOOP;

            v_error_msg := TRIM (v_error_msg);
         END IF;
      END IF;

      x_error_message := v_error_msg;
   END;

   PROCEDURE create_customer_contact_phone (
      p_party_site_id            NUMBER,
      p_phone_number             VARCHAR2,
      p_extn_number              VARCHAR2,
      x_contact_point_id   OUT   NUMBER,
      x_error_message      OUT   VARCHAR2
   )
   IS
      l_contact_point_rec   hz_contact_point_v2pub.contact_point_rec_type;
      l_phone_rec           hz_contact_point_v2pub.phone_rec_type;
      -- Variables to store values of out parameters for debugging purposes.
      x_return_status       VARCHAR2 (2000);
      x_msg_count           NUMBER;
      x_msg_data            VARCHAR2 (2000);
      -- Constant variables.
      g_created_by_module   VARCHAR2 (30)                        := 'HZ_CPUI';
      v_error_msg           VARCHAR2 (4000);
      l_msg_index_out       NUMBER;
   BEGIN
      -- Populate p_contact_point_rec and p_email_rec
      l_contact_point_rec.contact_point_type := 'PHONE';
      l_contact_point_rec.owner_table_name := 'HZ_PARTIES';
      l_contact_point_rec.owner_table_id := p_party_site_id;
      l_contact_point_rec.contact_point_purpose := 'BUSINESS';
      l_contact_point_rec.created_by_module := g_created_by_module;
      l_phone_rec.raw_phone_number := p_phone_number;
      l_phone_rec.phone_line_type := 'GEN';
      l_phone_rec.phone_extension := p_extn_number;
      hz_contact_point_v2pub.create_contact_point
                                 (p_init_msg_list          => fnd_api.g_false,
                                  p_contact_point_rec      => l_contact_point_rec,
                                  p_phone_rec              => l_phone_rec,
                                  x_contact_point_id       => x_contact_point_id,
                                  x_return_status          => x_return_status,
                                  x_msg_count              => x_msg_count,
                                  x_msg_data               => x_msg_data
                                 );

      -- Print log to buffer.
      --fnd_file.put_line (fnd_file.LOG,'x_return_status: ' || x_return_status);

      --fnd_file.put_line (fnd_file.LOG,'x_msg_count: ' || x_msg_count);
      --fnd_file.put_line (fnd_file.LOG,'x_msg_data: ' || x_msg_data);
      IF x_return_status <> 'S'
      THEN
         IF x_msg_count = 1
         THEN
            v_error_msg := x_msg_data;
         ELSIF NVL (x_msg_count, 0) > 1
         THEN
            FOR i IN 1 .. x_msg_count
            LOOP
               fnd_msg_pub.get (p_msg_index          => i,
                                p_data               => x_msg_data,
                                p_msg_index_out      => l_msg_index_out
                               );
               v_error_msg :=
                  SUBSTR (NVL (v_error_msg, ' ') || x_msg_data || ' ', 1,
                          4000);
            END LOOP;

            v_error_msg := TRIM (v_error_msg);
         END IF;
      END IF;

      x_error_message := v_error_msg;
   END;

   PROCEDURE create_customer_contact_fax (
      p_party_site_id            NUMBER,
      p_phone_number             VARCHAR2,
      x_contact_point_id   OUT   NUMBER,
      x_error_message      OUT   VARCHAR2
   )
   IS
      l_contact_point_rec   hz_contact_point_v2pub.contact_point_rec_type;
      l_phone_rec           hz_contact_point_v2pub.phone_rec_type;
      -- Variables to store values of out parameters for debugging purposes.
      x_return_status       VARCHAR2 (2000);
      x_msg_count           NUMBER;
      x_msg_data            VARCHAR2 (2000);
      l_msg_index_out       NUMBER;
      v_error_msg           VARCHAR2 (4000);
      -- Constant variables.
      g_created_by_module   VARCHAR2 (30)                        := 'HZ_CPUI';
   BEGIN
      -- Populate p_contact_point_rec and p_email_rec
      l_contact_point_rec.contact_point_type := 'PHONE';
      l_contact_point_rec.owner_table_name := 'HZ_PARTIES';
      l_contact_point_rec.owner_table_id := p_party_site_id;
      l_contact_point_rec.contact_point_purpose := 'BUSINESS';
      l_contact_point_rec.created_by_module := g_created_by_module;
      l_phone_rec.raw_phone_number := p_phone_number;
      l_phone_rec.phone_line_type := 'FAX';
      hz_contact_point_v2pub.create_contact_point
                                 (p_init_msg_list          => fnd_api.g_false,
                                  p_contact_point_rec      => l_contact_point_rec,
                                  p_phone_rec              => l_phone_rec,
                                  x_contact_point_id       => x_contact_point_id,
                                  x_return_status          => x_return_status,
                                  x_msg_count              => x_msg_count,
                                  x_msg_data               => x_msg_data
                                 );

      -- Print log to buffer.
      --fnd_file.put_line (fnd_file.LOG,'x_return_status: ' || x_return_status);

      --fnd_file.put_line (fnd_file.LOG,'x_msg_count: ' || x_msg_count);
      --fnd_file.put_line (fnd_file.LOG,'x_msg_data: ' || x_msg_data);
      IF x_msg_count > 1
      THEN
         FOR i IN 1 .. x_msg_count
         LOOP
            fnd_msg_pub.get (p_msg_index          => i,
                             p_data               => x_msg_data,
                             p_msg_index_out      => l_msg_index_out
                            );
            v_error_msg :=
                  SUBSTR (NVL (v_error_msg, ' ') || x_msg_data || ' ', 1,
                          4000);
         /*
         DBMS_OUTPUT.put_line
                   (   i
                    || '. '
                    || SUBSTR
                            (fnd_msg_pub.get (p_encoded      => fnd_api.g_false),
                             1,
                             255
                            )
                   );
          */
         END LOOP;

         x_error_message := v_error_msg;
      END IF;
   --x_error_message:= v_error_msg;
   END;

   PROCEDURE insert_data (
      x_errbuff        OUT NOCOPY   VARCHAR2,
      x_retcode        OUT NOCOPY   NUMBER,
      p_organization                VARCHAR2
   )
   IS
      l_user_id                    NUMBER;
      l_appl_short_name            VARCHAR2 (100);
      l_resp_id                    NUMBER;
      l_appl_id                    NUMBER;
      l_party_id                   NUMBER;
      l_party_number               VARCHAR2 (100);
      l_profile_id                 NUMBER;
      l_cust_account_id            NUMBER;
      l_account_number             VARCHAR2 (2000);
      l_party_site_id              NUMBER;
      l_party_site_number          NUMBER;
      l_cust_acct_site_id          NUMBER;
      l_site_use_id                NUMBER;
      l_party_rel_id               NUMBER;
      l_contact_point_id           NUMBER;
      l_cust_account_role_id       NUMBER;
      v_payment_term_id            NUMBER;
      v_gl_account_id              NUMBER;
      l_cust_account_profile_id    NUMBER;
      l_cust_act_prof_amt_id       NUMBER;
      l_error_message              VARCHAR2 (10000);
      v_error_message              VARCHAR2 (10000);
      v_check_message              VARCHAR2 (10000);
      v_org_id                     NUMBER;
      v_territory_code             VARCHAR2 (30);
      v_salesrep_id                NUMBER;
      v_territory_id               NUMBER;
      l_customer_class_code        VARCHAR2 (150);
      l_customer_catg_code         VARCHAR2 (150);
      l_category_code              VARCHAR2 (150);
      lv_frt_term                  VARCHAR2 (150);
      lv_ship_frt_term             VARCHAR2 (150);
      ln_cust_account_profile_id   NUMBER;
      ln_salesrep_id               NUMBER;
      l_cust_name_alias            VARCHAR2 (240);
   BEGIN
      BEGIN
         SELECT fnd.user_id, application.application_short_name,
                fresp.responsibility_id, fresp.application_id
           INTO l_user_id, l_appl_short_name,
                l_resp_id, l_appl_id
           FROM fnd_user fnd,
                fnd_responsibility_tl fresp,
                fnd_application application
          WHERE fnd.user_name = fnd_global.user_name
            AND fresp.application_id = application.application_id
            AND fresp.responsibility_name = fnd_profile.VALUE ('RESP_NAME');
      EXCEPTION
         WHEN OTHERS
         THEN
            v_check_message := 'Error in APPS Initialization ';
            v_error_message := v_error_message || v_check_message;
      END;

      SELECT organization_id
        INTO v_org_id
        FROM hr_operating_units
       WHERE NAME = p_organization;

--      DBMS_OUTPUT.put_line
--                        ('**************Customer Creation Start**************');
      fnd_global.apps_initialize (user_id           => l_user_id,
                                  -- fnd_global.user_id,
                                  resp_id           => l_resp_id,
                                  --fnd_global.resp_id,
                                  resp_appl_id      => l_appl_id
                                 --fnd_global.resp_appl_id
                                 );
      mo_global.init ('AR');
      mo_global.set_org_context (v_org_id, NULL, 'AR');
      fnd_global.set_nls_context ('AMERICAN');
      mo_global.set_policy_context ('S', v_org_id);

      FOR rec IN
         (SELECT DISTINCT RTRIM (LTRIM (cust_name)) customer_name,
                          'ORGANIZATION' customer_type,
                          RTRIM (LTRIM (cust_name)) account_name,
                          RTRIM (LTRIM (cust_class)) cust_class,
                          RTRIM (LTRIM (cust_catg)) cust_catg,      -- div_dff
                          RTRIM (LTRIM (cust_num)) cust_num,
                          RTRIM (LTRIM (acct_type)) acct_type
                     FROM xxdbl_customer_dm_tbl
                    WHERE 1 = 1
                      AND cust_account_id IS NULL
                      -- AND RTRIM (LTRIM (cust_num)) = '13427'
                      -- AND RTRIM (LTRIM (cust_name)) IN ('APEX TEXTILE PRINTING MILLS LIMITED','HAMS (BD) LTD.')
                       --= 'SHANTA EXPRESSIONS LTD.'
                      AND RTRIM (LTRIM (org_name)) = p_organization)
      LOOP
         SELECT organization_id
           INTO v_org_id
           FROM hr_operating_units
          WHERE NAME = p_organization;

         fnd_file.put_line (fnd_file.LOG, 'v_org_id ' || v_org_id);
         l_party_id := NULL;
         l_party_number := NULL;
         l_profile_id := NULL;
         l_cust_account_id := NULL;
         l_account_number := NULL;
         l_cust_account_profile_id := NULL;
         v_error_message := NULL;
         l_error_message := NULL;
         v_check_message := NULL;
         l_cust_name_alias := NULL;

         BEGIN
            SELECT hca.cust_account_id, hca.party_id, hp.party_number,
                   hcp.cust_account_profile_id
              INTO l_cust_account_id, l_party_id, l_party_number,
                   l_profile_id
              FROM hz_cust_accounts hca,
                   hz_parties hp,
                   hz_customer_profiles hcp
             WHERE NVL (hp.organization_name_phonetic, hca.account_number) =
                                                  RTRIM (LTRIM (rec.cust_num))
               AND hca.party_id = hp.party_id
               AND hca.cust_account_id = hcp.cust_account_id
               AND ROWNUM = 1;
         /* SELECT hca.cust_account_id,party.party_id
            INTO l_cust_account_id,l_party_id
            FROM hz_cust_accounts hca, hz_parties party
           WHERE hca.party_id = party.party_id
             AND party.party_name = rec.customer_name;*/
         EXCEPTION
            WHEN OTHERS
            THEN
               l_cust_account_id := NULL;
               l_party_id := NULL;
               l_party_number := NULL;
               l_profile_id := NULL;
         END;

         --
         BEGIN
            IF rec.cust_catg IS NOT NULL
            THEN
               BEGIN
                  SELECT lookup_code
                    INTO l_category_code
                    FROM fnd_lookup_values
                   WHERE lookup_type = 'CUSTOMER_CATEGORY'
                     AND UPPER (lookup_code) = UPPER (rec.cust_catg);

                  fnd_file.put_line (fnd_file.LOG,
                                     'l_category_code ' || l_category_code
                                    );
               EXCEPTION
                  WHEN OTHERS
                  THEN
                     l_category_code := NULL;
                     v_check_message := 'Customer Category is not defined ';
                     v_error_message := v_error_message || v_check_message;
                     fnd_file.put_line (fnd_file.LOG, v_check_message);
               END;
            END IF;

            BEGIN
               SELECT DISTINCT RTRIM (LTRIM (cust_name_alias))
                          INTO l_cust_name_alias
                          FROM xxdbl_customer_dm_tbl
                         WHERE 1 = 1
                           AND RTRIM (LTRIM (cust_num)) = rec.cust_num
                           AND RTRIM (LTRIM (cust_num)) IS NOT NULL
                           AND ROWNUM = 1;
            EXCEPTION
               WHEN OTHERS
               THEN
                  l_cust_name_alias := NULL;
            END;

            IF l_cust_account_id IS NULL
            THEN
               fnd_file.put_line
                  (fnd_file.LOG,
                      '*********** Customer Creation Start for *********** : '
                   || rec.customer_name
                  );

               BEGIN
                  SELECT hca.cust_account_id, hca.party_id, hp.party_number,
                         hcp.cust_account_profile_id
                    INTO l_cust_account_id, l_party_id, l_party_number,
                         l_profile_id
                    FROM hz_cust_accounts hca,
                         hz_parties hp,
                         hz_customer_profiles hcp
                   WHERE NVL (hp.organization_name_phonetic,
                              hca.account_number
                             ) = RTRIM (LTRIM (rec.cust_num))
                     AND hca.party_id = hp.party_id
                     AND hca.cust_account_id = hcp.cust_account_id
                     AND ROWNUM = 1;
               EXCEPTION
                  WHEN NO_DATA_FOUND
                  THEN
                     create_customer (rec.customer_name,
                                      rec.customer_type,
                                      l_cust_name_alias,
                                      rec.cust_num,
                                      l_category_code,
                                      l_party_id,
                                      l_party_number,
                                      l_profile_id,
                                      l_error_message
                                     );
                     fnd_file.put_line (fnd_file.LOG,
                                        'Party Id : ' || l_party_id
                                       );
                     fnd_file.put_line
                                      (fnd_file.LOG,
                                          'Error Message at create_customer :'
                                       || l_error_message
                                      );
--
                     l_error_message := NULL;
                     create_account
                        (rec.account_name,
                         l_party_id,
                         l_party_number,
                         apps.xxdbl_dm_customer_pkg.cust_code_derive_fn
                                                                (rec.acct_type),
                         l_category_code,
                         l_profile_id,
                         NULL,              --               --pass to attri 1
                         NULL,
                         --rec.dff_catg,                  -- Attribute category
                         l_customer_class_code,
                         l_cust_account_id,
                         l_account_number,
                         l_error_message
                        );
                     l_error_message := SUBSTR (l_error_message, 1, 200);
                     v_error_message := v_error_message || l_error_message;
                     fnd_file.put_line (fnd_file.LOG,
                                           'cust_account_id is:'
                                        || l_cust_account_id
                                       );
                     fnd_file.put_line (fnd_file.LOG,
                                           'account_number is:'
                                        || l_account_number
                                       );
                     fnd_file.put_line
                             (fnd_file.LOG,
                                 'Create Customer Account API Error Message :'
                              || l_error_message
                             );
                     v_error_message := l_error_message;

                     BEGIN
                        UPDATE xxdbl_customer_dm_tbl
                           SET cust_account_id = l_cust_account_id,
                               error_message = v_error_message
                         WHERE RTRIM (LTRIM (cust_num)) = rec.cust_num
                           AND RTRIM (LTRIM (org_name)) = p_organization;
                     EXCEPTION
                        WHEN OTHERS
                        THEN
                           NULL;
                     END;
                  WHEN OTHERS
                  THEN
                     l_party_id := NULL;
                     l_party_number := NULL;
                     l_profile_id := NULL;
                     l_cust_account_id := NULL;
                     l_account_number := NULL;
                     v_error_message :=
                        SUBSTR ('Error in Customer Create Account ' || SQLERRM,
                                1,
                                500
                               );
                     fnd_file.put_line (fnd_file.LOG,
                                           'Customer creation Error is:'
                                        || v_error_message
                                       );

                     BEGIN
                        UPDATE xxdbl_customer_dm_tbl
                           SET cust_account_id = l_cust_account_id,
                               error_message = 'FAILED ~ ' || v_error_message
                         WHERE RTRIM (LTRIM (cust_num)) = rec.cust_num
                           AND RTRIM (LTRIM (org_name)) = p_organization;
                     EXCEPTION
                        WHEN OTHERS
                        THEN
                           NULL;
                     END;
               END;
            END IF;

            -- Bill to Creation step by step
            IF l_cust_account_id IS NOT NULL
            THEN
               DBMS_OUTPUT.put_line
                  ('**************Customer Bill To Site Creation Start**************'
                  );

               FOR r_site IN
                  (SELECT DISTINCT RTRIM (LTRIM (cust_name)) customer_name,
                                   cust_catg, UPPER (country) country,

--                                   RTRIM
--                                        (LTRIM (bill_to_loc)
--                                        ) bill_to_site_name,
                                   RTRIM (LTRIM (addr1)) bill_to_addr1,
                                   RTRIM (LTRIM (addr2)) bill_to_addr2,
                                   RTRIM (LTRIM (addr3)) bill_to_addr3,
                                   RTRIM
                                      (LTRIM (postal_code)
                                      ) bill_to_postal_code,

                                   --  div_dff
                                   payment_terms,
                                   RTRIM
                                      (LTRIM (ship_to_loc_dff)
                                      ) ship_to_loc_dff,
                                   RTRIM
                                      (LTRIM (ship_to_site_postal_code)
                                      ) ship_to_site_postal_code,
                                   RTRIM
                                      (LTRIM (sales_order_type)
                                      ) sales_order_type,
                                   RTRIM (LTRIM (pricelistname))
                                                                pricelistname,
                                   RTRIM (LTRIM (freight_term)) freight_term,
                                   credit_limit, cust_num, state, city,
                                   postal_code,
                                   RTRIM
                                      (LTRIM (country_iso_code)
                                      ) country_iso_code
                              FROM xxdbl_customer_dm_tbl
                             WHERE RTRIM (LTRIM (cust_num)) =
                                                  RTRIM (LTRIM (rec.cust_num))
                               AND RTRIM (LTRIM (org_name)) = p_organization
                               AND bill_to_site_use_id IS NULL
                               AND bill_to_flag = 'YES'
                               AND RTRIM (LTRIM (cust_num)) IS NOT NULL
                                                                       -- AND RTRIM (LTRIM (cust_name)) IN ('APEX TEXTILE PRINTING MILLS LIMITED','HAMS (BD) LTD.')
                  )
               LOOP
                  l_party_site_id := NULL;
                  l_party_site_number := NULL;
                  l_cust_acct_site_id := NULL;
                  l_site_use_id := NULL;
                  v_payment_term_id := NULL;
                  v_gl_account_id := NULL;
                  l_cust_account_profile_id := NULL;
                  l_cust_act_prof_amt_id := NULL;
                  v_territory_code := NULL;
                  v_salesrep_id := NULL;
                  v_territory_id := NULL;
                  --                  v_error_message := NULL;
                  v_check_message := NULL;

                  IF r_site.country IS NOT NULL
                  THEN
                     BEGIN
                        SELECT territory_code
                          INTO v_territory_code
                          FROM fnd_territories
                         WHERE               --nls_territory = r_site.country;
                               territory_code = r_site.country_iso_code;

                        fnd_file.put_line (fnd_file.LOG,
                                              'v_territory_code  '
                                           || v_territory_code
                                          );
                     EXCEPTION
                        WHEN OTHERS
                        THEN
                           v_territory_code := NULL;
                           v_check_message :=
                                             'Territory Code is not defined ';
                           fnd_file.put_line (fnd_file.LOG, v_check_message);
                           v_error_message :=
                                           v_error_message || v_check_message;
                     END;
                  END IF;

                  IF r_site.cust_catg IS NOT NULL
                  THEN
                     -- Customer Category
                     BEGIN
                        SELECT lookup_code
                          INTO l_customer_catg_code
                          FROM fnd_lookup_values
                         WHERE lookup_type = 'CUSTOMER_CATEGORY'
                           AND UPPER (lookup_code) = UPPER (r_site.cust_catg);

                        fnd_file.put_line (fnd_file.LOG,
                                              'Customer catg code '
                                           || l_customer_catg_code
                                          );
                     EXCEPTION
                        WHEN OTHERS
                        THEN
                           l_customer_catg_code := NULL;
                           v_check_message :=
                                          'Customer Category is not defined ';
                           fnd_file.put_line (fnd_file.LOG, v_check_message);
                           v_error_message :=
                                           v_error_message || v_check_message;
                     END;
                  END IF;

                  ----------------------------- Bill to Site Creation Starts---------------------
                  l_error_message := NULL;
                  l_party_site_id := NULL;
                  l_party_site_number := NULL;

                  BEGIN
                     BEGIN
                        SELECT hzps.party_site_id, hcasa.cust_acct_site_id,
                               hcsua.site_use_id
                          INTO l_party_site_id, l_cust_acct_site_id,
                               l_site_use_id
                          FROM hz_cust_accounts hca,
                               hz_parties party,
                               hz_party_sites hzps,
                               hz_locations hzl,
                               hz_cust_acct_sites_all hcasa,
                               hz_cust_site_uses_all hcsua
                         WHERE hca.party_id = party.party_id
                           AND party.party_id = hzps.party_id
                           AND hzps.party_site_id = hcasa.party_site_id
                           AND hzps.location_id = hzl.location_id
                           AND hca.cust_account_id = hcasa.cust_account_id
                           AND hcasa.cust_acct_site_id =
                                                       hcsua.cust_acct_site_id
                           AND hcsua.site_use_code = 'BILL_TO'
                           AND NVL (party.organization_name_phonetic,
                                    hca.account_number
                                   ) = r_site.cust_num
                           --   AND hzps.party_site_name = r_site.bill_to_site_name
                           AND hcsua.org_id = v_org_id
                           AND ROWNUM = 1;
                     EXCEPTION
                        WHEN OTHERS
                        THEN
                           l_party_site_id := NULL;
                           l_cust_acct_site_id := NULL;
                           l_site_use_id := NULL;
                     END;

                     IF l_site_use_id IS NULL
                     THEN
                        -- Bill to Create Party Site
                        BEGIN
                           create_party_site
                                      (l_party_id,
                                       r_site.bill_to_addr1, -- address_line1,
                                       r_site.bill_to_addr2,  --address_line2,
                                       r_site.bill_to_addr3,  --address_line3,
                                       NULL,           --r_site.address_line4,
                                       r_site.city,
                                       r_site.postal_code,
                                       r_site.state,
                                       v_territory_code,     --r_site.country,
                                       NULL,                  --r_site.county,
                                       NULL,                   --zone/province
                                       NULL,                  --dff attribute1
                                       NULL,
                                       --r_site.bill_to_site_name,          -- Site name
                                       NULL,                -- r_site.div_dff,
                                       NULL,         --r_site.SHIP_TO_LOC_DFF,
                                       l_party_site_id,
                                       l_party_site_number,
                                       l_error_message
                                      );
                           --                        l_error_message := SUBSTR (l_error_message, 1, 200);
                           DBMS_OUTPUT.put_line
                                        (   'BILL TO Party Site API Message :'
                                         || l_error_message
                                        );
                           v_error_message :=
                                            v_error_message || l_error_message;
                        EXCEPTION
                           WHEN OTHERS
                           THEN
                              v_check_message :=
                                 SUBSTR
                                    (   'Error in Customer BILL To Party Site Creation -''~'
                                     || SQLERRM,
                                     1,
                                     500
                                    );
                              fnd_file.put_line (fnd_file.LOG,
                                                 v_check_message);
                              l_party_site_id := NULL;
                        --                           v_error_message :=
                        --                                            v_error_message || v_check_message;
                        END;

                        --                     v_error_message := v_error_message || l_error_message;
                        l_error_message := NULL;
                        l_cust_acct_site_id := NULL;

                        -- Create Customer Site
                        BEGIN
                           create_customer_site (l_cust_account_id,
                                                 l_party_site_id,
                                                 v_org_id,
                                                 NULL,             --territory
                                                 l_customer_catg_code,
                                                 l_cust_acct_site_id,
                                                 l_error_message
                                                );
                           l_error_message := SUBSTR (l_error_message, 1, 200);
                           fnd_file.put_line (fnd_file.LOG,
                                                 'Customer Account Site '
                                              || l_cust_acct_site_id
                                             );
                           DBMS_OUTPUT.put_line
                                     (   'Customer Account Site API Message :'
                                      || l_error_message
                                     );
                           v_error_message :=
                                            v_error_message || l_error_message;
                        EXCEPTION
                           WHEN OTHERS
                           THEN
                              NULL;
                              v_check_message :=
                                 SUBSTR ('Error in Customer Site :' || SQLERRM,
                                         1,
                                         500
                                        );
                              fnd_file.put_line (fnd_file.LOG,
                                                 v_check_message);
                              v_error_message :=
                                            v_error_message || v_check_message;
                        END;

                        --                     v_error_message := v_error_message || l_error_message;
                        IF r_site.payment_terms IS NOT NULL
                        THEN
                           -- Payment Terms
                           BEGIN
                              SELECT term_id
                                INTO v_payment_term_id
                                FROM ra_terms_tl
                               WHERE UPPER (NAME) =
                                                  UPPER (r_site.payment_terms);
                           EXCEPTION
                              WHEN OTHERS
                              THEN
                                 v_payment_term_id := NULL;
                                 v_check_message :=
                                              'Payment Terms is not defined ';
                                 fnd_file.put_line (fnd_file.LOG,
                                                    v_check_message
                                                   );
                                 v_error_message :=
                                            v_error_message || v_check_message;
                           END;
                        END IF;

                        l_error_message := NULL;
                        l_site_use_id := NULL;
--                        fnd_file.put_line (fnd_file.LOG,
--                                              'r_site.freight_term '
--                                           || r_site.freight_term
--                                          );
                        lv_frt_term := NULL;

                        -- Create Customer Bill Site Use
                        BEGIN
                           create_customer_site_uses
                                            (l_cust_acct_site_id,
                                             'BILL_TO',
                                             NULL, --r_site.bill_to_site_name,
                                             v_payment_term_id,
                                             NULL,          --r_site.tax_code,
                                             NULL,          --v_gl_account_id,
                                             v_org_id,
                                             NULL,            --v_salesrep_id,
                                             NULL,           --v_territory_id,
                                             NULL,
                                             NULL,
                                             NULL,
                                             NULL,
                                             l_site_use_id,
                                             l_error_message
                                            );
                           l_error_message := SUBSTR (l_error_message, 1, 200);
                           DBMS_OUTPUT.put_line
                                    (   'Customer Account Bill Site Use Id : '
                                     || l_site_use_id
                                    );
                           fnd_file.put_line
                                     (fnd_file.LOG,
                                         'Customer Account Bill Site Use Id :'
                                      || l_site_use_id
                                     );
                           DBMS_OUTPUT.put_line
                              (   'Customer Account Bill to Site Use API Message :'
                               || l_error_message
                              );
                           v_error_message :=
                                            v_error_message || l_error_message;
                        EXCEPTION
                           WHEN OTHERS
                           THEN
                              NULL;
                              v_check_message :=
                                 SUBSTR
                                      (   v_error_message
                                       || 'Error in Customer Bill Site Uses'
                                       || SQLERRM,
                                       1,
                                       500
                                      );
                              fnd_file.put_line (fnd_file.LOG,
                                                 v_check_message);
                              v_error_message :=
                                            v_error_message || v_check_message;
                        END;
                     END IF;

                     --                     v_error_message := v_error_message || l_error_message;
                     BEGIN
                        UPDATE xxdbl_customer_dm_tbl
                           SET cust_account_id = l_cust_account_id,
                               cust_acct_site_id = l_cust_acct_site_id,
                               bill_to_site_use_id = l_site_use_id,
                               error_message = v_error_message
                         WHERE RTRIM (LTRIM (cust_num)) = r_site.cust_num
                           AND RTRIM (LTRIM (org_name)) = p_organization
                           AND RTRIM (LTRIM (cust_num)) IS NOT NULL
--                           AND RTRIM (LTRIM (bill_to_loc)) =
--                                                      r_site.bill_to_site_name
                        ;
                     EXCEPTION
                        WHEN OTHERS
                        THEN
                           NULL;
                     END;

                     BEGIN
                        create_cust_profile
                           (p_cust_acct_id                 => l_cust_account_id,
                            p_site_use_id                  => l_site_use_id,
                            x_cust_account_profile_id      => l_cust_account_profile_id,
                            x_error_message                => l_error_message
                           );
                        DBMS_OUTPUT.put_line
                           (   ' create cust profile : l_cust_account_profile_id '
                            || l_cust_account_profile_id
                           );
                        fnd_file.put_line
                           (fnd_file.LOG,
                               ' create cust profile : l_cust_account_profile_id '
                            || l_cust_account_profile_id
                           );
                        DBMS_OUTPUT.put_line
                                  (   ' create cust profile : l_error_message'
                                   || l_error_message
                                  );
                     END;
                  END;
               END LOOP;
            END IF;

            ----------------------------- Bill to Site Creation Ends---------------------

            ----------------------------- Ship to Site creation starts ------------------
            IF l_cust_account_id IS NOT NULL
            THEN
               DBMS_OUTPUT.put_line
                  ('**************Customer Ship To Site Creation Start**************'
                  );

               FOR r_site IN
                  (SELECT DISTINCT RTRIM (LTRIM (cust_name)) customer_name,
                                   cust_catg, UPPER (country) country,

--                                   RTRIM
--                                        (LTRIM (bill_to_loc)
--                                        ) bill_to_site_name,
                                   postal_code,

--                                   RTRIM
--                                        (LTRIM (ship_to_loc)
--                                        ) ship_to_site_name,
                                   RTRIM (LTRIM (addr1)) ship_to_addr1,
                                   RTRIM (LTRIM (addr2)) ship_to_addr2,
                                   RTRIM (LTRIM (addr3)) ship_to_addr3, state,
                                   city,
--                                   RTRIM (LTRIM (ship_to_addr4))
--                                                                ship_to_addr4,
--
                                   --  div_dff,
                                        RTRIM (LTRIM (city)) ship_to_city,
                                   RTRIM (LTRIM (ship_to_state))
                                                                ship_to_state,
                                   RTRIM (LTRIM (ship_to_zone)) ship_to_zone,
                                   RTRIM
                                      (LTRIM (ship_to_province)
                                      ) ship_to_province,
                                   payment_terms, bill_to_site_use_id,
                                   RTRIM
                                      (LTRIM (ship_to_loc_dff)
                                      ) ship_to_loc_dff,
                                   RTRIM
                                      (LTRIM (ship_to_site_postal_code)
                                      ) ship_to_site_postal_code,
                                   RTRIM
                                      (LTRIM (sales_order_type)
                                      ) sales_order_type,
                                   RTRIM (LTRIM (pricelistname))
                                                                pricelistname,
                                   RTRIM (LTRIM (freight_term)) freight_term,
                                   RTRIM (LTRIM (sr_empid)) sr_empid,
                                   RTRIM (LTRIM (cust_num)) cust_num,
                                   RTRIM
                                      (LTRIM (country_iso_code)
                                      ) country_iso_code
                              FROM xxdbl_customer_dm_tbl
                             WHERE RTRIM (LTRIM (cust_num)) = rec.cust_num
                               AND RTRIM (LTRIM (org_name)) = p_organization
                               AND ship_to_site_use_id IS NULL
                               -- AND ship_to_loc IS NOT NULL
                               AND ship_to_flag = 'YES'
                                                       --  AND RTRIM (LTRIM (cust_name)) IN ('APEX TEXTILE PRINTING MILLS LIMITED','HAMS (BD) LTD.')
                  )
               LOOP
                  l_party_site_id := NULL;
                  l_party_site_number := NULL;
                  l_cust_acct_site_id := NULL;
                  l_site_use_id := NULL;
                  v_payment_term_id := NULL;
                  v_gl_account_id := NULL;
                  l_cust_account_profile_id := NULL;
                  l_cust_act_prof_amt_id := NULL;
                  v_territory_code := NULL;
                  v_salesrep_id := NULL;
                  v_territory_id := NULL;
--                  v_error_message := NULL;
                  v_check_message := NULL;
                  lv_ship_frt_term := NULL;

                  IF r_site.country IS NOT NULL
                  THEN
                     BEGIN
                        SELECT territory_code
                          INTO v_territory_code
                          FROM fnd_territories
                         WHERE territory_code = r_site.country_iso_code;
                     EXCEPTION
                        WHEN OTHERS
                        THEN
                           v_territory_code := NULL;
                           v_check_message := 'Error in Territory Code ';
                           fnd_file.put_line (fnd_file.LOG, v_check_message);
                           v_error_message :=
                                           v_error_message || v_check_message;
                     END;
                  END IF;

                  -- Customer Category
                  BEGIN
                     SELECT lookup_code
                       INTO l_customer_catg_code
                       FROM fnd_lookup_values
                      WHERE lookup_type = 'CUSTOMER_CATEGORY'
                        AND UPPER (lookup_code) = UPPER (r_site.cust_catg);
                  EXCEPTION
                     WHEN OTHERS
                     THEN
                        l_customer_catg_code := NULL;
                        v_error_message := 'Error in Customer Category';
                        fnd_file.put_line (fnd_file.LOG, v_error_message);
                        v_error_message := v_error_message || v_check_message;
                  END;

                  IF r_site.bill_to_site_use_id IS NULL
                  THEN
                     BEGIN
                        SELECT hcsua.site_use_id
                          INTO r_site.bill_to_site_use_id
                          FROM hz_cust_accounts hca,
                               hz_parties party,
                               hz_party_sites hzps,
                               hz_locations hzl,
                               hz_cust_acct_sites_all hcasa,
                               hz_cust_site_uses_all hcsua
                         WHERE hca.party_id = party.party_id
                           AND party.party_id = hzps.party_id
                           AND hzps.party_site_id = hcasa.party_site_id
                           AND hzps.location_id = hzl.location_id
                           AND hca.cust_account_id = hcasa.cust_account_id
                           AND hcasa.cust_acct_site_id =
                                                       hcsua.cust_acct_site_id
                           AND hcsua.site_use_code = 'BILL_TO'
                           AND hcsua.primary_flag = 'Y'
                           -- Added on 24-MAY-2016
                           AND NVL (party.organization_name_phonetic,
                                    hca.account_number
                                   ) = r_site.cust_num
                           -- AND hzps.party_site_name = r_site.bill_to_site_name
                           AND hcsua.org_id = v_org_id
                           AND ROWNUM = 1;
                     EXCEPTION
                        WHEN OTHERS
                        THEN
                           r_site.bill_to_site_use_id := NULL;
                     END;
                  END IF;

                  BEGIN
                     SELECT hzps.party_site_id, hcasa.cust_acct_site_id,
                            hcsua.site_use_id
                       INTO l_party_site_id, l_cust_acct_site_id,
                            l_site_use_id
                       FROM hz_cust_accounts hca,
                            hz_parties party,
                            hz_party_sites hzps,
                            hz_locations hzl,
                            hz_cust_acct_sites_all hcasa,
                            hz_cust_site_uses_all hcsua
                      WHERE hca.party_id = party.party_id
                        AND party.party_id = hzps.party_id
                        AND hzps.party_site_id = hcasa.party_site_id
                        AND hzps.location_id = hzl.location_id
                        AND hca.cust_account_id = hcasa.cust_account_id
                        AND hcasa.cust_acct_site_id = hcsua.cust_acct_site_id
                        AND hcsua.site_use_code = 'SHIP_TO'
                        AND NVL (party.organization_name_phonetic,
                                 hca.account_number
                                ) = r_site.cust_num
                        --   AND hzps.party_site_name = r_site.ship_to_site_name
                        AND hcsua.org_id = v_org_id
                        AND ROWNUM = 1;
                  EXCEPTION
                     WHEN OTHERS
                     THEN
                        l_party_site_id := NULL;
                        l_cust_acct_site_id := NULL;
                        l_site_use_id := NULL;
                  END;

                  ----------------------------- Ship to Site ---------------------
                  BEGIN
                     IF l_site_use_id IS NULL
                     THEN
                        l_error_message := NULL;
                        l_party_site_id := NULL;
                        l_party_site_number := NULL;

                        -- Create Ship to Party Site
                        BEGIN
                           create_party_site
                                      (l_party_id,
                                       r_site.ship_to_addr1, -- address_line1,
                                       r_site.ship_to_addr2,  --address_line2,
                                       r_site.ship_to_addr3,  --address_line3,
                                       NULL,
                                       ---- r_site.ship_to_addr4,   --r_site.address_line4,
                                       r_site.city,             --r_site.city,
                                       r_site.postal_code,
                                       r_site.state,           --r_site.state,
                                       v_territory_code,     --r_site.country,
                                       NULL,          --r_site.ship_to_county,
                                       r_site.ship_to_province,        -- Zone
                                       NULL,
                                       --r_site.div_dff,               -- dff_attribute1
                                       NULL,
                                       --r_site.ship_to_site_name,          -- Site name
                                       NULL,                 --r_site.div_dff,
                                       r_site.ship_to_loc_dff,
                                       l_party_site_id,
                                       l_party_site_number,
                                       l_error_message
                                      );
                           l_error_message := SUBSTR (l_error_message, 1, 200);
                           v_error_message :=
                                            v_error_message || l_error_message;
                           DBMS_OUTPUT.put_line
                                        (   'SHIP TO Party Site API Message :'
                                         || l_error_message
                                        );
                        EXCEPTION
                           WHEN OTHERS
                           THEN
                              v_check_message :=
                                 SUBSTR (   'Error in Customer Party Site'
                                         || SQLERRM,
                                         1,
                                         500
                                        );
                              fnd_file.put_line (fnd_file.LOG,
                                                 v_check_message);
                              l_party_site_id := NULL;
                              v_error_message :=
                                            v_error_message || v_check_message;
                        END;

                        l_error_message := NULL;
                        l_cust_acct_site_id := NULL;

                        -- Create Ship to Customr Site
                        BEGIN
                           create_customer_site (l_cust_account_id,
                                                 l_party_site_id,
                                                 v_org_id,
                                                 NULL,             --territory
                                                 l_customer_catg_code,
                                                 l_cust_acct_site_id,
                                                 l_error_message
                                                );
                           l_error_message := SUBSTR (l_error_message, 1, 200);
                           v_error_message :=
                                            v_error_message || l_error_message;
                           DBMS_OUTPUT.put_line
                                          (   'SHIP TO Customer Account Site '
                                           || l_cust_acct_site_id
                                          );
                           fnd_file.put_line
                                          (fnd_file.LOG,
                                              'SHIP TO Customer Account Site '
                                           || l_cust_acct_site_id
                                          );
                           DBMS_OUTPUT.put_line
                                     (   'Customer Account Site API Message :'
                                      || l_error_message
                                     );
                        EXCEPTION
                           WHEN OTHERS
                           THEN
                              NULL;
                              v_check_message :=
                                 SUBSTR ('Error in Customer Site :' || SQLERRM,
                                         1,
                                         500
                                        );
                              fnd_file.put_line (fnd_file.LOG,
                                                 v_check_message);
                              v_error_message :=
                                            v_error_message || v_check_message;
                        END;

                        --
                        l_site_use_id := NULL;
                        l_error_message := NULL;

--                        DBMS_OUTPUT.put_line
--                                            (   'SHIP TO FRT TERM '
--                                             || RTRIM
--                                                   (LTRIM (r_site.freight_term)
--                                                   )
--                                            );
--                        lv_ship_frt_term :=
--                                           RTRIM (LTRIM (r_site.freight_term));

                        /*  -- Sales Rep Id Derivation
                          BEGIN
                             SELECT res.salesrep_id
                               INTO ln_salesrep_id
                               FROM ra_salesreps_all res
                              WHERE res.salesrep_number = r_site.sr_empid
                                AND res.org_id = v_org_id;
                          EXCEPTION
                             WHEN OTHERS
                             THEN
                                ln_salesrep_id := NULL;
                          END;

                          fnd_file.put_line (fnd_file.LOG,
                                             'Sales Rep ID ' || ln_salesrep_id
                                            );
                          fnd_file.put_line (fnd_file.LOG,
                                             'Sales Rep ID ' || ln_salesrep_id
                                            );*/

                        -- Customer Ship to Site use
                        BEGIN
                           create_customer_site_uses
                                     (l_cust_acct_site_id,
                                      'SHIP_TO',
                                      NULL,        --r_site.ship_to_site_name,
                                      NULL,               --v_payment_term_id,
                                      NULL,                 --r_site.tax_code,
                                      NULL,                 --v_gl_account_id,
                                      v_org_id,
                                      NULL, --ln_salesrep_id, -- P_SALESREP_ID
                                      NULL,                    -- Territory id
                                      r_site.bill_to_site_use_id,
                                      r_site.sales_order_type,
                                      NULL,           -- r_site.pricelistname,
                                      lv_ship_frt_term,
                                      l_site_use_id,
                                      l_error_message
                                     );
                           l_error_message := SUBSTR (l_error_message, 1, 200);
                           v_error_message :=
                                            v_error_message || l_error_message;
                           DBMS_OUTPUT.put_line
                                      (   'SHIP TO Customer Account Site Use '
                                       || l_site_use_id
                                      );
                           fnd_file.put_line
                                      (fnd_file.LOG,
                                          'SHIP TO Customer Account Site Use '
                                       || l_site_use_id
                                      );
                           DBMS_OUTPUT.put_line
                                 (   'Customer Account Site Use API Message :'
                                  || l_error_message
                                 );
                        EXCEPTION
                           WHEN OTHERS
                           THEN
                              NULL;
                              v_check_message :=
                                 SUBSTR
                                      (   'Error in Customer Ship Site Uses'
                                       || SQLERRM,
                                       1,
                                       500
                                      );
                              fnd_file.put_line (fnd_file.LOG,
                                                 v_check_message);
                              v_error_message :=
                                            v_error_message || v_check_message;
                        END;

                        fnd_file.put_line (fnd_file.LOG,
                                              'SHIP_TO Site Use ID   '
                                           || l_site_use_id
                                          );
                     END IF;

                     BEGIN
                        UPDATE xxdbl_customer_dm_tbl
                           SET cust_account_id = l_cust_account_id,
                               cust_sacct_site_id = l_cust_acct_site_id,
                               ship_to_site_use_id = l_site_use_id,
                               error_message = v_error_message
                         WHERE RTRIM (LTRIM (cust_num)) = r_site.cust_num
                           AND RTRIM (LTRIM (org_name)) = p_organization;
                     EXCEPTION
                        WHEN OTHERS
                        THEN
                           NULL;
                     END;
                  END;
               END LOOP;
            END IF;

            ------------------------------------Ship to Site Creation ends------------------

            ---------------------------- Drawee to Site creation starts ------------------
            IF l_cust_account_id IS NOT NULL
            THEN
               DBMS_OUTPUT.put_line
                  ('**************Customer Drwaee Site Creation Start**************'
                  );

               FOR r_site IN
                  (SELECT DISTINCT RTRIM (LTRIM (cust_name)) customer_name,
                                   cust_catg, UPPER (country) country,

--                                   RTRIM
--                                        (LTRIM (bill_to_loc)
--                                        ) bill_to_site_name,
                                   postal_code,

--                                   RTRIM
--                                        (LTRIM (ship_to_loc)
--                                        ) ship_to_site_name,
                                   RTRIM (LTRIM (addr1)) ship_to_addr1,
                                   RTRIM (LTRIM (addr2)) ship_to_addr2,
                                   RTRIM (LTRIM (addr3)) ship_to_addr3, state,
                                   city,
--                                   RTRIM (LTRIM (ship_to_addr4))
--                                                                ship_to_addr4,
--
                                   --  div_dff,
                                        RTRIM (LTRIM (city)) ship_to_city,
                                   RTRIM (LTRIM (ship_to_state))
                                                                ship_to_state,
                                   RTRIM (LTRIM (ship_to_zone)) ship_to_zone,
                                   RTRIM
                                      (LTRIM (ship_to_province)
                                      ) ship_to_province,
                                   payment_terms, bill_to_site_use_id,
                                   RTRIM
                                      (LTRIM (ship_to_loc_dff)
                                      ) ship_to_loc_dff,
                                   RTRIM
                                      (LTRIM (ship_to_site_postal_code)
                                      ) ship_to_site_postal_code,
                                   RTRIM
                                      (LTRIM (sales_order_type)
                                      ) sales_order_type,
                                   RTRIM (LTRIM (pricelistname))
                                                                pricelistname,
                                   RTRIM (LTRIM (freight_term)) freight_term,
                                   RTRIM (LTRIM (sr_empid)) sr_empid,
                                   RTRIM (LTRIM (cust_num)) cust_num,
                                   RTRIM
                                      (LTRIM (country_iso_code)
                                      ) country_iso_code
                              FROM xxdbl_customer_dm_tbl
                             WHERE RTRIM (LTRIM (cust_num)) = rec.cust_num
                               AND RTRIM (LTRIM (org_name)) = p_organization
                               AND ship_to_site_use_id IS NOT NULL
                               -- AND ship_to_loc IS NOT NULL
                               AND drawee_to_flag = 'YES'
                                                         -- AND RTRIM (LTRIM (cust_name)) IN ('APEX TEXTILE PRINTING MILLS LIMITED','HAMS (BD) LTD.')
                  )
               LOOP
                  l_party_site_id := NULL;
                  l_party_site_number := NULL;
                  l_cust_acct_site_id := NULL;
                  l_site_use_id := NULL;
                  v_payment_term_id := NULL;
                  v_gl_account_id := NULL;
                  l_cust_account_profile_id := NULL;
                  l_cust_act_prof_amt_id := NULL;
                  v_territory_code := NULL;
                  v_salesrep_id := NULL;
                  v_territory_id := NULL;
--                  v_error_message := NULL;
                  v_check_message := NULL;
                  lv_ship_frt_term := NULL;

                  IF r_site.country IS NOT NULL
                  THEN
                     BEGIN
                        SELECT territory_code
                          INTO v_territory_code
                          FROM fnd_territories
                         WHERE territory_code = r_site.country_iso_code;
                     EXCEPTION
                        WHEN OTHERS
                        THEN
                           v_territory_code := NULL;
                           v_check_message := 'Error in Territory Code ';
                           fnd_file.put_line (fnd_file.LOG, v_check_message);
                           v_error_message :=
                                           v_error_message || v_check_message;
                     END;
                  END IF;

                  -- Customer Category
                  BEGIN
                     SELECT lookup_code
                       INTO l_customer_catg_code
                       FROM fnd_lookup_values
                      WHERE lookup_type = 'CUSTOMER_CATEGORY'
                        AND UPPER (lookup_code) = UPPER (r_site.cust_catg);
                  EXCEPTION
                     WHEN OTHERS
                     THEN
                        l_customer_catg_code := NULL;
                        v_error_message := 'Error in Customer Category';
                        fnd_file.put_line (fnd_file.LOG, v_error_message);
                        v_error_message := v_error_message || v_check_message;
                  END;

                  IF r_site.bill_to_site_use_id IS NULL
                  THEN
                     BEGIN
                        SELECT hcsua.site_use_id
                          INTO r_site.bill_to_site_use_id
                          FROM hz_cust_accounts hca,
                               hz_parties party,
                               hz_party_sites hzps,
                               hz_locations hzl,
                               hz_cust_acct_sites_all hcasa,
                               hz_cust_site_uses_all hcsua
                         WHERE hca.party_id = party.party_id
                           AND party.party_id = hzps.party_id
                           AND hzps.party_site_id = hcasa.party_site_id
                           AND hzps.location_id = hzl.location_id
                           AND hca.cust_account_id = hcasa.cust_account_id
                           AND hcasa.cust_acct_site_id =
                                                       hcsua.cust_acct_site_id
                           AND hcsua.site_use_code = 'DRAWEE'
                           AND hcsua.primary_flag = 'Y'
                           -- Added on 24-MAY-2016
                           AND NVL (party.organization_name_phonetic,
                                    hca.account_number
                                   ) = r_site.cust_num
                           -- AND hzps.party_site_name = r_site.bill_to_site_name
                           AND hcsua.org_id = v_org_id
                           AND ROWNUM = 1;
                     EXCEPTION
                        WHEN OTHERS
                        THEN
                           r_site.bill_to_site_use_id := NULL;
                     END;
                  END IF;

                  BEGIN
                     SELECT hzps.party_site_id, hcasa.cust_acct_site_id,
                            hcsua.site_use_id
                       INTO l_party_site_id, l_cust_acct_site_id,
                            l_site_use_id
                       FROM hz_cust_accounts hca,
                            hz_parties party,
                            hz_party_sites hzps,
                            hz_locations hzl,
                            hz_cust_acct_sites_all hcasa,
                            hz_cust_site_uses_all hcsua
                      WHERE hca.party_id = party.party_id
                        AND party.party_id = hzps.party_id
                        AND hzps.party_site_id = hcasa.party_site_id
                        AND hzps.location_id = hzl.location_id
                        AND hca.cust_account_id = hcasa.cust_account_id
                        AND hcasa.cust_acct_site_id = hcsua.cust_acct_site_id
                        AND hcsua.site_use_code = 'DRAWEE'
                        AND NVL (party.organization_name_phonetic,
                                 hca.account_number
                                ) = r_site.cust_num
                        --   AND hzps.party_site_name = r_site.ship_to_site_name
                        AND hcsua.org_id = v_org_id
                        AND ROWNUM = 1;
                  EXCEPTION
                     WHEN OTHERS
                     THEN
                        l_party_site_id := NULL;
                        l_cust_acct_site_id := NULL;
                        l_site_use_id := NULL;
                  END;

                  ----------------------------- Drawee to Site ---------------------
                  BEGIN
                     IF l_site_use_id IS NULL
                     THEN
                        l_error_message := NULL;
                        l_party_site_id := NULL;
                        l_party_site_number := NULL;

                        -- Create Ship to Party Site
                        BEGIN
                           create_party_site
                                      (l_party_id,
                                       r_site.ship_to_addr1, -- address_line1,
                                       r_site.ship_to_addr2,  --address_line2,
                                       r_site.ship_to_addr3,  --address_line3,
                                       NULL,
                                       ---- r_site.ship_to_addr4,   --r_site.address_line4,
                                       r_site.city,             --r_site.city,
                                       r_site.postal_code,
                                       r_site.state,           --r_site.state,
                                       v_territory_code,     --r_site.country,
                                       NULL,          --r_site.ship_to_county,
                                       r_site.ship_to_province,        -- Zone
                                       NULL,
                                       --r_site.div_dff,               -- dff_attribute1
                                       NULL,
                                       --r_site.ship_to_site_name,          -- Site name
                                       NULL,                 --r_site.div_dff,
                                       r_site.ship_to_loc_dff,
                                       l_party_site_id,
                                       l_party_site_number,
                                       l_error_message
                                      );
                           l_error_message := SUBSTR (l_error_message, 1, 200);
                           v_error_message :=
                                            v_error_message || l_error_message;
                           DBMS_OUTPUT.put_line
                                         (   'DRAWEE Party Site API Message :'
                                          || l_error_message
                                         );
                        EXCEPTION
                           WHEN OTHERS
                           THEN
                              v_check_message :=
                                 SUBSTR (   'Error in Customer Party Site'
                                         || SQLERRM,
                                         1,
                                         500
                                        );
                              fnd_file.put_line (fnd_file.LOG,
                                                 v_check_message);
                              l_party_site_id := NULL;
                              v_error_message :=
                                            v_error_message || v_check_message;
                        END;

                        l_error_message := NULL;
                        l_cust_acct_site_id := NULL;

                        -- Create Ship to Customr Site
                        BEGIN
                           create_customer_site (l_cust_account_id,
                                                 l_party_site_id,
                                                 v_org_id,
                                                 NULL,             --territory
                                                 l_customer_catg_code,
                                                 l_cust_acct_site_id,
                                                 l_error_message
                                                );
                           l_error_message := SUBSTR (l_error_message, 1, 200);
                           v_error_message :=
                                            v_error_message || l_error_message;
                           DBMS_OUTPUT.put_line
                                           (   'DRAWEE Customer Account Site '
                                            || l_cust_acct_site_id
                                           );
                           fnd_file.put_line
                                           (fnd_file.LOG,
                                               'DRAWEE Customer Account Site '
                                            || l_cust_acct_site_id
                                           );
                           DBMS_OUTPUT.put_line
                              (   'DRAWEE Customer Account Site API Message :'
                               || l_error_message
                              );
                        EXCEPTION
                           WHEN OTHERS
                           THEN
                              NULL;
                              v_check_message :=
                                 SUBSTR ('Error in Customer Site :' || SQLERRM,
                                         1,
                                         500
                                        );
                              fnd_file.put_line (fnd_file.LOG,
                                                 v_check_message);
                              v_error_message :=
                                            v_error_message || v_check_message;
                        END;

                        --
                        l_site_use_id := NULL;
                        l_error_message := NULL;
                        DBMS_OUTPUT.put_line
                                            (   'DRAWEE FRT TERM '
                                             || RTRIM
                                                   (LTRIM (r_site.freight_term)
                                                   )
                                            );

--                        lv_ship_frt_term :=
--                                           RTRIM (LTRIM (r_site.freight_term));

                        /*  -- Sales Rep Id Derivation
                          BEGIN
                             SELECT res.salesrep_id
                               INTO ln_salesrep_id
                               FROM ra_salesreps_all res
                              WHERE res.salesrep_number = r_site.sr_empid
                                AND res.org_id = v_org_id;
                          EXCEPTION
                             WHEN OTHERS
                             THEN
                                ln_salesrep_id := NULL;
                          END;

                          fnd_file.put_line (fnd_file.LOG,
                                             'Sales Rep ID ' || ln_salesrep_id
                                            );
                          fnd_file.put_line (fnd_file.LOG,
                                             'Sales Rep ID ' || ln_salesrep_id
                                            );*/

                        -- Customer Ship to Site use
                        BEGIN
                           create_customer_site_uses
                                     (l_cust_acct_site_id,
                                      'DRAWEE',
                                      NULL,        --r_site.ship_to_site_name,
                                      NULL,               --v_payment_term_id,
                                      NULL,                 --r_site.tax_code,
                                      NULL,                 --v_gl_account_id,
                                      v_org_id,
                                      NULL, --ln_salesrep_id, -- P_SALESREP_ID
                                      NULL,                    -- Territory id
                                      NULL,
                                      r_site.sales_order_type,
                                      NULL,           -- r_site.pricelistname,
                                      NULL,                --lv_ship_frt_term,
                                      l_site_use_id,
                                      l_error_message
                                     );
                           l_error_message := SUBSTR (l_error_message, 1, 200);
                           v_error_message :=
                                            v_error_message || l_error_message;
                           DBMS_OUTPUT.put_line
                                       (   'DRAWEE Customer Account Site Use '
                                        || l_site_use_id
                                       );
                           fnd_file.put_line
                                       (fnd_file.LOG,
                                           'DRAWEE Customer Account Site Use '
                                        || l_site_use_id
                                       );
                           DBMS_OUTPUT.put_line
                               (   'Customer Account DRAWEE Use API Message :'
                                || l_error_message
                               );
                        EXCEPTION
                           WHEN OTHERS
                           THEN
                              NULL;
                              v_check_message :=
                                 SUBSTR
                                    (   'Error in Customer drawee site Uses'
                                     || SQLERRM,
                                     1,
                                     500
                                    );
                              fnd_file.put_line (fnd_file.LOG,
                                                 v_check_message);
                              v_error_message :=
                                            v_error_message || v_check_message;
                        END;

                        fnd_file.put_line (fnd_file.LOG,
                                              'drawee Site Use ID   '
                                           || l_site_use_id
                                          );
                     END IF;

                     BEGIN
                        UPDATE xxdbl_customer_dm_tbl
                           SET cust_account_id = l_cust_account_id,
                               cust_drawee_acct_site_id = l_cust_acct_site_id,
                               drawee_to_site_use_id = l_site_use_id,
                               error_message = v_error_message
                         WHERE RTRIM (LTRIM (cust_num)) = r_site.cust_num
                           AND RTRIM (LTRIM (org_name)) = p_organization;
                     EXCEPTION
                        WHEN OTHERS
                        THEN
                           NULL;
                     END;
                  END;
               END LOOP;
            END IF;
         --------------- Drawee Site Creation Ends--------------
         EXCEPTION
            WHEN OTHERS
            THEN
               v_error_message := SUBSTR ('Error ~ ' || SQLERRM, 1, 500);

--               fnd_file.put_line (fnd_file.LOG,v_error_message);
               UPDATE xxdbl_customer_dm_tbl
                  SET error_message = 'Error' || v_error_message
                WHERE RTRIM (LTRIM (cust_num)) = rec.cust_num
                  AND RTRIM (LTRIM (org_name)) = p_organization;
         END;

         COMMIT;
         fnd_file.put_line
                      (fnd_file.LOG,
                          '************* End of Customer Loop for Customer : '
                       || rec.customer_name
                       || '*************'
                      );
        -- insert_customer_profile (p_organization, rec.customer_name);
      --insert_contact (p_organization, rec.customer_name);
      END LOOP;

--      insert_customer_profile (p_organization);
      fnd_file.put_line (fnd_file.LOG, '**************DONE***************');
   END;

   PROCEDURE insert_customer_profile (
      p_organization    VARCHAR2,
      p_customer_name   VARCHAR2
   )
   IS
      l_cust_account_id           NUMBER;
      l_cust_account_profile_id   NUMBER;
      l_object_version_number     NUMBER;
      l_profile_class_id          NUMBER;
      l_error_message             VARCHAR2 (4000);
      v_error_message             VARCHAR2 (4000);
      v_org_id                    NUMBER;
      l_cust_act_prof_amt_id      NUMBER;
      l_cust_acct_site_id         NUMBER;
      ln_site_use_id              NUMBER;
      ln_cust_site_use_id         NUMBER;
   BEGIN
--      fnd_global.apps_initialize
--                                (user_id           =>                  --1110,
--                                                      fnd_global.user_id,
--                                 resp_id           =>                -- 51130,
--                                                      fnd_global.resp_id,
--                                 resp_appl_id      =>                    --222
--                                                      fnd_global.resp_appl_id
--                                );
      fnd_global.apps_initialize (user_id           => 1110,
                                  -- fnd_global.user_id,
                                  resp_id           => 50746,
                                  --fnd_global.resp_id,
                                  resp_appl_id      => 222
                                 --fnd_global.resp_appl_id
                                 );

--      fnd_global.apps_initialize (user_id           => 0,
--                                  resp_id           => 20678,
--                                  resp_appl_id      => 222
--                                 );
      FOR r_profile IN (SELECT DISTINCT xcm.cust_account_id,

                                        --NVL(xcm.customer_profile,'DEFAULT')
                                        'DEFAULT' customer_profile
                                   FROM xxdbl_customer_dm_tbl xcm
                                  WHERE cust_account_id IS NOT NULL
                                    --AND xcm.legacy_code='0588'
                                    AND RTRIM (LTRIM (org_name)) =
                                                                p_organization
                                    AND RTRIM (LTRIM (cust_name)) =
                                                               p_customer_name
--                                    AND RTRIM (LTRIM (cust_name)) in ('3-D Holdings Limited.','A.K Real Estate Ltd.')
                      )
      LOOP
         l_object_version_number := NULL;
         l_cust_account_id := NULL;
         l_profile_class_id := NULL;
         l_cust_account_profile_id := NULL;
         v_error_message := NULL;

         SELECT organization_id
           INTO v_org_id
           FROM hr_operating_units
          WHERE NAME = p_organization;

         mo_global.set_org_context (v_org_id, NULL, 'AR');
         mo_global.set_policy_context ('S', v_org_id);
         mo_global.init ('AR');

--         fnd_file.put_line (fnd_file.LOG,'cust_account_id: '
--                               || r_profile.cust_account_id
--                              );
         BEGIN
            SELECT hcpc.profile_class_id
              INTO l_profile_class_id
              FROM hz_cust_profile_classes hcpc
             WHERE TRIM (UPPER (hcpc.NAME)) =
                                     TRIM (UPPER (r_profile.customer_profile));
         EXCEPTION
            WHEN OTHERS
            THEN
               v_error_message :=
                         v_error_message || 'Customer or profile not created';
         END;

         BEGIN
            SELECT hcp.cust_account_profile_id, hcp.object_version_number
              INTO l_cust_account_profile_id, l_object_version_number
              FROM hz_customer_profiles hcp
             WHERE hcp.cust_account_id = r_profile.cust_account_id;
         EXCEPTION
            WHEN OTHERS
            THEN
               v_error_message :=
                                v_error_message || 'Customer profile missing';
         END;

         BEGIN
            SELECT hcsua.site_use_id
              INTO ln_cust_site_use_id
              FROM hz_cust_acct_sites_all cust_acct_site,
                   hz_cust_site_uses_all hcsua
             WHERE cust_acct_site.cust_account_id = r_profile.cust_account_id
               AND hcsua.cust_acct_site_id = cust_acct_site.cust_acct_site_id
               AND cust_acct_site.bill_to_flag = 'P'
               AND cust_acct_site.status = 'A';
         EXCEPTION
            WHEN OTHERS
            THEN
               v_error_message := v_error_message || 'Site Use Id Missing';
         END;

         l_error_message := NULL;

         IF v_error_message IS NULL
         THEN
            update_cust_profile (r_profile.cust_account_id,
                                 ln_cust_site_use_id,
                                 l_profile_class_id,
                                 l_cust_account_profile_id,
                                 l_object_version_number,
                                 l_error_message
                                );
--            fnd_file.put_line (fnd_file.LOG,   'l_object_version_number Updated: '
--                                  || l_object_version_number
--                                 );
--            v_error_message :=
--                   SUBSTR (v_error_message || '~' || l_error_message, 1, 4000);
         END IF;

         UPDATE xxdbl_customer_dm_tbl
            SET profile_error_message = v_error_message
          WHERE cust_account_id = r_profile.cust_account_id;
      END LOOP;

      FOR r_profile IN
         (SELECT DISTINCT xcm.cust_account_id, 'BDT' currency,
                          xcm.credit_limit global_credit_limit,
                          xcm.credit_limit bill_to_credit_limit
                     FROM xxdbl_customer_dm_tbl xcm
                    WHERE cust_account_id IS NOT NULL
--                                    AND xcm.BILL_TO_CREDIT_LIMIT IS NOT NULL
                     -- AND NVL (credit_limit, 0) <> 0
                      AND RTRIM (LTRIM (org_name)) = p_organization
                      AND RTRIM (LTRIM (cust_name)) = p_customer_name
                      AND NOT EXISTS (
                               SELECT 'X'
                                 FROM hz_cust_profile_amts hzp
                                WHERE hzp.cust_account_id =
                                                           xcm.cust_account_id))
      LOOP
         BEGIN
            l_cust_act_prof_amt_id := NULL;
            l_cust_account_id := NULL;
            l_cust_acct_site_id := NULL;
            l_cust_account_profile_id := NULL;

            SELECT hca.cust_account_id, hcp.cust_account_profile_id
              INTO l_cust_account_id, l_cust_account_profile_id
              FROM hz_cust_accounts hca,
                   hz_parties hp,
                   hz_customer_profiles hcp
             WHERE hca.party_id = hp.party_id
               AND hca.cust_account_id = hcp.cust_account_id
               AND hcp.cust_account_id = r_profile.cust_account_id
               AND hcp.site_use_id IS NULL;

            l_error_message := NULL;
            customer_profile_amt (l_cust_account_id,
                                  ln_cust_site_use_id,
                                  l_cust_account_profile_id,
                                  r_profile.currency,
                                  r_profile.global_credit_limit,
                                  r_profile.bill_to_credit_limit,
                                  l_cust_act_prof_amt_id,
                                  l_error_message
                                 );

            UPDATE xxdbl_customer_dm_tbl
               SET profile_error_message = l_error_message
             WHERE cust_account_id = r_profile.cust_account_id;
         EXCEPTION
            WHEN OTHERS
            THEN
               NULL;
         END;
      END LOOP;
   END;

   PROCEDURE insert_contact (p_organization VARCHAR2, p_customer_name VARCHAR2)
   IS
      l_party_id               NUMBER;
      l_party_number           VARCHAR2 (100);
      l_profile_id             NUMBER;
      l_cust_account_id        NUMBER;
      l_account_number         VARCHAR2 (2000);
      l_party_site_id          NUMBER;
      l_party_site_number      NUMBER;
      l_cust_acct_site_id      NUMBER;
      l_site_use_id            NUMBER;
      l_party_rel_id           NUMBER;
      l_contact_point_id       NUMBER;
      l_cust_account_role_id   NUMBER;
      v_payment_term_id        NUMBER;
      v_gl_account_id          NUMBER;
      l_error_message          VARCHAR2 (4000);
      v_error_message          VARCHAR2 (4000);
      v_org_id                 NUMBER;
   BEGIN
      NULL;
--      fnd_global.apps_initialize
--                                (user_id           =>                  --1110,
--                                                      fnd_global.user_id,
--                                 resp_id           =>                 --51130,
--                                                      fnd_global.resp_id,
--                                 resp_appl_id      =>                    --222
--                                                      fnd_global.resp_appl_id
--                                );
      fnd_global.apps_initialize (user_id           => 1110,
                                  -- fnd_global.user_id,
                                  resp_id           => 50746,
                                  --fnd_global.resp_id,
                                  resp_appl_id      => 222
                                 --fnd_global.resp_appl_id
                                 );

      /*fnd_global.apps_initialize (user_id           => 0,
                                  resp_id           => 20678,
                                  resp_appl_id      => 222
                                 );*/
      FOR r_contact2 IN
         (SELECT xx.*
            FROM (SELECT DISTINCT y.contact_name contact_person,
                                  y.telephone contact_telephone,
                                  mobile contact_mobile, fax contact_fax,
                                  email contact_email, NULL extn_number,
                                  y.cust_account_id, y.cust_acct_site_id,
                                  RTRIM (LTRIM (y.org_name)) operating_unit
                             FROM xxdbl_customer_dm_tbl y
                            WHERE y.contact_name IS NOT NULL
                              AND y.cust_acct_site_id IS NOT NULL
                              AND y.cust_account_id IS NOT NULL
                              AND RTRIM (LTRIM (y.org_name)) = p_organization
                              AND NVL (status, 'X') <> 'DONE'
                              AND y.cust_acct_site_id IS NOT NULL
                              AND RTRIM (LTRIM (cust_name)) = p_customer_name
                  UNION
                  SELECT DISTINCT y.contact_name contact_person,
                                  y.telephone contact_telephone,
                                  mobile contact_mobile, fax contact_fax,
                                  email contact_email, NULL extn_number,
                                  y.cust_account_id,
                                  y.cust_sacct_site_id cust_acct_site_id,
                                  RTRIM (LTRIM (y.org_name)) operating_unit
                             FROM xxdbl_customer_dm_tbl y
                            WHERE y.contact_name IS NOT NULL
                              AND y.cust_account_id IS NOT NULL
                              AND y.cust_sacct_site_id IS NOT NULL
                              AND RTRIM (LTRIM (y.org_name)) = p_organization
                              AND NVL (status, 'X') <> 'DONE'
                              AND y.cust_sacct_site_id IS NOT NULL
                              AND RTRIM (LTRIM (cust_name)) = p_customer_name
                                                                             --and legacy_code = '0281'
                 ) xx)
      LOOP
         BEGIN
            v_error_message := NULL;
            l_party_rel_id := NULL;
            l_contact_point_id := NULL;
            l_cust_account_role_id := NULL;
            l_party_id := NULL;

            SELECT organization_id
              INTO v_org_id
              FROM hr_operating_units
             WHERE NAME = r_contact2.operating_unit;

            mo_global.set_org_context (v_org_id, NULL, 'AR');
            mo_global.set_policy_context ('S', v_org_id);
            mo_global.init ('AR');

            BEGIN
               SELECT party_id
                 INTO l_party_id
                 FROM hz_cust_accounts
                WHERE cust_account_id = r_contact2.cust_account_id;
            EXCEPTION
               WHEN OTHERS
               THEN
                  l_party_id := NULL;
            END;

            --fnd_file.put_line (fnd_file.LOG,   'cust_account_id: '
             --                     || r_contact2.cust_account_id
             --                    );
            --fnd_file.put_line (fnd_file.LOG,   'cust_acct_site_id: '
            --                      || r_contact2.cust_acct_site_id
             --                    );
            IF l_party_id IS NOT NULL
            THEN
               l_error_message := NULL;

               BEGIN
                  create_customer_contact
                                       (NULL, --r_contact2.contact_first_name,
                                        r_contact2.contact_person,
                                        NULL,     --r_contact2.exp_compliance,
                                        NULL,          --r_contact2.executive,
                                        l_party_id,
                                        l_party_rel_id,
                                        l_error_message
                                       );
               EXCEPTION
                  WHEN OTHERS
                  THEN
                     NULL;
               END;

--               v_error_message :=
--                           SUBSTR (v_error_message || l_error_message, 1, 100);
               --fnd_file.put_line (fnd_file.LOG,   'Customer Contact Created: '
               --                     || r_contact2.contact_person
               --                     );
               l_error_message := NULL;

               BEGIN
                  create_customer_contact_role (r_contact2.cust_account_id,
                                                r_contact2.cust_acct_site_id,
                                                l_party_rel_id,
                                                NULL,
                                                --r_contact2.exp_compliance,
                                                NULL,  --r_contact2.executive,
                                                l_cust_account_role_id,
                                                l_error_message
                                               );
               EXCEPTION
                  WHEN OTHERS
                  THEN
                     NULL;
               END;

--               v_error_message :=
--                           SUBSTR (v_error_message || l_error_message, 1, 100);
               --fnd_file.put_line (fnd_file.LOG,   'Customer Contact Role Created: '
               --                     || r_contact2.contact_person
               --                     );
               l_error_message := NULL;

               IF r_contact2.contact_telephone IS NOT NULL
               THEN
                  BEGIN
                     create_customer_contact_phone
                                               (l_party_rel_id,
                                                r_contact2.contact_telephone,
                                                r_contact2.extn_number,
                                                l_contact_point_id,
                                                l_error_message
                                               );
                  EXCEPTION
                     WHEN OTHERS
                     THEN
                        NULL;
                  END;
--                  v_error_message :=
--                           SUBSTR (v_error_message || l_error_message, 1, 100);
               --fnd_file.put_line (fnd_file.LOG,   'Phone created: '
               --                      || r_contact2.contact_telephone
               --                      );
               END IF;

               l_error_message := NULL;

               IF r_contact2.contact_email IS NOT NULL
               THEN
                  BEGIN
                     create_customer_contact_email (l_party_rel_id,
                                                    r_contact2.contact_email,
                                                    l_contact_point_id,
                                                    l_error_message
                                                   );
                  EXCEPTION
                     WHEN OTHERS
                     THEN
                        NULL;
                  END;
--                  v_error_message :=
--                           SUBSTR (v_error_message || l_error_message, 1, 100);
               --fnd_file.put_line (fnd_file.LOG,   'Email created: '
               --                      || r_contact2.contact_email
               --                     );
               END IF;

               l_error_message := NULL;

               IF r_contact2.contact_mobile IS NOT NULL
               THEN
                  BEGIN
                     create_customer_contact_mobile
                                                  (l_party_rel_id,
                                                   r_contact2.contact_mobile,
                                                   l_contact_point_id,
                                                   l_error_message
                                                  );
                  EXCEPTION
                     WHEN OTHERS
                     THEN
                        NULL;
                  END;
--                  v_error_message :=
--                           SUBSTR (v_error_message || l_error_message, 1, 100);
               --fnd_file.put_line (fnd_file.LOG,   'Mobile created: '
               --                      || r_contact2.contact_mobile
               --                     );
               END IF;

               l_error_message := NULL;

               IF r_contact2.contact_fax IS NOT NULL
               THEN
                  BEGIN
                     create_customer_contact_fax (l_party_rel_id,
                                                  r_contact2.contact_fax,
                                                  l_contact_point_id,
                                                  l_error_message
                                                 );
                  EXCEPTION
                     WHEN OTHERS
                     THEN
                        NULL;
                  END;
--                  v_error_message :=
--                           SUBSTR (v_error_message || l_error_message, 1, 100);
               --fnd_file.put_line (fnd_file.LOG,   'Fax created: '
               --                      || r_contact2.contact_fax
               --                     );
               END IF;
--               UPDATE xxssgil_customer_dm_tbl5 z
--                  SET error_message = error_message || 'Contact Upload DONE'
--                WHERE cust_acct_site_id = r_contact2.cust_acct_site_id
--                   OR cust_sacct_site_id = r_contact2.cust_acct_site_id;
            END IF;
         EXCEPTION
            WHEN OTHERS
            THEN
               NULL;
--               UPDATE xxssgil_customer_dm_tbl5 z
--                  SET error_message = error_message || 'Contact Upload Error '
--                WHERE cust_acct_site_id = r_contact2.cust_acct_site_id
--                   OR cust_sacct_site_id = r_contact2.cust_acct_site_id;
         END;
      END LOOP;

      NULL;
   END;

   FUNCTION order_type_fn (p_oe_type VARCHAR2, p_org_id NUMBER)
      RETURN NUMBER
   IS
      ln_type_id   NUMBER;
   BEGIN
      SELECT all_types.transaction_type_id
        INTO ln_type_id
        FROM apps.oe_transaction_types_all all_types,
             apps.oe_transaction_types_tl tl_types
       WHERE 1 = 1
         AND UPPER (tl_types.NAME) = UPPER (p_oe_type)
         -- AND tl_types.LANGUAGE = fnd_global.base_language
         AND all_types.transaction_type_code = 'ORDER'
         AND all_types.org_id = p_org_id
         --fnd_profile.VALUE ('ORG_ID')
         AND all_types.transaction_type_id = tl_types.transaction_type_id
         AND TRUNC (SYSDATE) BETWEEN NVL (all_types.start_date_active,
                                          TRUNC (SYSDATE) - 1
                                         )
                                 AND NVL (all_types.end_date_active,
                                          TRUNC (SYSDATE) + 1
                                         );

      RETURN ln_type_id;
   EXCEPTION
      WHEN OTHERS
      THEN
         RETURN NULL;
   END;

   FUNCTION price_list_fn (p_price_list VARCHAR2)
      RETURN NUMBER
   IS
      ln_price_list_id   NUMBER;
   BEGIN
      SELECT qp_hdr.list_header_id
        INTO ln_price_list_id
        FROM qp_secu_list_headers_v qp_hdr
       WHERE UPPER (NAME) = UPPER (p_price_list);

      RETURN ln_price_list_id;
   EXCEPTION
      WHEN OTHERS
      THEN
         RETURN NULL;
   END;

   FUNCTION cust_code_derive_fn (p_cust_type VARCHAR2)
      RETURN VARCHAR2
   IS
      l_cust_type_code   VARCHAR2 (10);
   BEGIN
      SELECT values1.lookup_code
        INTO l_cust_type_code
        FROM fnd_lookup_values values1, fnd_application_tl appl
       WHERE values1.lookup_type = 'CUSTOMER_TYPE'
         AND appl.application_id = values1.view_application_id
         AND appl.application_name = 'Receivables'
         AND UPPER (meaning) = UPPER (p_cust_type);

      RETURN l_cust_type_code;
   EXCEPTION
      WHEN OTHERS
      THEN
         RETURN NULL;
   END;
END;
/