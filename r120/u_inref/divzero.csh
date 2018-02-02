#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2018 YottaDB LLC. and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
#
$echoline
echo "# Test that division by zero issues DIVZERO error and not SIGINTDIV"
$echoline
#

# The positive numeric range covered by YottaDB is [1E-43, 9.999999999999999999E46]
# The negative numeric range covered by YottaDB is [-9.999999999999999999E46, -1E-43]
# Check division by zero for a wide range of representative values in this range

set mantissa = (1 9.999999999999999999)

foreach sign ("" "-")	# loop to go through positive and negative numbers
	# Cover exponent ranges 1E-42 thru 1E47
	@ exp = -42
	while ($exp < 48)
		foreach mant ($mantissa)
			set num = "${sign}${mant}E${exp}"
			echo "# Testing : 1/($num*0)"	# This tests that op_mul.c returns a result mval of 0 correctly
			$gtm_exe/mumps -run %XCMD 'set x='$num' write 1/(x*0)'
			echo "# Testing : 1/(($num*0)/$num)"	# This tests that op_div.c returns a result mval of 0 correctly
			$gtm_exe/mumps -run %XCMD 'set x='$num' write 1/((x*0)/x)'
			# Below cases do not test any fix specifically, but covers integer division possibilities too
			echo "# Testing : 1\(($num*0)/$num)"
			$gtm_exe/mumps -run %XCMD 'set x='$num' write 1\((x*0)/x)'
			echo "# Testing : 1/(($num*0)\$num)"
			$gtm_exe/mumps -run %XCMD 'set x='$num' write 1/((x*0)\x)'
			echo "# Testing : 1\(($num*0)\$num)"
			$gtm_exe/mumps -run %XCMD 'set x='$num' write 1\((x*0)\x)'
			@ exp = $exp + 1
		end
	end
end

echo ""
$echoline
echo "# Test a few more specific cases"
$echoline
cat > specific_tests.txt << CAT_EOF
((10**(-N2))*N1)**(-2)
1/((10**(1-N1))*N1)
1/(((1/10)**N2)*N1)
1/(((1/10)**N1)*N2)
1/(((1/N1)**N1)*N1)
1/(((1/N1)**N2)*N1)
1/(((1/N1)**N1)*N2)
1/(((1/N1)**N2)*N2)
1/(((1/N2)**N1)*N1)
1/(((1/N2)**N2)*N1)
1/(((1/N2)**N1)*N2)
1/(((1/N2)**N2)*N2)
1/(((10/N1)**10)*N1)
1/(((10/N2)**10)*N1)
1/(((10/N1)**10)*N2)
1/(((10/N2)**10)*N2)
1/(((10/N1)**2)*N1)
1/(((10/N2)**2)*N1)
1/(((10/N1)**2)*N2)
1/(((10/N2)**2)*N2)
1/(((10/N1)**N1)*N1)
1/(((10/N2)**N1)*N1)
1/(((10/N1)**N1)*N2)
1/(((10/N2)**N1)*N2)
1/(((10/N1)**N2)*N1)
1/(((10/N2)**N2)*N1)
1/(((10/N1)**N2)*N2)
1/(((10/N2)**N2)*N2)
1/(((2/10)**N1)*N1)
1/(((2/N1)**10)*N1)
CAT_EOF

foreach expr (`cat specific_tests.txt`)
	echo "# Testing : $expr"
	$gtm_exe/mumps -run %XCMD 'set N1=26489595746075820900000000000000,N2=887952097261892.795 write '"$expr"
end
