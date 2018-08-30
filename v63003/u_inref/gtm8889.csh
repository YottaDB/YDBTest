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
#
#

echo "# Pressing Control C while in zhelp, would get an error in previous versions"
echo ""
echo "# Terminal Display:"
echo ""
# Setting prompt explicitly so we can run on previous GTM versions too (which default to "GTM>")
setenv gtm_prompt "YDB>"
(expect -d $gtm_tst/$tst/u_inref/gtm8889.exp > expect.outx) >& expect.dbg
if ($status) then
	echo "EXPECT Failed"
endif
perl $gtm_tst/com/expectsanitize.pl expect.outx > expect_sanitized.outx
# We have seen occasional test failures (on slower systems particularly when they are loaded) where
# Line 2 below (containing just "YDB>") additionally shows up in the output.
# ------------------
# 1 : Topic?
# 2 : YDB>
# 3 : YDB>halt
# ------------------
# It is not clear why that shows up but that is not important for this test (which is to ensure there is no error
# after pressing Ctrl-C) so we remove lines containing just "YDB>" in the grep below.
#
$grep -vE '^$|^YDB>$' expect_sanitized.outx
