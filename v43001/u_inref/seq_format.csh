#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2002-2016 Fidelity National Information		#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
# The awk scripts used to sort lost transactions on the seqno are no longer necessary, simple sort will do:
# mupip_rollback.csh -resync=<JNL_SEQNO> -lost=lostxn.log "*"
# sort -n -k6,6 -t\\ lostxn.log
#The above will work for UNIX. For VMS, the equivalent of sort (the 6th field) needs to be done.

# extract.awk needs the PINI records to create of list of PIDs to mask the actual PIDs found in the later logical records.
# However, in this test case we are dealing with lost and broken records which need not contain all the PINI records
# generated until now. This will cause some logical records to be left without their associated PINI records and hence the
# reference files will not match. To avoid this, pass 1 for maskpid to unconditionally mask the PID found in the logical
# records
# extract.awk is used to check .lost and .broken files in the source side. The stream seqno will be "0" for non-suppl instance and non-zero for suppl instance
set strm_seqno_zero = "TRUE"
if ((1 == $test_replic) && (2 == $test_replic_suppl_type)) then
	set strm_seqno_zero = "FALSE"
endif
if ((1 == $gtm_test_spanreg) || (3 == $gtm_test_spanreg)) then
	set colno = 0
	if ($?test_collation_no) then
		set colno = $test_collation_no
	endif
	setenv test_specific_gde $gtm_tst/$tst/inref/seq_format_col${colno}.sprgde
endif
setenv gtm_test_spanreg 0	# We have already pointed a spanning gld to test_specific_gde
alias check_mjf '$tst_awk -f $gtm_tst/mupjnl/inref/extract.awk -v "user=$USER" -v "host=$HOST:r:r:r" -v detail=1 -v maskpid=1 '"-v strm_seqno_zero=$strm_seqno_zero" '\!:*'

echo "Begin seq_format test..."
source $gtm_tst/com/dbcreate.csh mumps 3

echo "mtp TS ():Serial" >! mtp.m
echo "	for i=1:1:3 s (^x(i),^a(i),^b(i))=i" >> mtp.m
echo "	TC" >> mtp.m
$gtm_exe/mumps -run mtp
$gtm_exe/mumps -run mtp
$gtm_exe/mumps -run mtp
$gtm_exe/mumps -run jnlrec
$gtm_exe/mumps -run mtp
$gtm_tst/com/dbcheck.csh

# to ensure broken and lost files, extract separately:
$gtm_exe/mupip journal -forward -extract=mumps.extr mumps.mjl
$gtm_exe/mupip journal -forward -extract=a.extr a.mjl
$gtm_exe/mupip journal -forward -extract=b.extr b.mjl

cat *.lost *.broken > seq_format.out1

if ($?gtm_chset) then
	if ($gtm_chset == "UTF-8") then
		set numlines = `cat seq_format.out1 | $grep "UTF-8" | wc -l `
		if ($numlines != 6) then
			echo "Test fail in UTF-8 check"
		endif
		mv seq_format.out1 seq_format.out2
		cat seq_format.out2 | sed 's/ UTF-8//g' > seq_format.out1
	endif
endif

sort -n -k6,6 -t\\ seq_format.out1 > seq_format.out
# Mask off volatile journal record fields like nodeflags (different between trigger supporting and trigger non-supporting
# platforms), timestamp and pid. Since the PFIN and PINI records do not contain sequence numbers and the purpose of this
# test is to sort the journal records by sequence number, it is okay not to include the PINI and PFIN in the final output
check_mjf seq_format.out | $grep -v -E "^01|^02"

echo "End seq_format test."
