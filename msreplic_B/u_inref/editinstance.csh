#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2006-2016 Fidelity National Information		#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
#
# If run with journaling, this test requires BEFORE_IMAGE so set that unconditionally even if test was started with -jnl nobefore
source $gtm_tst/com/gtm_test_setbeforeimage.csh


$MULTISITE_REPLIC_PREPARE 4
## There are some checks in the instance_create subtest, this subtest tests the details of the -editinstance qualifier.
##
## - mupip replic -editinstance -show mumps.repl
## 	--> We expect a REPLINSTOPEN error (with secondary message "No such file or directory") since there is no instance file.
## - Bad instance file:
##   rm mumps.repl
##   touch mumps.repl
##   mupip repl -editinstance -show mumps.repl
## 	--> We expect a REPLINSTREAD error since the read of the file header itself will fail.

echo ""
echo "Expect a REPLINSTOPEN and a REPLINSTREAD error for the next 2 commands"
echo ""
$MUPIP replicate -editinstance -show mumps.repl >&! editinstance_REPLINSTOPEN.out
if ( "os390" == $gtm_test_osname ) then
        set errENO = "SYSTEM-E-ENO129"
else
        set errENO = "SYSTEM-E-ENO2"
endif
$msr_err_chk editinstance_REPLINSTOPEN.out REPLINSTOPEN $errENO
# unset errENO because it contains an ERROR message that would otherwise be picked up by test/com/errors_helper.csh
unset errENO
if (-e mumps.repl) \rm mumps.repl
touch mumps.repl
$MUPIP replicate -editinstance -show mumps.repl >&! editinstance_REPLINSTREAD.out
$msr_err_chk editinstance_REPLINSTREAD.out REPLINSTREAD
\rm mumps.repl

## - create an instance file
##   $MULTISITE_REPLIC_PREPARE 4
##   dbcreate 1
$gtm_tst/com/dbcreate.csh mumps

## - mupip replic -editinstance -show
## 	--> It should prompt for the instance file name.
## 	Using here documents (<< EOF):
## 	a) do not enter an instance name (i.e. null input)
## 		--> We expect a MUPCLIERR error.
## 	b) enter the file name mumps.repl
## 		--> This should succeed.
## - Try -edit, -editins, -edi
##   mupip replic -edit -show mumps.repl
##   	--> This should succeed (forward it's output to some file so the reference file is not too crowded).
##   mupip replic -e -show mumps.repl
##   	--> This should succeed (forward it's output to some file so the reference file is not too crowded).

setenv gtm_repl_instance "mumps.repl"
$MUPIP replicate -instance_create -name=$gtm_test_msr_INSTNAME1 $gtm_test_qdbrundown_parms
echo ""
echo "Expect a MUPCLIERR error next"
echo ""
$MUPIP replicate -editinstance -show << MUPIP_EOF

MUPIP_EOF
$MUPIP replicate -editinstance -show << MUPIP_EOF
mumps.repl
MUPIP_EOF
$MUPIP repl -editins -show mumps.repl >&! repl_editins.out
if( $status) echo "TEST-E-EDITINSTANCE MUPIP repl -editins -show mumps.repl command failed"
$MUPIP repl -edit -show mumps.repl >&! repl_edit.out
if( $status) echo "TEST-E-EDITINSTANCE MUPIP repl -edit -show mumps.repl command failed"
$MUPIP repl -e -show mumps.repl >&! repl_e.out
if( $status) echo "TEST-E-EDITINSTANCE MUPIP repl -e -show mumps.repl command failed"
# move away mumps.repl and let the following START commands create new mumps.repl according to test_replic_suppl_type
\mv mumps.repl mumps.repl.show_bak

