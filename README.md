# uael's `~/.config` directory

## Overview

I just wanted to have fun using [Nix Flakes](https://nixos.wiki/wiki/Flakes) on my new MacBook.
This might someday include my [old Linux dot files](https://github.com/uael/dotfiles) as well.

In my MacBook I jump around using [Raycast](https://www.raycast.com/) and hack on the
[Wez's Terminal](https://github.com/wez/wezterm) with the
[fish shell](https://github.com/fish-shell/fish-shell), managed by
[fisher](https://github.com/jorgebucaran/fisher) with a
[tide](https://github.com/IlanCosman/tide) prompt.

> [!NOTE]
> This configurations aren't using Nix to configure packages on purpose as I want to be able to
> clone this `~/.config` anywhere without requiring nix.

## Getting started

Assuming your configuration directory to be `~/.config`, pull this into it (as it might already
exists and bot be empty)
```bash
cd ~/.config
git init
git remote add origin https://github.com/uael/.config
git pull origin master
```

Optionally, manage everything else using [Nix](https://nixos.org) through [nix-darwin](https://github.com/LnL7/nix-darwin)
```bash
nix run nix-darwin -- switch --flake ~/.config
```

> [!WARNING]
> Make sure to restart the current shell session to activate.

> [!TIP]
> To install [Nix](https://nixos.org/download) run `sh <(curl -L https://nixos.org/nix/install)`.
