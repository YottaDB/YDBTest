#!/usr/local/bin/tcsh  -f
$switch_chset "M" >& switch_chset.log
setenv gtmgbldir "mumps.gld"

$gtm_tst/$tst/u_inref/gtcm_start_enc.csh >& gtcm_start.log
$gtm_tst/com/dbcreate.csh mumps 1

$MUPIP set -file -journal=on,nobe,enable mumps.dat 
$GTM << EOF
do viagtcm^testenc
h
EOF
$gtm_tst/com/wait_for_log.csh -log gtcm_start.log -message "CRYPTINIT" -duration 30 -waitcreation
$gtm_tst/com/check_error_exist.csh gtcm_start.log "CRYPTINIT" "CRYPTBADCONFIG"
$gtm_tst/$tst/u_inref/gtcm_stop.csh >& gtcm_stop.log
$gtm_tst/com/dbcheck.csh
