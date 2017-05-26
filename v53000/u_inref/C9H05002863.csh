#!/usr/local/bin/tcsh -f
#
# C9H05-002863
$GDE exit
if("ENCRYPT" == $test_encryption) then
        $gtm_tst/com/create_key_file.csh >& create_key_file_dbload.out
endif
$MUPIP create
setenv gtm_ztrap_form adaptive
$GTM << EOF
do ^c002863
do ^c002863
do ^c002863
halt
EOF
unset gtm_ztrap_form
