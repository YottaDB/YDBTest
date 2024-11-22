#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2017-2024 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
#
# Test of ydb_tp_st() function in the SimpleThreadAPI
#
$gtm_tst/com/dbcreate.csh mumps 1

if ($?gtm_test_trigger) then
	if ($gtm_test_trigger) then
		# ----------------------------------------------------------------------
		# If test framework has defined triggers, test those too with ydb_tp_st()
		# ----------------------------------------------------------------------
		#
		# Trigger file for tp1.c (to test TP + triggers with SimpleThreadAPI)
		set trgfile = tp1.trg
		cat > $trgfile << CAT_EOF
+^tp1 -command=set -xecute="set ^tp1lvtrig=\$ztval"
CAT_EOF
		$MUPIP trigger -noprompt -triggerfile=$trgfile >& $trgfile.out

		# Trigger file for tp2.c (to test TP + triggers with SimpleThreadAPI)
		set trgfile = tp2.trg
		cat > $trgfile << CAT_EOF
+^tp2 -command=set -xecute="set ^tp2trig(\$ztval)="""""
CAT_EOF
		$MUPIP trigger -noprompt -triggerfile=$trgfile >& $trgfile.out
	endif
endif

echo "Copy all C programs that need to be tested"
cp $gtm_tst/$tst/inref/{tp[0-9]*.c,glvnZWRITE.c} .

cat > tp.xc << CAT_EOF
driveZWRITE: void driveZWRITE(I:ydb_string_t *)
gvnZWRITE: void ^gvnZWRITE()
gvnincr2callin: void ^gvnincr2callin()
tp3preserveA: void A^tp3preserve(I:ydb_string_t *)
tp3preserveB: void B^tp3preserve()
CAT_EOF

setenv GTMCI tp.xc	# needed to invoke driveZWRITE.m from tp*.c below

cat > c2m2c.xc << CAT_EOF
`pwd`/libc2m2c.so
c2m2c: int c2m2c()
CAT_EOF

setenv GTMXC c2m2c.xc

# Compile c2m2c.c
set file = c2m2c.c
cp $gtm_tst/$tst/inref/$file .
set exefile = $file:r
$gt_cc_compiler $gtt_cc_shl_options -I$gtm_tst/com -I$gtm_dist -g $file
$gt_cc_compiler ${gt_ld_shl_options} ${gt_ld_option_output} libc2m2c.so $exefile.o


# Compile glvnZWRITE.c (needed by tp3_preservelvn.c)
set file = glvnZWRITE.c
set exefile = $file:r
$gt_cc_compiler $gtt_cc_shl_options -I$gtm_tst/com -I$gtm_dist -g $file

foreach file (tp*.c)
	if (("ENCRYPT" == "$test_encryption" ) && ("tp5_TPTIMEOUT.c" == $file)) then
		# This test checks for TPTIMEOUT happening within $zmaxtptime value of 1 second
		# But with -encrypt, database open takes more than a few seconds and causes failures.
		# So we disable this part of the test in case of -encrypt.
		continue
	endif
	echo " --> Running $file <---"
	set exefile = $file:r
	$gt_cc_compiler $gtt_cc_shl_options -I$gtm_tst/com -I$gtm_dist -g $file
	$gt_ld_linker $gt_ld_option_output $exefile $gt_ld_options_common $exefile.o glvnZWRITE.o $gt_ld_sysrtns $ci_ldpath$gtm_dist -L$gtm_dist $tst_ld_yottadb $gt_ld_syslibs >& $exefile.map
	if (0 != $status) then
		echo "TP-E-LINKFAIL : Linking $exefile failed. See $exefile.map for details"
		continue
	endif
	`pwd`/$exefile
	echo ""
end

$gtm_tst/com/dbcheck.csh
