#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2026 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################

echo "#-----------------------------------------------------------------------------------------------#"
echo "# [#1310] RECLOAD for a bad encryption handle index in a binary extract keeps its TEXT detail   #"
echo "#-----------------------------------------------------------------------------------------------#"
echo

# When MUPIP LOAD -FORMAT=BINARY finds a data block whose encryption handle index is outside the handles in the
# extract header, bin_load() issues RECLOAD followed by TEXT naming the expected range. That gtm_putmsg_csa() call
# passed the record number buffer once more after its length and address, so the consumption loop took that address
# as a message id and ERR_TEXT as its FAO count. The TEXT detail was replaced by an unrelated system message, and a
# Debug build failed "assert(0 == i)" in gtm_putmsg_list(). bin_load() forks a core before issuing the message, so
# one core file is expected either way.

setenv gtm_test_use_V6_DBs 0
setenv test_encryption ENCRYPT
source $gtm_tst/com/set_encrypt_env.csh $tst_general_dir $tst_ver $tst_image $tst_src >>! $tst_general_dir/set_encrypt_env.log
setenv acc_meth BG		# MM and encryption is not supported
setenv gtm_test_spanreg 0

echo '# Stage 1 : make an encrypted binary extract and give its first data block an out-of-range handle index'
echo '# Command : $gtm_tst/com/dbcreate.csh mumps'
$gtm_tst/com/dbcreate.csh mumps >&! dbcreate.out
if (0 == $status) then
	echo "PASS : the encrypted database was created"
else
	echo "WRONG : dbcreate.csh failed - see dbcreate.out"
	cat dbcreate.out
endif
echo '# Command : $gtm_exe/mumps -run %XCMD '"'"'for i=1:1:10 set ^a(i)=i'"'"
$gtm_exe/mumps -run %XCMD 'for i=1:1:10 set ^a(i)=i' >&! fill.out
echo '# Command : $MUPIP extract -format=binary extr.bin'
$MUPIP extract -format=binary extr.bin >&! extract.out
$grep -q 'RECORDSTAT, TOTAL:.*Key cnt: 10 ' extract.out
if (0 == $status) then
	echo "PASS : 10 records were extracted"
else
	echo "WRONG : the extract did not report 10 records - see extract.out"
	cat extract.out
endif
echo '# Command : perl $gtm_tst/$tst/inref/ydb1310_patch_handle.pl extr.bin 99'
perl $gtm_tst/$tst/inref/ydb1310_patch_handle.pl extr.bin 99 >&! patch.out
if (0 == $status) then
	echo "PASS : the handle index of the first data block is now 99"
else
	echo "WRONG : could not patch the extract - see patch.out"
	cat patch.out
endif
echo '# Command : $gtm_exe/mumps -run %XCMD '"'"'kill ^a'"'"
$gtm_exe/mumps -run %XCMD 'kill ^a' >&! kill.out
echo

echo '# Stage 2 : load the patched extract'
echo '# Command : $MUPIP load -format=binary extr.bin'
$MUPIP load -format=binary extr.bin >&! load.out
$grep '^%' load.out >&! load_msgs.logx
$tst_awk '(1 == NR) && /^%YDB-F-RECLOAD, Error loading record number: 2$/ {r++} (2 == NR) && /^%YDB-I-TEXT, Encryption handle expected in the range \[0; 1\) but found 99$/ {t++} END {exit !((2 == NR) && r && t)}' load_msgs.logx
if (0 == $status) then
	echo "PASS : MUPIP LOAD reported RECLOAD followed by TEXT with the expected handle range, and no other message"
else
	echo "WRONG : expected exactly RECLOAD then TEXT - see load.out"
	cat load_msgs.logx
endif
$gtm_tst/com/check_error_exist.csh load.out RECLOAD >&! check_load.logx
# bin_load() forks a core (and sends GVFAILCORE to the operator log) before it issues RECLOAD
set ncores = `ls -1 core* |& $grep -c '^core'`
if (1 == $ncores) then
	echo "PASS : the one core file that bin_load() forks was found"
else
	echo "WRONG : expected 1 core file, found $ncores"
endif
foreach corename (`ls -1 core* |& $grep '^core'`)
	mv $corename hidden_expected_core_$corename
end
echo

$gtm_tst/com/dbcheck.csh >&! dbcheck.out
if (0 == $status) then
	echo "PASS : dbcheck.csh found no integrity errors"
else
	echo "WRONG : dbcheck.csh failed - see dbcheck.out"
	cat dbcheck.out
endif
