## Usage

```
$ nix develop .#<board-size>

```
where `<board-size>` is one of 13, 14, 15, 17, 19, or 37. Engines of size `N` support all sizes less than `N`.

This will fill the directory with all the files you need to run the GUI and the AI for size `<board-size>`, as well as give you an executable for the GUI.

To launch the GUI, run

```
$ lizzieyzy
```

If it's frozen on a gray screen, just wait. It should load eventually.

## Importing SGF Files

LizzieYZY doesn't use normal SGF files, or at least the hex version doesn't, so they need to be converted first. After running `nix develop`, you will see a directory called `sgf`. Place any SGF files you want to be converted into this directory, then run `convert-sgf`. They will be converted and changed to `.yzy.sfg` files. You can leave the converted files in `sgf`, as the conversion script will not act on `.yzy.sgf` files.

## Why not use only 37x37?

- [The article](https://zhuanlan.zhihu.com/p/476464087) talking about this AI mentions the 13x13 engine was trained much more extensively than the other sizes.

- [This comment](https://github.com/hzyhhzy/KataGo/blob/ab3df7864a104601eb20470cbed79619599c8cfc/cpp/CMakeLists.txt#L36) leads me to believe that the engine is slower the bigger the board size, if that's true, you'll get maximum performance by using the smallest size that works for you.

## Modification

You can modify the `katago` derivation in `flake.nix` to use a different backend. If you have a strong graphics card, this will probably give you more performance. See the following information:
- [KataGo Backends](https://github.com/lightvector/KataGo#opencl-vs-cuda-vs-tensorrt-vs-eigen)
- [katago nix expression](https://github.com/NixOS/nixpkgs/blob/4fddc9be4eaf195d631333908f2a454b03628ee5/pkgs/games/katago/default.nix)
- How to set up opencl for intel: `hardware.opengl.extraPackages = [ pkgs.intel-ocl ];`
