{
  description = "Abel's Darwin system flake";

  # The `follows` keyword in inputs is used for inheritance.
  # Here, `inputs.nixpkgs` is kept consistent with
  # the `inputs.nixpkgs` of the current flake,
  # to avoid problems caused by different versions of nixpkgs.
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nix-darwin = {
      url = "github:LnL7/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # home-manager, used for managing user configuration.
    home-manager = {
      url = "github:nix-community/home-manager/release-23.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Nix homebrew.
    nix-homebrew.url = "github:zhaofengli-wip/nix-homebrew";
    homebrew-bundle = {
      url = "github:homebrew/homebrew-bundle";
      flake = false;
    };
    homebrew-cask = {
      url = "github:homebrew/homebrew-cask";
      flake = false;
    };
    homebrew-core = {
      url = "github:homebrew/homebrew-core";
      flake = false;
    };

    mac-app-util.url = "github:hraban/mac-app-util"; # Utilities for Mac App launchers
  };

  outputs = inputs@{ self, nix-darwin, nixpkgs, home-manager, nix-homebrew, homebrew-bundle, homebrew-cask, homebrew-core, mac-app-util }:
  let
    configuration = { pkgs, ... }: {
      # List packages installed in system profile. To search by name, run:
      # $ nix-env -qaP | grep wget
      environment.systemPackages = [ pkgs.vim ];

      # Auto upgrade nix package and the daemon service.
      services.nix-daemon.enable = true;

      # Necessary for using flakes on this system.
      nix.settings.experimental-features = "nix-command flakes";

      # Create /etc/zshrc that loads the nix-darwin environment.
      programs.zsh.enable = true;  # default shell on catalina

      # Set Git commit hash for darwin-version.
      system.configurationRevision = self.rev or self.dirtyRev or null;

      # Used for backwards compatibility, please read the changelog before changing.
      # $ darwin-rebuild changelog
      system.stateVersion = 4;

      # The platform the configuration will be used on.
      nixpkgs.hostPlatform = "aarch64-darwin";

      # Allow un-free packages e.g. vscode.
      nixpkgs.config.allowUnfree = true;
    };
  in {
    # Build darwin flake using:
    # $ darwin-rebuild build --flake .#Abels-MacBook-Pro
    darwinConfigurations."Abels-MacBook-Pro" = nix-darwin.lib.darwinSystem {
      modules = [
        configuration
        mac-app-util.darwinModules.default
        nix-homebrew.darwinModules.nix-homebrew {
          nix-homebrew = {
            user = "uael";
            enable = true;
            mutableTaps = false;
            autoMigrate = true;
            taps = {
              "homebrew/homebrew-core" = homebrew-core;
              "homebrew/homebrew-cask" = homebrew-cask;
              "homebrew/homebrew-bundle" = homebrew-bundle;
            };
          };
        }
        home-manager.darwinModules.home-manager ({ pkgs, config, lib, ... }: {
          # Required to fix `Error: HOME is set to "/Users/XXX" but we expect "/var/empty"`.
          users.users.uael.home = "/Users/uael";

          # Homebrew config.
          homebrew = {
            enable = true;
            onActivation.upgrade = true;
            # Fallback for packages that aren't supported through nix (for darwin at least).
            # Otherwise `home.packages` might be preferred.
            casks = [
              "google-chrome"
              "jetbrains-toolbox"
              "raycast"
              "vlc"
            ];
          };

          # `home-manager` config.
          home-manager = {
            useGlobalPkgs = true;
            useUserPackages = true;

            users.uael = {
              imports = [ mac-app-util.homeManagerModules.default ];

              # Let Home Manager install and manage itself.
              programs.home-manager.enable = true;

              # Home Manager needs a bit of information about you and the
              # paths it should manage.
              home.username = "uael";
              home.homeDirectory = "/Users/uael";

              # Enable `fontconfig`.
              fonts.fontconfig.enable = true;

              # User packages.
              home.packages = with pkgs; [
                bat
                broot
                discord
                fish
                git
                lsd
                qbittorrent
                vscode
                wezterm

                # Virtual machines.
                (utm.overrideAttrs (oldAttrs: { version = "4.5"; }))

                # Fonts.
                (nerdfonts.override { fonts = [ "JetBrainsMono" ]; })
              ];

              # This value determines the Home Manager release that your
              # configuration is compatible with. This helps avoid breakage
              # when a new Home Manager release introduces backwards
              # incompatible changes.
              #
              # You can update Home Manager without changing this value. See
              # the Home Manager release notes for a list of state version
              # changes in each release.
              #
              # TODO: Remove `enableNixpkgsReleaseCheck` when switching to 24.05.
              home.stateVersion = "23.11";
              home.enableNixpkgsReleaseCheck = false;
            };
          };
        })
      ];
    };

    # Expose the package set, including overlays, for convenience.
    darwinPackages = self.darwinConfigurations."Abels-MacBook-Pro".pkgs;
  };
}
