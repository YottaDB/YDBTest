#!/usr/local/bin/tcsh
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

# Switch ydb_chset env var to M mode
unsetenv ydb_chset
unsetenv gtm_chset

# Switch ydb_routines env var to M mode such that the same .m file can be run concurrently by processes
# in UTF-8 and M mode at the same time. This is needed by the "do ^sstepgbl" calls done in for example the
# io/diskfollow_timeout subtest. It is invoked from utffollowtimeout.m in UTF-8 mode and from utftimeoutinit.m in M mode.
# We do not want a INVOBJFILE error due to chset mismatch so switch the obj dir for the M mode process to a different directory.

mkdir -p chset_m_obj

setenv gtmroutines "chset_m_obj($gtm_tst/$tst/inref $gtm_tst/com .) $gtmroutines"
setenv ydb_routines "$gtmroutines"
