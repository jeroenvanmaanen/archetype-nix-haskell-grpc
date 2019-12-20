FROM lnl7/nix

RUN nix-channel --add https://nixos.org/channels/nixos-unstable
RUN nix-channel --update

ENV NIX_PATH='/nix/var/nix/profiles/per-user/root/channels/nixos'
RUN rm -f '/root/.nix-defexpr/nixos'

RUN nix-env -i bash-interactive
RUN nix-env -i ghc-8.6.5
RUN nix-env -i cabal-install

RUN mkdir -p /root/.config/nixpkgs ; echo '{ allowBroken = true; }' > /root/.config/nixpkgs/config.nix
