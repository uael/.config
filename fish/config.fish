if status is-interactive
  # Remove Intro message
  set fish_greeting

  if not functions -q fisher
    curl -sL https://git.io/fisher | source && fisher update
  end

  set -x PATH $PATH ~/.local/bin
  set -x PATH $PATH ~/.cargo/bin
  set -x PATH $PATH /etc/profiles/per-user/$USER/bin

  alias ls=lsd
  alias cat=bat
end
