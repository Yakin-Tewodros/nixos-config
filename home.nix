{ config, pkgs, ... }:

{
  home.username = "unitrix";
  home.homeDirectory = "/home/unitrix";
  home.stateVersion = "25.11";

  home.packages = with pkgs; [
    fuchsia-cursor
  ];

  programs.bash.enable = true;
  programs.fish = {
    enable = true;
    interactiveShellInit = ''
      set fish_greeting # Disable greeting
    '';
  };

  home.shellAliases = {
    ll = "ls -l";
    nrs = "sudo nixos-rebuild switch";
  };

  programs.kitty = {
    enable = true;
    settings = {
      confirm_os_window_close = 0;
      enable_audio_bell = false;
      mouse_hide_wait = "-1.0";
      window_padding_width = 15;
      # window_margin_width = 15;
      cursor_trail = 1;
      hide_window_decorations = true;
      background = "#1d1d20";
      font_family = "JetBrainsMono Nerd Font";
      font_size = 13;
      # font.name = "JetBrainsMono Nerd Font";
      # font.package = "pkgs.nerd-fonts.jetbrains-mono";
      # font.size = "13";
      symbol_map = let
        mappings = [
          "U+23FB-U+23FE"
          "U+2B58"
          "U+E200-U+E2A9"
          "U+E0A0-U+E0A3"
          "U+E0B0-U+E0BF"
          "U+E0C0-U+E0C8"
          "U+E0CC-U+E0CF"
          "U+E0D0-U+E0D2"
          "U+E0D4"
          "U+E700-U+E7C5"
          "U+F000-U+F2E0"
          "U+2665"
          "U+26A1"
          "U+F400-U+F4A8"
          "U+F67C"
          "U+E000-U+E00A"
          "U+F300-U+F313"
          "U+E5FA-U+E62B"
        ];
      in
        (builtins.concatStringsSep "," mappings) + " Symbols Nerd Font";
    };
  };

home.pointerCursor = {
  name = "Bibata-Modern-Classic";
  package = pkgs.bibata-cursors;
  size = 24;

  gtk.enable = true;
  x11.enable = true;
};

home.sessionVariables = {
  XCURSOR_THEME = "Bibata-Modern-Classic";
  XCURSOR_SIZE = "24";
};

  gtk = {
    enable = true;
    cursorTheme = {
      name = "Bibata-Modern-Classic"; # Or "Adwaita", "Breeze", etc.
      package = pkgs.bibata-cursors;
      size = 24; # Optional: Set size (e.g., 24, 32, 48)
    };
    # Note the different syntax for gtk3 and gtk4
    gtk3.extraConfig = {
      "gtk-cursor-theme-name" = "Bibata-Modern-Classic";
    };
    gtk4.extraConfig = {
      Settings = ''
      gtk-cursor-theme-name=Bibata-Modern-Classic
      '';
    };
  };

  xdg.portal = {
    enable = true;
    extraPortals = [ pkgs.xdg-desktop-portal-gtk ]; # Fixes OpenURI and cursor themes in flatpaks
    config = {
      common.default = "*"; # Use default portal backend selection method
      # example with hyprland
      # hyprland.preferred = [ "Fuchsia-Pop" "gtk" ];
    };
    configPackages = [
      pkgs.xdg-desktop-portal-gtk # Ensure this portal is available
    ];
  };

  dconf.settings = {
    # Register custom shortcuts (must include ALL of them)
    "org/gnome/settings-daemon/plugins/media-keys" = {
      custom-keybindings = [
        "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/"
        "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom1/"
      ];
    };
  
    # Built-in GNOME shortcuts
    "org/gnome/desktop/wm/keybindings" = {
      close = [ "<Super>q" ];
      toggle-fullscreen = [ "<Super>F11" ];
    };
  
    # Super+T → kitty
    "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0" = {
      name = "Open Kitty";
      command = "kitty";
      binding = "<Super>t";
    };
  
    # Super+E → Home folder
    "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom1" = {
      name = "Home Folder";
      command = "nautilus ~";
      binding = "<Super>e";
    };
  };

}
