{ pkgs, lib, ... }:

let
  isLinux = pkgs.stdenv.hostPlatform.isLinux;
  isDarwin = pkgs.stdenv.hostPlatform.isDarwin;

  flakePath =
    if isDarwin then "~/Projects/Desktop/.#macbook" else "~/Projects/Desktop/.#alice";
  homeManagerFlake = "~/Projects/Desktop/.#sasha@alice";

  sharedAliases = {
    ls = "eza --icons";
    ll = "eza --icons -l";
    la = "eza --icons -a";
    lla = "eza --icons -la";
    cat = "bat";
    top = "btop";
    search = "rg";
    tree = "tree -I 'node_modules|.git|.venv'";
    v = "nvim";
    e = "nvim";
    fm = "lf";
    fmt = "nixfmt";
    lint-nix = "statix check";
    lint-sh = "shellcheck";
    neo = "fastfetch";
    sysinfo = "fastfetch";
    tkill = "tmux kill-server";
    decrypt = "age -d";
    encrypt = "age -e";
    gst = "git status";
    ga = "git add .";
    gc = "git commit -a -m";
    gl = "git log --oneline --graph -10";
    mkvenv = "uv venv";
    vac = "source .venv/bin/activate";
    vdac = "deactivate";
    webup = "python3 -m http.server 8080 --bind 127.0.0.1";
  };

  linuxAliases = {
    rebuild-sys = "sudo nixos-rebuild switch --flake ${flakePath}";
    rebuild-hm = "nix run home-manager -- switch --flake ${homeManagerFlake}";
    rebuild-all = "sudo nixos-rebuild switch --flake ${flakePath} && nix run home-manager -- switch --flake ${homeManagerFlake}";
    rebuild = "nix run home-manager -- switch --flake ${homeManagerFlake}";
    hm = "nix run home-manager -- switch --flake ${homeManagerFlake}";
    ss = "grim -g \"$(slurp)\" - | wl-copy";
    doc = "obsidian";
    pdf = "zathura";
    draw = "xournalpp";
    study = "anki";
    msg = "discord";
    ide = "codium";
    code = "codium";
    menu = "rofi -show drun";
    emoji = "rofimoji -a copy";
    lock = "swaylock";
    vm = "virt-manager";
    play = "playerctl play-pause";
    playnext = "playerctl next";
    playprev = "playerctl previous";
    "vol+" = "pactl set-sink-volume @DEFAULT_SINK@ +5%";
    "vol-" = "pactl set-sink-volume @DEFAULT_SINK@ -5%";
    "bright+" = "brightnessctl set +5%";
    "bright-" = "brightnessctl set 5%-";
    xc = "wl-copy";
    wifi = "nmtui";
    obs = "obs-studio";
  };

  darwinAliases = {
    rebuild = "darwin-rebuild switch --flake ${flakePath}";
    xc = "pbcopy";
    xp = "pbpaste";
  };
in
{
  programs.zsh = {
    enable = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;
    enableCompletion = true;

    history = {
      size = 50000;
      save = 50000;
      ignoreDups = true;
      ignoreAllDups = true;
      share = true;
    };

    shellAliases =
      sharedAliases
      // (if isLinux then linuxAliases else { })
      // (if isDarwin then darwinAliases else { });

    initContent =
      ''
        typeset -U path
        umask 027
        eval "$(zoxide init --cmd cd zsh)"
        gup() {
          if [ $# -lt 2 ]; then
            echo "Usage: gup <branch> <message>"
            return 1
          fi
          local branch="$1" message="$2"
          git fetch && git pull origin "$branch"
          echo "--- Git Status ---"
          git status --short
          read -q "REPLY?Stage all changes? (y/N) " && echo
          [[ "$REPLY" == "y" ]] || return
          git add .
          git diff --staged
          read -q "REPLY?Commit '$message'? (y/N) " && echo
          if [[ "$REPLY" == "y" ]]; then
            git commit -m "$message" && git push -u origin "$branch" && echo "All done"
          else
            git reset
          fi
        }
        untar() {
          if [ -z "$1" ]; then
            echo "Usage: untar <file.tar.xz|tar.gz|tar.bz2|tar>"
            return 1
          fi
          if [ ! -f "$1" ]; then
            echo "Error: File not found: $1"
            return 1
          fi
          tar -xf "$1" && echo "Extracted $1"
        }
        _nix_shell_info() {
          if [ -n "$IN_NIX_SHELL" ]; then
            local name="''${name:-nix}"
            echo " %F{yellow}($name)%f"
          fi
        }
        lf() {
          tmp="$(mktemp)"
          command lf -last-dir-path="$tmp" "$@"
          if [ -f "$tmp" ]; then
            dir="$(cat "$tmp")"
            [ -d "$dir" ] && [ "$dir" != "$(pwd)" ] && cd "$dir"
          fi
          rm -f "$tmp"
        }
      ''
      + lib.optionalString isLinux ''
        myip() {
          ip route get 1.1.1.1 2>/dev/null | awk '{for(i=1;i<=NF;i++) if ($i=="src") print $(i+1)}'
        }
        wp() {
          local dir="$HOME/Pictures/wallpapers"
          case "$1" in
            ls) eza --icons "$dir" ;;
            search) find "$dir" -iname "*$2*" -not -name wallpaper ;;
            "")  echo "Usage: wp <wallpaper> | wp ls | wp search <keyword>" ;;
            *)
              local match
              match=$(find "$dir" -maxdepth 1 \( -name "$1" -o -name "$1.*" \) -not -name wallpaper | head -1)
              if [ -n "$match" ]; then
                cp "$match" "$dir/wallpaper" && i3 restart && echo "Wallpaper set to $1"
              else
                echo "Wallpaper '$1' not found"
              fi ;;
          esac
        }
      ''
      + lib.optionalString isDarwin ''
        myip() {
          ipconfig getifaddr en0 2>/dev/null || echo "No active interface"
        }
      '';
  };

  programs.starship = {
    enable = true;
    enableZshIntegration = true;
    settings = {
      add_newline = true;
      format = "$username$hostname$nix_shell$directory$git_branch$git_status$line_break$character";
      username = {
        show_always = true;
        format = "[$user]($style)";
        style_user = "white";
      };
      hostname = {
        ssh_only = false;
        format = "@[$hostname]($style) ";
        style = "white";
      };
      directory = {
        truncation_length = 4;
        style = "cyan";
      };
      git_branch = {
        format = "[$symbol$branch]($style) ";
        style = "green";
      };
      nix_shell = {
        format = "[($name)]($style) ";
        style = "yellow";
      };
      character = {
        success_symbol = "[\\$](bright-cyan)";
        error_symbol = "[\\$](red)";
      };
    };
  };
}
