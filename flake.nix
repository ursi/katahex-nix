{ inputs =
    { katago = { url = "github:hzyhhzy/KataGo/Hex2022"; flake = false; };
      make-shell.url = "github:ursi/nix-make-shell/1";
      nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
      utils.url = "github:ursi/flake-utils/8";
    };

  outputs = { utils, ... }@inputs:
    with builtins;
    utils.apply-systems { inherit inputs; }
      ({ make-shell, pkgs, ... }:
         let
           l = p.lib; p = pkgs;
           katago = board-size:
             let
               bs = toString board-size;
               tcd = "target_compile_definitions(katago PRIVATE COMPILE_MAX_BOARD_LEN=${bs})";
             in
             (p.katago.overrideAttrs
                (attrs:
                   { src = inputs.katago; version = "hex2022-${bs}x${bs}";

                     preConfigure =
                       ''
                       ${attrs.preConfigure}
                       echo '${tcd}' >> CMakeLists.txt
                       '';
                   }
             )).override { enableGPU = false; };

           lizzieyzy =
             let
               src =
                 p.fetchurl
                   { url = "https://drive.google.com/u/0/uc?id=1qbTTmPFiUkM_346DeKS1E9gJR-roNH63&export=download&confirm=t&uuid=101373af-a46f-4794-a1c7-151c1f5fe59a&at=ALgDtszvi-tg4S5aGQ9t7AnXcflU:1676397446078";
                     hash = "sha256-IfvKChZVaxdPrmm2NTAzS19+VW2IQ8gK5+UG0rKFESk=";
                   };
             in
             p.runCommand "lizzieyzy" {}
               ''
               ${p.unzip}/bin/unzip ${src}
               mv KataHex_LizzieYZY $out
               cd $out
               patch config.txt ${./config.patch}
               find -name '*.bat' -exec rm "{}" ";"
               find -name '*.dll' -exec rm "{}" ";"
               find -name '*.exe' -exec rm "{}" ";"
               '';

           model =
             p.fetchurl
               { url = "https://drive.google.com/u/0/uc?id=1xMvP_75xgo0271nQbmlAJ40rvpKiFTgP&export=download&confirm=t&uuid=0fd3460e-dc4e-4e7d-81a5-ab11c1cf1772&at=ALgDtswWGdmlMCoyYDj55UXZkQQ5:1676420358456";
                 hash = "sha256-DWvLu0Upd49uGLI0t7ftxWjjzfiwjqfrDzXmXofvFwU=";
               };


           shell = board-size:
             make-shell
               { packages =
                   let
                     convert-sgf =
                       p.writeShellScriptBin "convert-sgf"
                         ''
                         shopt -s nullglob
                         cd sgf
                         for file in *; do
                           if [[ "$file" != *.yzy.sgf ]]; then
                             name="$(basename "$file" .sgf)"
                             ${p.nodejs}/bin/node ${./convert-sgf.js} "$file" > "$name.yzy.sgf"
                             echo "converted: $file"
                             rm "$file"
                           fi
                         done
                         '';
                   in
                   with p;
                   [ convert-sgf
                     jdk
                     (writeShellScriptBin "lizzieyzy" "java -jar KataHex.jar")
                     nodejs
                   ];

                 env.XDG_DATA_DIRS = "${p.gtk3}/share/gsettings-schemas/${p.gtk3.name}:$XDG_DATA_DIRS";

                 setup =
                   ''
                   cp -nr ${lizzieyzy}/. .
                   chmod -R u+w .
                   ln -fs ${model} weights/katahex_model_20220618.bin.gz
                   ln -fs ${katago board-size}/bin/katago engine/katahex${toString board-size}
                   chmod -R u+w .

                   mkdir -p sgf
                   '';
               };
         in
         { devShells =
             { default = shell 13;
               "14" = shell 14;
               "15" = shell 15;
               "19" = shell 19;
             };
         }
      );
}