## - create some history, and modify different fields in it.
##   START INST1 INST2
##   RUN INST1 '$gtm_tst/com/simpleinstanceupdate.csh 1'
##   SYNC INST1 INST2
##   STOPSRC INST1 INST2
##   STARTSRC INST1 INST2
##   RUN INST1 '$gtm_tst/com/simpleinstanceupdate.csh 3'
##   SYNC INST1 INST2
##   STOPSRC INST1 INST2
##   STARTSRC INST1 INST2
##   RUN INST1 '$gtm_tst/com/simpleinstanceupdate.csh 10'
##   SYNC INST1 INST2
##   STOPSRC INST1 INST2
##   STARTSRC INST1 INST2
##   RUN INST1 '$gtm_tst/com/simpleinstanceupdate.csh 4'
##   SYNC INST1 INST2
##   STOPSRC INST1 INST2
##   STARTSRC INST1 INST2
##   RUN INST1 '$gtm_tst/com/simpleinstanceupdate.csh 100'
##   SYNC INST1 INST2
##   STOPSRC INST1 INST2
##   STARTSRC INST1 INST2
##   RUN INST1 '$gtm_tst/com/simpleinstanceupdate.csh 1'
##   SYNC INST1 INST2
##   STOPSRC INST1 INST2
##   STARTSRC INST1 INST2
##   RUN INST1 '$gtm_tst/com/simpleinstanceupdate.csh 1'
##   SYNC INST1 INST2
##   STOPSRC INST1 INST2
##   STARTSRC INST1 INST2
##   RUN INST1 '$gtm_tst/com/simpleinstanceupdate.csh 5'
##   SYNC INST1 INST2           #prior to crash
##   STARTSRC INST1 INST3	#note there is no receiver server running for INST3, this is only to see the slots

$MSR START INST1 INST2 RP
$MSR RUN INST1 $gtm_tst/com/simpleinstanceupdate.csh 1
$MSR SYNC INST1 INST2
$MSR STOPSRC INST1 INST2
$MSR STARTSRC INST1 INST2 RP
$MSR RUN INST1 '$gtm_tst/com/simpleinstanceupdate.csh 3'
$MSR SYNC INST1 INST2
$MSR STOPSRC INST1 INST2
$MSR STARTSRC INST1 INST2 RP
$MSR RUN INST1 '$gtm_tst/com/simpleinstanceupdate.csh 10'
$MSR SYNC INST1 INST2
$MSR STOPSRC INST1 INST2
$MSR STARTSRC INST1 INST2 RP
$MSR RUN INST1 '$gtm_tst/com/simpleinstanceupdate.csh 4'
$MSR SYNC INST1 INST2
$MSR STOPSRC INST1 INST2
$MSR STARTSRC INST1 INST2 RP
$MSR RUN INST1 '$gtm_tst/com/simpleinstanceupdate.csh 100'
$MSR SYNC INST1 INST2
$MSR STOPSRC INST1 INST2
$MSR STARTSRC INST1 INST2 RP
$MSR RUN INST1 '$gtm_tst/com/simpleinstanceupdate.csh 1'
$MSR SYNC INST1 INST2
$MSR STOPSRC INST1 INST2
$MSR STARTSRC INST1 INST2 RP
$MSR RUN INST1 '$gtm_tst/com/simpleinstanceupdate.csh 1'
$MSR SYNC INST1 INST2
$MSR STOPSRC INST1 INST2
$MSR STARTSRC INST1 INST2 RP
# wait for connection to replication server to occur prior to doing primary updates for accurate Connect Sequence Number"
get_msrtime
$gtm_tst/com/wait_for_log.csh -log SRC_$time_msr.log -message "Sending REPL_HISTREC message" -duration 100 -waitcreation  # wait up to 100 seconds
$MSR RUN INST1 "$gtm_tst/com/simpleinstanceupdate.csh 5"
$MSR SYNC INST1 INST2
$MSR STARTSRC INST1 INST3 RP

##   Verify detailed and nondetailed output:
##     RUN INST1 '$MUPIP replic -editinstance -show mumps.repl         >& editinstance_nodetail.out'
##     RUN INST1 '$MUPIP replic -editinstance -show mumps.repl -detail >& editinstance_detail.out'
##     Forward the output of both commands into log files, and compare against a saved version (to keep reference file
##     easier to follow).

$MSR RUN INST1 '$MUPIP replicate -editinstance -show mumps.repl         >& editinstance_nodetail.out'
$MSR RUN INST1 '$MUPIP replicate -editinstance -show mumps.repl -detail >& editinstance_detail.out'
 ##TODO## Compare with what?

