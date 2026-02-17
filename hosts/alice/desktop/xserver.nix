# X server, display manager, i3
{ ... }:
{
  services.xserver = {
    enable = true;
    displayManager.lightdm.enable = true;
    windowManager.i3.enable = true;
    xkb = {
      layout = "us";
      variant = "";
    };
  };

  services.displayManager = {
    autoLogin.enable = true;
    autoLogin.user = "sasha";
    defaultSession = "none+i3";
  };

}
