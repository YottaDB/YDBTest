#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2019 YottaDB LLC and/or its subsidiaries.	#
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

echo '# Test that tls interface headers (*interface.h) are exposed in $ydb_dist'

echo '# ls for $ydb_dist/*interface.h. Should see 4 files'
ls $ydb_dist/*interface.h
if (0 != $status) then
	echo 'Could not find $ydb_dist/*interface.h'
endif

echo; echo '# ls for $ydb_dist/utf8/*interface.h. Should see 4 file'
ls $ydb_dist/utf8/*interface.h
if (0 != $status) then
	echo 'Could not find $ydb_dist/utf8/*interface.h'
endif

exit 0
