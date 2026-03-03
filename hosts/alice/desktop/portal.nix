{ pkgs, lib, ... }:
{
  xdg.portal = {
    enable = true;
    wlr.enable = true;
    extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
    config = {
      common.default = "gtk";
      sway.default = lib.mkForce [ "wlr" "gtk" ];
    };
  };
}
