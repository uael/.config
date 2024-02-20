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

    # home-manager, used for managing user configuration
    home-manager = {
      url = "github:nix-community/home-manager/release-23.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Utilities for Mac App launchers.
    mac-app-util.url = "github:hraban/mac-app-util";
  };

  outputs = inputs@{ self, nix-darwin, nixpkgs, home-manager, mac-app-util }:
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
    };
  in {
    # Build darwin flake using:
    # $ darwin-rebuild build --flake .#Abels-MacBook-Pro
    darwinConfigurations."Abels-MacBook-Pro" = nix-darwin.lib.darwinSystem {
      modules = [
        configuration
        mac-app-util.darwinModules.default
        home-manager.darwinModules.home-manager ({ pkgs, config, lib, ... }: {
          # Allow un-free packages e.g. vscode.
          nixpkgs.config.allowUnfree = true;

          # Required to fix `Error: HOME is set to "/Users/XXX" but we expect "/var/empty"`.
          users.users.uael.home = "/Users/uael";

          # `home-manager` config
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
                alacritty
                bat
                fish
                git
                lsd
                vscode

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
