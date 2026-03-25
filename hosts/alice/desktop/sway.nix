{ pkgs, ... }:
{
  # Required for rpi-imager (and other tools) to access block devices without sudo
  services.udisks2.enable = true;

  programs.sway = {
    enable = true;
    wrapperFeatures.gtk = true;
  };

  services.greetd = {
    enable = true;
    settings.default_session = {
      command = "${pkgs.tuigreet}/bin/tuigreet --time --cmd sway";
      user = "greeter";
    };
  };

  programs.xwayland.enable = true;

  security.pam.services.swaylock = { };
}
