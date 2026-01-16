# NixOS configuration for alice
{
  config,
  pkgs,
  lib,
  inputs,
  ...
}: let
  flakeInputs = lib.filterAttrs (_: lib.isType "flake") inputs;
  xonUvox = pkgs.xonsh.override {
    extraPackages = ps: [ pkgs.xontrib-uvox ];
  };
in {
  imports = [
    ./hardware-configuration.nix
    ./secrets.nix
  ];

  # ==========================================================================
  # Host identification
  # ==========================================================================
  networking.hostName = "alice";
  networking.networkmanager.enable = true;
  system.stateVersion = "24.11";

  # ==========================================================================
  # Boot configuration
  # ==========================================================================
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.systemd-boot.configurationLimit = 5;
  boot.initrd.luks.devices."luks-92570add-ebcc-47da-917b-baea70fab43d".device = "/dev/disk/by-uuid/92570add-ebcc-47da-917b-baea70fab43d";

  # ==========================================================================
  # Nix settings
  # ==========================================================================
  nixpkgs.config.allowUnfree = true;

  nix = {
    settings = {
      experimental-features = "nix-command flakes";
      flake-registry = "";
      nix-path = config.nix.nixPath;
    };
    channel.enable = false;
    registry = lib.mapAttrs (_: flake: {inherit flake;}) flakeInputs;
    nixPath = lib.mapAttrsToList (n: _: "${n}=flake:${n}") flakeInputs;
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 30d";
    };
    optimise.automatic = true;
  };

  # ==========================================================================
  # Security
  # ==========================================================================
  networking.firewall.enable = true;

  security = {
    sudo.enable = true;
    sudo.wheelNeedsPassword = false;
    rtkit.enable = true;
  };

  services.openssh = {
    enable = true;
    settings.PermitRootLogin = "no";
  };

  # ==========================================================================
  # Users
  # ==========================================================================
  users.users.sasha = {
    uid = 1000;
    isNormalUser = true;
    description = "sasha";
    hashedPassword = "$6$D310RvwPyv5ZIocG$eG83A0Dt7bRdHMrRK29wk8PEFLcLw5dTnC1N0b8/ODKHc.UmbMlaQE///o4SUHB3vQ4wrKx/L5IkiU6YFzrw01";
    extraGroups = ["networkmanager" "wheel" "libvirtd"];
    shell = xonUvox;
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGgoYdp8IORl7zx130albZSo41PJRPARjZLSTeo2eQqa tahgijones@gmail.com"
    ];
  };

  # ==========================================================================
  # Desktop environment - i3 Window Manager
  # ==========================================================================
  services.xserver = {
    enable = true;
    displayManager.lightdm.enable = true;
    windowManager.i3.enable = true;
    xkb = {
      layout = "us";
      variant = "";
    };
  };

  services.displayManager = {
    autoLogin.enable = true;
    autoLogin.user = "sasha";
    defaultSession = "none+i3";
  };

  # Printing disabled per user preference
  # services.printing.enable = true;
  hardware.pulseaudio.enable = false;

  # ==========================================================================
  # Audio - PipeWire
  # ==========================================================================
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };
 
  programs.firefox.enable = true;

  # System packages (not user-specific - those go in home-manager)
  environment.systemPackages = with pkgs; [
    # Core utilities
    vim
    wget
    curl
    git

    # i3 and desktop
    i3
    i3status
    i3lock
    i3lock-fancy
    i3blocks
    rofi
    rofimoji
    picom
    feh
    stalonetray
    arandr
    autorandr
    lxappearance
    numlockx

    gemini-cli-bin

    # Terminal (kitty and xonsh managed by home-manager)

    # Audio/Media controls
    pamixer
    brightnessctl
    playerctl
    pulseaudio # for pactl

    # Screenshots
    flameshot

    # Clipboard
    xclip

    # X11 tools
    acpi
    sysstat # for mpstat
    xdotool
    xorg.xdpyinfo
    xorg.xprop
    xorg.xrandr

    # GTK theming
    adapta-gtk-theme
    papirus-icon-theme

    # Virtualization
    libvirt
    qemu
    spice-vdagent
    virt-manager
    virt-viewer
  ];

  # ==========================================================================
  # Bluetooth
  # ==========================================================================
  services.blueman.enable = true;
  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;
    settings = {
      General = {
        Enable = "Source,Sink,Media,Socket";
        Experimental = true;
      };
    };
  };

  # ==========================================================================
  # Power Management
  # ==========================================================================
  services.tlp = {
    enable = true;
    settings = {
      CPU_BOOST_ON_AC = 1;
      CPU_BOOST_ON_BAT = 0;
      CPU_SCALING_GOVERNOR_ON_AC = "performance";
      CPU_SCALING_GOVERNOR_ON_BAT = "powersave";
    };
  };
  services.power-profiles-daemon.enable = false;
  powerManagement.powertop.enable = true;
  services.thermald.enable = true;

  # ==========================================================================
  # SSD TRIM
  # ==========================================================================
  services.fstrim.enable = true;

  # ==========================================================================
  # Virtualization
  # ==========================================================================
  virtualisation.libvirtd.enable = true;
  
  programs.virt-manager.enable = true;

  # ==========================================================================
  # Network Services
  # ==========================================================================
  services.tailscale.enable = true;
  services.syncthing = {
    enable = true;
    user = "sasha";
    dataDir = "/home/sasha";
    configDir = "/home/sasha/.config/syncthing";
  };

  # ==========================================================================
  # XDG Portal (for screen sharing)
  # ==========================================================================
  xdg.portal = {
    enable = true;
    extraPortals = [pkgs.xdg-desktop-portal-gtk];
    config.common.default = "*";
  };

  # ==========================================================================
  # Documentation
  # ==========================================================================
  documentation.enable = true;
  documentation.dev.enable = true;
  documentation.man.enable = true;

  # ==========================================================================
  # Fonts
  # ==========================================================================
  fonts.packages = with pkgs; [
    noto-fonts
    noto-fonts-color-emoji
    cascadia-code
    font-awesome
    powerline-fonts
    powerline-symbols
    jetbrains-mono
    # (nerdfetch.override { fonts = [ "JetBrainsMono" "CascadiaCode" ]; }) not needed
  ];

  programs.xonsh.enable = true;

  # ==========================================================================
  # Environment Variables
  # ==========================================================================
  environment.variables = {
    EDITOR = "nvim";
    XKB_DEFAULT_LAYOUT = "us";
  };

  # ==========================================================================
  # Locale settings
  # ==========================================================================
  time.timeZone = "America/New_York";
  i18n.defaultLocale = "en_US.UTF-8";
  i18n.extraLocaleSettings = {
    LC_ADDRESS = "en_US.UTF-8";
    LC_IDENTIFICATION = "en_US.UTF-8";
    LC_MEASUREMENT = "en_US.UTF-8";
    LC_MONETARY = "en_US.UTF-8";
    LC_NAME = "en_US.UTF-8";
    LC_NUMERIC = "en_US.UTF-8";
    LC_PAPER = "en_US.UTF-8";
    LC_TELEPHONE = "en_US.UTF-8";
    LC_TIME = "en_US.UTF-8";
  };
}
