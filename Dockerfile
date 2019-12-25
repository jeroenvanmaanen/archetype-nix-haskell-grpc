FROM lnl7/nix

RUN nix-channel --add https://nixos.org/channels/nixos-unstable
RUN nix-channel --update

ENV NIX_PATH='/nix/var/nix/profiles/per-user/root/channels/nixos'
RUN rm -f '/root/.nix-defexpr/nixos'

RUN nix-env -i bash-interactive
RUN nix-env -i ghc-8.6.5
RUN nix-env -f '<.>' -iA cabal-install
RUN nix-env -f '<.>' -iA curl
RUN nix-env -f '<.>' -iA protobuf
RUN nix-env -f '<.>' -iA haskellPackages.proto-lens-protoc

RUN mkdir -p /root/.config/nixpkgs ; echo '{ allowBroken = true; }' > /root/.config/nixpkgs/config.nix

RUN mkdir /src
RUN cd /src ; git clone https://github.com/AxonIQ/axon-server-api.git