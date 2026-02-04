{ config, pkgs, ... }:
let
  # Nord-inspired color palette - customize here for system-wide theming
  colors = {
    base00 = "#2e3440"; # Background
    base01 = "#3b4252"; # Alt background
    base02 = "#434c5e"; # Selection
    base03 = "#4c566a"; # Comments
    base04 = "#d8dee9"; # Alt foreground
    base05 = "#eceff4"; # Foreground
    base06 = "#8fbcbb"; # Diff add
    base07 = "#88c0d0"; # Diff remove

    # Accent colors
    red = "#bf616a";
    green = "#a3be8c";
    yellow = "#ebcb8b";
    orange = "#d08770";
    blue = "#81a1c1";
    purple = "#b48ead";
    cyan = "#8fbcbb";
  };

  # Generate gtk.css from Nix color palette
  gtkCss = pkgs.writeText "gtk.css" ''
    @define-color base00 ${colors.base00};
    @define-color base01 ${colors.base01};
    @define-color base02 ${colors.base02};
    @define-color base03 ${colors.base03};
    @define-color base04 ${colors.base04};
    @define-color base05 ${colors.base05};
    @define-color base06 ${colors.base06};
    @define-color base07 ${colors.base07};

    @define-color red ${colors.red};
    @define-color green ${colors.green};
    @define-color yellow ${colors.yellow};
    @define-color orange ${colors.orange};
    @define-color blue ${colors.blue};
    @define-color purple ${colors.purple};
    @define-color cyan ${colors.cyan};

    @define-color accent ${colors.blue};
    @define-color accent-danger ${colors.red};
    @define-color accent-warning ${colors.yellow};
    @define-color accent-success ${colors.green};

    /* Window and general background */
    window {
      background-color: @base00;
      color: @base05;
    }

    /* Header bars and title bars */
    headerbar,
    .titlebar {
      background-color: @base01;
      color: @base05;
      border-color: @base02;
    }

    /* Buttons */
    button {
      background-image: none;
      background-color: @base02;
      color: @base05;
      border: 1px solid @base03;
    }

    button:hover {
      background-color: @base03;
    }

    button:active {
      background-color: @accent;
      color: @base00;
    }

    /* Text entries */
    entry {
      background-color: @base01;
      color: @base05;
      border: 1px solid @base03;
      padding: 4px;
    }

    entry:focus {
      border-color: @accent;
    }

    /* Scrollbars */
    scrollbar slider {
      background-color: @base03;
      border-radius: 4px;
    }

    scrollbar slider:hover {
      background-color: @base04;
    }

    /* Selection */
    selection {
      background-color: @accent;
      color: @base00;
    }

    /* Tooltips */
    tooltip {
      background-color: @base02;
      color: @base05;
      border: 1px solid @base03;
    }
  '';
in
{
  gtk = {
    enable = true;

    theme = {
      name = "Adapta-Nokto";
      package = pkgs.adapta-gtk-theme;
    };

    iconTheme = {
      name = "Papirus-Dark";
      package = pkgs.papirus-icon-theme;
    };

    cursorTheme = {
      name = "Bibata-Modern-Classic";
      package = pkgs.bibata-cursors;
      size = 24;
    };
  };

  # Pointer cursor configuration
  home.pointerCursor = {
    name = "Bibata-Modern-Classic";
    package = pkgs.bibata-cursors;
    size = 24;
    gtk.enable = true;
    x11.enable = true;
  };

  # Generate and install gtk.css for both GTK 3 and 4
  xdg.configFile."gtk-3.0/gtk.css".source = gtkCss;
  xdg.configFile."gtk-4.0/gtk.css".source = gtkCss;

  # Settings file for dark theme preference
  xdg.configFile."gtk-3.0/settings.ini".text = ''
    [Settings]
    gtk-application-prefer-dark-theme=1
    gtk-theme-name=Adapta-Nokto
    gtk-icon-theme-name=Papirus-Dark
    gtk-cursor-theme-name=Bibata-Modern-Classic
    gtk-cursor-theme-size=24
  '';
}
