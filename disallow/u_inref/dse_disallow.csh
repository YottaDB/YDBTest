#!/usr/local/bin/tcsh -f
#
# D9D09002364 [Narayanan] 
#
$gtm_tst/com/dbcreate.csh mumps			# need a temporary database for DSE startup
cp $gtm_tst/$tst/inref/dse_cmd_disallow.txt .	# copy the dse_disallow.txt file from inref
#
$GTM <<EOF
	do ^d002364("dse_cmd_disallow.txt","$DSE")
EOF
#
$gtm_tst/com/dbcheck.csh	# no updates should have gone in by the disallow commands. db should therefore be clean.
