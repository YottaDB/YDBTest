#!/usr/local/bin/tcsh
#################################################################
#								#
# Copyright (c) 2023 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################

#
# Note we need before image journaling in this test so the MUPIP REPLIC -SHOW -BACKWARD command
# we use in Test#7 below functions correctly as this command requires before image journaling.
#
setenv acc_meth BG			# Before image journaling does not work with MM mode
setenv gtm_test_jnl "SETJNL"		# Enable journaling so Test#7 is able to work
setenv tst_jnl_str "-journal=enable,on,before" # Make before image journaling the default
setenv ydb_msgprefix "GTM"		# So can run the test under GTM or YDB
$echoline
echo
echo '# gtm6952 - verify we can use decimal or hex (new) values in various parameters'
echo '#'
echo '# The places where the new routine cli_is_hex_explicit() was called were identified and a list'
echo '# of commands and the parameters that use this new routine were identified and are called below'
echo '# to test this support.'
echo
echo '# Setup MSR and run dbcreate'
echo
$MULTISITE_REPLIC_PREPARE 2
$gtm_tst/com/dbcreate.csh mumps >>& dbcreate_log.txt
if ($status) then
	echo 'DB create failed - output below - test terminated'
	cat dbcreate_log.txt
	exit 1
endif
echo
echo '### Test #1 - Start source and receiver services but start with large buffer size - specified in hex for the'
echo '#             source server and in decimal for the receiver server. This is testing calls to cli_get_int64()'
echo '#             that uses cli_is_hex_explicit().'
echo '#'
echo '# Begin by starting both links - Source server buffer size will be 0x100001000 while the receiver server buffer'
echo '# size will be the equivalent decimal value (4294971392).'
setenv gtm_test_jnlpool_buffsize 0x100001000 # Start primary source server with jnlpool size > 4GB
setenv tst_buffsize 4294971392               # Start receiver server with same size receive pool but in decimal
$MSR START INST1 INST2 RP >>& REPL_startup.log
get_msrtime
set repl_start_time = "$time_msr"
echo
echo "Primary startup command (buffsize should be 0x100001000):"
echo "     "`$grep "replic -source -start" SRC_${repl_start_time}.log | cut -d ' ' -f13`
echo
echo "Secondary startup command (buffsize should be 4294971392):"
echo "     "`$grep "replic -receiv -start" $SEC_DIR/RCVR_${repl_start_time}.log | cut -d ' ' -f13`
echo
$echoline
echo
echo '### Test #2 - Test call to cli_get_uint64() that it accepts both decimal and hex values for -decvalue option of DSE'
echo
echo '# -- Show current max_rec_size in fileheader'
$DSE d -f |& $grep "Maximum record size"
echo
echo '# -- Run DSE change -fileheader -decvalue=0xfd -decloc=48 to change the record size via -decloc/-decvalue'
$DSE change -f -decvalue=0xfd -decloc=48
echo
echo '# -- Show new max_rec_size in fileheader'
$DSE d -f |& $grep "Maximum record size"
echo
$echoline
echo
echo '### Test #3 - Test call to cli_get_int() that it accepts both decimal and hex values for -writes_per_flush option of DSE'
echo
echo '# -- Show current writes_per_flush in fileheader'
$DSE d -f |& $grep "No. of writes/flush" | cut -b 52-
echo
echo '# -- Run DSE change -fileheader -writes_per_flush=0xa'
$DSE change -fileheader -writes_per_flush=0xa
echo
echo '# -- Show new writes_per_flush in fileheader'
$DSE d -f |& $grep "No. of writes/flush" | cut -b 52-
echo
$echoline
echo
echo '### Test #4 - Test call from mupip_size() for the -HEURISTIC.LEVEL parameter in MUPIP SIZE. This test'
echo '#		    is testing another use of cli_is_hex_explicit() which if affirmative, drives STRTOL() with'
echo '#		    a base 16 arg instead of a base 10 arg. It is a unique use and one worth testing to make'
echo '#		    sure the hex value is accepted. Verify same output regardless of how value is specified.'
echo '#		    Note this works because of the 25K records loaded into the DB such that a level 2 DB index'
echo '#		    was created.'
echo
echo '# -- Add some records to the database'
$gtm_dist/mumps -run ^%XCMD 'for i=1:1:25000 set ^a(i)=$justify(i,54)'
echo
echo '# -- First run MUPIP size -heuristic="scan,level=0x2" (hex parm) and save output'
$MUPIP SIZE -heuristic="scan,level=0x2" -region=DEFAULT >& mupipsizehexlvl.txt
# We don't want both invocations to create errors and have the errors match so verify the return code of this command
# to make sure that is not the case (also guarantees a file mismatch).
set save_status = $status
if (0 != $save_status) then
    echo "Command failed rc = $save_status"
    echo "Command failed rc = $save_status" >> mupipsizehexlvl.txt
endif
echo
echo '# -- Now run MUPIP size -heuristic="scan,level=2" (dec parm) and save output'
$MUPIP SIZE -heuristic="scan,level=2" -region=DEFAULT >& mupipsizedeclvl.txt
echo
echo '# -- Compare outputs'
diff -bcw mupipsizehexlvl.txt mupipsizedeclvl.txt
if (0 == $status) then
    echo '** Output files are the same - PASS'
else
    echo '** Output files differ - fail'
endif
echo
$echoline
echo
echo 'The following MUPIP JOURNAL tests are not meant to accomplish anything important or even useful. They are intended'
echo 'only to force the syntax to be checked so we know the fields being tested with hexadecimal values (that used to be'
echo 'decimal-only values) are accepted. All of these tests are testing uses of cli_is_hex_explicit() in mur_get_options.c'
echo 'and testing the ability of these options to accept hexadecimal values when preceded by "0x". So if the command'
echo 'succeeds without a parsing error - the test passes.'
echo
$echoline
echo
echo '### Test #5 - Test -ID parameter from MUPIP JOURNAL'
echo
echo '# -- Run MUPIP journal -extract -id="0x3f29,0x8fffffff" -forward "*"'
$MUPIP journal -extract -id="0x3f29,0x8fffffff" -forward "*" >& jnlextr_id.log
set savestatus = $status
if (0 != $savestatus) then
    echo " ** FAIL - Command failed with rc = $savestatus"
else
    echo ' ** PASS'
endif
echo
$echoline
echo
echo '### Test #6 - Test -SEQNO parameter from MUPIP JOURNAL'
echo
echo '# -- Run MUPIP journal -show -seqno="0xffffffffffffffff" -forward "*"'
$MUPIP journal -show -seqno="0xffffffffffffffff" -forward "*" >& mupip_jnl_show.out
set savestatus = $status
if (0 != $savestatus) then
    echo " ** FAIL - Command failed with rc = $savestatus"
else
    echo ' ** PASS'
endif
$grep "%YDB-" mupip_jnl_show.out
echo
$echoline
echo
echo '### Test #7 - Test -LOOKBACK_LIMIT.OPERATIONS parameter from MUPIP JOURNAL -SHOW'
echo
echo '# -- Run MUPIP journal -show -lookback_limit="operations=0x300" -backward "*"'
$MUPIP journal -show -lookback_limit="operations=0x300" -backward "*" >& jnlshow_lookback.log
set savestatus = $status
if (0 != $savestatus) then
    echo " ** FAIL - Command failed with rc = $savestatus"
else
    echo ' ** PASS'
endif
echo
$echoline
echo
echo "# Run dbcheck.csh -extract to ensure db extract on primary matches secondary"
$gtm_tst/com/dbcheck.csh -extract
