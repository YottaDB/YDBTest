#!/usr/local/bin/tcsh
#
# D9E10002504 [Malli] TSTART in Direct mode fails if it specifies preserved locals
#
$gtm_tst/com/dbcreate.csh mumps 1 255 480 512 100 16384
echo "Testing TSTART with preserved locals in direct mode..."
$GTM << GTM_EOF
	s x=1,y=2,z=3
	w "Locals before TSTART (x,y): ",! zwr
	tstart (x,y):serial
	s x=10,y=20,z=30
	w "Locals before restart: ",! zwr
	trestart
	w "Locals after restart: ",! zwr
GTM_EOF

$gtm_tst/com/dbcheck.csh
