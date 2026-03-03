{ pkgs, ... }:

let
  feh = pkgs.feh;
  mpv = pkgs.mpv;
  zathura = pkgs.zathura;
  xdgOpen = "${pkgs.xdg-utils}/bin/xdg-open";
  fileCmd = "${pkgs.file}/bin/file";
  gnutar = pkgs.gnutar;
  unzip = pkgs.unzip;
  unrar = pkgs.unrar;
  p7zip = pkgs.p7zip;
  dragonDrop = pkgs.dragon-drop;
  bat = pkgs.bat;
  kitty = pkgs.kitty;
  pistol = pkgs.pistol;
  fzf = pkgs.fzf;
  ripgrep = pkgs.ripgrep;
  findutils = pkgs.findutils;

  previewer = pkgs.writeShellScriptBin "pv" ''
    #!/bin/sh
    file="$1"
    w="$2"
    h="$3"
    x="$4"
    y="$5"
    mime="$(${fileCmd} -Lb --mime-type -- "$file" 2>/dev/null)"
    case "$mime" in
      image/*)
        ${kitty}/bin/kitty +kitten icat --silent --stdin no --transfer-mode file \
          --place "''${w:-80}x''${h:-40}@''${x:-0}x''${y:-0}" "$file" < /dev/null > /dev/tty
        exit 1
        ;;
      *)
        ${pistol}/bin/pistol "$file"
        ;;
    esac
  '';

  cleaner = pkgs.writeShellScriptBin "clean" ''
    #!/bin/sh
    ${kitty}/bin/kitty +kitten icat --clear --stdin no --silent --transfer-mode file < /dev/null > /dev/tty
  '';
in
{
  programs.lf = {
    enable = true;

    settings = {
      preview = true;
      hidden = true;
      drawbox = true;
      icons = true;
      sixel = false;
    };

    keybindings = {
      "\"" = "";
      o = "";
      c = "";
      "." = "set hidden!";
      "<enter>" = "open";
      ee = "$$EDITOR \"\$f\"";
      dd = "cut";
      y = "copy";
      p = "paste";
      D = "delete";
      a = "rename";
      x = "extract";
      mf = "mkfile";
      md = "mkdir";
      do = "dragon-out";
      "<c-f>" = "fzf_jump";
      "<c-g>" = "fzf_search";
      gh = "cd";
      gc = "cd ~/.config";
    };

    commands = {
      open = ''
        case $(${fileCmd} --mime-type "$f" -bL) in
          text/*) $EDITOR "$f" ;;
          image/*) ${feh}/bin/feh "$f" ;;
          video/*) ${mpv}/bin/mpv "$f" ;;
          application/pdf) ${zathura}/bin/zathura "$f" ;;
          *) ${xdgOpen} "$f" ;;
        esac
      '';

      extract = ''
        ''${{
          case "$f" in
            *.tar.bz2|*.tbz2) ${gnutar}/bin/tar xjf "$f" ;;
            *.tar.gz|*.tgz) ${gnutar}/bin/tar xzf "$f" ;;
            *.tar.xz|*.txz) ${gnutar}/bin/tar xJf "$f" ;;
            *.tar) ${gnutar}/bin/tar xf "$f" ;;
            *.zip) ${unzip}/bin/unzip "$f" ;;
            *.rar) ${unrar}/bin/unrar x "$f" ;;
            *.7z) ${p7zip}/bin/7z x "$f" ;;
            *) echo "Unsupported format" ;;
          esac
        }}
      '';

      dragon-out = "%${dragonDrop}/bin/dragon-drop -a -x \"\$fx\"";

      mkdir = ''
        ''${{
          printf "Directory name: "
          read DIR
          mkdir -p "$DIR"
        }}
      '';

      mkfile = ''
        ''${{
          printf "File name: "
          read FILE
          touch "$FILE"
        }}
      '';

      fzf_jump = ''
        ''${{
          res="$(${findutils}/bin/find . -maxdepth 3 | ${fzf}/bin/fzf --reverse --header='Jump to location')"
          if [ -n "$res" ]; then
            if [ -d "$res" ]; then cmd="cd"; else cmd="select"; fi
            res="$(printf '%s' "$res" | sed 's/\\/\\\\/g;s/"/\\"/g')"
            lf -remote "send $id $cmd \"$res\""
          fi
        }}
      '';

      fzf_search = ''
        ''${{
          RG_PREFIX="${ripgrep}/bin/rg --column --line-number --no-heading --color=always --smart-case"
          ${fzf}/bin/fzf --ansi --disabled --layout=reverse --header="Search in files" \
            --delimiter=: \
            --bind="start:reload([ -n {q} ] && $RG_PREFIX -- {q} || true)" \
            --bind="change:reload([ -n {q} ] && $RG_PREFIX -- {q} || true)" \
            --bind='enter:become(lf -remote "send $id select \"$(printf "%s" {1} | sed '"'"'s/\\/\\\\/g;s/"/\\"/g'"'"')\"")' \
            --preview='${bat}/bin/bat --color=always {1} --highlight-line {2}'
        }}
      '';
    };

    extraConfig = ''
      set cleaner ${cleaner}/bin/clean
      set previewer ${previewer}/bin/pv
    '';
  };

  home.packages = with pkgs; [
    dragon-drop
    pistol
    unzip
    unrar
    p7zip
    gnutar
    poppler-utils
    fzf
    ripgrep
    findutils
  ];

  xdg.configFile."lf/icons".source = pkgs.fetchurl {
    url = "https://raw.githubusercontent.com/gokcehan/lf/master/etc/icons.example";
    hash = "sha256-c0orDQO4hedh+xaNrovC0geh5iq2K+e+PZIL5abxnIk=";
  };
}
