if status is-interactive
  # Remove Intro message
  set fish_greeting

  if not functions -q fisher
    curl -sL https://git.io/fisher | source && fisher update
  end

  set -x PATH $PATH ~/.local/bin
  set -x PATH $PATH ~/.cargo/bin
  set -x PATH $PATH ~/.nix-profile/bin

  alias ls=lsd
  alias cat=bat
end
