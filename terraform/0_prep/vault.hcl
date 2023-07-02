 storage "file" {
        path = "/opt/vault/data"
      }
      ui = true
      max_lease_ttl = "2160h"
      default_lease_ttl = "2160h"
      listener "tcp" {
        address = "0.0.0.0:8200"
        tls_disable = 1
        proxy_protocol_behavior = "use_always"
      }

      api_addr = "http://vault.azure.sbx.tbcloud.org:8200"
