#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2026 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################

echo "#-----------------------------------------------------------------------------------------------#"
echo '# [#947] $ZEOF works correctly for files which are soft links to files in the /proc file system #'
echo "#-----------------------------------------------------------------------------------------------#"
echo


echo "## Run [wc -l /etc/mtab]"
wc -l /etc/mtab >&! wc.out
cat wc.out
set lines = `cat wc.out | cut -f 1 -d ' '`
echo "## Run [ydb1228.m] routine"
$ydb_dist/yottadb -r ydb1228 $lines
