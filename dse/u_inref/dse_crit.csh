#################################################################
#								#
# Copyright (c) 2002, 2015 Fidelity National Information	#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
# Test dse -crit

echo '# Disable JFO because it causes crit contention between the source server and the DSE process <dse_jfo_holds_crit>' >> settings.csh
setenv gtm_test_jnlfileonly 0
echo "setenv gtm_test_jnlfileonly 0" >> settings.csh
unsetenv gtm_test_jnlpool_sync
echo "unsetenv gtm_test_jnlpool_sync" >> settings.csh

set dse_awkfile=$gtm_tst/$tst/u_inref/awkfile.awk #BYPASSOK
$tst_tcsh $gtm_tst/$tst/u_inref/crit.csh  >&! crit_proc_spec
$tst_awk -f $dse_awkfile crit_proc_spec
unset dse_awkfile
