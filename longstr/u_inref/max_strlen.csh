#! /usr/local/bin/tcsh -f
echo "max_strlen subtest"
echo "string larger than 1 MB will give error"
echo "Test if zhow v:a and zwr work after the error"
$GTM << \aa
s a=0
w $$^longstr(1048577),!
zshow "v":a
zwr
h
\aa
#
echo "Test for various string related functions with long string"
$GTM << EOF
d ^fnlgstr
EOF
$GTM << aa >& zshow.txt
d ^crelgstr
zshow "B"
zshow "C"
zshow "D"
zshow "V"
zshow "*"
aa
$GTM << \aa
d ^shrnkfil("zshow.txt")
\aa
echo "End of the subtest"
