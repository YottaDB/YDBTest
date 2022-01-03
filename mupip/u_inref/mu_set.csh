#! /usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2002-2016 Fidelity National Information		#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
#								#
# Copyright (c) 2017-2022 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.                                          #
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
#
##################################
# mu_set.csh  test for mupip set #
##################################
#
#
echo MUPIP SET
#
#
# In case of replication or reorg, turn them off for this part of the test
# for dbcheck
unsetenv test_replic
unsetenv gtm_repl_instance
setenv test_reorg NON_REORG
#
#
@ corecnt = 1
setenv gtmgbldir "./set.gld"
if (-f tempse.com) then
    \rm tempse.com
endif
echo "change -segment DEFAULT -file=set" >!  tempse.com
echo "add -name a* -region=rega"         >>! tempse.com
echo "add -name b* -region=regb"         >>! tempse.com
echo "add -region rega -d=sega"          >>! tempse.com
echo "add -region regb -d=segb"          >>! tempse.com
echo "template -segment -block_size=1024" >>! tempse.com	# later part of the test relies on 1K block size
echo "add -segment sega -file=set1"      >>! tempse.com
echo "add -segment segb -file=set2"      >>! tempse.com
if (("MM" == $acc_meth) && (0 == $gtm_platform_mmfile_ext)) then
	echo "change -segment DEFAULT -allocation=400"	>>! tempse.com
	echo "change -segment sega -allocation=200"	>>! tempse.com
	echo "change -segment segb -allocation=200"	>>! tempse.com
endif
#
setenv test_specific_gde $cwd/tempse.com
$gtm_tst/com/dbcreate.csh set
#
$gtm_exe/mumps -run %XCMD 'do ^musetchk("before.txt")'
#
echo "#"
echo "# Set with a bad region"
echo "#"
$MUPIP set -region FREELUNCH -g=3096
echo "#"
echo "# Set with a bad file"
echo "#"
$MUPIP set -file FREELUNCH.dat -g=3096
echo "#"
echo "# Set with a bad access method"
echo "#"
$MUPIP set -file set.dat -access_method=foo
echo "#"
echo "# Set with a bad extension_count"
echo "#"
$MUPIP set -file set.dat -ext=-1
echo "#"
echo "# Set with a bad extension_count"
echo "#"
$MUPIP set -region RegA -EXT=1048576
echo "#"
echo "# Set with a bad global buffers"
echo "#"
$MUPIP set -file set.dat -glo=2
echo "#"
echo "# Set with a bad global buffers"
echo "#"
$MUPIP set -region RegA -GLO=2097152
echo "#"
echo "# Set with a bad key size"
echo "#"
$MUPIP set -file set.dat -key=2
echo "#"
echo "# Set with a bad key size"
echo "#"
$MUPIP set -region RegA -key=1020
echo "#"
echo "# Set with a bad lock space"
echo "#"
$MUPIP set -file set.dat -lock=9
echo "#"
echo "# Set with a bad lock space"
echo "#"
$MUPIP set -region RegA -lock=262145
echo "#"
echo "# Set with a bad mutex slots"
echo "#"
$MUPIP set -file set.dat -mutex=63
echo "#"
echo "# Set with a bad mutex slots"
echo "#"
$MUPIP set -region RegA -MUTEX=32769
echo "#"
echo "# Set with a bad record size"
echo "#"
$MUPIP set -file set.dat -rec=-1
echo "#"
echo "# Set with a bad record size"
echo "#"
$MUPIP set -region RegA -REC=1048577
echo "#"
echo "# Set with a bad sleep spin limit"
echo "#"
$MUPIP set -file set.dat -sleep=-1
echo "#"
echo "# Set with a bad sleep spin limit"
echo "#"
$MUPIP set -region RegA -SLEEP=1000001
echo "#"
echo "# Set with a bad spin sleep count"
echo "#"
$MUPIP set -file set.dat -spin=-1
echo "#"
echo "# Set with a bad spin sleep count"
echo "#"
$MUPIP set -region RegA -SPIN=1000000001
echo "#"
echo "# Set with a bad version"
echo "#"
$MUPIP set -file set.dat -ver=V3
echo "#"
echo "# Set with a bad wait disk"
echo "#"
$MUPIP set -region RegA -wait=-1
echo "#"
echo "# Sets with a things that won't fly because of current state"
echo "#"
source $gtm_tst/com/leftover_ipc_cleanup_if_needed.csh $0 # do rundown if needed before requiring standalone access
$MUPIP set -region RegA -key=1019
$MUPIP set -region RegA -reserved=1000
$MUPIP set -region RegA -record=60
#
$gtm_exe/mumps -run %XCMD 'do ^musetchk("errors.txt")'
#
$gtm_exe/mumps -run %XCMD 'do dochk^musetchk("before.txt","errors.txt")'
#
$gtm_exe/mumps -run %XCMD 'do fill1^myfill("set")'
$gtm_exe/mumps -run %XCMD 'do fill1^myfill("ver")'
source $gtm_tst/$tst/u_inref/check_core_file.csh "se" "$corecnt"
#
set mupip_set_output = mupip_set.out
$MUPIP set -file set.dat -g=2048 -access_method=BG -EPOCHT -extension_CO=2000 -rec=2048 -spin=3000 -sleep=4 >>& $mupip_set_output
if ($status > 0) then
    echo "ERROR from $MUPIP set file set.dat g 2048. Please check $mupip_set_output"
    exit 2
endif
#Region Name in Mixed cases should be accepted
$MUPIP set -region Rega,REGB -g=3096  |& sort -f >>& $mupip_set_output
if ($status > 0) then
    echo "ERROR from $MUPIP set region rega regb g 3096. Please check $mupip_set_output"
    exit 3
endif
$MUPIP set -region "*" -res=7 |& sort -f >>& $mupip_set_output
if ($status > 0) then
    echo "ERROR from $MUPIP set -r asterisk res 7. Please check $mupip_set_output"
    exit 4
endif
# -nodefer_alloc is not supported on solaris and hpux itanium
if ($HOSTOS =~ {SunOS,HP-UX}) then
    set nodefer = ""
else
    set nodefer = "-nodefer_alloc"
endif
$MUPIP set -region "*" -lock=4000 -MUTEX_SLOTS=1500 -qdbrundown -key=255 $nodefer |& sort -f >>& $mupip_set_output
if ($status > 0) then
    echo "ERROR from $MUPIP set r asterisk lock etc. Please check $mupip_set_output"
    exit 4
endif

# <argumentless_rundown_causes_test_failure/resolution_v2> Filter out SHMREMOVED messages in case there is an argumentless MUPIP
# RUNDOWN from another test running at the same time
$grep -v SHMREMOVED $mupip_set_output
#
$gtm_exe/mumps -run %XCMD 'do ^musetchk("after.txt")'
#
$gtm_exe/mumps -run %XCMD 'do fill1^myfill("ver")'
source $gtm_tst/$tst/u_inref/check_core_file.csh "se" "$corecnt"
#
$gtm_exe/mumps -run %XCMD 'do dochk^musetchk("before.txt","after.txt")'
#
$gtm_tst/com/dbcheck.csh
#####################
# END of mu_set.csh #
#####################
