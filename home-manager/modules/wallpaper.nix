# Declarative wallpaper management via Home Manager
# Wallpapers are placed in ~/.background-image
# i3 uses feh to set the wallpaper from this file
# To set a wallpaper:
#   1. Place your wallpaper file in ~/Pictures/wallpapers/
#   2. Use 'wp <name>' alias to set it as active
#   3. Or directly symlink: ln -s ~/Pictures/wallpapers/your-wallpaper ~/.background-image
{ ... }:
{
  # Create wallpapers directory for user to add custom wallpapers
  home.file."Pictures/wallpapers/.keep".text = "";

  # Optionally set a default wallpaper (customize with your own)
  # Uncomment and modify the line below to set a default:
  # home.file.".background-image".source = /path/to/your/wallpaper.png;
}
