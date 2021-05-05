{ pkgs ? import (fetchTarball https://github.com/nixos/nixpkgs/archive/625ce6c7f66c0b2ccae30f95cdd9e48feed8561c.tar.gz) { }
, name ? "ghcr.io/thmzlt/liker"
, tag ? "latest"
}:
let
  rubyEnv = pkgs.bundlerEnv {
    name = "ruby-env";
    version = "0.0.0";
    gemdir = ./.;
  };

  package =
    pkgs.stdenv.mkDerivation {
      name = "liker";
      src = ./.;
      buildInputs = [ rubyEnv.wrappedRuby ];

      installPhase = ''
        mkdir -p $out
        cp -r ${rubyEnv}/* $out/
        cp $src/app.rb $out/
      '';
    };
in
pkgs.dockerTools.buildLayeredImage {
  name = name;
  tag = tag;

  config = {
    Entrypoint = [ "${package}/bin/bundle" "exec" ];
    Cmd = [ "${rubyEnv.wrappedRuby}/bin/ruby" "${package}/app.rb" "-o" "0.0.0.0" "-p" "8080" ];
    Ports = [ "8080:8080" ];
  };
}
