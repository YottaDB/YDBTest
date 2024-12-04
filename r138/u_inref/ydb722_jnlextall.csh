#!/usr/local/bin/tcsh -f
#################################################################
#                                                               #
# Copyright (c) 2023-2024 YottaDB LLC and/or its subsidiaries.       #
# All rights reserved.                                          #
#                                                               #
#       This source code contains the intellectual property     #
#       of its copyright holder(s), and is made available       #
#       under a license.  If you do not know the terms of       #
#       the license, please stop and do not read further.       #
#                                                               #
#################################################################
#
# Helper script used by ydb722.csh to do a journal extract of INST1 and INST2 and display key portions of the extract output.
#
# $1 - caller test name (e.g. "test1" or "test2" etc.). This script does different steps based on the caller test name.
#
set testname = $1

foreach instance (INST1 INST2)
	set mjffile = ${testname}_$instance.mjf
	# Before taking journal extract, flush the journal buffer contents to disk or else the extract could be incomplete
	# Also, if the instance is frozen (possible if test framework randomly sets gtm_test_fake_enospc env var to 1),
	# the "mupip journal -extract" command would issue a "%YDB-W-DBCOLLREQ" warning which the test framework will later
	# catch and cause a test failure. So filter that out from the output before storing in jnlextall.out.
	$MSR RUN $instance 'set msr_dont_trace; $gtm_exe/mumps -run jnlflush^ydb722; $gtm_tst/com/jnlextall.csh mumps |& grep -v DBCOLLREQ >& jnlextall.out; $grep -E "SET|ZTRIG|LGTRIG|NULL|KILL|ZTWORM|TCOM" mumps.mjf' | grep -v '#t' | cut -b 24- > $mjffile
	switch ($testname)
	case "test1":
	case "test3":
	case "test4":
		echo "# Below is key journal record info in mumps.mjl on instance $instance"
		$tst_awk -F\\ -f $gtm_tst/$tst/u_inref/ydb722_jnlextall.awk $mjffile | sed 's/"[0-9]*,[0-9]*"/"$H"/g'
		breaksw
	case "test2":
		echo "# Below is list of SET journal records in mumps.mjl on instance $instance"
		$tst_awk -F\\ -f $gtm_tst/$tst/u_inref/ydb722_jnlextall.awk $mjffile | $grep "x[12](.)="
		breaksw
	case "test4":
	default:
		breaksw
	endsw
end

