{
  description = "llama-cpp-ocaml";

  inputs = {
    flake-utils.url = "github:numtide/flake-utils";
    nixpkgs = {
      url = "github:nix-ocaml/nix-overlays";
      inputs.flake-utils.follows = "flake-utils";
    };
  };
  outputs =
    { self
    , nixpkgs
    , flake-utils
    }:
    (flake-utils.lib.eachDefaultSystem (system:
    let
      pkgs = nixpkgs.legacyPackages."${system}".appendOverlays [
        (self: super: {
          ocamlPackages = super.ocaml-ng.ocamlPackages_5_1.overrideScope'
            (oself: osuper:
              with oself;
              { }
            );
        })
      ];
      inherit (pkgs) ocamlPackages;
    in
    with pkgs;
    with ocamlPackages;
    {
      devShells.default = (
        pkgs.mkShell
        #.override {
        #  stdenv = pkgs.clang15Stdenv;
        #}
      )
        {
          env.NIX_CFLAGS_COMPILE = lib.optionalString stdenv.isDarwin "-I${lib.getDev libcxx}/include/c++/v1";
          buildInputs = [
            ctypes
            ctypes-foreign
            utop
            cppo
          ];
          nativeBuildInputs = [
            libcxx
            dune-configurator
            findlib
            ocaml
            containers-data
            ocaml-lsp
            dune_3
            ocamlformat
            iter
            cmake
          ]
          ++ pkgs.lib.optionals (pkgs.stdenv.isDarwin && !pkgs.stdenv.isAarch64) [ pkgs.darwin.cctools ]
          ++ (with pkgs; lib.optionals stdenv.isDarwin
            (with darwin.apple_sdk.frameworks; [
              ApplicationServices
              SystemConfiguration
              Accelerate
              CoreGraphics
              CoreVideo
              Foundation
              Metal
              MetalKit
            ]));
          OCAMLRUNPARAM = "b";
        };
    }));
}
