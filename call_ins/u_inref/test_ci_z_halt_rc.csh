#################################################################
#								#
# Copyright (c) 2017-2021 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.                                          #
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
#
# Test conditions:
#   1. C main routine does call-in to routine that expects a return value (test both int and string returns)
#   2. Test various types of exits the routine does:
#        a. HALT but caller expects a return value.
#        b. ZHALT with return value which should be returned to caller.
#        c. ZGOTO 0 but caller expects a return value.
#        d. QUIT no return value when one is expected (expect QUITARGREQD error).
#        e. QUIT with a return value when one is NOT expected (expect NOTEXTRINSIC error).
#   3. Test call-in to routine supplying args when none are expected (expect FMLLSTMISSING error).
#

#
# Define the set of call-in routines we are testing. Note we define entries for testcizhaltrcint() and
# testcizhaltrcstr() twice - once with one arg (which we expect to work) and once with 2 args which we
# expect to fail.
#
setenv GTMCI testcizhaltrc.xc
cat >> $GTMCI << EOF
testcizhaltrcint:         ydb_int_t    *testcizhaltrcint^testcizhaltrc(I:ydb_int_t)
testcizhaltrcstr:         ydb_string_t *testcizhaltrcstr^testcizhaltrc(I:ydb_int_t)
testcizhaltnoargs:        ydb_int_t    *testcizhaltnoargs^testcizhaltrc(I:ydb_int_t)
testcizhalt2manyargsint:  ydb_int_t    *testcizhaltrcint^testcizhaltrc(I:ydb_int_t, I:ydb_int_t)
testcizhalt2manyargsstr:  ydb_string_t *testcizhaltrcstr^testcizhaltrc(I:ydb_int_t, I:ydb_int_t)
testcizhaltnoretv:        void          testcizhaltnoretval^testcizhaltrc(I:ydb_int_t)
testzhaltnonbytenumbers:  void          testzhaltnonbytenumbers^testcizhaltrc(I:ydb_int_t)
EOF

# Copy C program containing various "ydb_ci()" calls. Error return values are expected to be negative here.
cp $gtm_tst/$tst/inref/testcizhaltrcmain.c ydb_ci.c
# Create similar C program using "gtm_ci()" calls instead. Error return values are expected to be positive here.
sed 's/ydb_ci/gtm_ci/g;s/libyottadb.h"/&\n#include "gtmxc_types.h"/;' ydb_ci.c > gtm_ci.c

foreach file (gtm_ci ydb_ci)
	echo "# Compile/build C file : $file.c"
	$gt_cc_compiler $gtt_cc_shl_options $file.c -I$gtm_dist
	$gt_ld_linker $gt_ld_option_output $file $gt_ld_options_common $file.o $gt_ld_sysrtns $ci_ldpath$gtm_dist -L$gtm_dist $tst_ld_yottadb $gt_ld_syslibs >& link.map
	if (0 != $status) then
		cat link.map
	endif
	echo "# Run executable : `pwd`/$file"
	`pwd`/$file
end
#
echo "End of test_ci_z_halt_rc subtest"
