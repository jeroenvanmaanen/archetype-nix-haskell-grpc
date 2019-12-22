# Archetype of a Haskell project that makes gRPC connections built with Nix

This project is still **Work In Progress**. I think I've got all necessary
dependencies lined up, but I still have to connect the dots... 

## Introduction

My aim is to create a project that
can be used as a template for future projects with the following
characteristics:
* Command / Query Responsibility Segregation (CQRS)
* Event Sourcing
* Strong typing
* Pure functional programming
* High Performance
* High Availability
* Scalability

On top of that, I would love to be able to start a project as a monolithic
application and have it evolve into a collection of micro-services that is
integrated into a service mesh architecture.

The components that I want to combine are:
* Docker (to minimise the impact on/from the host system)
* Nix (to manage dependencies)
* Axon Server (for event storage, message routing, and scalability)
* Haskell (for pure functional programming, strong typing and performance)
* Envoy (for service mesh architecture and high availability)

I fell in love with fused-effects for monad composition, so I plan to use
that too. `;-)`

Axon and Envoy use gRPC to integrate with other components, so I would like to
develop Haskell programs that integrate smoothly with gRPC APIs. I tried to
get [Haskell gRPC support](https://github.com/awakesecurity/gRPC-haskell)
from Awake Security to work, but failed miserably. This is an attempt to use
[haskell-grpc-native](https://github.com/haskell-grpc-native).

## Setup

I mostly followed [Getting Started Haskell Project with Nix](https://maybevoid.com/posts/2019-01-27-getting-started-haskell-nix.html)
by _Soares Chen_. Any flaws are of course my own.

To work with this project, you need to install docker. The first step after
that is to acquire a docker image that has Nix and GHC. It will be pulled from
docker hub automatically the first time you run `docker run` or
`docker-compose up`. You can also build it yourself with:
```
[host]$ docker build --tag jeroenvm/nix . # Optional. It is also available on Docker Hub
```

After that, start two docker containers, one with Nix and GHC, the other with
Axon Server: 
```
[host-ttya]$ src/test/docker/docker-compose-up.sh --dev
```

Then, in another terminal window, open a bash prompt inside the container that
has Nix and GHC:
```
[host-ttyb]$ docker exec -ti foo_foo_1 bash
[foo]$ nix-env -iA -f '<.>' curl
[foo]$ curl http://axon-server:8024/
```

This is a list of commands that I figured out and might come in handy: 
```
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
```
