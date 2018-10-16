#!/usr/local/bin/tcsh -f
#################################################################
#                                                               #
# Copyright (c) 2018 YottaDB LLC. and/or its subsidiaries.      #
# All rights reserved.                                          #
#                                                               #
#       This source code contains the intellectual property     #
#       of its copyright holder(s), and is made available       #
#       under a license.  If you do not know the terms of       #
#       the license, please stop and do not read further.       #
#                                                               #
#################################################################
#
echo "--------------------------------------------------------------------------------------------------------------------"
echo 'Release Note: The GT.M compiler -NOWARNING qualifier for the MUMPS command and $ZCOMPILE suppresses warning messages'
echo 'for BADCHAR, BLKTOODEEP, and LITNONGRAPH; previously it did not. (GTM-8956)'
echo "--------------------------------------------------------------------------------------------------------------------"
echo "# Test that the GT.M compiler -NOWARNING qualifier supresses BADCHAR, BLKTOODEEP, and LITNOGRAPH warning messages."
echo ""
foreach mode (UTF-8 M)
	echo "# Test in $mode Mode"
	if ( "$mode" == "UTF-8" ) then
		echo "# UTF-8 mode should expect a BADCHAR, BLKTOODEEP, and LITNONGRAPH error."
	else
		echo "# M mode should expect BLKTOODEEP and LITNONGRAPH errors."
	endif

	# Compile env vars are unset to avoid complications from parent environment
	unsetenv ydb_compile
	unsetenv gtmcompile

	# Change ydb_chset mode to UTF-8 or M to test both cases
	source $gtm_tst/com/switch_chset.csh $mode

	echo "# Compile without -nowarning to obtain errors"
	$ydb_dist/mumps $gtm_tst/$tst/inref/gtm8956.m
	echo "--------------------------------------------------------------------------------------------------------------------"
	echo "# Compile with -nowarning, should not receive errors"
	$ydb_dist/mumps -nowarning $gtm_tst/$tst/inref/gtm8956.m
	echo "--------------------------------------------------------------------------------------------------------------------"
	echo '# Compile using ZCompile with $ZCompile set to obtain errors'
	$ydb_dist/mumps -direct << EOF
		SET \$ZCOMPILE=\$ZCOMPILE_" -warning"
		ZCOMPILE "$gtm_tst/$tst/inref/gtm8956.m"
EOF

	echo "--------------------------------------------------------------------------------------------------------------------"
	echo '# Compile using ZCompile with $ZCompile set to -nowarning, should not recieve errors'
	$ydb_dist/mumps -direct << EOF
		SET \$ZCOMPILE=\$ZCOMPILE_" -nowarning"
		ZCOMPILE "$gtm_tst/$tst/inref/gtm8956.m"
EOF

echo "--------------------------------------------------------------------------------------------------------------------"
echo ""
end
