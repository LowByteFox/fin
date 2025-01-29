#!/bin/sh

BIN="$HOME/.local/bin/"
MOD="$HOME/.local/lib/perl5/fin/"
mkdir -vp $BIN 
mkdir -vp $MOD
mv fin fin.orig
echo "#!/usr/bin/perl -I$HOME/.local/lib/perl5/fin/" > fin
tail -n +3 fin.orig >> fin
cp -v fin $BIN
cp -v *.pm $MOD

mv fin.orig fin
