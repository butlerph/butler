{ pkgs ? import <nixpkgs> {} }:
  
with pkgs;

let
  inherit (lib) optional optionals;

  erlang = beam.interpreters.erlangR23;
  elixir = beam.packages.erlangR23.elixir_1_11;
  nodejs = nodejs-12_x;
in

mkShell {
  buildInputs = [cacert git erlang elixir cargo nodejs]
    ++ optional stdenv.isLinux inotify-tools
    ++ optionals stdenv.isDarwin (with darwin.apple_sdk.frameworks; [
      CoreFoundation
      CoreServices
    ]);

    shellHook = ''
      export LANG=C.UTF-8
    '';
}