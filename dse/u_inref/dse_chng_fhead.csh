#!/usr/local/bin/tcsh
#################################################################
#								#
# Copyright (c) 2002-2015 Fidelity National Information		#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
#								#
# Copyright (c) 2017-2018 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.                                          #
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################

# the output of this test relies on dse dump -file output, therefore let's not change the block version:
setenv gtm_test_mupip_set_version "disable"
setenv gtm_test_disable_randomdbtn
#define allocation to be 3000 to avoid extensions during the test and hence sporadic DBFGTBC integrity errors on crash.
$gtm_tst/com/dbcreate.csh . -alloc=3000 -block_size=1024
cp mumps.dat mumps.bak

echo "Start fileheader tests..."
echo "before changes..."

$DSE dump -fileheader


#make invalid  changes to the fileheader

#NULL gets caught as invalid character
echo "command: change -fileheader -location=NULL -size=1 -value=1 ..."
#bad size gets caught
echo "command: change -fileheader -location=10 -size=z -value=1..."
#bad location gets caught
echo "command: change -fileheader -location=Z -size=1 -value=1..."
#zero size should not cause core
echo "command: change -fileheader -location=1000 -size=0 -value=99 ..."
echo "check converting string to hex for value...."
echo "check converting string to hex for location..."

$DSE << EOF
change -fileheader -location="\" -size=1 -value=1
change -fileheader -location=10 -size=z -value=1
change -fileheader -location=Z -size=1 -value=1
change -fileheader -location=1000 -size=0 -value=99
change -fileheader -location=1600 -size=1 -value=10000000000
change -fileheader -location=50000000000000000000000 -size=1 -val=11
change -fileheader -location=fffffffffffffffffffffff -size=1 -val=11
exit
EOF

#make valid changes to the fileheader and check that message returns
# value per size given

echo "command: change -fileheader -location=1000 -value=11111111 size=1"
echo "command: change -fileheader -location=1002 -value=22222222 size=2"
echo "command: change -fileheader -location=1000 -value=22222222 size=4"
# size=8 qualifier added now as from V5 we support them too.
echo "command: change -fileheader -location=1200 -value=7FFFFFFFFFFFFFFF size=8"
echo "command: change -fileheader -location=1200 -value=FFFFFFFFFFFFFFFF size=8"

$DSE << EOF >&! fix_endian.txt
change -fileheader -location=1000 -value=11111111 -size=1
change -fileheader -location=1002 -value=22222222 -size=2
change -fileheader -location=1000 -value=22222222 -size=4
change -fileheader -location=1200 -value=7FFFFFFFFFFFFFFF -size=8
change -fileheader -location=1200 -value=FFFFFFFFFFFFFFFF -size=8
EOF

$tst_awk '{print}' fix_endian.txt | sed 's/Old Value = 285221410 \[0x11002222\]/Old Value = XXXXXXXX [0xXXXXXXXX]/g' | sed 's/Old Value = 572653585 \[0x22220011\]/Old Value = XXXXXXXX [0xXXXXXXXX]/g'

echo after changes...

$DSE dump -fileheader

rm mumps.dat
mv mumps.bak mumps.dat

echo "Check -nocrit qualifier..."
$gtm_tst/$tst/u_inref/dse_crita_fhead.csh

echo "end critical section tests..."
$DSE << EOF
ch -fi -kill=1
q
EOF
$MUPIP integ -R "*"
$DSE << EOF
ch -fi -kill=0
q
EOF
$MUPIP integ -R "*"

echo "dse change -file -sleep=0 -spin=FFFFFF"
$DSE change -file -sleep=0 -spin=0xFFFFFF
echo "dse dump -file"
$DSE dump -file >& dse_dump_0.out
$gtm_tst/com/grepfile.csh 'Spin sleep time mask    0x00FFFFFF' dse_dump_0.out 1
$gtm_tst/com/grepfile.csh 'Mutex Sleep Spin Count           0' dse_dump_0.out 1

