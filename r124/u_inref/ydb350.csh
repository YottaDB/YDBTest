#################################################################
#								#
# Copyright (c) 2018 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
#
# Test that terminal has ECHO characteristics after READ or WRITE or direct-mode-read commands
#

# First prepare an external call (that does a "stty -a") to fetch terminal settings.
$gt_cc_compiler $gtt_cc_shl_options -I$gtm_tst/com -I$gtm_dist $gtm_tst/$tst/inref/ydb350_sttydisp.c
$gt_ld_shl_linker ${gt_ld_option_output}libydb350_sttydisp${gt_ld_shl_suffix} $gt_ld_shl_options ydb350_sttydisp.o $gt_ld_syslibs
setenv	GTMXC	ydb350_sttydisp.tab
echo "`pwd`/libydb350_sttydisp${gt_ld_shl_suffix}" > $GTMXC
cat >> $GTMXC << CAT_EOF
sttydisp:	void	ydb350_sttydisp()
CAT_EOF

# Turn on expect debugging using "-d". The debug output would be in expect.dbg in case needed to analyze stray timing failures.
(expect -d $gtm_tst/$tst/u_inref/ydb350.exp > expect.out) >& expect.dbg
if ($status) then
	echo "EXPECT-E-FAIL : expect returned non-zero exit status"
endif
mv expect.out expect.outx	# move .out to .outx to avoid -E- from being caught by test framework
perl $gtm_tst/com/expectsanitize.pl expect.outx > expect_sanitized.outx
cat expect_sanitized.outx
