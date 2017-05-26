#!/usr/local/bin/tcsh -f
#
setenv test_reorg NON_REORG
setenv gtm_test_mupip_set_version "V5"
$gtm_tst/com/dbcreate.csh mumps 3
$GDE << EOF
	add -name a -region=areg 
	add -name b -region=breg
EOF

$gtm_dist/mumps -run truncatehasht

# Truncate each database file
$MUPIP reorg -truncate |& $grep -E "Truncated|TRUNC|#t"

$gtm_tst/com/dbcheck.csh
