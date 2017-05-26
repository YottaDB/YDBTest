#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2010-2016 Fidelity National Information		#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
# This test ensures that hot copy of a running database from one host to another host (with different endianness) does not
# result in GTMASSERT when accessed on the remote side. Pre V5.4-001 versions did not reset volatile fields during
# endian conversion which resulted in unintended GTMASSERTs during database initalization


setenv gtm_test_mupip_set_version "disable"
setenv gtm_test_disable_randomdbtn

cat << CAT_EOF >&! updatehang.m
updatehang	;
		set file="updatehang.pid" open file use file write \$JOB close file
		set ^simpleupdate=1
		set ^done=0
		for i=1:1:3600  quit:^done  hang 1
CAT_EOF

$gtm_tst/com/dbcreate.csh mumps 1

# Shutdown the replication servers in the primary and secondary side. This is needed because we are attempting to hot copy
# mumps.dat from the primary to the secondary while the update process will be running and doing an endian conversion on the
# secondary. This could cause unintended asserts in the update process log as the ENDIANCVT assumes standalone access when
# a database of LITTLE/BIG endian is converted to BIG/LITTLE endian in a BIG/LITTLE endian machine respectively. Since this
# test does not do anything special with respect to replication, this should be okay.
$gtm_tst/com/RF_SHUT.csh "off" >&! RF_SHUT.out

echo ""
$echoline
echo "Do a simple update and hang for eternity"
$echoline
echo ""
echo ""

($gtm_exe/mumps -r updatehang >&! updatehang.out &) >&! updatehang_bg.out

$echoline
echo "Wait for the hang to start"
$echoline
echo ""
echo ""
$GTM << GTM_EOF
do ^waitforglobal
quit
GTM_EOF

$DSE all -buffer_flush

$echoline
echo "Do a hot copy of mumps.dat to remote side"
$echoline
echo ""
echo ""
$rcp mumps.dat "$tst_remote_host":$SEC_SIDE/

$echoline
echo "Do endiancvt on the remote side and attempt and INTEG on the database. Expect no issues"
$echoline
echo ""
echo ""
$sec_shell "$sec_getenv ; cd $SEC_SIDE ;  echo Y | $MUPIP endiancvt mumps.dat; $MUPIP integ -reg DEFAULT"

echo ""
$echoline
echo "Halt the hanging process"
$echoline
echo ""
echo ""
$GTM << GTM_EOF >&! done.out
set ^done=1
quit
GTM_EOF

set updatehang_pid = `cat updatehang.pid`
$gtm_tst/com/wait_for_proc_to_die.csh $updatehang_pid

$gtm_tst/com/dbcheck.csh -noshut	# The replication servers are already shutdown
