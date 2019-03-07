#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2002-2016 Fidelity National Information		#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
#								#
# Copyright (c) 2017-2018 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
#
# test multiple regions after a kill
if (-f $gtm_tst/$tst/inref/tptest0.gde) then
        setenv test_specific_gde $gtm_tst/$tst/inref/tptest0.gde
endif
setenv sub_test multireg1
setenv gtm_test_sprgde_id ${sub_test}	# to differentiate multiple dbcreates done in the same subtest
$gtm_tst/com/dbcreate.csh . 2

$GTM << GTM_EOF
w "do ^tptest0",! do ^tptest0
h
GTM_EOF
$gtm_tst/com/dbcheck.csh -extract

# 	test multiple regions with restarts
\rm $tst_working_dir/*.gld
\rm $tst_working_dir/*.dat
if (-f $gtm_tst/$tst/inref/tptest1.gde) then
        setenv test_specific_gde $gtm_tst/$tst/inref/tptest1.gde
endif
setenv sub_test multireg2
setenv gtm_test_sprgde_id ${sub_test}	# to differentiate multiple dbcreates done in the same subtest
$gtm_tst/com/dbcreate.csh . 2

$GTM << GTM_EOF
w "do ^tptest1",! do ^tptest1
h
GTM_EOF
$gtm_tst/com/dbcheck.csh -extract

#	test multiple regions with rollbacks
\rm $tst_working_dir/*.gld
\rm $tst_working_dir/*.dat
if (-f $gtm_tst/$tst/inref/tptest2.gde) then
        setenv test_specific_gde $gtm_tst/$tst/inref/tptest2.gde
endif
setenv sub_test multireg3
setenv gtm_test_sprgde_id ${sub_test}	# to differentiate multiple dbcreates done in the same subtest
$gtm_tst/com/dbcreate.csh . 2

$GTM << GTM_EOF
w "do ^tptest2",! do ^tptest2
h
GTM_EOF
$gtm_tst/com/dbcheck.csh -extract

#	test multiple regions with rollbacks
\rm $tst_working_dir/*.gld
\rm $tst_working_dir/*.dat
if (-f $gtm_tst/$tst/inref/tptest3.gde) then
        setenv test_specific_gde $gtm_tst/$tst/inref/tptest3.gde
endif
setenv sub_test multireg4
setenv gtm_test_sprgde_id ${sub_test}	# to differentiate multiple dbcreates done in the same subtest
$gtm_tst/com/dbcreate.csh . 3

$GTM << GTM_EOF
w "do ^tptest3",! do ^tptest3
h
GTM_EOF
$gtm_tst/com/dbcheck.csh -extract
unsetenv test_specific_gde

#	test kills, followed by a rollback, followed by non-tp sets
setenv sub_test tptest4
setenv gtm_test_sprgde_id ${sub_test}	# to differentiate multiple dbcreates done in the same subtest
$gtm_tst/com/dbcreate.csh mumps . 255 500 1024 500 128
$GTM << GTM_EOF
w "do ^tptest4",! do ^tptest4
h
GTM_EOF
$gtm_tst/com/dbcheck.csh -extract
unsetenv sub_test

#	test kills, followed by a rollback, followed by non-tp sets
setenv sub_test tptest5
setenv gtm_test_sprgde_id ${sub_test}	# to differentiate multiple dbcreates done in the same subtest
$gtm_tst/com/dbcreate.csh mumps . 255 500 1024 500 64
$GTM << GTM_EOF
w "do ^tptest5",! do ^tptest5
h
GTM_EOF
$gtm_tst/com/dbcheck.csh -extract
unsetenv sub_test

#	test a transaction that updates more than 13 blocks in a bitmap
setenv sub_test tptestj
setenv gtm_test_sprgde_id ${sub_test}	# to differentiate multiple dbcreates done in the same subtest
$gtm_tst/com/dbcreate.csh mumps . 255 1000 1024 50 1024
$GTM << GTM_EOF
w "do ^tptestj",! do ^tptestj
h
GTM_EOF
$gtm_tst/com/dbcheck.csh -extract
unsetenv sub_test

#	test a transaction that updates more than half the buffers
setenv sub_test tptestk
setenv gtm_test_sprgde_id ${sub_test}	# to differentiate multiple dbcreates done in the same subtest
$gtm_tst/com/dbcreate.csh mumps . 255 1000 1024 500 64
# for dbg build, this will print a dummy PASS.
if ("dbg" == $tst_image) then
	#this is DUMMY output
	echo ""
	echo "YDB>"
	echo "do ^tptestk"
	echo ""
	echo "Caution: Database Block Certification Has Been Enabled"
	echo ""
	echo "PASS from tptestk"
	echo "YDB>"
else
	$GTM << GTM_EOF
	w "do ^tptestk",! do ^tptestk
	h
GTM_EOF
endif
$gtm_tst/com/dbcheck.csh -extract
unsetenv sub_test

#	test a transaction that does kills and rollbacks
setenv sub_test tptestl
setenv gtm_test_sprgde_id ${sub_test}	# to differentiate multiple dbcreates done in the same subtest
$gtm_tst/com/dbcreate.csh mumps . 255 1000 1024 50 64
$GTM << GTM_EOF
w "do ^tptestl",! do ^tptestl
h
GTM_EOF
$gtm_tst/com/dbcheck.csh -extract
unsetenv sub_test

#	test a transaction that does kills and rollbacks
setenv sub_test tptestm
setenv gtm_test_sprgde_id ${sub_test}	# to differentiate multiple dbcreates done in the same subtest
$gtm_tst/com/dbcreate.csh mumps . 255 1000 1024 50 64
$GTM << GTM_EOF
w "do ^tptestm",! d ^tptestm
h
GTM_EOF
$gtm_tst/com/dbcheck.csh -extract
unsetenv sub_test

#	test a transaction split an index to the right with an existing chain
setenv sub_test tptestn
setenv gtm_test_sprgde_id ${sub_test}	# to differentiate multiple dbcreates done in the same subtest
$gtm_tst/com/dbcreate.csh mumps . 255 500 1024 50 1024
$GTM << GTM_EOF
w "do ^tptestn",! do ^tptestn
h
GTM_EOF
$gtm_tst/com/dbcheck.csh -extract
unsetenv sub_test

#	test a transaction split an index to the left with an existing chain
setenv sub_test tptesto
setenv gtm_test_sprgde_id ${sub_test}	# to differentiate multiple dbcreates done in the same subtest
$gtm_tst/com/dbcreate.csh mumps . 255 500 1024 50 1024
$GTM << GTM_EOF
w "do ^tptesto",! do ^tptesto
h
GTM_EOF
$gtm_tst/com/dbcheck.csh -extract
unsetenv sub_test

#	test a transaction split an index to the left with an existing chain
setenv sub_test tptestp
setenv gtm_test_sprgde_id ${sub_test}	# to differentiate multiple dbcreates done in the same subtest
$gtm_tst/com/dbcreate.csh mumps . 255 500 1024 50 1024
$GTM << GTM_EOF
w "do ^tptestp",! do ^tptestp
h
GTM_EOF
$gtm_tst/com/dbcheck.csh -extract
unsetenv sub_test

#	test a transaction split an index to the left with an existing chain
setenv sub_test tptestq
setenv gtm_test_sprgde_id ${sub_test}	# to differentiate multiple dbcreates done in the same subtest
$gtm_tst/com/dbcreate.csh mumps . 255 500 1024 50 1024
$GTM << GTM_EOF
w "do ^tptestq",! do ^tptestq
h
GTM_EOF
$gtm_tst/com/dbcheck.csh -extract
unsetenv sub_test

#	test that creates a root, kills it and recreates it
setenv sub_test tptestr
setenv gtm_test_sprgde_id ${sub_test}	# to differentiate multiple dbcreates done in the same subtest
$gtm_tst/com/dbcreate.csh mumps . 255 500 1024 50 1024
$GTM << GTM_EOF
w "do ^tptestr",! do ^tptestr
h
GTM_EOF
$gtm_tst/com/dbcheck.csh -extract
unsetenv sub_test

#	test a transaction creating, destroying and recreating index blocks
setenv sub_test tptests
setenv gtm_test_sprgde_id ${sub_test}	# to differentiate multiple dbcreates done in the same subtest
$gtm_tst/com/dbcreate.csh mumps . 255 500 1024 50 1024
$GTM << GTM_EOF
w "do ^tptests",! do ^tptests
h
GTM_EOF
$gtm_tst/com/dbcheck.csh -extract
unsetenv sub_test

#	test a transaction split an index to the left with an existing chain
setenv sub_test tptestt
setenv gtm_test_sprgde_id ${sub_test}	# to differentiate multiple dbcreates done in the same subtest
$gtm_tst/com/dbcreate.csh mumps . 255 500 1024 50 1024
$GTM << GTM_EOF
w "do ^tptestt",! do ^tptestt
h
GTM_EOF
$gtm_tst/com/dbcheck.csh -extract
unsetenv sub_test

#	test a transaction that creates index blocks and then kill the right most
setenv sub_test tptestu
setenv gtm_test_sprgde_id ${sub_test}	# to differentiate multiple dbcreates done in the same subtest
$gtm_tst/com/dbcreate.csh mumps . 255 500 1024 50 1024
$GTM << GTM_EOF
w "do ^tptestu" do ^tptestu
h
GTM_EOF
$gtm_tst/com/dbcheck.csh -extract
unsetenv sub_test

#	test a transaction that creates index blocks and then kill the middle
setenv sub_test tptestv
setenv gtm_test_sprgde_id ${sub_test}	# to differentiate multiple dbcreates done in the same subtest
$gtm_tst/com/dbcreate.csh mumps . 255 500 1024 50 1024
$GTM << GTM_EOF
w "do ^tptestv",! do ^tptestv
h
GTM_EOF
$gtm_tst/com/dbcheck.csh -extract
unsetenv sub_test

#	test a transaction that creates index blocks and then kills a pre-existing ancestor
setenv sub_test tptestw
setenv gtm_test_sprgde_id ${sub_test}	# to differentiate multiple dbcreates done in the same subtest
$gtm_tst/com/dbcreate.csh mumps . 255 500 1024 50 1024
$GTM << GTM_EOF
w "do ^tptestw",! do ^tptestw
h
GTM_EOF
$gtm_tst/com/dbcheck.csh -extract
unsetenv sub_test

#	test multiple regions with restarts
\rm $tst_working_dir/*.gld
\rm $tst_working_dir/*.dat
if (-f $gtm_tst/$tst/inref/tptesty.gde) then
        setenv test_specific_gde $gtm_tst/$tst/inref/tptesty.gde
endif
setenv sub_test tptesty
setenv gtm_test_sprgde_id ${sub_test}	# to differentiate multiple dbcreates done in the same subtest
$gtm_tst/com/dbcreate.csh . 2
$GTM << GTM_EOF
w "do ^tptesty",! do ^tptesty
h
GTM_EOF
$gtm_tst/com/dbcheck.csh -extract
unsetenv test_specific_gde

#	test of a case of kills in a transaction
setenv sub_test tptestz
setenv gtm_test_sprgde_id ${sub_test}	# to differentiate multiple dbcreates done in the same subtest
$gtm_tst/com/dbcreate.csh mumps . 255 500 1024 50 1024
$GTM << GTM_EOF
w "do ^tptestz",! do ^tptestz
h
GTM_EOF
$gtm_tst/com/dbcheck.csh -extract

# The below section tests ZTP which is no longer supported. And it fails asserts from V63002 onwards. Hence it is commented out.
# if(! $?test_replic) then
# 	\rm -f mumps.mjl
# 	setenv sub_test tpztsztc
# 	setenv gtm_test_sprgde_id ${sub_test}	# to differentiate multiple dbcreates done in the same subtest
# 	$gtm_tst/com/dbcreate.csh mumps
# 	if(! $?test_replic) $MUPIP set -file -journal=enable,on,before,file=mumps.mjl mumps.dat
# 	$GTM << GTM_EOF
# w "do ^tpztsztc",!  do ^tpztsztc
# h
# GTM_EOF
# 	$gtm_tst/com/dbcheck.csh -extract
# 	$grep "TEST FAILED" *.mjo*
# endif
#
