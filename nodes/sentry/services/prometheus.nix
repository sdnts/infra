{ ... }:
{
  services.prometheus = {
    enable = true;
    globalConfig = {
      scrape_interval = "1m";
    };
    scrapeConfigs = [
      {
        job_name = "node";
        static_configs = [
          { targets = [ "mainframe:9100" ]; }
          { targets = [ "bastion:9100" ]; }
          { targets = [ "vault:9100" ]; }
          { targets = [ "sentry:9100" ]; }
        ];
      }

      {
        job_name = "nginx";
        static_configs = [
          { targets = [ "bastion:9113" ]; }
        ];
      }

      {
        job_name = "prometheus";
        static_configs = [ { targets = [ "prometheus.lab.sdnts.dev" ]; } ];
      }

      {
        job_name = "grafana";
        static_configs = [ { targets = [ "grafana.lab.sdnts.dev" ]; } ];
      }

      {
        job_name = "jellyfin";
        static_configs = [ { targets = [ "jellyfin.lab.sdnts.dev" ]; } ];
      }
    ];
  };
}
