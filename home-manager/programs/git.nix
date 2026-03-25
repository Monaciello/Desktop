# Git configuration — uses 1Password SSH agent for commit signing
{
  pkgs,
  config,
  ...
}:
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
      # HM 25.05+: explicit format silences migration warning (we use SSH signing via 1Password)
      format = "ssh";
    };
    settings = {
      user.name = "monaciello";
      # Public GitHub noreply — avoids committing a private address. For other remotes or a real
      # address, set `user.email` in ~/.config/git/config.local and use `include.path` (see HM docs).
      user.email = "monaciello@users.noreply.github.com";
      gpg.format = "ssh";
      gpg."ssh".program = opSshSign;
    };
  };
}
