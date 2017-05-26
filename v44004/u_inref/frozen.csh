#!/usr/local/bin/tcsh
# This is to test a fix that went in with C9D12-002472.
#test that even if one region is frozen, TP updates can continue if that region is
#not updated
$gtm_tst/com/dbcreate.csh . 3 255 1000
$GTM << EOF
set ^a=1
EOF
$MUPIP freeze -on AREG >& freeze_on_AREG.out
$GTM << EOF
do ^tpupd
halt
EOF
$grep OK tpupd.out
if ($status) then
	echo "TEST-E-FAIL, did not see an OK from child"
endif
$MUPIP freeze -off AREG >& freeze_off_AREG.out
$gtm_tst/com/dbcheck.csh