##   $gtm_tst/com/view_instancefiles.csh -print -instance INST1 -detail
##   	-->The history after these updates should be:
## 	   <seqno=  1,name=INSTANCE1, cycle=1>		(offset:0x600)
## 	   <seqno=  2,name=INSTANCE1, cycle=2>		(offset:0x640)
## 	   <seqno=  5,name=INSTANCE1, cycle=3>		(offset:0x680)
## 	   <seqno= 15,name=INSTANCE1, cycle=4>		(offset:0x6C0)
## 	   <seqno= 19,name=INSTANCE1, cycle=5>		(offset:0x700)
## 	   <seqno=119,name=INSTANCE1, cycle=6>		(offset:0x740)
## 	   <seqno=120,name=INSTANCE1, cycle=7>		(offset:0x780)
## 	   <seqno=121,name=INSTANCE1, cycle=8>		(offset:0x7C0)
## 	   state=CRASH, there should be a slot for INST2, INST3

$gtm_tst/com/view_instancefiles.csh -instance INST1 -print -detail

##   CRASH INST1
##   STOPRCV INST1 INST2

$MSR CRASH INST1
$MSR STOPRCV INST1 INST2
## - Show some of the fields of the instance file:
##   Below we define some offsets, these are not meant to be determined on the fly, but from the actual output once the
##   software is ready, and can be hardcoded into the test script. Let's add comments about what the offset is picking
##   just in case the format of the instance file changes one day, and we need to update these offsets. But that is not
##   very probable, so it is easier and more preferable to just hard-code the offsets into the test.
##
##   History (Triple records):
##   Pick offset1 as the offset of the last seqno field (121) from the -show output above. (size1=8)
##   Pick offset2 as the offset of the instancename field for seqno 119 from the -show output above. (size2=8)
##   Pick offset2a as the offset of the second half of the instancename field for seqno 119 (offset2+8). (size2a=8)
##   Pick offset3 as the offset of the cycle field for seqno 15 (cycle=4) from the -show output above. (size3=4)
##
##   Secondary Slots:
##   Pick offset4 as the offset of the instancename for the secondary slot for INST2 from the -show output above. (size4=8)
##   Pick offset4a as the offset of the second half instancename for the secondary slot for INST2 from the -show output above. (size4a=8)
##   Pick offset4b as the offset of the resync_seqno field for the secondary slot for INST2 from the -show output above. (size4b=8)
##
##   File Header:
##   Pick offset5 as the offset of the instance name for this instance from the -show output above. (size5=8)
##   Pick offset5a as the offset of the second half of the instance name for this instance from the -show output above. (size5a=8)
##   Pick offset6 as the offset of the crash state for this instance from the -show output above. (size6=4)
##
##   For each of these offsets (offset1-6), let's view the contents:
##   mupip replic -edit -change -offset=<offsetx> -size=<sizex> mumps.repl		#where <sizex> is the size of that field.
##   	--> verify contents.
 #-> The above test is not done, since the output will be endian depandent..
##   Also check that the offsets are expected from the offset.csh output of the related fields. For the data layout now,
##   the values of the offsets should be, let's hard code these in the test, no need to determine them on-the-fly:
##   -----------------------------------------
##
setenv offset1  C70	; setenv size1  8
setenv offset2  B20	; setenv size2  8
setenv offset2a B28	; setenv size2a 8
setenv offset3  A00	; setenv size3  4
setenv offset4  400	; setenv size4  8
setenv offset4a 408	; setenv size4a 8
setenv offset4b 410	; setenv size4b 8
setenv offset5  50	; setenv size5  8
setenv offset5a 58	; setenv size5a 8
setenv offset6  A4	; setenv size6  4

##   Test bad size and bad offset. We expect the following error from all
## 	Error: OFFSET [0x0000074C] should be a multiple of Size [8]
## 	or
## 	Error: OFFSET [0x000006DA] should be a multiple of Size [4]
##
##   Test bad size:
##   mupip replic -edit -change -offset=<offset1> -size=3 mumps.repl
##   For each of these offsets (offset1-6), let's attempt to view the contents at a wrong size:
##   mupip replic -edit -change -offset=<offsetxbad> -size=<sizex> mumps.repl
##   where offsetxbad is (offsetx + sizex/2).
## 	--> All except the instancename fields should error (size check is not done for the instancename fields since
## 	    that is quite long itself). This is the decision at the time of writing of this test plan (no size check
## 	    for instancename fields), the actual behavior might change by the time the software is finalized, check
## 	    the behavior then.
##
##   Bad offset:
##   Try to see a location that is not a multiple of size:
##   bad_offset1 = <offset1> + 3
##   mupip replic -edit -change -offset=<bad_offset1> -size=4 mumps.repl
##   	--> We expect an appropriate error message.
##   mupip replic -edit -change -offset=badoffset -size=4 mumps.repl	#note "badoffset" is not a valid hex number
##   	--> We expect an appropriate error message.
##   Try to see beyond the instance file. Determine the last offset from the output above, add 0x100 to it, and try
##   mupip replic -edit -change -offset=<large_offset> -size=4 mumps.repl
##   	--> We expect an appropriate error message.

