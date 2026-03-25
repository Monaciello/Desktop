{ pkgs, ... }:
let
  colors = import ./colors.nix;
in
{
  programs.waybar = {
    enable = true;
    package = pkgs.waybar;
    systemd.enable = true;

    settings = {
      mainBar = {
        layer = "top";
        position = "top";
        height = 36;
        spacing = 12;

        # Mac-like: minimal left, right-aligned essential status modules, simple center
        modules-left = [ ];
        modules-center = [ ];
        modules-right = [
          "network"
          "pulseaudio"
          "battery"
          "clock"
        ];

        # Module definitions
        network = {
          format-wifi = "󰤨 {essid}";
          format-ethernet = "󰈁 {ifname}";
          format-linked = "󰈁 {ifname} (No IP)";
          format-disconnected = "󰤭 Offline";
          tooltip-format = "{ifname}: {ipaddr}/{cidr}";
          on-click = "${pkgs.networkmanagerapplet}/bin/nm-connection-editor";
        };

        pulseaudio = {
          format = "{icon} {volume}%";
          format-muted = "󰖁 Muted";
          format-icons = {
            default = [
              "󰕾" # high
              "󰖀" # med
              "󰕿" # low
            ];
          };
          on-click = "${pkgs.pulseaudio}/bin/pactl set-sink-mute @DEFAULT_SINK@ toggle";
        };

        battery = {
          bat = "BAT0";
          interval = 8;
          states = {
            warning = 30;
            critical = 15;
          };
          format = "{icon} {capacity}%";
          format-charging = " {capacity}%";
          format-plugged = "󰚥 {capacity}%";
          format-alt = "{icon} {time}";
          format-icons = [
            "󰁺"
            "󰂆"
            "󰁼"
            "󰁾"
            "󰁹"
          ];
        };

        clock = {
          format = "{:%a %d %b  %H:%M}";
          tooltip-format = "<big>{:%A, %B %d, %Y}</big>";
        };
      };
    };

    style = ''
      * {
        font-family: "San Francisco", "SF Pro Text", "Inter", "Segoe UI", "Cantarell", "Noto Sans", "Cascadia Code", "monospace", sans-serif;
        font-size: 16px;
        border: none;
        border-radius: 10px;
        min-height: 0;
      }

      window#waybar {
        background: rgba(245, 245, 245, 0.72);
        color: ${colors.text};
        border-radius: 12px;
        box-shadow: 0px 2px 8px 0px rgba(0,0,0,0.07);
      }

      #network,
      #pulseaudio,
      #battery,
      #clock {
        color: #222222;
        background: transparent;
        padding: 0 18px;
        margin: 4px 0;
        border-radius: 10px;
      }

      #clock {
        font-weight: 520;
        letter-spacing: 0.5px;
      }

      #network {
        font-family: "SF Pro Text", "Segoe UI", "Cantarell", "Noto Sans", "monospace", sans-serif;
        font-weight: 450;
      }

      #pulseaudio {
        font-family: "SF Pro Text", monospace, sans-serif;
      }

      #battery.charging,
      #battery.plugged {
        color: ${colors.green};
      }

      #battery.warning:not(.charging):not(.plugged) {
        color: ${colors.yellow};
      }

      #battery.critical:not(.charging):not(.plugged) {
        color: ${colors.red};
        animation: blink 0.8s linear infinite alternate;
      }

      @keyframes blink {
        to {
          background: ${colors.red};
          color: #fff;
        }
      }

      #pulseaudio.muted {
        color: #aaaaaa;
      }
    '';
  };
}
