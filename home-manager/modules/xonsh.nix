{
  config,
  pkgs,
  ...
}: {
  home.packages = [
    ( pkgs.xonsh.override {
       extraPackages = ps: [
        pkgs.xontrib-uvox
       ];
    })
  ];
  home.file.".xonshrc".text = builtins.readFile ./dotfiles/xonshrc;
}
