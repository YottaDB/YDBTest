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
##########################################################
# The test scheme is:
#
#	test locks and z(de)alloc
#   . server 2 grabs ^b (GT.CM), and ^d, and a locally
#	test locks and z(de)alloc
#   . server 1 grabs ^c,^d, a, b (GT.CM)
#	test locks and z(de)alloc
#
# the database layout is:
# client  : AREG
# server 1: CREG, DEFAULT
# server 2: BREG
#########################################################
##############################################################################
# Add tests for locking longnamed globals as well once LKE issues are resolved
##############################################################################
source $gtm_tst/com/dbcreate.csh . 4
# if (-e $tst_working_dir/GTCM_x.csh) source $tst_working_dir/GTCM_x.csh; setenv | grep GTCM_
echo "I've disabled all checking -- Nergis"

setenv > setenv.out
$sec_shell "SEC_SHELL_GTCM SEC_GETENV_GTCM ; $rcp $gtm_tst/$tst/inref/*.m TST_REMOTE_HOST_GTCM:SEC_DIR_GTCM"
echo "Testing LOCK and Z(DE)ALLOCATE..."
echo "No other processes are holding locks..."

echo "locks101"
$gtm_exe/mumps -run locks101
echo "done locks101"
$gtm_exe/mumps -run testit
echo "##################################################################################"
# lock ^b on other server
# region REGB is always going to be on server 2
echo "Now, server 2 will lock ^b, (along with it's local ^d,a,b) and the tests lkebas and zalloc will be run while server 2 is holding it's locks"
($rsh $tst_remote_host_2  "source $gtm_tst/com/remote_getenv.csh $SEC_DIR_GTCM_2 ; cd $SEC_DIR_GTCM_2; "'$gtm_exe/mumps'" -run lockb </dev/null > lockb.out" & )
$rsh $tst_remote_host_2  "cd $SEC_DIR_GTCM_2; $gtm_tst/$tst/u_inref/lke_check.csh $gtm_tst $SEC_DIR_GTCM_2 2 b yes"
if ( "0" != $status)  then
	echo "$tst_remote_host_2 could not lock ^b. Cannot continue testing"
	$gtm_tst/com/dbcheck.csh
	exit
endif

echo "Server 2 is holding some locks locally..."
$gtm_exe/mumps -run testit
echo "##################################################################################"

# lock ^c on the other server
if ($?tst_remote_host_1) then
	set chostno = 3
	set tst_remote_host_1 = $tst_remote_host_1
	set SEC_DIR_GTCM_1 = $SEC_DIR_GTCM_1
else
	set chostno = 1
	set tst_remote_host_1 = $tst_remote_host_1
	set SEC_DIR_GTCM_1 = $SEC_DIR_GTCM_1
endif
echo "Now the tests will be run again with Server 1 locking ^c (and it's local ^d)"

($rsh $tst_remote_host_1  "source $gtm_tst/com/remote_getenv.csh $SEC_DIR_GTCM_1 ; cd $SEC_DIR_GTCM_1; "'$gtm_exe/mumps'" -run lockc </dev/null > lockc.out" & )
$rsh $tst_remote_host_1  "cd $SEC_DIR_GTCM_1; $gtm_tst/$tst/u_inref/lke_check.csh $gtm_tst $SEC_DIR_GTCM_1 1 c yes"
if ( "0" != $status)  then
	echo "$tst_remote_host_1  could not lock ^c.  Cannot continue testing"
	$gtm_tst/com/dbcheck.csh
	exit
endif


echo "Both Server 1 and 2 are holding some locks locally..."
$gtm_exe/mumps -run testit
echo "##################################################################################"

#$gtm_tst/$tst/u_inref/exit.csh c
#$gtm_tst/$tst/u_inref/exit.csh b
$rsh $tst_remote_host_1  "source $gtm_tst/com/remote_getenv.csh $SEC_DIR_GTCM_1 ; cd $SEC_DIR_GTCM_1; "'$gtm_exe/mumps'" -run relec"
$rsh $tst_remote_host_2  "source $gtm_tst/com/remote_getenv.csh $SEC_DIR_GTCM_2; cd $SEC_DIR_GTCM_2; "'$gtm_exe/mumps'" -run releb"
sleep 20 # give them some time to exit
$gtm_tst/com/dbcheck.csh
