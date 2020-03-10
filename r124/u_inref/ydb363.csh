#!/usr/local/bin/tcsh -f
#################################################################
#                                                               #
# Copyright (c) 2020 YottaDB LLC and/or its subsidiaries.       #
# All rights reserved.                                          #
#                                                               #
#       This source code contains the intellectual property     #
#       of its copyright holder(s), and is made available       #
#       under a license.  If you do not know the terms of       #
#       the license, please stop and do not read further.       #
#                                                               #
#################################################################
#
echo "# Tests that YottaDB correctly issues NUMOFLOW errors for literal expressions whic contain large numeric values stored as strings."
echo "# Previously in some cases YottaDB would return potentially incorrect values."
echo ""

# Unset side effects and the boolean for ydb and gtm due to random test parameters.
source $gtm_tst/com/unset_ydb_env_var.csh ydb_side_effects gtm_side_effects
source $gtm_tst/com/unset_ydb_env_var.csh ydb_boolean gtm_boolean

echo "# Generate and compile each m file. Then run the m file in -run mode and -direct mode."
echo ""
echo "# Generate true.m for specific test cases."
echo "test()" >> true.m
echo '	write "true",!' >> true.m
echo "	quit 1" >> true.m
cat true.m
echo "-----------------------------------------------"
$ydb_dist/mumps -run gentestfiles $gtm_tst/$tst/inref/ydb363
# For loop for 0 and 1 boolean settings
foreach bool ( 0 1 )
	# For loop for each m test file
	source $gtm_tst/com/set_ydb_env_var_random.csh ydb_boolean gtm_boolean $bool
	echo "Running with boolean set to $bool"
	foreach subt ( tst*.m )
		echo "Subtest $subt"
		cat $subt
		echo "# Compile the m file"
		$ydb_dist/mumps $subt
		echo ""
		echo "# Run the m file using mumps -run"
		$ydb_dist/mumps -run $subt:r
		echo ""
		echo "# Compile/Run the m file using mumps -direct"
		$ydb_dist/mumps -direct < $subt
		echo "-----------------------------------------------"
	end
end
