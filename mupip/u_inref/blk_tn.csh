#! /usr/local/bin/tcsh -f
# "D9A06-001606  TPFAIL LLLL in ING USA"
if ($?test_replic == 1) exit 0
\rm -f *.dat
setenv gtmgbldir mumps.gld
$gtm_tst/com/dbcreate.csh mumps 1
$GTM << EOF
f i=1:1:1000 s ^a(i)=i
h
EOF
$DSE << EOF
f -bl=3
d -header
d -f
EOF
echo "Test is valid, if a(1000) is in block 3"
echo "Test is valid, if block 3 has transaction number 3e8"
echo "Test is valid, if file header has curr_tn = 3e9"
$DSE << EOF
ch -file -curr=3e8
d -f
quit
EOF
$MUPIP integ mumps.dat
if $status then
	$gtm_tst/com/dbcheck.csh
	echo "Test PASSED"
	exit 0
endif
# If you are here test already failed
$GTM << EOF
d ^blktn
h
EOF
$gtm_tst/com/dbcheck.csh
