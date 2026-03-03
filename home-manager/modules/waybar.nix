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
        height = 30;
        spacing = 7;

        modules-left = [
          "sway/workspaces"
          "sway/mode"
          "sway/window"
        ];
        modules-center = [ ];
        modules-right = [
          "network"
          "cpu"
          "disk"
          "pulseaudio"
          "battery"
          "clock"
        ];

        "sway/workspaces" = {
          disable-scroll = false;
          all-outputs = true;
          format = "{name}";
        };

        "sway/mode" = {
          format = "<span style=\"italic\">{}</span>";
        };

        "sway/window" = {
          format = "{}";
          max-length = 50;
          tooltip = false;
        };

        network = {
          format-wifi = "  {essid} ({signalStrength}%)";
          format-ethernet = "  {ifname}";
          format-linked = "  {ifname} (No IP)";
          format-disconnected = "⚠ Disconnected";
          tooltip-format = "{ifname}: {ipaddr}/{cidr}";
          on-click = "${pkgs.networkmanagerapplet}/bin/nm-connection-editor";
        };

        cpu = {
          format = "  {usage}%";
          tooltip = false;
          interval = 1;
        };

        disk = {
          format = "  {percentage_used}%";
          path = "/";
          interval = 30;
          tooltip-format = "{path}: {used} / {total}";
        };

        pulseaudio = {
          format = "{icon} {volume}%";
          format-muted = " Muted";
          format-icons = {
            headphone = "";
            hands-free = "";
            headset = "";
            phone = "";
            portable = "";
            car = "";
            default = [
              ""
              ""
              ""
            ];
          };
          on-click = "${pkgs.pulseaudio}/bin/pactl set-sink-mute @DEFAULT_SINK@ toggle";
        };

        battery = {
          bat = "BAT0";
          interval = 5;
          states = {
            warning = 30;
            critical = 15;
          };
          format = "{icon} {capacity}%";
          format-charging = " {capacity}%";
          format-plugged = " {capacity}%";
          format-alt = "{icon} {time}";
          format-icons = [
            ""
            ""
            ""
            ""
            ""
          ];
        };

        clock = {
          format = "  {:%a %b %d  %H:%M}";
          tooltip-format = "<big>{:%Y %B}</big>\n<tt><small>{calendar}</small></tt>";
        };
      };
    };

    style = ''
      * {
        font-family: "Cascadia Code", monospace;
        font-size: 12px;
        border: none;
        border-radius: 0;
        min-height: 0;
      }

      window#waybar {
        background-color: rgba(15, 28, 33, 0.7);
        color: ${colors.text};
      }

      #workspaces button {
        padding: 0 10px;
        color: ${colors.mauve};
        background-color: rgba(15, 28, 33, 0.7);
      }

      #workspaces button.focused {
        color: #0f1c21;
        background-color: ${colors.yellow};
      }

      #workspaces button.active {
        color: #0f1c21;
        background-color: ${colors.mauve};
      }

      #workspaces button.urgent {
        color: ${colors.text};
        background-color: ${colors.teal};
      }

      #mode {
        color: ${colors.text};
        background-color: rgba(15, 28, 33, 0.7);
        padding: 0 10px;
      }

      #window {
        color: ${colors.text};
        background-color: rgba(15, 28, 33, 0.7);
        padding: 0 10px;
      }

      #network,
      #cpu,
      #disk,
      #pulseaudio,
      #battery,
      #clock {
        color: ${colors.text};
        background-color: rgba(15, 28, 33, 0.7);
        padding: 0 10px;
      }

      #battery.charging {
        color: ${colors.green};
      }

      #battery.warning:not(.charging) {
        color: ${colors.yellow};
      }

      #battery.critical:not(.charging) {
        color: ${colors.red};
        animation: blink 0.5s linear infinite alternate;
      }

      @keyframes blink {
        to {
          background-color: ${colors.red};
          color: #0f1c21;
        }
      }

      #pulseaudio.muted {
        color: ${colors.overlay1};
      }
    '';
  };
}
