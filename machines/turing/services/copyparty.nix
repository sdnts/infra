{ ... }:

{
  services.copyparty = {
    enable = true;
    settings = {
      i = "127.0.0.1";
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
