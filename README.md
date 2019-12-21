# Archetype of a Haskell project that makes gRPC connections built with Nix

I mostly followed [Getting Started Haskell Project with Nix](https://maybevoid.com/posts/2019-01-27-getting-started-haskell-nix.html) by _Soares Chen_. Any flaws are of course my own.

```
[host]$ docker build --tag jeroenvm/nix . # Optional. It is also available on Docker Hub
[host]$ docker run --rm -ti -v "${HOME}:${HOME}" -w "$(pwd)" jeroenvm/nix
[container]$ nix-shell -p "haskellPackages.ghcWithPackages (pkgs: [pkgs.http2-grpc-proto-lens])"
[nix-shell]# ghci
Prelude> import Network.GRPC.HTTP2.ProtoLens

[container]$ nix-shell --pure shell.nix
[nix-shell]# ghci
Prelude> import Network.HTTP2.Client

[container]$ nix-shell --pure -p cabal2nix --run "cabal2nix ." > default.nix
[container]$ nix-build release.nix
[container]$ result/bin/archetype-nix-haskell

[container]$ nix-env -f '<.>' -iA haskellPackages."http2-grpc-proto-lens"
[container]$ nix-env -f '<.>' -iA haskellPackages.hoogle
[container]$ hoogle generate --insecure

[container]$ nix-shell --pure shell.nix --run "cabal repl"

[host-ttya]$ src/test/docker/docker-compose-up.sh --dev
[host-ttyb]$ docker exec -ti foo_foo_1 bash
[foo]$ nix-env -iA -f '<.>' curl
[foo]$ curl http://axon-server:8024/
```
