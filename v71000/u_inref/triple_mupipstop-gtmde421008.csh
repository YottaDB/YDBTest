#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2025 YottaDB LLC and/or its subsidiaries.	#
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
$gtm_tst/com/dbcheck.csh >& dbcheck.log
