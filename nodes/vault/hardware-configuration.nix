{ ... }:
{
  hardware.facter.reportPath = ./_facter.json;

  # Only manage the boot eMMC here; the nas ZFS pool is imported separately.
  # Preserve the existing partition UUIDs so deployment needs no repartitioning.
  disko.devices.disk.disk1 = {
    device = "/dev/disk/by-id/mmc-Biwin_0xf2ab8c1d";
    type = "disk";
    content = {
      type = "gpt";
      partitions = {
        esp = {
          priority = 1;
          size = "1G";
          type = "EF00";
          uuid = "ab1abf41-474f-4180-9651-6767f7565217";
          content = {
            type = "filesystem";
            format = "vfat";
            mountpoint = "/boot";
            mountOptions = [
              "fmask=0022"
              "dmask=0022"
            ];
          };
        };
        swap = {
          priority = 2;
          size = "4G";
          type = "8200";
          uuid = "ebacefcc-071f-41e9-9d2f-05ba1a5c3be7";
          content.type = "swap";
        };
        root = {
          size = "100%";
          uuid = "3bb8b67b-9dca-49db-92a6-572ba7ccf201";
          content = {
            type = "filesystem";
            format = "ext4";
            mountpoint = "/";
          };
        };
      };
    };
  };
}
