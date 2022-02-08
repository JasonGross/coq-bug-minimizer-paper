{ pkgs ? import (fetchTarball {
    url = "https://github.com/NixOS/nixpkgs/archive/08ef0f28e3a41424b92ba1d203de64257a9fca6a.tar.gz";
    sha256 = "1mql1gp86bk6pfsrp0lcww6hw5civi6f8542d4nh356506jdxmcy";
  }) {}
, pythonPackages ? pkgs.python3Packages
}:

pkgs.mkShell {
  buildInputs = with pythonPackages; [
    jupyterlab requests numpy pandas matplotlib
  ];
  shellHook = "jupyter-lab";
}
