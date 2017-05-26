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
#
# Bypass this test for snail/turtle due to their perpetual slowness and intermittent failures due to.
#
set hostn = $HOST:r:r:r
if (("snail" == "$hostn") || ("turtle" == "$hostn")) exit
#
# This test should not use fake-ENOSPC or TLS (replication encryption)  because they can affect test timings significantly.
#
setenv gtm_test_fake_enospc 0
setenv gtm_test_tls "FALSE"
#
echo ""
echo "C9A03-001430"
echo ""
# delta is set to be 6 in ztrapit.m, if the process times out in less than timeout+delta, it is assumed to pass.
set timeout=10
set longwait=20
$gtm_tst/com/dbcreate.csh mumps 1 255 1000 1024 500 4096
#
#==============================================
#NEWLINE
#==============================================
# Globals set below are used throughout the test
$GTM <<END
set ^IterNo=0,^timeout=$timeout,^longwait=$longwait
END
$GTM <<END
set ^modname="nwlntst",^useport="False"
w "Testing New Line",!
do ^driver
h
END
$GTM <<END
set ^modname="fortst",^useport="False"
w "Testing for loop",!
do ^driver
h
END
$GTM <<END
set ^modname="locktst",^useport="False"
w "Testing lock",!
do ^driver
h
END
$GTM <<END
set ^modname="hangtst",^useport="False"
w "Testing hang",!
do ^driver
h
END

source $gtm_tst/com/portno_acquire.csh  >>& portno.out
$GTM <<END
set ^modname="rdtcptst"
w "Testing read from TCP",!
set ^portno=$portno,^useport="True"
do ^driver
h
END
sleep 10
$GTM <<END
set ^modname="opentst",^useport="True"
w "Testing open using TCP",!
do ^driver
h
END
$gtm_tst/com/portno_release.csh
#==============================================
#JOB ----job cannot be tested in UNIX
#==============================================

#==============================================
#Direct Mode
#==============================================
$GTM << EOF
w "Testing TP in direct Mode:New Line",!
EOF
$gtm_tst/$tst/u_inref/tptime_direct.csh >>&! tptime_Directmode.logx
cat DirectModepasslog.logx
#
# tptimeout deferral test
#
echo "#"
echo "TPTimeout deferral testing"
echo
$GTM << EOF
Do ^tptimeecode
EOF

$gtm_tst/com/dbcheck.csh
