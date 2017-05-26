#! /usr/local/bin/tcsh -f

$gtm_tst/com/dbcreate.csh mumps . 125 500 . 30000
if ($gtm_test_tp == "TP" ) then
	setenv parms "tp"
else
	setenv parms "nontp"
endif

$GTM << GTM_EOF
d ^mdivis("$parms")
GTM_EOF

$gtm_tst/com/dbcheck.csh -extract
cat mdivis*.mje*
