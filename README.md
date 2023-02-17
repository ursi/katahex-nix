## Usage
```
$ nix develop
```
This will fill the directory with all the files you need to run the GUI and the AI, as well as give you an executable for the GUI.

To launch the GUI, run
```
$ lizzieyzy
```

If it's frozen on a gray screen, just wait. It should load eventually.

## Modification

You can modify the `katago` derivation to use a different backend. If you have a strong graphics card, this will probably give you more performance. See these files for information:
- [KataGo Backends](https://github.com/lightvector/KataGo#opencl-vs-cuda-vs-tensorrt-vs-eigen)
- [katago nix expression](https://github.com/NixOS/nixpkgs/blob/8c619a1f3cedd16ea172146e30645e703d21bfc1/pkgs/games/katago/default.nix)
