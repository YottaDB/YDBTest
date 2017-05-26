#!/usr/local/bin/tcsh
#
# C9C95-002003 Set $PIECE/$EXTRACT give error if part of a compound SET statement
#
$gtm_tst/com/dbcreate.csh mumps 1
$GTM << GTM_EOF
	do ^c002003
GTM_EOF
$gtm_tst/com/dbcheck.csh
