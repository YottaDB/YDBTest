#################################################################
#								#
# Copyright (c) 2023 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
unsetenv gtm_trace_gbl_name	# We already enable trace and don't want to deal with 'trace already on'
setenv gtm_test_disable_trace_gbl # .. errors when THIS test turns tracing on. We need it when we need it.
echo '# GTM-4814 Verify M-profiling (VIEW "TRACE") restored after ZSTEP'
echo '#'
echo '# Release note:'
echo '#'
echo '# GT.M restores TRACE operation (M-Profiling) after ZSTEP operations. However, issuing a'
echo '# VIEW "[NO]TRACE" may interfere with ZSTEP operations. Note that using ZSTEP materially'
echo '# impacts M-Profiling times, so using these two facilities together may be problematic.'
echo '# Previously, ZSTEP usage usually turned off M-Profiling. (GTM-4814)'
echo '#'
echo
echo '# Create database'
$gtm_tst/com/dbcreate.csh mumps 1
echo
echo '# Drive ^gtm4814 to generate trace with embedded ZSTEP commands'
$gtm_dist/mumps -run gtm4814 <<EOF
zstep
zstep
zstep
zcontinue
EOF
echo
echo '# This next test turns things around. It starts with a break and some direct mode ZSTEP commands, then'
echo '# enables tracing while continuing to ZSTEP and see if it interfers with the ZSTEPs. Do this again'
echo '# when we stop tracing to see if that inteferes with orderly ZSTEPs. What we expect to see is interference'
echo '# from the trace being started that prevents subsequent ZSTEPs from working. We proceed as if a ZCONTINUE'
echo '# had been done.'
$gtm_dist/mumps -run gtm4814B^gtm4814 <<EOF
zstep
zstep
zstep
zstep
zstep
zstep
zstep
zstep
zstep
zstep
zstep
zcontinue
EOF
echo
echo '# Validate DB'
$gtm_tst/com/dbcheck.csh
