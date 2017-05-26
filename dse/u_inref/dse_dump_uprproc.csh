#!/usr/local/bin/tcsh -f
$DSE << DSE_EOF >& updproc.out
d -f -updproc
quit
DSE_EOF
grep "Upd reserved area"  updproc.out
grep "Pre read trigger factor"  updproc.out
