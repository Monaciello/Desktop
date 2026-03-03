# Git configuration — uses 1Password SSH agent for commit signing
{ pkgs, config, lib, ... }:
let
  homeDir = config.home.homeDirectory;
  isDarwin = pkgs.stdenv.hostPlatform.isDarwin;
  opSshSign =
    if isDarwin then
      "/Applications/1Password.app/Contents/MacOS/op-ssh-sign"
    else
      "${pkgs._1password-gui}/bin/op-ssh-sign";
in
{
  programs.git = {
    enable = true;
    signing = {
      key = "${homeDir}/.ssh/id_ed25519.pub";
      signByDefault = true;
    };
    settings = {
      user.name = "monaciello";
      user.email = "tahgijones@gmail.com";
      gpg.format = "ssh";
      gpg."ssh".program = opSshSign;
    };
  };
}