$MUPIP replicate -edit -change -offset=$offset1 -size=3 mumps.repl
echo "Test offset = offset + size/2 for each of the offsets 1-6"
echo ""

foreach i (1 2 2a 3 4 4a 4b 5 5a 6)
	setenv offx `echo echo \$"offset$i" | $tst_tcsh`
	setenv sizx `echo echo \$"size$i" | $tst_tcsh`
	setenv badoff `echo "obase=16; ibase=16; $offx + $sizx / 2" | bc`
	$MUPIP replicate -edit -change -offset=$badoff -size=$sizx mumps.repl
end
echo ""
echo "Test a bad offset, non-HEX value for offset and out of scope offset"
echo ""
set bad_offset1  = "7D3"  # <offset1 + 3>
set large_offset = "DC0" # For the transactions above the last offset will be 7E0. Since it is fixed, we'll just add 0x100 to it.

$MUPIP replicate -edit -change -offset=$bad_offset1 -size=4 mumps.repl
$MUPIP replicate -edit -change -offset=badoffset -size=4 mumps.repl
$MUPIP replicate -edit -change -offset=$large_offset -size=4 mumps.repl
echo ""

##
## - RUN INST1 '$gtm_tst/com/mupip_rollback.csh -losttrans=lost1.glo "*"'
## - Edit some fields of the instance file on INST1, then verify the contents using view_instancefiles.csh. Change the
##   values of all offsets defined in the above step.
##   mupip replic -edit -change -offset=<offset1> -size=8 -value=151 mumps.repl
##   view_instancefiles.csh -diff -detail
##   Let's also test the REPLINSTSEQORD error here (now that we've "corrupted" the instance file):
##   Attempt to start replication and do some updates on INST1.
##   STARTSRC INST1 INST3
##   	--> We expect a REPLINSTSEQORD error since the actual jnlseqno (122) will be less than the one recorded in the
## 	    instance file (151).
##   STOPSRC INST1 INST3

$MSR RUN INST1 '$gtm_tst/com/mupip_rollback.csh -losttrans=lost1.glo "*" >&! rollback_losttrans.out'
$MSR RUN INST1 '$grep -E "RLBKJNSEQ|JNLSUCCESS" rollback_losttrans.out'
$gtm_tst/com/view_instancefiles.csh -instance INST1 -detail >&! view_instancefile_afterrollback.out
# The above is done to minimise the diff to just the change in value we do below and not worry about the earlier journal/crash related ones
$MUPIP replic -edit -change -offset=$offset1 -size=8 -value=151 mumps.repl
$gtm_tst/com/view_instancefiles.csh -instance INST1 -detail -diff
setenv msr_dont_chk_stat
$MSR STARTSRC INST1 INST3
get_msrtime
$msr_err_chk $gtm_test_msr_DBDIR1/START_$time_msr.out REPLINSTSEQORD NOJNLPOOL
#$MSR STOPSRC INST1 INST3
 #-> since STARTSRC won't work, STOPSRC is not required

