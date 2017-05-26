#!/usr/local/bin/tcsh -f
#
# DH01002638 - Return reasonable error message if file to be compiled is there, but open fails (permissions, perhaps)
#

cat >> badopen.m <<EOF
badopen	;
	w "hello",!
	q
EOF
chmod 004 badopen.m
$GTM <<EOF
 d ^badopen
EOF
chmod 664 badopen.m
$gtm_exe/mumps -run badopen

echo "End of DH01002638 test..."
