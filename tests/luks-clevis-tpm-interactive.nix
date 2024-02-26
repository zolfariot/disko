{ pkgs ? import <nixpkgs> { }
, diskoLib ? pkgs.callPackage ../lib { }
}:
diskoLib.testLib.makeDiskoTest {
  inherit pkgs;
  name = "luks-clevis-tpm-interactive";
  disko-config = ../example/luks-clevis-tpm-interactive.nix;
  extraInstallerConfig = {
    # Currently luks-clevis only works with systemd in initrd
    virtualisation.tpm.enable = true;
  };
  extraSystemConfig = {
    boot.initrd.systemd.enable = true;
  };
  extraTestScript = ''
    machine.succeed("cryptsetup isLuks /dev/vda2");
  '';
  bootCommands = ''
    machine.wait_for_console_text("")
    machine.wait_for_console_text("vda")
    machine.send_console("secretsecret\n")
  '';
}
