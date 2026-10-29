{ config, ... }:

{
  age.secrets.nginx.file = ../../../secrets/nginx.age;

  services.prometheus.exporters.nginx = {
    enable = true;
    port = 9113;
  };

  services.nginx = {
    enable = true;
    clientMaxBodySize = "128m";

    virtualHosts."lab.sdnts.dev" = {
      useACMEHost = "lab.sdnts.dev";
      forceSSL = true;
      locations."/" = {
        return = "200 '<html><body>It works</body></html>'";
        extraConfig = ''
          default_type text/html;
        '';
      };
    };

    virtualHosts."metrics.lab.sdnts.dev" = {
      serverAliases = [ "prometheus.lab.sdnts.dev" ];
      useACMEHost = "lab.sdnts.dev";
      forceSSL = true;
      locations."/" = {
        proxyPass = "http://sentry:9090";
      };
    };

    virtualHosts."grafana.lab.sdnts.dev" = {
      useACMEHost = "lab.sdnts.dev";
      forceSSL = true;
      locations."/" = {
        proxyPass = "http://sentry:3000";
        extraConfig = ''
          proxy_set_header Host grafana.lab.sdnts.dev;
          proxy_set_header Origin https://grafana.lab.sdnts.dev;
        '';
      };

      # Disable routing to the metrics endpoint. Prometheus will reach out to the host directly (bypassing nginx). This
      # prevents metrics from being accidentally exposed publicly.
      locations."= /metrics".return = "404";
    };

    virtualHosts."restic.lab.sdnts.dev" = {
      useACMEHost = "lab.sdnts.dev";
      forceSSL = true;
      locations."/" = {
        proxyPass = "http://vault:8990";
        extraConfig = ''
          client_max_body_size 64M;
        '';
      };
    };

    # Copyparty
    virtualHosts."bastion.lab.sdnts.dev" = {
      useACMEHost = "lab.sdnts.dev";
      forceSSL = true;
      locations."/" = {
        proxyPass = "http://bastion:3923";
      };
    };
    virtualHosts."vault.lab.sdnts.dev" = {
      useACMEHost = "lab.sdnts.dev";
      forceSSL = true;
      locations."/" = {
        proxyPass = "http://vault:3923";
      };
    };
    virtualHosts."sentry.lab.sdnts.dev" = {
      useACMEHost = "lab.sdnts.dev";
      forceSSL = true;
      locations."/" = {
        proxyPass = "http://sentry:3923";
      };
    };

    virtualHosts."tv.lab.sdnts.dev" = {
      serverAliases = [ "jellyfin.lab.sdnts.dev" ];
      useACMEHost = "lab.sdnts.dev";
      forceSSL = true;
      locations."/" = {
        proxyPass = "http://vault:8096";
      };

      # Disable routing to the metrics endpoint. Prometheus will reach out to the host directly (bypassing nginx). This
      # prevents metrics from being accidentally exposed publicly.
      locations."= /metrics".return = "404";
    };

    virtualHosts."recipes.lab.sdnts.dev" = {
      serverAliases = [ "mealie.lab.sdnts.dev" ];
      useACMEHost = "lab.sdnts.dev";
      forceSSL = true;
      locations."/" = {
        proxyPass = "http://vault:9000";
      };
    };

    virtualHosts."photos.lab.sdnts.dev" = {
      serverAliases = [ "immich.lab.sdnts.dev" ];
      useACMEHost = "lab.sdnts.dev";
      forceSSL = true;
      locations."/" = {
        proxyPass = "http://vault:2283";
        extraConfig = ''
          proxy_request_buffering off;
          proxy_read_timeout 600s;
          proxy_send_timeout 600s;
          send_timeout 600s;
        '';
      };
    };

    virtualHosts."ha.lab.sdnts.dev" = {
      serverAliases = [ "homeassistant.lab.sdnts.dev" ];
      useACMEHost = "lab.sdnts.dev";
      forceSSL = true;
      locations."/" = {
        proxyPass = "http://homeassistant:8123";
        extraConfig = ''
          proxy_http_version 1.1;
          proxy_set_header Upgrade $http_upgrade;
          proxy_set_header Connection "upgrade";
        '';
      };
    };
  };

  security.acme = {
    acceptTerms = true;
    defaults.email = "acme@sdnts.dev";
    certs = {
      "lab.sdnts.dev" = {
        domain = "lab.sdnts.dev";
        extraDomainNames = [
          "*.lab.sdnts.dev"
        ];
        group = "nginx";
        dnsProvider = "cloudflare";

        # Contains CLOUDFLARE_DNS_API_TOKEN=<token>
        # Needs Zone Edit permissions
        environmentFile = config.age.secrets.nginx.path;
      };
    };
  };
}
