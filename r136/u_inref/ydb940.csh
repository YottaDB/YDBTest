#################################################################
#								#
# Copyright (c) 2022 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################

echo '# Test $PRINCIPAL output device flush, if it is a terminal, happens on call-out from M to C'

echo "# Compile ydb940.c and make it a .so file"
set file="ydb940"
$gt_cc_compiler $gtt_cc_shl_options -I$gtm_tst/com -I$gtm_dist $gtm_tst/$tst/inref/$file.c
$gt_ld_shl_linker ${gt_ld_option_output}lib${file}${gt_ld_shl_suffix} $gt_ld_shl_options $file.o $gt_ld_syslibs

echo "# Set up the external call environment/files"
setenv GTMXC $file.tab
echo `pwd`"/lib${file}${gt_ld_shl_suffix}" > $GTMXC
cat >> $GTMXC << CAT_EOF
Part2printf: int $file()
CAT_EOF

echo "# Use expect to create a terminal"
echo "# And call M inside the terminal"
echo "# The M program does a write (Part1) to the terminal followed by the C external call which does a write (Part2)"
echo "# to the terminal as well. The M program then does one final write (Part3) to the terminal. We expect the parts"
echo "# to show up in that order. Without the YDB#940 code fixes, (Part2) used to show up before (Part1)."

# Turn on expect debugging using "-d". The debug output would be in expect.dbg in case needed to analyze stray timing failures.
(expect -d $gtm_tst/$tst/u_inref/$file.exp > expect.out) >& expect.dbg
if ($status) then
	echo "EXPECT-E-FAIL : expect returned non-zero exit status"
endif
mv expect.out expect.outx	# move .out to .outx to avoid -E- from being caught by test framework
perl $gtm_tst/com/expectsanitize.pl expect.outx > expect_sanitized.outx
cat expect_sanitized.outx

