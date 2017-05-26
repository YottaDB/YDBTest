#!/usr/local/bin/tcsh -f
#################################################################
#								#
#	Copyright 2010, 2013 Fidelity Information Services, Inc	#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
#

# Prevent random usage of V4 database
setenv gtm_test_mupip_set_version "disable"

@ rand = `$gtm_exe/mumps -run rand 2`
if ($rand) then
	setenv gtm_error_on_jnl_file_lost "1"
	set expected_jnl_state = "ON"
else
	set expected_jnl_state = "OFF"
endif

echo "Testing that callers of jnl_ensure_open() handle non-return success"
echo "On error, journaling should be $expected_jnl_state"

alias dump_file_header '$DSE dump -fileheader |& $grep -E "Journal State" | $grep -v $expected_jnl_state'
alias disable_wb 'unsetenv gtm_white_box_test_case_enable'
alias enable_wb 'setenv gtm_white_box_test_case_enable 1'
alias enable_jnl '$MUPIP set -journal=disable -file mumps.dat >&/dev/null ; rm mumps.mjl* >& /dev/null ; $MUPIP set -journal=enable,before -file mumps.dat'

setenv gtm_white_box_test_case_number 43
setenv gtm_white_box_test_case_count 1

setenv gtmgbldir "mumps.gld"

$gtm_tst/com/dbcreate.csh mumps

echo "** Testing for sr_port/desired_db_format_set.c"
enable_jnl
enable_wb
$MUPIP set -file -version=V4 mumps.dat >& desired_db_format_set.output
disable_wb
if ("ON" == "$expected_jnl_state") then
	set expected_db_format = "V5"
else
	set expected_db_format = "V4"
endif
$DSE dump -file |& $grep "Desired DB Format" | $grep -v $expected_db_format
dump_file_header

echo "** Testing for sr_unix/gdsfilext.c"
enable_jnl
enable_wb
$MUPIP extend DEFAULT >& gdsfilext.output
disable_wb
dump_file_header

echo "** Testing for sr_unix/set_jnl_file_close.c"
setenv gtm_white_box_test_case_count 2
enable_jnl
$gtm_exe/mumps -run %XCMD 'set ^a=1  zsystem "setenv gtm_white_box_test_case_enable 1; $MUPIP backup -online -newjnlfiles DEFAULT bak_set_jnl_file_close"' >& set_jnl_file_close.output
dump_file_header
setenv gtm_white_box_test_case_count 1

echo "** Testing for sr_unix/wcs_flu.c"
enable_jnl
$gtm_exe/mumps -run %XCMD 'set ^a=1  zsystem "setenv gtm_white_box_test_case_enable 1; $MUPIP backup -online -newjnlfiles DEFAULT bak_wcs_flu"' >& wcs_flu.output

echo "** Testing for sr_port/dse_simulate_t_end.c"
enable_jnl
enable_wb
$DSE maps -restore_all >& dse_simulate_t_end.output
disable_wb
dump_file_header

echo "** Testing for sr_port/gdsfhead.h"
enable_jnl
enable_wb
$gtm_exe/mumps -run %XCMD 'view "FLUSH"' >& gdsfhead.output
disable_wb
dump_file_header

echo "** Testing for sr_port/t_end.c"
enable_jnl
enable_wb
$gtm_exe/mumps -run %XCMD 'set ^a=1' >& t_end.output
disable_wb
dump_file_header

echo "** Testing for sr_port/wcs_recover.c"
enable_jnl
enable_wb
$DSE << EOF >& wcs_recover.output
crit -seize
crit -remove
EOF
disable_wb
dump_file_header

echo "** Testing for sr_port/op_view.c"
enable_jnl
enable_wb
$gtm_exe/mumps -run %XCMD 'view "JNLFLUSH"' >& op_view.output
disable_wb
dump_file_header

echo "** Testing for sr_unix/gds_rundown.c"
enable_jnl
enable_wb
setenv gtm_white_box_test_case_count 2
$gtm_exe/mumps -run %XCMD 'set $etrap="QUIT"  set ^a=1' >& gds_rundown.output
setenv gtm_white_box_test_case_count 1
disable_wb
dump_file_header

echo "** Testing for sr_port/op_ztcommit.c"
enable_jnl
enable_wb
setenv gtm_white_box_test_case_count 3
$gtm_exe/mumps -run %XCMD 'ztstart  set ^a=1  ztcommit' >& op_ztcommit.output
setenv gtm_white_box_test_case_count 1
disable_wb
dump_file_header

echo "** Testing for sr_port/tp_tend.c"
enable_jnl
enable_wb
$gtm_exe/mumps -run %XCMD 'tstart  set ^a=1  tcommit' >& tp_tend.output
disable_wb
dump_file_header

echo "** Testing for sr_unix/jnl_file_extend.c"
$MUPIP set -journal=disable -file mumps.dat >&/dev/null
rm mumps.mjl* >& /dev/null
$MUPIP set -journal="enable,before,allocation=4096,autoswitchlimit=4096,extension=8192" -file mumps.dat
enable_wb
setenv gtm_white_box_test_case_count 28367
$gtm_exe/mumps -run %XCMD 'for i=1:1:35000 set ^a=i'
disable_wb
dump_file_header
$MUPIP set -journal=disable -file mumps.dat >&/dev/null
rm mumps.mjl* >& /dev/null
$MUPIP set -journal="enable,before,allocation=4096,autoswitchlimit=4096,extension=8192" -file mumps.dat
enable_wb
setenv gtm_white_box_test_case_count 28369
$gtm_exe/mumps -run %XCMD 'for i=1:1:35000 set ^a=i'
disable_wb
setenv gtm_white_box_test_case_count 1
dump_file_header

echo "** Testing for sr_port/mur_output_record.c"
enable_jnl
# The kill -9 done below can hit the process at the midst of wcs_wtstart in which case the # of dirty buffer and the active queue
# will be out-of-sync in the shared memory. This would result in the subsequent journal recovery to assert fail in wcs_flu. To
# workaround the assert, white box test case 29 (WBTEST_CRASH_SHUTDOWN_EXPECTED) needs to be defined. However, the test already
# defines WBTEST_JNL_FILE_OPEN_FAIL. So, do a 'dse buff' to ensure all the dirty buffers are written to disk before proceeding with
# the kill -9. This way the shared memory information will be in sync with respect to the dirty buffers and active queue.
$GTM << EOF
set ^a=1
zsystem "$gtm_exe/dse buff >&! dsebuff.out"
zsystem "$kill9 "_\$job
EOF
enable_wb
setenv gtm_white_box_test_case_count 2
$MUPIP journal -recover -backward mumps.mjl >& mur_output_record.output
setenv gtm_white_box_test_case_count 1
disable_wb
$MUPIP rundown -file mumps.dat
$MUPIP journal -recover -backward mumps.mjl >& mur_output_record_good.output
dump_file_header

$gtm_tst/com/dbcheck.csh -noonline
