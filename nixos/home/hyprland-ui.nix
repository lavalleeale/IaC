{ config, ... }:

{
  services = {
    dunst = {
      enable = true;
      settings = {
        global = {
          width = 445;
          height = 100;
          offset = "(10, 10)";
          corner_radius = 10;
          padding = 13;
          horizontal_padding = 15;
          idle_threshold = 120;
          font = "Fira Mono 16";
          alignment = "left";
          format = "<b>%s (%a)</b>\\n%b";
          markup = "full";
          max_icon_size = 64;
          browser = "xdg-open";
          history_length = 10;
          line_height = 16;
        };
        urgency_low = {
          background = config.pywal-nix.colourScheme.special.background;
          foreground = config.pywal-nix.colourScheme.colours.color6;
        };
        urgency_normal = {
          background = config.pywal-nix.colourScheme.special.background;
          foreground = config.pywal-nix.colourScheme.colours.color6;
        };
        urgency_critical = {
          background = config.pywal-nix.colourScheme.special.background;
          foreground = config.pywal-nix.colourScheme.colours.color6;
        };
      };
    };

    hyprpaper = {
      enable = true;
      settings = {
        preload = [ "${config.pywal-nix.colourScheme.wallpaper}" ];
        wallpaper = [ (", " + config.pywal-nix.colourScheme.wallpaper) ];
      };
    };

    hypridle = {
      enable = true;
      settings = {
        general = {
          lock_cmd = "pidof hyprlock || hyprlock";
          before_sleep_cmd = "loginctl lock-session";
          after_sleep_cmd = "hyprctl dispatch dpms on";
        };
        listener = {
          timeout = 150;
          on-timeout = "brightnessctl -s set 0";
          on-resume = "brightnessctl -r";
        };
      };
    };
  };

  programs = {
    hyprlock = {
      enable = true;
      settings = {
        background = {
          monitor = "";
          path = "/home/alex/Pictures/wallpapers/current";
          color = "rgba(0, 0, 0, 0)";
          blur_passes = 2;
          contrast = 1;
          brightness = 0.5;
          vibrancy = 0.2;
          vibrancy_darkness = 0.2;
        };
        general = {
          hide_cursor = false;
          grace = 0;
          disable_loading_bar = true;
        };
        auth = {
          fingerprint = {
            enabled = true;
            ready_message = "Scan fingerprint to unlock";
            present_message = "Scanning...";
          };
        };
        input-field = {
          monitor = "";
          size = "250, 60";
          outline_thickness = 2;
          dots_size = 0.2;
          dots_spacing = 0.35;
          dots_center = true;
          outer_color = "rgba(255, 255, 255, 0.2)";
          inner_color = "rgba(0, 0, 0, 0.2)";
          font_color = "rgb(ffffff)";
          fade_on_empty = false;
          rounding = -1;
          check_color = "rgb(204, 136, 34)";
          placeholder_text =
            ''<i><span foreground="##cdd6f4">Input Password...</span></i>'';
          hide_input = false;
          position = "0, -200";
          halign = "center";
          valign = "center";
        };
        label = [
          {
            monitor = "";
            text = ''cmd[update:1000] date +"%A, %B %d"'';
            color = "rgba(242, 243, 244, 0.75)";
            font_size = 22;
            font_family = "JetBrains Mono";
            position = "0, 350";
            halign = "center";
            valign = "center";
          }
          {
            text = "$FPRINTPROMPT";
          }
          {
            monitor = "";
            text = ''cmd[update:1000] date +"%-I:%M"'';
            color = "rgba(242, 243, 244, 0.75)";
            font_size = 95;
            font_family = "JetBrains Mono Extrabold";
            position = "0, 200";
            halign = "center";
            valign = "center";
          }
          {
            monitor = "";
            text = "cmd[update:1000] id -nu";
            color = "rgb(ffffff)";
            font_size = 14;
            font_family = "JetBrains Mono";
            position = "0, -10";
            halign = "center";
            valign = "top";
          }
          {
            monitor = "";
            text = "cmd[update:1000] cat /sys/class/power_supply/BAT1/capacity";
            color = "rgb(ffffff)";
            font_size = 24;
            font_family = "JetBrains Mono";
            position = "-90, -10";
            halign = "right";
            valign = "top";
          }
        ];
        image = {
          monitor = "";
          path = "/home/alex/Pictures/profile.png";
          size = 100;
          border_size = 2;
          border_color = "rgb(ffffff)";
          position = "0, -100";
          halign = "center";
          valign = "center";
        };
      };
    };

    waybar = {
      enable = true;
      style = ''
        * {
          border: none;
          font-family: Cousine Nerd Font;
          font-size: 15px;
        }

        window#waybar {
          background-color: rgba(0, 0, 0, 0);
          transition-property: background-color;
          transition-duration: 0.5s;
        }

        window#waybar.hidden {
          opacity: 0.2;
        }

        #battery {
          border-radius: 0 10px 10px 0;
        }

        #network {
          border-radius: 10px 0 0 10px;
        }

        #clock,
        #workspaces,
        #custom-nextevent,
        #power-profiles-daemon {
          border-radius: 10px;
        }

        #workspaces button {
          padding: 0 0px;
          color: ${config.pywal-nix.colourScheme.special.foreground};
        }

        #workspaces button:hover {
          box-shadow: inherit;
        }

        #workspaces button.active {
          color: @color5;
        }

        #mode {
          background-color: #64727d;
          border-bottom: 3px solid #ffffff;
        }

        .module {
          padding: 0 10px;
          color: ${config.pywal-nix.colourScheme.special.foreground};
          background-color: ${config.pywal-nix.colourScheme.special.background};
        }

        label:focus {
          background-color: #000000;
        }

        #network.disconnected {
          background-color: #f53c3c;
        }

        #custom-media {
          background-color: #66cc99;
          color: #2a5c45;
          min-width: 100px;
        }

        #custom-media.custom-spotify {
          background-color: #66cc99;
        }

        #custom-media.custom-vlc {
          background-color: #ffa000;
        }

        #idle_inhibitor.activated {
          background-color: #ecf0f1;
          color: #2d3436;
        }

        #mpd {
          background-color: #66cc99;
          color: #2a5c45;
        }

        #mpd.disconnected {
          background-color: #f53c3c;
        }

        #mpd.stopped {
          background-color: #90b1b1;
        }

        #mpd.paused {
          background-color: #51a37a;
        }

        #custom-nextevent,
        #idle_inhibitor,
        #power-profiles-daemon {
          margin-left: 5px;
        }
      '';
      settings = {
        mainBar = {
          reload_style_on_change = true;
          layer = "top";
          position = "top";
          height = 30;
          modules-left = [
            "hyprland/workspaces"
            "hyprland/submap"
            "custom/media"
            "power-profiles-daemon"
            "custom/nextevent"
          ];
          modules-center = [ "clock" ];
          modules-right = [ "network" "temperature" "cpu" "memory" "battery" ];
          "hyprland/workspaces" = { format = "{name}"; };
          "hyprland/submap" = { format = ''<span style="italic">{}</span>''; };
          clock = {
            tooltip-format = ''
              <big>{:%Y %B}</big>
              <tt><small>{calendar}</small></tt>'';
            format-alt = "{:%Y-%m-%d}";
            format = "{:%I:%M %p}";
          };
          cpu = {
            format = "{usage}% ";
            tooltip = false;
          };
          memory = { format = "{}% "; };
          temperature = {
            hwmon-path = "/sys/class/hwmon/hwmon5/temp1_input";
            critical-threshold = 80;
          };
          backlight = {
            format = "{percent}% {icon}";
            reverse-scrolling = true;
            format-icons = [ "" "" "" "" "" "" "" "" "" ];
          };
          battery = {
            states = {
              warning = 30;
              critical = 15;
            };
            format = "{capacity}% {icon}";
            format-full = "{capacity}% {icon}";
            format-charging = "{capacity}% ";
            format-plugged = "{capacity}% ";
            format-alt = "{time} {icon}";
            format-icons = [ "" "" "" "" "" ];
            interval = 1;
          };
          power-profiles-daemon = {
            format = "{icon}";
            tooltip-format = ''
              Power profile: {profile}
              Driver: {driver}'';
            tooltip = true;
            format-icons = {
              default = "";
              performance = "";
              balanced = "";
              power-saver = "";
            };
          };
          network = {
            interface = "wlp*";
            format-wifi = "{essid} ({signalStrength}%) ";
            format-ethernet = "{ipaddr}/{cidr} ";
            tooltip-format = "{ifname} via {gwaddr} ";
            format-linked = "{ifname} (No IP) ";
            format-disconnected = "Disconnected ⚠";
            format-alt = "{ifname}: {ipaddr}/{cidr}";
            tooltip = true;
          };
          pulseaudio = {
            format = "{volume}% {icon}";
            format-bluetooth = "{volume}% {icon} {format_source}";
            format-bluetooth-muted = " {icon} {format_source}";
            format-muted = " {format_source}";
            format-source = "{volume}% ";
            format-source-muted = "";
            format-icons = {
              headphone = "";
              hands-free = "";
              headset = "";
              phone = "";
              portable = "";
              car = "";
              default = [ "" "" "" ];
            };
            on-click = "pavucontrol";
            reverse-scrolling = true;
          };
          "custom/media" = {
            format = "{icon} {text}";
            return-type = "json";
            max-length = 40;
            format-icons = {
              spotify = "";
              default = "🎜";
            };
            escape = true;
            exec = "$HOME/.config/waybar/mediaplayer.py 2> /dev/null";
          };
          "custom/power" = {
            format = "⏻ ";
            tooltip = false;
            menu = "on-click";
            menu-file = "$HOME/.config/waybar/power_menu.xml";
            menu-actions = {
              shutdown = "shutdown now";
              reboot = "reboot";
              suspend = "systemctl suspend";
              hibernate = "systemctl hibernate";
            };
          };
          "custom/nextevent" = {
            format = "{}";
            max-length = 40;
            escape = true;
            interval = 60;
            exec = "nextevent $HOME/Calendars/racs.ics";
          };
        };
      };
    };
  };
}
