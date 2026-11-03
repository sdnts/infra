{ ... }:

{
  services.immich = {
    enable = true;
    host = "0.0.0.0";
    port = 2283;
    mediaLocation = "/nas/media/photos";
    # machine-learning.enable = false;
  };
}
