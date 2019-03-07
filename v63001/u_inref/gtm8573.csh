#!/usr/local/bin/tcsh -f
#################################################################
#                                                               #
# Copyright (c) 2018 YottaDB LLC and/or its subsidiaries.       #
# All rights reserved.                                          #
#                                                               #
#       This source code contains the intellectual property     #
#       of its copyright holder(s), and is made available       #
#       under a license.  If you do not know the terms of       #
#       the license, please stop and do not read further.       #
#                                                               #
#################################################################
#
echo "---------------------------------------------------------------------------------------------------------------------------"
echo " Release Note that is being tested:"
echo "---------------------------------------------------------------------------------------------------------------------------"
echo '(GTM-8573) : When the argument of an IF command is a literal value or expression, the GT.M compiler generates code to set'
echo '$TEST appropriately and ignores the rest of the line. When the argument of a command postconditional is a literal value or'
echo 'expression, the GT.M compiler evaluates the postconditional and either generates code for an unconditional command or omits'
echo 'generation for the command. Previously, the computation was performed at run time. Note that literal postconditionals '
echo 'evaluating to 0 result in smaller object modules than literal postconditionals evaluating to non-zero values.'
echo "---------------------------------------------------------------------------------------------------------------------------"
echo ""
echo "# Test that the GT.M compiler computes the IF condition or postconditional and appropriately ignores the remainder of the line."
echo ""
echo "# Each subtest will be compiled in mumps and print out the machine operations."
echo "# Without compiler optimization, there would be a dozen opcodes, but now there should be no more than four."
echo ""
echo "# Generate the subtest m files."
echo ""
$ydb_dist/mumps -run gentestfiles $gtm_tst/$tst/inref/gtm8573
foreach subt ( tst* )
	echo "Subtest $subt"
	cat $subt
	echo "# Running $subt subtest"
	echo "# Generate opcodes for $subt"
	$ydb_dist/mumps -machine -lis=$subt:r.lis $subt
	echo "# Display the opcodes."
	$ydb_dist/mumps -run LOOP^%XCMD --xec='/write:$zfind(%l,"OC_") $zpiece(%l,";",2),\!/' <$subt:r.lis
	echo ""
end
