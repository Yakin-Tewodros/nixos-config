# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:
let
home-manager = builtins.fetchTarball {
  url = "https://github.com/nix-community/home-manager/archive/release-25.11.tar.gz";
  sha256 = "13fmry1jd0na71fxhzms9qf3ybj6shgvnphq4p1akxxmv44gzq20";
};
in
{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
      (import "${home-manager}/nixos")
    ];

    home-manager.useUserPackages = true;
    home-manager.useGlobalPkgs = true;
    home-manager.backupFileExtension = "backup";
    home-manager.users.unitrix = import ./home.nix;    

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Use latest kernel.
  boot.kernelPackages = pkgs.linuxPackages_6_1;

  # memmap
  boot.kernelParams = [
    "memmap=128M$0x2BB000000"
  ];

# ################################################################################

  nix = {
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 14d";
    };

    optimise = {
      automatic = true;
      dates = [ "weekly" ];
    };

    settings = {

      auto-optimise-store = true;
#     max-jobs = 4;
#     cores = 0;
#     max-substitution-jobs = 16;
#     http-connections = 50;

      substituters = [
        "https://cache.nixos.org"
        "https://nix-community.cachix.org"
        "https://mirror.sjtu.edu.cn/nix-channels/store" # Shanghai Jiao Tong University - best for Asia
        "https://mirrors.ustc.edu.cn/nix-channels/store" # USTC backup mirror
        # "https://hyprland.cachix.org"
        # "https://aseipp-nix-cache.global.ssl.fastly.net"
      ];

#     trusted-public-keys = [
#       "cache.nixos.org-1:6NCHdD59X431o0gWypbQdK5ZPzZp9Yq+1pP7o0f6tqM="
#       "nix-community.cachix.org-1:mB9FSKXESj1v3Yv1fR8Fv1LkzG4lWc5h9b6Ew9R0Z9o="
#     ];

    };
  };

  fonts = {
    enableDefaultPackages = true;
    enableGhostscriptFonts = true;
  
    packages = with pkgs; [
      nerd-fonts.jetbrains-mono
    ];
  
    fontconfig.defaultFonts = {
      monospace = [ "JetBrainsMono Nerd Font" ];
    };
  };


