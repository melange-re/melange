#! /bin/sh

set -e
set -u

cd $cur__lib/bucklescript
tar xvf libocaml.tar.gz
mv others/* .
mv runtime/* .
mv stdlib-412/stdlib_modules/* .
mv stdlib-412/* .

## wrap bsc to add BSLIB
mv $cur__bin/bsc.exe $cur__bin/bsc_.exe
cat > $cur__bin/bsc.exe <<EOF
#! $(which sh)

eval $cur__bin/bsc_.exe -I \$BSLIB '"\$@"'
EOF
chmod +x $cur__bin/bsc.exe

ln -s $cur__bin/bsc.exe $cur__bin/bsc
ln -s $cur__bin/bsb.exe $cur__bin/bsb
