#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2025-2026 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
# Note that the core file detection logic below is copied and revised from r130/u_inref/ydb534.csh

cat << CAT_EOF | sed 's/^/# /;'
********************************************************************************************
GTM-DE421008 - Test the following release note
********************************************************************************************

Original GT.M release note (from http://tinco.pair.com/bhaskar/gtm/doc/articles/GTM_V7.1-000_Release_Notes.html#GTM-DE421008):

MUPIP STOP three times within a minute logs the event to syslog and otherwise acts like a kill -9 by stopping a process at points that may not be safe, except that it may produce a core file; previously any three MUPIP STOPs over the life of a process acted like a kill -9 and produced no record of the event. (GTM-DE421008)

Revised YottaDB release note:

MUPIP STOP three times within a minute acts like a kill -9 by stopping a process at points that may not be safe, except that it may produce a core file; previously any three MUPIP STOPs over the life of a process acted like a kill -9. (GTM-DE421008)

CAT_EOF
echo ''

setenv ydb_msgprefix "GTM"
echo '# Run [dbcreate.csh] to create database'
$gtm_tst/com/dbcreate.csh mumps >& dbcreate.log
$gtm_dist/mumps -run gtmde421008^gtmde421008

# On an ASAN build, a process that MUPIP STOP terminates can core inside ASAN itself rather than in
# YottaDB code. The signal lands while ASAN is inside its own "free" interceptor, which allocates
# through DlSymAllocator, and ASAN responds by calling Die() and aborting:
#
#	#9  __sanitizer::Abort()
#	#10 __sanitizer::Die()
#	#11 __sanitizer::CombinedAllocator<...>::Allocate(...)
#	#12 __sanitizer::InternalAlloc(...)
#	#13 __sanitizer::DlSymAllocator<DlsymAlloc>::Allocate(...)
#	#14 __interceptor_free()
#
# YottaDB frames DO appear in such a core, at #0 and #2, but only as the signal handler reacting to
# the abort: every frame that led to it is ASAN's, and no YottaDB frame appears below them. So the
# core says nothing about the MUPIP STOP behaviour this subtest verifies.
#
# The test for it is the DlSymAllocator frame, not merely the presence of __sanitizer:: frames. An
# ASAN-DETECTED YottaDB bug - a heap buffer overflow, say - also unwinds through __sanitizer:: and
# __asan:: frames on its way to Die(), and hiding those would hide a real defect. DlSymAllocator is
# ASAN's own dlsym-time allocator, reached from its interceptors rather than from anything YottaDB
# asked for. If some other ASAN-internal abort shows up later it will fail the subtest, which is the
# right way round: a failure gets looked at, a hidden core does not.
source $gtm_tst/com/is_libyottadb_asan_enabled.csh	# sets gtm_test_libyottadb_asan_enabled
if ($gtm_test_libyottadb_asan_enabled) then
	foreach corefile (`find . -maxdepth 1 -name 'core*' -type f`)
		set coreexe = `file $corefile | tr ',' '\n' | $grep execfn | awk '{print $2}' | sed "s/'//g"`
		if (! -e "$coreexe") set coreexe = $gtm_dist/dse
		$gtm_tst/com/get_dbx_c_stack_trace.csh $corefile $coreexe >& $corefile:t.stack.outx
		$grep -q "DlSymAllocator" $corefile:t.stack.outx
		if (0 == $status) then
			mv $corefile hidden_expected_asan_core_$corefile:t
			# Record it in a .outx file: this is nondeterministic, so it must not reach the compared output
			echo "Hid an ASAN-internal core ($corefile:t): its stack has no YottaDB frame" >> asan_core_hidden.outx
		endif
	end
endif

$gtm_tst/com/dbcheck.csh >& dbcheck.log