# ################################################################################

  networking = {
    hostName = "nixos"; # Define your hostname.
    networkmanager.enable = true;
    firewall = {
      trustedInterfaces = [ "wlp5s0" "virbr0" ];
    };

    # wireless.enable = true;  # Enables wireless support via wpa_supplicant.
    # Configure network proxy if necessary
    # proxy.default = "http://user:password@proxy:port/";
    # proxy.noProxy = "127.0.0.1,localhost,internal.domain";
  };

  zramSwap.enable = true;

  # Set your time zone.
  time.timeZone = "Africa/Addis_Ababa";

  # Select internationalisation properties.
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

  # Enable the GNOME Desktop Environment.
  services.desktopManager.gnome.enable = true;
  services.displayManager.gdm.enable = true;

  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };

  # services.printing.enable = true; # Enable CUPS to print documents.

  # Enable sound with pipewire.
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    # If you want to use JACK applications, uncomment this
    #jack.enable = true;

    # use the example session manager (no others are packaged yet so this is enabled by default,
    # no need to redefine it in your config for now)
    #media-session.enable = true;
  };

  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.libinput.enable = true;

  services.ollama = {
    enable = true;
    # loadModels = [ "llama3.2:3b" "deepseek-r1:1.5b"];
    package = pkgs.ollama-cuda;
  };

  services.open-webui.enable = true;

  # Enable flatpak
  services.flatpak.enable = true;

  # Graphics
  services.xserver.enable = true;
  hardware.graphics.enable = true;
  services.xserver.videoDrivers = [
    "modesetting"
    "nvidia"
  ];
  hardware.nvidia = {
    open = false;
    modesetting.enable = true;
    powerManagement = {
      enable = true;
      finegrained = true;
    };
    prime = {
      offload.enable = true;
      offload.enableOffloadCmd = true;
      intelBusId = "PCI:0:2:0";
      nvidiaBusId = "PCI:1:0:0";
    };
  };

  #  boot.extraModprobeConfig = ''
  #    options nvidia NVreg_DynamicPowerManagement=0x02
  #  '';

  #  environment.sessionVariables = {
  #    __NV_PRIME_RENDER_OFFLOAD = "0";
  #    __GLX_VENDOR_LIBRARY_NAME = "mesa";
  #    __VK_LAYER_NV_optimus = "N";
  #  };
  
  users.users.unitrix = {
    isNormalUser = true;
    description = "unitrix";
    extraGroups = [ "networkmanager" "wheel" "libvirtd" "docker" "podman" ];
    shell = pkgs.fish;
    packages = with pkgs; [
      # Tools
        mpv kitty nethogs easyeffects telegram-desktop fsearch obsidian 
	qbittorrent gimp koreader qimgv gparted firefox-devedition
	scrcpy czkawka-full file
      # Dev
        filezilla vscode distrobox # jetbrains.idea netbeans
      # Dev Tools
        gcc lazygit nodejs docker-compose cmake python3
	php phpPackages.composer mariadb alpaca
      # QoL
        pop-launcher kanata 
      # Fonts
        nerd-fonts.jetbrains-mono
      # Gnome
        gnome-extension-manager gnome-tweaks gnomeExtensions.pop-shell gdm-settings
        dconf-editor 
      # Utilities
        wl-clipboard btop qemu_full yt-dlp fzf fd ripgrep ntfs3g lsd trash-cli 
	bat kdePackages.ark unrar-wrapper unzip p7zip gzip pkg-config 
	kdePackages.kimageformats libheif fish go gdb gnumake bzip2 xz 
	ffmpeg-full bibata-cursors # bibata-cursors-translucent 
      ];
  };

  # Cursor
  environment.variables = {
    XCURSOR_THEME = "Bibata-Modern-Classic"; # or Bibata-Modern-Ice, etc.
    XCURSOR_SIZE = "24";
  };

  # db setup
    # services.mysql.enable = true;
    services.mysql = {
      enable = true;
      package = pkgs.mariadb;
    
      settings = {
        mysqld = {
          bind-address = "127.0.0.1";
        };
      };
    };

  # Open-any-terminal
  # services.xserver.desktopManager.gnome.extraGSettingsOverridePackages = [
  services.desktopManager.gnome.extraGSettingsOverridePackages = [
    pkgs.nautilus-open-any-terminal
  ];
  environment.sessionVariables.NAUTILUS_EXTENSION_DIR = "${config.system.path}/lib/nautilus/extensions-4";
  environment.pathsToLink = [
    "/share/nautilus-python/extensions"
  ];
  programs.nautilus-open-any-terminal = {
    enable = true;
    terminal = "kitty";
  };

  # Install programs
  programs.firefox.enable = true;
  programs.yazi.enable = true;
  programs.git.enable = true;
  programs.java.enable = true;
  programs.neovim.enable = true;

  environment = {
    variables = { EDITOR = "nvim"; VISUAL = "nvim"; };
    shellAliases = {
      "ll" = "ls -l";
      "v" = "nvim";
      "y" = "yazi";
    };
  };

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    vim
    wget
  ];

  # Filesystems
  boot.supportedFilesystems = [ "ntfs" ];
  fileSystems."/mnt/Yakin" = {
    device = "/dev/disk/by-uuid/84B2ECA7B2EC9F44";  # find with lsblk -f
    fsType = "ntfs-3g";
    options = [ "uid=1000" "gid=100" "umask=022" "x-gvfs-show" "noauto" ];
    neededForBoot = false;
  };
  fileSystems."/mnt/shared" = {
    device = "/dev/disk/by-uuid/39F3E5012C5CD2CB";  # find with lsblk -f
    fsType = "ntfs-3g";
    options = [ "rw" "uid=1000" "gid=100" "umask=022" "x-gvfs-show" ];
    neededForBoot = false;
  };
  #  fileSystems."/mnt/Windows" = {
  #    device = "/dev/disk/by-uuid/E60686F60686C6D1";  # find with lsblk -f
  #    fsType = "ntfs-3g";
  #    options = [ "uid=1000" "gid=100" "umask=022" "noauto" "x-gvfs-show" ];
  #    neededForBoot = false;
  #  };


  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # Microcode
  hardware.cpu.intel.updateMicrocode = true;

  # Syncthing
  services.syncthing = {
    enable = true;
    dataDir = "/home/unitrix";
    openDefaultPorts = true;
    configDir = "/home/unitrix/.config/syncthing";
    user = "unitrix";
    group = "users";
    # guiAddress = "0.0.0.0:8384";
    # declarative = { SNIPPED };
  };

  # KANATA #
  # Enable the uinput module
  boot.kernelModules = [ "uinput" ];
  # Enable uinput
  hardware.uinput.enable = true;
  # Set up udev rules for uinput
  services.udev.extraRules = ''
  # Enable runtime PM for NVIDIA GPU
  ACTION=="add", SUBSYSTEM=="pci", ATTR{vendor}=="0x10de", ATTR{power/control}="auto"

  # uinput device rule
  KERNEL=="uinput", MODE="0660", GROUP="uinput", OPTIONS+="static_node=uinput"
