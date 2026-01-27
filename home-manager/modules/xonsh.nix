{
  config,
  pkgs,
  ...
}: {
  home.packages = [
    (pkgs.xonsh.override {
      extraPackages = ps: [ pkgs.xontrib-uvox ];
    })
  ];
  # xonsh with xontrib-uvox is defined at host level (xonUvox)
  # Here we only manage the xonshrc config file
  home.file.".xonshrc".text = builtins.readFile ./dotfiles/xonshrc;
}
