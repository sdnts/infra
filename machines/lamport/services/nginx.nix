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

    # Routes for services that warrant a pretty URL (*.lab.sdnts.dev). These URLs are useful when sharing with non-
    # technical family members.
    # Tailscale policies are set up to allow any tailnet member access to these services, so administrative services
    # such as Prometheus etc. are excluded. Admin services are accessed over their *.panthera-flops.ts.net addresses.
    virtualHosts = {
      "ha.lab.sdnts.dev" = {
        serverAliases = [ "homeassistant.lab.sdnts.dev" ];
        useACMEHost = "lab.sdnts.dev";
        forceSSL = true;
        locations."/" = {
          proxyPass = "https://home-assistant.panthera-flops.ts.net";
          proxyWebsockets = true;
          extraConfig = ''
            proxy_ssl_server_name on;
          '';
        };
      };

      "photos.lab.sdnts.dev" = {
        serverAliases = [ "immich.lab.sdnts.dev" ];
        useACMEHost = "lab.sdnts.dev";
        forceSSL = true;
        locations."/" = {
          proxyPass = "https://immich.panthera-flops.ts.net";
          proxyWebsockets = true;
          recommendedProxySettings = true;
          extraConfig = ''
            proxy_ssl_server_name on;
            proxy_request_buffering off;
            proxy_read_timeout 600s;
            proxy_send_timeout 600s;
            send_timeout 600s;
          '';
        };
      };

      "recipes.lab.sdnts.dev" = {
        serverAliases = [ "mealie.lab.sdnts.dev" ];
        useACMEHost = "lab.sdnts.dev";
        forceSSL = true;
        locations."/" = {
          proxyPass = "https://mealie.panthera-flops.ts.net";
          recommendedProxySettings = true;
          extraConfig = ''
            proxy_ssl_server_name on;
          '';
        };
      };

      "tv.lab.sdnts.dev" = {
        serverAliases = [ "jellyfin.lab.sdnts.dev" ];
        useACMEHost = "lab.sdnts.dev";
        forceSSL = true;
        locations."/" = {
          proxyPass = "https://jellyfin.panthera-flops.ts.net";
          recommendedProxySettings = true;
          extraConfig = ''
            proxy_ssl_server_name on;
          '';
        };
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
