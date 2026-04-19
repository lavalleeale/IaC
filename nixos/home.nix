{ lib, config, pkgs, pkgs-unstable, hyprland-plugins, ... }:

let stripFirst = s: builtins.substring 1 (builtins.stringLength s - 1) s;
in {
  # Home Manager needs a bit of information about you and the
  # paths it should manage.
  home = {
    username = "alex";
    homeDirectory = "/home/alex";
    packages = with pkgs;
      let
        mediaTools = [ imagemagick plasma5Packages.kdeconnect-kde ];

        # Science and education
        scienceTools = [ mars-mips texlive-custom ];
        texlive-custom = texlive.combine {
          inherit (pkgs.texlive)
            scheme-medium titlesec fontawesome changepage enumitem;
        };
        editors = [
          android-studio
          jetbrains.clion
          jetbrains.phpstorm
          pkgs-unstable.neovim
          vim
          pkgs-unstable.vscode
        ];
        securityTools =
          [ openssl sbctl tpm2-tools yubikey-manager bitwarden-cli ];
        virtTools = [
          (vagrant.override { withLibvirt = false; })
          dnsmasq
          packer
          virt-manager
        ];
        desktopApps = [
          catppuccin-papirus-folders
          alacritty
          kdePackages.dolphin
          dunst
          google-chrome
          firefox
          zen-browser
          kitty
          obsidian
          parsec-bin
          ledger-live-desktop
          postman
          prismlauncher
          tetrio-desktop
          tor-browser-bundle-bin
          vesktop
          vlc
        ];
        waylandTools = [
          brightnessctl
          hyprshot
          hyprsunset
          pamixer
          rofi-wayland
          wayvnc
          wl-clipboard
        ];
        otherUtils = [
          borgbackup
          code-cursor
          dmenu
          eza
          flintlock
          gorg
          wl-paste
          libimobiledevice
          libisoburn
          linuxKernel.packages.linux_zen.perf
          mangohud
          monero-cli
          monero-gui
          power-profiles-daemon
          pywal
          samba
          unzip
          valgrind
          xdg-utils
        ];
        devUtils = [
          act
          atuin
          cachix
          cypress
          gemini-cli
          gh
          jq
          niv
          nix-output-monitor
          nixfmt-classic
          nixpkgs-fmt
          starship
          thefuck
          zoxide
        ];
      in devUtils ++ mediaTools ++ scienceTools ++ securityTools ++ virtTools
      ++ desktopApps ++ waylandTools ++ otherUtils ++ editors;

    # This value determines the Home Manager release that your
    # configuration is compatible with. This helps avoid breakage
    # when a new Home Manager release introduces backwards
    # incompatible changes.
    #
    # You can update Home Manager without changing this value. See
    # the Home Manager release notes for a list of state version
    # changes in each release.
    stateVersion = "25.05";
    shellAliases = {
      bell = ''echo -e "\a"'';
      pbcopy = "wl-copy";
      pbpaste = "wl-paste";
      please = "sudo $(fc -ln -1)";
      open = "xdg-open";
      vg =
        "valgrind --leak-check=full --track-origins=yes --show-reachable=yes";
      ls = "eza";
      ll = "eza -l";
      nix-s = "nix-shell --run $SHELL -p";
      f = "fuck --yeah";
    };
  };
  qt = {
    enable = true;
    platformTheme.name = "adwaita";
    style.name = "adwaita-dark";
  };
  pywal-nix.wallpaper = ./wallpapers/current;
  wayland.windowManager.hyprland = {
    enable = true;
    plugins = let plugins = hyprland-plugins.packages.${pkgs.system};
    in [ plugins.hyprexpo ];
    settings = {
      plugin = { hyprexpo = { columns = 2; }; };
      general = {
        gaps_in = 5;
        gaps_out = 15;
        border_size = 3;
        "col.active_border" = "$color1 $color1 $color2 45deg";
        "col.inactive_border" = "$color3 $color3 $color4 45deg";
        resize_on_border = true;
        allow_tearing = false;
        layout = "dwindle";
      };
      decoration = {
        rounding = 10;
        active_opacity = 1.0;
        inactive_opacity = 0.8;
        blur = {
          enabled = true;
          size = 2;
          passes = 1;
          special = true;
          vibrancy = 0.1696;
        };
      };
      animations = {
        enabled = true;
        bezier = "myBezier, 0.05, 0.9, 0.1, 1.05";
        animation = [
          "windows, 1, 7, myBezier"
          "windowsOut, 1, 7, default, popin 80%"
          "border, 1, 10, default"
          "borderangle, 1, 8, default"
          "fade, 1, 7, default"
          "workspaces, 1, 10, myBezier, slide"
          "specialWorkspace, 1, 6, myBezier, slidefadevert -80"
        ];
      };
      misc = {
        force_default_wallpaper = 1;
        disable_hyprland_logo = true;
      };
      gestures = {
        workspace_swipe = true;
        workspace_swipe_fingers = 4;
      };
      input = {
        kb_layout = "us";
        follow_mouse = 1;
        sensitivity = 0;
        touchpad = {
          natural_scroll = true;
          disable_while_typing = false;
        };
      };
      device = [
        {
          name = "frmw0004:00-32ac:0006-consumer-control-1";
          natural_scroll = true;
        }
        {
          name = "thinkpad-essential-wireless-mouse";
          sensitivity = -1.0;
        }
        {
          name = "logitech-usb-receiver";
          sensitivity = -0.75;
        }
      ];
      xwayland.force_zero_scaling = true;
      monitor = [ ",preferred,auto,auto" "eDP-1,2256x1504@60,0x0,1.175" ];
      env = [
        "XCURSOR_SIZE,24"
        "HYPRCURSOR_SIZE,24"
        "ELECTRON_OZONE_PLATFORM_HINT,wayland"
        "QT_QPA_PLATFORMTHEME,qt6ct"
        "GOPATH,$HOME/go"
        "GOBIN,$HOME/go/bin"
        "YARNBIN,$HOME/.yarn/bin"
        "PYENV_ROOT,$HOME/.pyenv"
        "PATH,$HOME/.pyenv/bin:$PATH:$HOME/go/bin:$HOME/.yarn/bin:$HOME/.local/bin:$HOME/.rvm/bin"
        "XDG_CONFIG_HOME,$HOME/.config"
        "XDG_DATA_HOME,$HOME/.local/share"
        "HYPRSHOT_DIR,$HOME/Screenshots"
      ];
      exec-once = [
        "/usr/lib/polkit-kde-authentication-agent-1"
        "hyprsunset"
        "dunst"
        "waybar"
        "xremap $HOME/.config/xremap/config.yml"
        "sleep 1 && wl-copy-slurp"
        "$(dirname $(readlink $(which kdeconnect-app)))/../libexec/kdeconnectd "
        "[workspace $zenWorkspace silent] zen-beta"
        "[workspace $terminalWorkspace silent] alacritty"
        "[workspace $codeWorkspace silent] code"
        "[workspace $obsidianWorkspace silent] obsidian"
      ];
      "$mainMod" = "SUPER";
      "$zenWorkspace" = "1";
      "$terminalWorkspace" = "2";
      "$codeWorkspace" = "3";
      "$obsidianWorkspace" = "4";
      bind = [
        "$mainMod, RETURN, exec, alacritty"
        "$mainMod, C, killactive,"
        "$mainMod, L, exec, hyprlock"
        "$mainMod, J, togglefloating,"
        "$mainMod, space, exec, pidof gorg || gorg -a"
        ''$mainMod, grave, exec, sh -c "dunstify "Start and size" "$(slurp)"''
        "$mainMod, left, movefocus, l"
        "$mainMod, right, movefocus, r"
        "$mainMod, up, movefocus, u"
        "$mainMod, down, movefocus, d"
        "$mainMod, Tab, workspace, $zenWorkspace"
        "$mainMod, q, workspace, $terminalWorkspace"
        "$mainMod, w, workspace, $codeWorkspace"
        "$mainMod, e, workspace, $obsidianWorkspace"
        "$mainMod, r, workspace, 5"
        "$mainMod SHIFT, Tab, movetoworkspace, $zenWorkspace"
        "$mainMod SHIFT, q, movetoworkspace, $terminalWorkspace"
        "$mainMod SHIFT, w, movetoworkspace, $codeWorkspace"
        "$mainMod SHIFT, e, movetoworkspace, $obsidianWorkspace"
        "$mainMod SHIFT, r, movetoworkspace, 5"
        "$mainMod, S, togglespecialworkspace, magic"
        "$mainMod SHIFT, S, movetoworkspace, special:magic"
        "$mainMod, mouse_down, workspace, e+1"
        "$mainMod, mouse_up, workspace, e-1"
        ", PRINT, exec, hyprshot -m window -m active --clipboard-only"
        "$shiftMod, PRINT, exec, hyprshot -m region --clipboard-only"
        "$mainMod, H, exec, dunstctl close"
        "$mainMod SHIFT, H, exec, dunstctl history-pop"
        "$mainMod, V, exec, wl-copy-picker gorg -m equation,dmenu"
        "$mainMod, G, togglegroup"
        "$mainMod, N, changegroupactive, f"
        "$mainMod SHIFT, N, changegroupactive, b"
        "$mainMod, B, exec, $HOME/.local/bin/btcon"
        "$mainMod, F, fullscreen"
      ];
      bindm = [
        "$mainMod, mouse:272, movewindow"
        "$mainMod, mouse:273, resizewindow"
      ];
      bindel = [
        ",XF86AudioRaiseVolume, exec, pamixer -i 5"
        ",XF86AudioLowerVolume, exec, pamixer -d 5"
        ",XF86AudioMute, exec, pamixer -t"
        ",XF86MonBrightnessUp, exec, brightnessctl s 10%+"
        ",XF86MonBrightnessDown, exec, brightnessctl s 10%-"
        "SHIFT,XF86MonBrightnessUp, exec, hyprctl hyprsunset identity"
        "SHIFT,XF86MonBrightnessDown, exec, hyprctl hyprsunset temperature 1000"
        ",XF86AudioMedia, hyprexpo:expo, toggle"
      ];
      bindl = [
        ", XF86AudioNext, exec, playerctl next"
        ", XF86AudioPause, exec, playerctl play-pause"
        ", XF86AudioPlay, exec, playerctl play-pause"
        ", XF86AudioPrev, exec, playerctl previous"
      ];
      windowrulev2 = [
        "nofocus,class:^$,title:^$,xwayland:1,floating:1,fullscreen:0,pinned:0"
        "workspace $zenWorkspace, class:zen-beta"
        "workspace $codeWorkspace, class:code"
        "group, class:code"
        "float, title:Picture-in-Picture"
        "pin, title:Picture-in-Picture"
        "size 30% 30%, title:Picture-in-Picture"
        "float, title:^Extension"
      ];
    } // lib.genAttrs ((builtins.genList (i: "$color" + toString i) 16)
      ++ [ "$background" "$foreground" "$cursor" ]) (name:
        let key = stripFirst name;
        in "rgb(" + stripFirst
        (if lib.hasAttr key config.pywal-nix.colourScheme.colours then
          config.pywal-nix.colourScheme.colours.${key}
        else
          config.pywal-nix.colourScheme.special.${key}) + ")");
  };
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
    gpg-agent = {
      enable = true;
      pinentry.package = pkgs.pinentry-qt;
    };
  };

  # Let Home Manager install and manage itself.
  programs = {
    home-manager.enable = true;
    direnv.enable = true;
    hyprlock = {
      enable = true;
      settings = {
        background = {
          monitor = "";
          #path = screenshot
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

        # INPUT FIELD
        input-field = {
          monitor = "";
          size = "250, 60";
          outline_thickness = 2;
          dots_size = 0.2; # Scale of input-field height, 0.2 - 0.8
          dots_spacing = 0.35; # Scale of dots' absolute size, 0.0 - 1.0
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

        # Fingerprint status
        label = [
          # DATE
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

          # TIME
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

          # USERNAME
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

          # BATTERY PERCENTAGE
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

        # Profile Picture
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
    alacritty = {
      enable = true;
      settings = {
        window = {
          opacity = 0.5;
          blur = true;
        };
        font.bold = {
          family = "FiraCode Nerd Font Mono";
          style = "Bold";
        };
        font.bold_italic = {
          family = "FiraCode Nerd Font Mono";
          style = "Bold Italic";
        };
        font.italic = {
          family = "FiraCode Nerd Font Mono";
          style = "Italic";
        };
        font.normal = {
          family = "FiraCode Nerd Font Mono";
          style = "Regular";
        };
        keyboard.bindings = [{
          key = "N";
          mods = "Control|Shift";
          action = "CreateNewWindow";
        }];
        hints.enabled = [
          # Open links in firefox
          {
            regex =
              "https?:\\\\/\\\\/[\\\\w.]*(?:[-a-zA-Z0-9()@:%_\\\\+.~#?&\\\\/=]*)";
            command = {
              program = "zen-beta";
              args = [ "--new-tab" ];
            };
            mouse = { enabled = true; };
          }
          # Open files in vscode
          {
            regex = "[\\\\w\\\\.-][\\\\w/-]+\\\\.\\\\S+(:\\\\d+:\\\\d+)?";
            command = {
              program = "code";
              args = [ "--goto" ];
            };
            mouse = { enabled = true; };
          }
        ];
      };
    };
    git = {
      enable = true;
      userName = "Alex Lavallee";
      userEmail = "73203142+lavalleeale@users.noreply.github.com";
      signing = {
        key = "34F2E4A1C992F98B51C01D22968D37F0C632E219";
        signByDefault = true;
      };
      ignores = [
        ".direnv"
        ".envrc"
        "shell.nix"
        "default.nix"
        "Session.vim"
        "venv"
        "aliases.zsh"
        ".copilot-pull-request-description-instructions.md"
      ];
      extraConfig = {
        "credential \"https://github.com\"".helper =
          "!/run/current-system/sw/bin/gh auth git-credential";
        "credential \"https://gist.github.com\"".helper =
          "!/run/current-system/sw/bin/gh auth git-credential";
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
    zsh = {
      enable = true;
      initContent = ''
        mklatex() {
            if [ -z "$1" ]; then
                echo "Usage: mklatex <filename>"
                return 1
            fi
            local filename="$1"
            latexmk -pdf -halt-on-error "$filename" && latexmk -c "$filename"
        }
        split() {
            local escaped
            escaped=$(printf '%q ' "$@")
            hyprctl dispatch exec "alacritty --working-directory $(pwd) -e sh -c \"$escaped\""
        }
        bindkey "^[[1;5C" forward-word
        bindkey "^[[1;5D" backward-word
        export GPG_TTY=$(tty)
        wal -Rq
        autoload -U edit-command-line
        zle -N edit-command-line
        bindkey '^xe' edit-command-line
        bindkey '^x^e' edit-command-line
      '';
      sessionVariables = {
        EDITOR = "code --wait";
        VISUAL = "code --wait";
        DIRENV_LOG_FORMAT = "";
      };
      enableCompletion = true;
      autosuggestion.enable = true;
      syntaxHighlighting.enable = true;
    };
    zoxide = {
      enable = true;
      options = [ "--cmd cd" ];
    };
    atuin.enable = true;
    thefuck.enable = true;
    starship = {
      enable = true;
      settings = {
        format =
          "[](red)$os$username[](bg:blue fg:red)$directory[](fg:blue bg:green)$git_branch$git_status[](fg:green bg:cyan)$nix_shell[](fg:cyan bg:yellow)$time[ ](fg:yellow)";
        username = {
          show_always = true;
          style_user = "bg:red";
          style_root = "bg:red";
          format = "[$user ]($style)";
          disabled = false;
        };
        os = {
          style = "bg:#9A348E";
          disabled = true;
        };
        directory = {
          style = "bg:blue";
          format = "[ $path ]($style)";
          truncation_length = 3;
          truncation_symbol = "…/";
          substitutions = {
            "Documents" = "󰈙 ";
            "Downloads" = " ";
            "Music" = " ";
            "Pictures" = " ";
          };
        };
        c = {
          symbol = " ";
          style = "bg:cyan";
          format = "[ $symbol ($version) ]($style)";
        };
        nix_shell = {
          style = "bg:cyan fg:white";
          format = "[via $symbol(($name))]($style)";
        };
        elixir = {
          symbol = " ";
          style = "bg:cyan";
          format = "[ $symbol ($version) ]($style)";
        };
        elm = {
          symbol = " ";
          style = "bg:cyan";
          format = "[ $symbol ($version) ]($style)";
        };
        git_branch = {
          symbol = "";
          style = "bg:green";
          format = "[ $symbol $branch ]($style)";
        };
        git_status = {
          style = "bg:green";
          format = "[ $all_status$ahead_behind ]($style)";
        };
        golang = {
          symbol = " ";
          style = "bg:cyan";
          format = "[ $symbol ($version) ]($style)";
        };
        gradle = {
          style = "bg:cyan";
          format = "[ $symbol ($version) ]($style)";
        };
        haskell = {
          symbol = " ";
          style = "bg:cyan";
          format = "[ $symbol ($version) ]($style)";
        };
        java = {
          symbol = " ";
          style = "bg:cyan";
          format = "[ $symbol ($version) ]($style)";
        };
        julia = {
          symbol = " ";
          style = "bg:cyan";
          format = "[ $symbol ($version) ]($style)";
        };
        nodejs = {
          symbol = "";
          style = "bg:cyan";
          format = "[ $symbol ($version) ]($style)";
        };
        nim = {
          symbol = "󰆥 ";
          style = "bg:cyan";
          format = "[ $symbol ($version) ]($style)";
        };
        rust = {
          symbol = "";
          style = "bg:cyan";
          format = "[ $symbol ($version) ]($style)";
        };
        scala = {
          symbol = " ";
          style = "bg:cyan";
          format = "[ $symbol ($version) ]($style)";
        };
        time = {
          disabled = false;
          time_format = "%R"; # Hour:Minute Format
          style = "bg:yellow";
          format = "[ $time ]($style)";
        };
      };
    };
  };
}
