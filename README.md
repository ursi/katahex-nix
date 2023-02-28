## Usage

```
$ nix develop
```

This will fill the directory with all the files you need to run the GUI and the AI for size 13x13 (and smaller), as well as give you an executable for the GUI.

To launch the GUI, run

```
$ lizzieyzy
```

If it's frozen on a gray screen, just wait. It should load eventually.

## Importing SGF Files

LizzieYZY doesn't use normal SGF files, or at least the hex version doesn't, so they need to be converted first. After running `nix develop`, you will see a directory called `sgf`. Place any SGF files you want to be converted into this directory, then run `convert-sgf`. They will be converted and changed to `.yzy.sfg` files. You can leave the converted files in `sgf`, as the conversion script will not act on `.yzy.sgf` files.

## Other Board Sizes

You can get versions of the engine that support size 14, 15, and 19 by running

```
nix develop .#N
```

where `N` is the size you want. Engines of size `N` support all sizes less than `N`. However, [this comment](https://github.com/hzyhhzy/KataGo/blob/ab3df7864a104601eb20470cbed79619599c8cfc/cpp/CMakeLists.txt#L36) leads me to believe that the engine is slower the bigger the board size, so I allow supporting only the size you need for maximum performance.

## Modification

You can modify the `katago` derivation to use a different backend. If you have a strong graphics card, this will probably give you more performance. See these files for information:
- [KataGo Backends](https://github.com/lightvector/KataGo#opencl-vs-cuda-vs-tensorrt-vs-eigen)
- [katago nix expression](https://github.com/NixOS/nixpkgs/blob/8c619a1f3cedd16ea172146e30645e703d21bfc1/pkgs/games/katago/default.nix)