'';
# services.udev.extraRules = ''
#   # Enable runtime PM for NVIDIA GPU
#   ACTION=="add", SUBSYSTEM=="pci", ATTR{vendor}=="0x10de", ATTR{power/control}="auto"
# '';
# services.udev.extraRules = ''
#   KERNEL=="uinput", MODE="0660", GROUP="uinput", OPTIONS+="static_node=uinput"
# '';
  # Ensure the uinput group exists
  users.groups.uinput = { };
  # Add the Kanata service user to necessary groups
  systemd.services.kanata-internalKeyboard.serviceConfig = {
    SupplementaryGroups = [ "input" "uinput" ];
  };
  services.kanata = {
    enable = true;
    keyboards = {
      internalKeyboard = {
        devices = [ # Use `ls /dev/input/by-path/` to find your keyboard devices.
          "/dev/input/by-path/platform-i8042-serio-0-event-kbd"
        ];
        extraDefCfg = "process-unmapped-keys yes";
        config = ''
          (defsrc
            caps lsft rsft
          )
          
          ;; default layer: caps tap => Esc, hold => Left Ctrl
          ;; Shift keys use @lsft_alias/@rsft_alias so they shift and also activate the shifted layer
          (deflayer default
            @cap   @lsft_alias   @rsft_alias
          )
          
          ;; shifted layer (active while a Shift key is held):
          ;; caps tap => CapsLock, hold => Left Ctrl
          (deflayer shifted
            @capS  @lsft_alias   @rsft_alias
          )
          
          (defalias
            ;; default caps behaviour
            cap  (tap-hold-press 200 200 esc  lctl)
            ;; caps behaviour while shift layer is active
            capS (tap-hold-press 200 200 caps lctl)
          
            ;; Shift keys both act as shift and activate the shifted layer while held
            lsft_alias (multi lsft (layer-while-held shifted))
            rsft_alias (multi rsft (layer-while-held shifted))
          )
        '';
      };
    };
  };

  environment.sessionVariables.NIXOS_OZONE_WL = "1";

  # VMs
  programs.virt-manager.enable = true;
  virtualisation.spiceUSBRedirection.enable = true;
  virtualisation.libvirtd = {
    enable = true;
    onBoot = "start";
    qemu = {
      package = pkgs.qemu_kvm;
#     runAsRoot = true;
      swtpm.enable = true;
#     ovmf = {
#       enable = true;
#       packages = [(pkgs.OVMF.override {
#         secureBoot = true;
#         tpmSupport = true;
#       }).fd];
#     };
    };
  };

  virtualisation.podman = {
    enable = true;
    dockerCompat = true;
  };

#  virtualisation.docker = {
#    enable = true;
#  };
  
  systemd.services."libvirt-default-network" = {
    description = "Autostart libvirt default network";
    after = ["libvirtd.service"];
    wantedBy = ["multi-user.target"];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = "true";
      ExecStart = "${pkgs.libvirt}/bin/virsh net-start default";
      ExecStop = "${pkgs.libvirt}/bin/virsh net-destroy default";
    };
  };

  programs.fish.enable = true;
  
  # Enable the OpenSSH daemon.
  services.openssh.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "25.11"; # Did you read the comment?

}
