{
  hq = {
    ssh = {
      host.publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIElyCp73bj6rynqXtidNGtIRLm5/ZIcMO2l19RB2yHWv";
      users.sdnts.publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMWGM4NdIRG/7JuEZInmXCOk/SzVmElszaXoY2az+XnA";
    };
  };
  cloudflare = {
    ssh = {
      host.publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIH/UcIUjjMizXx9wp4XB/n7omfxWRkrSd/+hBWWeQjsV";
      users.sdnts.publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAsUFP0se63MTYdLStdlIw95EcmA/HUm8n5WXF1wuaIz";
    };
  };
  mainframe.ssh.host.publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFmIy/g0BbC5ZcZP622kZfsQv/2qRq3ZBFfnz9i+ZB3f";
  bastion.ssh.host.publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMyFKQNMR+B9BBb+qVLkFOHDTAAToHETmXJHiZL0apPv";
  sentry.ssh.host.publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINW8KnnWZwAg+rZBpZM/5Eos3XhuYfkTAhkBc+8TElv5";
  vault.ssh.host.publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGrO1XKk8EKcSdyQLB1l4SyY00RBR4vgHlV8geZDrLO3";
}
