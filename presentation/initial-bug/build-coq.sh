#!/usr/bin/env bash

if [ -z "$J" ]; then
    J=5
fi

git submodule update --init --recursive
cd HoTT-coq
git reset --hard
patch -p1 < ../HoTT-coq-configure.patch
./configure -local -camlp5dir "$(ocamlfind query camlp5)" -with-doc no -coqide no
make -j$J
cd ..
