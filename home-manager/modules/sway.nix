# =============================================================================
# KEY LAYOUT
# =============================================================================
# Super (Mod4) = All window manager controls (focus, move, workspaces, layouts)
# Alt   (Mod1) = App launchers only (rofi, rofimoji, swaylock)
# Super+App    = Direct app shortcuts: d=Discord, v=Firefox, q=virt-manager,
#                Shift+f=flameshot, Shift+n=lf, Shift+o=Obsidian, Shift+r=OBS
# Hardware keys = Media / brightness (XF86 keys)
# Leader key (Neovim/tmux) = Space
# =============================================================================

{ pkgs, lib, ... }:
let
  colors = import ./colors.nix;

  mod = "Mod4";   # Super -- all WM controls
  modApp = "Mod1"; # Alt   -- app launchers only
  mod4 = "Mod4";  # Super+app shortcuts
  terminal = "${pkgs.kitty}/bin/kitty";
  wallpaper = "$HOME/Pictures/wallpapers/wallpaper";
in
{
  wayland.windowManager.sway = {
    enable = true;
    package = pkgs.sway;
    wrapperFeatures.gtk = true;
    checkConfig = false;

    config = {
      modifier = mod;

      fonts = {
        names = [ "Cascadia Code" ];
        size = 10.0;
      };

      terminal = terminal;

      startup = [
        { command = "${pkgs.flameshot}/bin/flameshot"; }
        { command = "${pkgs.networkmanagerapplet}/bin/nm-applet --indicator"; }
        { command = "${pkgs.mako}/bin/mako"; }
      ];

      input = {
        "type:touchpad" = {
          natural_scroll = "enabled";
          tap = "enabled";
          drag = "enabled";
        };
        "type:keyboard" = {
          xkb_layout = "us";
          xkb_numlock = "enabled";
        };
      };

      output = {
        "*" = {
          bg = "${wallpaper} fill";
        };
      };

      window = {
        border = 1;
        titlebar = false;
      };

      floating = {
        border = 1;
        titlebar = false;
      };

      gaps = {
        inner = 10;
        outer = 2;
        smartGaps = true;
      };

      workspaceOutputAssign = [ ];

      assigns = {
        "4:Notes" = [ { app_id = "obsidian"; } ];
      };

      keybindings = lib.mkOptionDefault {
        # WM core (Super)
        "${mod}+Return" = "exec ${terminal}";
        "${mod}+Shift+q" = "kill";
        "${mod}+Shift+c" = "reload";
        "${mod}+Ctrl+r" = "restart";

        # App launchers (Alt) -- no conflict with terminal/editor
        "${modApp}+s" = "exec ${pkgs.rofi}/bin/rofi -show drun";
        "${modApp}+c" = "exec ${pkgs.rofimoji}/bin/rofimoji -a copy";
        "${modApp}+x" = "exec ${pkgs.swaylock}/bin/swaylock";

        # Direct app shortcuts (Super+key)
        "${mod4}+d" = "exec ${pkgs.discord}/bin/discord";
        "${mod4}+Shift+f" = "exec ${pkgs.flameshot}/bin/flameshot gui";
        "${mod4}+Shift+n" = "exec ${terminal} -e ${pkgs.lf}/bin/lf";
        "${mod4}+Shift+o" = "exec ${pkgs.obsidian}/bin/obsidian";
        "${mod4}+q" = "exec ${pkgs.virt-manager}/bin/virt-manager";
        "${mod4}+Shift+r" = "exec ${pkgs.obs-studio}/bin/obs";
        "${mod4}+v" = "exec ${pkgs.firefox}/bin/firefox";

        "XF86AudioRaiseVolume" = "exec ${pkgs.pulseaudio}/bin/pactl set-sink-volume @DEFAULT_SINK@ +5%";
        "XF86AudioLowerVolume" = "exec ${pkgs.pulseaudio}/bin/pactl set-sink-volume @DEFAULT_SINK@ -5%";
        "XF86AudioMute" = "exec ${pkgs.pulseaudio}/bin/pactl set-sink-mute @DEFAULT_SINK@ toggle";

        "XF86MonBrightnessDown" = "exec ${pkgs.brightnessctl}/bin/brightnessctl set 5%-";
        "XF86MonBrightnessUp" = "exec ${pkgs.brightnessctl}/bin/brightnessctl set +5%";

        "XF86AudioPlay" = "exec ${pkgs.playerctl}/bin/playerctl play-pause";
        "XF86AudioPause" = "exec ${pkgs.playerctl}/bin/playerctl play-pause";
        "XF86AudioNext" = "exec ${pkgs.playerctl}/bin/playerctl next";
        "XF86AudioPrev" = "exec ${pkgs.playerctl}/bin/playerctl previous";

        "${mod}+h" = "focus left";
        "${mod}+j" = "focus down";
        "${mod}+k" = "focus up";
        "${mod}+l" = "focus right";
        "${mod}+Shift+h" = "move left";
        "${mod}+Shift+j" = "move down";
        "${mod}+Shift+k" = "move up";
        "${mod}+Shift+l" = "move right";

        "${mod}+e" = "splith";
        "${mod}+o" = "splitv";
        "${mod}+f" = "fullscreen toggle";
        "${mod}+p" = "layout stacking";
        "${mod}+b" = "layout tabbed";
        "${mod}+t" = "layout toggle split";

        "${mod}+Shift+space" = "floating toggle";
        "${mod4}+space" = "focus mode_toggle";

        "${mod}+1" = "workspace number 1:Web";
        "${mod}+2" = "workspace number 2:Term";
        "${mod}+3" = "workspace number 3:Code";
        "${mod}+4" = "workspace number 4:Notes";
        "${mod}+5" = "workspace number 5:Files";
        "${mod}+6" = "workspace number 6:Media";
        "${mod}+7" = "workspace number 7:Chat";
        "${mod}+8" = "workspace number 8:VM";
        "${mod}+9" = "workspace number 9:Misc";
        "${mod}+0" = "workspace number 10:Mon";

        "${mod}+Shift+1" = "move container to workspace number 1:Web";
        "${mod}+Shift+2" = "move container to workspace number 2:Term";
        "${mod}+Shift+3" = "move container to workspace number 3:Code";
        "${mod}+Shift+4" = "move container to workspace number 4:Notes";
        "${mod}+Shift+5" = "move container to workspace number 5:Files";
        "${mod}+Shift+6" = "move container to workspace number 6:Media";
        "${mod}+Shift+7" = "move container to workspace number 7:Chat";
        "${mod}+Shift+8" = "move container to workspace number 8:VM";
        "${mod}+Shift+9" = "move container to workspace number 9:Misc";
        "${mod}+Shift+0" = "move container to workspace number 10:Mon";

        "${mod}+r" = "mode resize";
        "${mod}+g" = "mode gaps";

        # Power menu (override default exit prompt)
        "${mod}+Shift+e" = "exec ${pkgs.sway}/bin/swaynag -f 'Cascadia Code, 12' -m 'Exit Sway? This will end your current Wayland session.' -B 'Exit now' 'swaymsg exit' -B 'Suspend' 'systemctl suspend' -B 'Reboot' 'systemctl reboot' -B 'Power off' 'systemctl poweroff'";
      };

      modes = {
        resize = {
          "h" = "resize shrink width 10 px";
          "j" = "resize grow height 10 px";
          "k" = "resize shrink height 10 px";
          "l" = "resize grow width 10 px";
          "Return" = "mode default";
          "Escape" = "mode default";
        };
        gaps = {
          "1" = "gaps inner all set 10, gaps outer all set 4, mode default";
          "2" = "gaps inner all set 1, gaps outer all set 1, mode default";
          "Return" = "mode default";
          "Escape" = "mode default";
        };
      };

      colors = {
        focused = {
          border = colors.yellow;
          background = colors.yellow;
          text = "#0f1c21";
          indicator = colors.yellow;
          childBorder = colors.yellow;
        };
        focusedInactive = {
          border = colors.surface2;
          background = colors.surface2;
          text = "#0f1c21";
          indicator = colors.surface2;
          childBorder = colors.surface2;
        };
        unfocused = {
          border = colors.surface2;
          background = colors.surface2;
          text = "#0f1c21";
          indicator = colors.surface2;
          childBorder = colors.surface2;
        };
        urgent = {
          border = colors.teal;
          background = colors.teal;
          text = colors.text;
          indicator = colors.teal;
          childBorder = colors.teal;
        };
      };

      bars = [ ];
    };

  };
}
