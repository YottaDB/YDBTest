#!/usr/local/bin/tcsh -f
#################################################################
#								#
#	Copyright 2002, 2013 Fidelity Information Services, Inc	#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
###############################################################
# SERVER
echo "####################### Test SERVER crash #########################################"
source $gtm_tst/com/dbcreate.csh . 4

echo "Start a GT.M client and crash one of the servers (the one on $tst_remote_host_2)"
$gtm_exe/mumps -run long </dev/null >& long.log

$gtm_tst/com/check_error_exist.csh long.log "GTM-E-GVPUTFAIL" "GTM-W-NOTPRINCIO"
echo "Re-start a server (on $tst_remote_host_2)"
setenv start_time `date +%H_%M_%S`
setenv portno_gtcm `$rsh $tst_remote_host_2  "source $gtm_tst/com/remote_getenv.csh $SEC_DIR_GTCM_2 ;cd $SEC_DIR_GTCM_2;source $gtm_tst/com/portno_acquire.csh"`
if (-e gtcm_portno_2.txt) mv gtcm_portno_2.txt  gtcm_portno_2.txt_`date +%H_%M_%S`
echo $portno_gtcm >&! gtcm_portno_2.txt
setenv GTCM_${tst_remote_host_2:r:r:r:r} "[${tst_remote_host_2}]:$portno_gtcm"
$rsh $tst_remote_host_2  "source $gtm_tst/com/remote_getenv.csh $SEC_DIR_GTCM_2 ; cd $SEC_DIR_GTCM_2; $gtm_tst/com/GTCM_SERVER.csh $portno_gtcm $start_time >&! $SEC_DIR_GTCM_2/gtcm_start_${start_time}.out"

echo "Re-try a client"
$GTM << EOF
s ^A=1
s ^B=2
s ^C=3
s ^D=4
w "^A,^B,^C,^D: ",^A,^B,^C,^D
EOF

$gtm_tst/com/dbcheck.csh
