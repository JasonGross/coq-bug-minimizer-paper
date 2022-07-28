#!/usr/bin/env bash

if [ -z "$J" ]; then
    J=5
fi

git submodule update --init --recursive
cd HoTT-coq
git reset --hard
patch -p1 < ../HoTT-coq-configure.patch

# camlp4              4.01
# camlp5              6.17
# The Objective Caml compiler, version 3.12.1
./configure -local -camlp5dir "$(ocamlfind query camlp5)" -with-doc no -coqide no
make -j$J TIMED=1
cd ..
