{ pkgs ? import <nixpkgs> { }
}:

let
  yarnPkg = pkgs.mkYarnPackage {
    name = "connect-cardano-wallet-elm-node-packages";
    src = ./.;
    doDist = false;
    publishBinsFor = [ "webpack" "webpack-cli" ];
  };
in
pkgs.stdenv.mkDerivation {
  name = "connect-cardano-wallet-elm";
  src = pkgs.lib.cleanSource ./.;

  buildInputs = with pkgs.elmPackages; [
    elm
    elm-format
    yarnPkg
    pkgs.yarn
    pkgs.nodePackages.webpack
    pkgs.nodePackages.webpack-cli
  ];

  patchPhase = ''
    rm -rf elm-stuff
    ln -s ${yarnPkg}/libexec/${yarnPkg.name}/node_modules ./node_modules
    export PATH="${yarnPkg}/bin:$PATH"
  '';

  configurePhase = pkgs.elmPackages.fetchElmDeps {
    elmVersion = "0.19.1";
    elmPackages = import ./elm-src.nix;
    registryDat = ./registry.dat;
  };

  installPhase = ''
    mkdir -p $out
    yarn --offline build-connect-cardano-wallet-elm
  '';
}
