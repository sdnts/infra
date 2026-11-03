{ ... }:

{
  services.copyparty = {
    enable = true;
    settings = {
      i = "0.0.0.0";
      allow-csrf = true;
    };

    volumes = {
      "/" = {
        path = "/";
        access = {
          rwmd = "*";
        };
      };
      "/nas" = {
        path = "/nas/";
        access = {
          rwmd = "*";
        };
      };
    };
  };
}
