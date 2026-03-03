{ config, ... }:
{
  xdg = {
    enable = true;

    userDirs = {
      enable = true;
      createDirectories = true;
      documents = "${config.home.homeDirectory}/Files/Documents";
      download = "${config.home.homeDirectory}/Files/Downloads";
      pictures = "${config.home.homeDirectory}/Pictures";
      desktop = "${config.home.homeDirectory}/Files/Desktop";
      music = "${config.home.homeDirectory}/Files/Music";
      videos = "${config.home.homeDirectory}/Files/Videos";
      templates = "${config.home.homeDirectory}/Files/Templates";
      publicShare = "${config.home.homeDirectory}/Files/Public";
    };
  };
}
