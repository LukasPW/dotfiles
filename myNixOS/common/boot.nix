{...}:
{
    boot.loader.systemd-boot.enable = false;
    boot.loader.limine.enable = true;
    boot.loader.efi.canTouchEfiVariables = true;
    boot.loader.limine.maxGenerations = 5;
    #Limine config
  boot.loader.limine.style = {
    wallpapers = [ ./Fireplace.png ];   # path to your splash image
    wallpaperStyle = "stretched";           # CachyOS uses stretched, not centered/tiled
      # Light gray background, dark text for contrast
      #backdrop = "D3D3D3";  # light gray fill for the screen

      graphicalTerminal = {
        background = "00D3D3D3";  # TT=00 (opaque) + light gray, matches backdrop
        foreground = "1A1A2E";    # dark navy — reads clearly on light gray
      };

      interface = {
        brandingColor = "1A1A2E";  # title text at top
        helpColor = "333333";      # keybind hints
      };
  };

  boot.loader.limine.extraConfig = ''
    remember_last_entry: yes

    # Catppuccin Mocha palette (CachyOS default)
    term_palette: 1e1e2e;f38ba8;a6e3a1;f9e2af;89b4fa;f5c2e7;94e2d5;cdd6f4
    term_palette_bright: 585b70;f38ba8;a6e3a1;f9e2af;89b4fa;f5c2e7;94e2d5;cdd6f4
    term_background: ffffffff
    term_foreground: cdd6f4
    term_background_bright: ffffffff
    term_foreground_bright: cdd6f4
  '';
  }
