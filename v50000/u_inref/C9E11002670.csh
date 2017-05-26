#!/usr/local/bin/tcsh -f
echo "zlink with long path and not specifying full path in zlink"
set dir="longpath__________________28"
mkdir $dir
pushd $dir
\cp $gtm_tst/$tst/inref/looooooooooooooooooongname789012.m .
$GTM << aaa
do ^zlnklpth
h
aaa
popd
#
echo "zlink with long path and specifying full path in zlink"
set dir="longpath____________________30"
mkdir $dir
pushd $dir
\cp $gtm_tst/$tst/inref/looooooooooooooooooongname789012.m .
$GTM << aaa
do ^zlnkfpth
h
aaa
popd