echo "dse dump -file -all"
$DSE dump -file -all >& dse_dump_1.out
$grep "Fully Upgraded" dse_dump_1.out

echo "dse change -file -fully_upgraded=0"
$DSE change -file -fully_upgraded=0
echo "dse dump -file -all"
$DSE dump -file -all >& dse_dump_2.out
$grep "Fully Upgraded" dse_dump_2.out

echo "dse change -file -fully_upgraded=1"
$DSE change -file -fully_upgraded=1
echo "dse dump -file -all"
$DSE dump -file -all >& dse_dump_3.out
$grep "Fully Upgraded" dse_dump_3.out

echo "dse change -file -fully_upgraded=TRUE it should give an error"
$DSE change -file -fully_upgraded=TRUE

echo "dse change -file fully_upgraded=-7"
$DSE change -file -fully_upgraded=-7

echo "dse change -file fully_upgraded=7"
$DSE change -file -fully_upgraded=7
echo "dse dump -file -all"
$DSE dump -file -all >& dse_dump_4.out
$grep "Fully Upgraded" dse_dump_4.out

echo "dse change -file fully_upgraded=32313214343"
$DSE change -file -fully_upgraded=32313214343


echo "testing interrupted_recov flag"

echo "set tp transactions"
$MUPIP set $tst_jnl_str -reg "*" >&! jnl_on.log
$grep "YDB-I-JNLSTATE" jnl_on.log | sort
\rm -rf jobid.txt

$gtm_tst/com/abs_time.csh time1 >>! /dev/null
set time1 = `cat time1_abs`
$gtm_exe/mumps -run %XCMD 'tstart  set ^a=1  tcommit  zsystem "'$kill9 '"_$job'
$MUPIP rundown -reg "*" -override

if (! $gtm_test_jnl_nobefore) then
	echo "unset gtmgbldir and try journal recover"
	unsetenv gtmgbldir
	$MUPIP journal -recover -since=\"$time1\" -backward mumps.mjl

	sleep 2

	echo "Set gtmgbldir and retry journal recover"
	setenv gtmgbldir mumps.gld
	setenv gtm_white_box_test_case_enable 1
	setenv gtm_white_box_test_case_number 48
	$MUPIP journal -recover -since=\"$time1\" -backward mumps.mjl
	unsetenv gtm_white_box_test_case_enable
	unsetenv gtm_white_box_test_case_number

	echo "mupip rundown"
	$MUPIP rundown -reg "*" -override

	echo "mupip integ"
	$MUPIP integ -reg "*"
	# Output redirected to outx since we are expecting CORRPUT_FILE error
	$DSE dump -file -all >& dse_dump_5.outx
	$grep "Recover interrupted" dse_dump_5.outx

	echo "Set -partial_recov_bypass"
	$MUPIP set -file mumps.dat -partial_recov_bypass
	$MUPIP integ -reg "*"
	# Disable journal flag
	echo "Turn off journaling"
	$MUPIP set -journal="disable" -reg "*"

	echo "Moving journal files to bak"
	mkdir bak
	mv *mjl* bak/

	# Enable journal flag
	echo "Enable journaling"
	$MUPIP set -journal="on,enable,before" -reg "*"
	# Test journal recovery
	echo "Attempt a journal backward recovery"
	$MUPIP journal -recover -backward mumps.mjl
	$DSE dump -file -all >& dse_dump_6.out
	$grep "Recover interrupted" dse_dump_6.out
	echo "Set -interrupted_recov=FALSE"
	$DSE  change -file -interrupted_recov=FALSE
	$DSE dump -file -all >& dse_dump_7.out
	$grep "Recover interrupted" dse_dump_7.out
	# Journal recovery should now pass
	echo "Retry backward journal recovery, after setting interrupted_recov=FALSE"
	$MUPIP journal -recover -backward mumps.mjl
endif

# Clean up relinkctl shared memory.
$MUPIP rundown -relinkctl >&! mupip_rundown_rctl.logx

$gtm_tst/com/dbcheck.csh
echo "end fileheader tests..."
