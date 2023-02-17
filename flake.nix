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
           katago =
             (p.katago.overrideAttrs
                (_: { src = inputs.katago; version = "hex2022"; }
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
               dir=KataHex_LizzieYZY
               patch $dir/config.txt ${./config.patch}
               mv $dir $out
               '';

           model =
             p.fetchurl
               { url = "https://drive.google.com/u/0/uc?id=1xMvP_75xgo0271nQbmlAJ40rvpKiFTgP&export=download&confirm=t&uuid=0fd3460e-dc4e-4e7d-81a5-ab11c1cf1772&at=ALgDtswWGdmlMCoyYDj55UXZkQQ5:1676420358456";
                 hash = "sha256-DWvLu0Upd49uGLI0t7ftxWjjzfiwjqfrDzXmXofvFwU=";
               };

         in
         { devShells.default =
             make-shell
               { packages =
                   with p;
                   [ jdk
                     (writeShellScriptBin "lizzieyzy" "java -jar KataHex.jar")
                   ];

                 setup =
                   ''
                   cp -nr ${lizzieyzy}/. .
                   chmod -R u+w .
                   cp -n ${model} weights/katahex_model_20220618.bin.gz
                   cp ${katago}/bin/katago engine/katago
                   chmod -R u+w .
                   '';
               };
         }
      );
}
