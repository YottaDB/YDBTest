#################################################################
#								#
# Copyright (c) 2022 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################

echo '# Test that stat() errors in $ZROUTINES due to OBJECT directory permission issues print file name'
echo '## Set $zroutines = [/etc/ssl/private(/tmp)]. And then run [do ^dummy].'
echo '## Expecting [/etc/ssl/private/dummy.o] to show up in the %YDB-E-SYSCALL message below'
$ydb_dist/yottadb -run %XCMD 'set $zroutines="/etc/ssl/private(/tmp)" do ^dummy'

echo ''
echo '# Test that stat() errors in $ZROUTINES due to SOURCE directory permission issues print file name'
echo '## Set $zroutines = [.(./subdir)]. Create [./subdir/dummy.m].'
echo '## Remove execute permissions from [./subdir]. And then run [do ^dummy].'
echo '## Expecting [./subdir/dummy.m] to show up in the %YDB-E-SYSCALL message below'
rm -rf subdir
mkdir subdir
cd subdir; echo "" > dummy.m; cd ..
chmod -x ./subdir
$ydb_dist/yottadb -run %XCMD 'set $zroutines=".(./subdir)" do ^dummy'
chmod +x ./subdir

