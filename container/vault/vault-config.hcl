storage "file" {
        path = "/vault/file"
}

ui                  = true
max_lease_ttl       = "2160h"
default_lease_ttl   = "2160h"
disable_mlock       = true

listener "tcp" {
        address                 = "https://0.0.0.0:8200"
        tls_disable             = 1
#        proxy_protocol_behavior = "use_always"
}

max_lease_ttl           = "10h"
default_lease_ttl       = "10h"
api_addr                = "https://0.0.0.0:8200"
disable_clustering      = true