{ ... }:
let
  colors = import ./colors.nix;
in
{
  home.file.".stalonetrayrc".text = ''
    geometry 1x10
    icon_size 24
    background "${colors.crust}"
    grow_gravity NW
    sticky true
    skip_taskbar true
    icon_gravity NW
    transparent true
    tint_color "${colors.crust}"
    tint_alpha 255
  '';
}
