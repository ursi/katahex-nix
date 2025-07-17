{
  inputs = {
    katago = { url = "github:hzyhhzy/KataGo/Hex2024"; flake = false; };
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    utils.url = "github:ursi/flake-utils/8";
  };

  outputs = inputs:
    with builtins;
    inputs.utils.apply-systems { inherit inputs; }
      ({ pkgs, ... }:
        let
          l = p.lib;
          p = pkgs;
          katago = board-size:
            let
              bs = toString board-size;
              tcd = "target_compile_definitions(katago PRIVATE COMPILE_MAX_BOARD_LEN=${bs})";
            in
            (p.katago.overrideAttrs
              (attrs: {
                src = inputs.katago;
                version = "hex2024-${bs}x${bs}";

                preConfigure = ''
                  ${attrs.preConfigure}
                  echo '${tcd}' >> CMakeLists.txt
                '';
              })).override { backend = "eigen"; };

          lizzieyzy =
            let
              src =
                p.fetchurl {
                  url = "https://drive.usercontent.google.com/download?id=1qbTTmPFiUkM_346DeKS1E9gJR-roNH63&export=download&authuser=0&confirm=t&uuid=3be66e82-9230-4eb8-a4ef-c8d9a3370afb&at=APZUnTWNUMn9hiz18pXkC3UKW10p%3A1708186356878";
                  hash = "sha256-IfvKChZVaxdPrmm2NTAzS19+VW2IQ8gK5+UG0rKFESk=";
                };
            in
            p.runCommand "lizzieyzy" { } ''
              ${p.unzip}/bin/unzip ${src}
              mv KataHex_LizzieYZY $out
              cd $out
              patch config.txt ${./config.patch}
              find -name '*.bat' -exec rm "{}" ";"
              find -name '*.dll' -exec rm "{}" ";"
              find -name '*.exe' -exec rm "{}" ";"
            '';

          model = p.fetchurl {
            url = "https://github.com/hzyhhzy/KataGomo/releases/download/Hex_20250131/hex3_27x_b28.bin.gz";
            hash = "sha256-2FkrQ3E9CN1o+P2scPBFDpCJrGY+3SIa8lkbwdw8j4Y=";
          };

          shell = board-size:
            p.mkShell {
              packages =
                let
                  convert-sgf =
                    p.writeShellScriptBin "convert-sgf" ''
                      shopt -s nullglob
                      cd sgf
                      for file in *; do
                        if [[ "$file" != *.yzy.sgf ]]; then
                          name="$(basename "$file" .sgf)"
                          ${l.getExe p.nodejs} ${./convert-sgf.js} "$file" > "$name.yzy.sgf"
                          echo "converted: $file"
                          rm "$file"
                        fi
                      done
                    '';
                in
                with p; [
                  convert-sgf
                  jdk
                  (writeShellScriptBin "lizzieyzy" "java -jar KataHex.jar")
                  nodejs
                ];

              XDG_DATA_DIRS = "${p.gtk3}/share/gsettings-schemas/${p.gtk3.name}:$XDG_DATA_DIRS";

              shellHook = ''
                cp -nr ${lizzieyzy}/. .
                chmod -R u+w .
                ln -fs ${model} weights/model.bin.gz
                ln -fs ${katago board-size}/bin/katago engine/katahex${toString board-size}
                chmod -R u+w .

                mkdir -p sgf
              '';
            };
        in
        {
          devShells = {
            "13" = shell 13;
            "14" = shell 14;
            "15" = shell 15;
            "19" = shell 19;
          };

          formatter = p.nixpkgs-fmt;
        });
}
