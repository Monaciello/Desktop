# Git configuration
{ ... }:
{
  programs.git = {
    enable = true;
    signing = {
      key = "/home/sasha/.ssh/id_ed25519.pub";
      signByDefault = true;
    };
    settings = {
      user.name = "monaciello";
      user.email = "tahgijones@gmail.com";
      gpg.format = "ssh";
    };
  };
}
