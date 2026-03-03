{ pkgs, ... }:
let
  colors = import ./colors.nix;

  # Generate gtk.css from Catppuccin Mocha palette
  gtkCss = pkgs.writeText "gtk.css" ''
    @define-color base ${colors.base};
    @define-color mantle ${colors.mantle};
    @define-color crust ${colors.crust};
    @define-color surface0 ${colors.surface0};
    @define-color surface1 ${colors.surface1};
    @define-color surface2 ${colors.surface2};
    @define-color overlay0 ${colors.overlay0};
    @define-color overlay1 ${colors.overlay1};
    @define-color text ${colors.text};
    @define-color subtext0 ${colors.subtext0};
    @define-color subtext1 ${colors.subtext1};

    @define-color red ${colors.red};
    @define-color green ${colors.green};
    @define-color yellow ${colors.yellow};
    @define-color peach ${colors.peach};
    @define-color blue ${colors.blue};
    @define-color mauve ${colors.mauve};
    @define-color teal ${colors.teal};
    @define-color pink ${colors.pink};
    @define-color lavender ${colors.lavender};

    @define-color accent ${colors.blue};
    @define-color accent-danger ${colors.red};
    @define-color accent-warning ${colors.yellow};
    @define-color accent-success ${colors.green};

    /* Window and general background */
    window {
      background-color: @base;
      color: @text;
    }

    /* Header bars and title bars */
    headerbar,
    .titlebar {
      background-color: @mantle;
      color: @text;
      border-color: @surface0;
    }

    /* Buttons */
    button {
      background-image: none;
      background-color: @surface0;
      color: @text;
      border: 1px solid @surface1;
    }

    button:hover {
      background-color: @surface1;
    }

    button:active {
      background-color: @accent;
      color: @base;
    }

    /* Text entries */
    entry {
      background-color: @mantle;
      color: @text;
      border: 1px solid @surface1;
      padding: 4px;
    }

    entry:focus {
      border-color: @accent;
    }

    /* Scrollbars */
    scrollbar slider {
      background-color: @surface1;
      border-radius: 4px;
    }

    scrollbar slider:hover {
      background-color: @surface2;
    }

    /* Selection */
    selection {
      background-color: @accent;
      color: @base;
    }

    /* Tooltips */
    tooltip {
      background-color: @surface0;
      color: @text;
      border: 1px solid @surface1;
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
