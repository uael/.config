# uael's `~/.config`

Install [nix](https://nixos.org/download#nix-install-macos) first:
```bash
sh <(curl -L https://nixos.org/nix/install)
```

```bash
# Move to `~/.config` directory.
cd ~/.config

# Add remote `.config` files.
git init
git remote add origin https://github.com/uael/.config
git pull origin master

# Nix-darwin switch (restart current shell session to activate).
nix run nix-darwin -- switch --flake ~/.config
```
