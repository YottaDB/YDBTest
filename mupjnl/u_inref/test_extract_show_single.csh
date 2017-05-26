#!/usr/local/bin/tcsh -f
#################################################################
#								#
#	Copyright 2003, 2014 Fidelity Information Services, Inc	#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
echo "TEST MUPIP JOURNAL -EXTRACT AND -SHOW SINGLE REGION"
#
# If run with journaling, this test requires BEFORE_IMAGE so set that unconditionally even if test was started with -jnl nobefore
source $gtm_tst/com/gtm_test_setbeforeimage.csh
#
setenv test_extract 1
setenv test_show 1
$gtm_tst/$tst/u_inref/mu_jnl_extract_show.csh 1 >& test_extract_show_single.outx
# Filter out some output
# ALIGN - align_size is randomly set by $cms_tools/do_test.csh - smaller align size might result in more ALIGN records
$grep -vE "MUJNLSTAT|NOPREVLINK|EPOCH|PBLK|ALIGN|End of Data|End Transaction" test_extract_show_single.outx
