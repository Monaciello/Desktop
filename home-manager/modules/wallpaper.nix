{ ... }:
{
  # Create wallpapers directory for user to add custom wallpapers
  home.file."Pictures/wallpapers/.keep".text = "";

  # Optionally set a default wallpaper (customize with your own)
  # Uncomment and modify the line below to set a default:
  # home.file.".background-image".source = /path/to/your/wallpaper.png;
}