##
##   Then modify the other fields as well.  Below is a table summarizing what to change and the expected results.
##   offset 	value		size	expected result final value
##   ----------------------------------------------------------------------
##   							INSTANCE1
##   offset2	41		1	success		ANSTANCE1	# 0x41 -- A
##   offset2+1	32		1	success		A2STANCE1	# 0x32 -- 2
##   offset2+2	4B		1	success		A2KTANCE1	# 0x4B -- K
##   offset2+2	4C		1	success		A2LTANCE1	# 0x4C -- L
##   offset2+3	0x4D		1	success		A2LMANCE1	# 0x4D -- M
##   offset2+3	4E		1	success		A2LNANCE1	# 0x4E -- N
##   offset2+4	4F		1	success		A2LNONCE1	# 0x4F -- O
##   offset2+5	4G		1	error (CLIERR)
##   offset2+5	50		1	success		A2LNOPCE1	# 0x50 -- P
##   offset2+6	0		1	success		A2LNOP
##
##   offset3	8		size3	success
##   offset4	5A		4	success		ZNSTANCE2      	#0x5A -- Z
##
##   offset5	69		1	success		iNSTANCE1	# 0x69 -- i
##   offset5+1	6A		1	success		ijSTANCE1	# 0x6A -- j
##   offset5+2	6b		1	success		ijkTANCE1	# 0x6B -- k
##   offset5+3	6c		1	success		ijklANCE1	# 0x6C -- l
##   offset5+4	0x6d		1	success		ijklmNCE1	# 0x4D -- m
##   offset5+5	0x6e		1	success		ijklmnCE1	# 0x4D -- m
##   offset5+6	0		1	success		ijklmn
##
##   offset6	0		size6	success
##
##   Note: Some of the values above (either -value, -size, or expected result) might change when the implementation is
##   completed. We'll modify the table above in that case.

echo "Changing the offset $offset2"
echo ""
set offx = $offset2 ; set isadd = 1
foreach valuex (41 32 32 4B 4C 4D 4E 4F 4F 4G 50 0)
	$MUPIP replicate -edit -change -offset=$offx -size=1 -value=$valuex mumps.repl
	$MUPIP replicate -editinstance -show -detail mumps.repl |& $grep "^0x00000$offset2"
	if ("1" == "$isadd") then
		set offx = `echo "obase=16; ibase=16; $offx + 1 " | bc`
		set isadd = 0
	else
		set isadd = 1
	endif
end
echo ""
$MUPIP replic -edit -change -offset=$offset3  -size=$size3 -value=8 mumps.repl
$MUPIP replic -edit -change -offset=$offset4  -size=1 -value=5A mumps.repl
$MUPIP replicate -editinstance -show -detail mumps.repl |& $grep "^0x00000$offset4"
echo ""

echo "Changing the offset $offset5"
echo ""
set offx = $offset5
foreach valuex (69 6A 6B 6C 6D 6E 0)
	$MUPIP replic -edit -change -offset=$offx -size=1 -value=$valuex mumps.repl
	$MUPIP replicate -editinstance -show -detail mumps.repl |& $grep "^0x000000$offset5"
	set offx = `echo "obase=16; ibase=16; $offx + 1 " | bc`
end
$MUPIP replic -edit -change -offset=$offset6  -size=$size6 -value=1 mumps.repl

##   $gtm_tst/com/view_instancefiles.csh -diff -instance INST1 -detail
##   	--> verify the only differences are the ones made in the above step.
##

$gtm_tst/com/view_instancefiles.csh -diff -instance INST1 -detail
# INST3 and INST4 receiver server were never "officially" started in the test. So, there isn't any mumps.repl file available in
# these instances. If $gtm_custom_errors is set, then the INTEG on INST3 and INST4 will error out with FTOKERR/ENO2. To avoid this,
# unsetenv gtm_custom_errors.
unsetenv gtm_custom_errors
# For multihost tests, setting it in the environment is not enough. So, create unsetenv_individual.csh and send it to INST{3,4}
# which gets sourced by remote_getenv.csh.
echo "unsetenv gtm_custom_errors" >&! unsetenv_individual.csh
$MSR RUN SRC=INST1 RCV=INST3 '$gtm_tst/com/cp_remote_file.csh __SRC_DIR__/unsetenv_individual.csh _REMOTEINFO___RCV_DIR__/'	\
					>&! transfer_unsetenv_individual_inst3.out
$MSR RUN SRC=INST1 RCV=INST4 '$gtm_tst/com/cp_remote_file.csh __SRC_DIR__/unsetenv_individual.csh _REMOTEINFO___RCV_DIR__/'	\
					>&! transfer_unsetenv_individual_inst4.out
$gtm_tst/com/dbcheck.csh -extract INST1 INST2
## =====================================================================
