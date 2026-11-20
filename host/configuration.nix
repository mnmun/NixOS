{
  pkgs,
  system,
  stateVersion,
  scripts,
  keek,
  ...
}:
{
  boot = {
    initrd.kernelModules = [ "amdgpu" ];

    kernelPackages = pkgs.linuxPackagesFor pkgs.linux_xanmod_latest;
    kernelParams = [
      "video=DisplayPort-0:1920x1080@60"
      "video=HDMI-A-0:1920x1080@75"
    ];

    loader = {
      efi = {
        canTouchEfiVariables = true;
        efiSysMountPoint = "/boot/efi";
      };

      grub = {
        device = "nodev";
        efiSupport = true;
        gfxmodeEfi = "1920x1080";
        useOSProber = true;
      };
    };

    supportedFilesystems = [ "ntfs" ];
  };

  swapDevices = [
    {
      device = "/var/lib/swapfile";
      size = 16 * 1024;
    }
  ];

  documentation = {
    enable = true;
    info.enable = true;

    man = {
      enable = true;
      generateCaches = true;
      man-db.enable = true;
    };
  };

  i18n = {
    defaultLocale = "en_US.UTF-8";
    supportedLocales = [
      "en_US.UTF-8/UTF-8"
      "ru_RU.UTF-8/UTF-8"
    ];
  };

  environment = {
    systemPackages = [
      scripts.packages.${system}.default
      keek.packages.${system}.default
      pkgs.kdePackages.networkmanager-qt
    ];

    plasma6.excludePackages = with pkgs.kdePackages; [
      plasma-browser-integration
    ];
  };

  fonts = {
    enableDefaultPackages = true;
    fontconfig.useEmbeddedBitmaps = true;

    packages = with pkgs; [
      nerd-fonts.jetbrains-mono
    ];
  };

  hardware = {
    bluetooth = {
      enable = true;
      powerOnBoot = true;
    };

    graphics = {
      enable = true;
      enable32Bit = true;
    };

    steam-hardware = {
      enable = true;
    };
  };

  networking = {
    hostName = "B550";

    # For wg-quick: https://wiki.nixos.org/wiki/WireGuard#wg-quick_issues_with_NetworkManager
    networkmanager = {
      enable = true;
      dns = "systemd-resolved";
    };

    firewall = {
      # TODO test syncthing without settings below

      # Syncthing ports: 8384 for remote access to GUI
      # 22000 TCP and/or UDP for sync traffic
      # 21027/UDP for discovery
      # source: https://docs.syncthing.net/users/firewall.html
      allowedTCPPorts = [
        8384
        22000
      ];

      allowedUDPPorts = [
        22000
        21027
      ];

      # Enable wireguard
      logReversePathDrops = true;

      extraCommands = ''
        ip46tables -t mangle -I nixos-fw-rpfilter -p udp -m udp --sport 51820 -j RETURN
        ip46tables -t mangle -I nixos-fw-rpfilter -p udp -m udp --dport 51820 -j RETURN
      '';

      extraStopCommands = ''
        ip46tables -t mangle -D nixos-fw-rpfilter -p udp -m udp --sport 51820 -j RETURN || true
        ip46tables -t mangle -D nixos-fw-rpfilter -p udp -m udp --dport 51820 -j RETURN || true
      '';
    };
  };

  nix = {
    package = pkgs.nixVersions.latest;

    settings = {
      auto-optimise-store = true;

      experimental-features = [
        "nix-command"
        "flakes"
      ];

      substituters = [
        "https://cache.nixos.org"
        "https://nix-community.cachix.org"
      ];

      trusted-users = [
        "a"
        "w"
      ];

      trusted-public-keys = [
        "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      ];
    };
  };

  nixpkgs.config = {
    allowUnfree = true;
    allowUnfreePredicate = _: true;
  };

  programs = {
    gnupg.agent = {
      enable = true;
      enableSSHSupport = true;
    };

    nh.enable = true;

    nix-ld = {
      enable = true;
      libraries = with pkgs; [
        alsa-lib
        at-spi2-core
        cairo
        cups
        dbus
        fontconfig
        freetype
        glib
        libgbm
        libx11
        libxcb
        libxext
        libxfixes
        libxkbcommon
        libxrandr
        nspr
        nss
        pango
        vulkan-loader
        xorg.libXcomposite
        xorg.libXdamage
        libGL
        libvorbis
        mpg123
        SDL2
      ];
    };
  };

  services = {
    blueman.enable = true;

    displayManager = {
      plasma-login-manager.enable = true;
    };

    desktopManager = {
      plasma6.enable = true;
    };

    openssh = {
      enable = true;
      settings.PasswordAuthentication = false;
    };

    picom = {
      enable = true;
      vSync = true;
    };

    printing = {
      enable = true;
    };

    pulseaudio = {
      enable = false;
    };

    # For wg-quick: https://wiki.nixos.org/wiki/WireGuard#wg-quick_issues_with_NetworkManager
    resolved = {
      enable = true;
    };

    xserver = {
      enable = true;
      videoDrivers = [ "amdgpu" ];

      xkb = {
        layout = "us,ru";
        options = "grp:alt_shift_toggle";
      };

      xrandrHeads = [
        {
          output = "HDMI-A-0";
          primary = true;
          monitorConfig = ''
            VertRefresh 75
          '';
        }
        {
          output = "DisplayPort-0";
        }
      ];
    };
  };

  system = {
    stateVersion = stateVersion;
  };

  time.timeZone = "Europe/Moscow";

  users.users = {
    a = {
      description = "a";
      isNormalUser = true;

      extraGroups = [
        "networkmanager"
        "wheel"
        "audio"
      ];

      packages = with pkgs; [
        glibcLocalesUtf8
      ];
    };

    w = {
      description = "w";
      isNormalUser = true;

      extraGroups = [
        "networkmanager"
        "wheel"
        "audio"
      ];

      packages = with pkgs; [
        glibcLocalesUtf8
      ];
    };
  };
}
