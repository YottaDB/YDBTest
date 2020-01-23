#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2020 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################

# Unset side effects and the boolean for ydb and gtm due to random test parameters.
source $gtm_tst/com/unset_ydb_env_var.csh ydb_side_effects gtm_side_effects
source $gtm_tst/com/unset_ydb_env_var.csh ydb_boolean gtm_boolean

echo "# Test that compiling boolean expressions involving side effects used in an integer context does not GTMASSERT if ydb_boolean=1"
cp $gtm_tst/$tst/inref/ydb554*.m .

foreach bool ( 0 1 )
	source $gtm_tst/com/set_ydb_env_var_random.csh ydb_boolean gtm_boolean $bool
	echo " --> Test with ydb_boolean env var set to $bool"
	foreach file (ydb554*.m)
		set basename = $file:r
		rm -f $basename.o	# remove .o file, if it exists, from a prior iteration
		echo -n "   -> Testing [yottadb -run $basename] : Expected output is 1 : Actual output is "
		$ydb_dist/yottadb -run $basename
	end
end
