{ pkgs ? import <nixpkgs> { }
, diskoLib ? pkgs.callPackage ../lib { }
}:
diskoLib.testLib.makeDiskoTest {
  inherit pkgs;
  name = "luks-clevis-tpm-interactive";
  disko-config = ../example/luks-clevis-tpm-interactive.nix;
  extraInstallerConfig = {
    virtualisation.tpm.enable = true;
  };
  extraSystemConfig = {
    # nixos/clevis does not support luks bind in non-systemd initrd
    boot.initrd.systemd.enable = true;
  };
  extraTestScript = ''
    machine.succeed("cryptsetup isLuks /dev/vda2")
    machine.fail('cryptsetup open --test-passphrase /dev/vda2 --key-file <(echo -n "clevis-temp-passphrase")')
  '';
  # TODO: figure out how to link the same virtual TPM to install and booted machine
  bootCommands = ''
    machine.wait_for_console_text("Starting password query on")
    machine.send_console("secretsecret\n")
  '';
}
