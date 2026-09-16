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

# Nothing this script echoes may contain an error message in its %YDB-<severity>- form. com/errors.csh
# scans the subtest output for that shape and would fail the subtest on the very error being described,
# so the mnemonics below appear bare. The routine reports them the same way.

echo "#----------------------------------------------------------------------------------------------------#"
echo "# [YDB#1268] The stderr= device of a PIPE is readable even when the OPEN specifies writeonly          #"
echo "#----------------------------------------------------------------------------------------------------#"
echo
echo '# A PIPE OPENed with both writeonly and stderr="devname" produced a stderr device that could not be'
echo "# READ: the first READ got DEVICEWRITEONLY, Cannot read from a write-only device. So there was no way"
echo "# to ask for a command stderr without also taking its stdout, the workaround being to drop writeonly,"
echo "# which makes YottaDB create a stdout pipe that the application then has to discard."
echo "#"
echo "# sr_unix/iopi_open.c builds the stderr device and fixes its direction, setting read_only on it, but"
echo "# then opens it with the same deviceparameter list the caller gave the PIPE. sr_unix/iorm_use.c walked"
echo "# that list and set write_only on the stderr device too, and sr_unix/iorm_readfl.c refuses a READ from"
echo "# a write_only device."
echo "#"
echo "# The first assertion of stage 1 is the failing case. Its other two assertions, and stages 2 to 4, all"
echo "# pass on a build without the fix: they are here so that a fix which cleared the direction altogether,"
echo "# rather than leaving the one iopi_open.c set, does not go unnoticed."
echo "#"
echo "# Each stage runs in its own process, so a device left in a bad state by one cannot affect the next."
echo

cp $gtm_tst/$tst/inref/ydb1268.m .

echo '# Stage 1 : OPEN with writeonly and stderr="perr1"'
echo '# Command : $ydb_dist/yottadb -run wonly^ydb1268'
echo "#   expect the stderr device to give [to-stderr], a WRITE to it to be refused with DEVICEREADONLY,"
echo "#   and a READ from the PIPE device itself to be refused with DEVICEWRITEONLY"
$ydb_dist/yottadb -run wonly^ydb1268
echo

echo '# Stage 2 : OPEN with readonly and stderr="perr2", which worked before the fix'
echo '# Command : $ydb_dist/yottadb -run ronly^ydb1268'
echo "#   expect the stderr device to give [to-stderr]"
$ydb_dist/yottadb -run ronly^ydb1268
echo

echo '# Stage 3 : OPEN with stderr="perr3" and neither direction, which worked before the fix'
echo '# Command : $ydb_dist/yottadb -run plain^ydb1268'
echo "#   expect the stderr device to give [to-stderr] and the PIPE device to give [to-stdout]"
$ydb_dist/yottadb -run plain^ydb1268
echo

echo "# Stage 4 : CLOSE and re-OPEN reusing both device names in one process"
echo '# Command : $ydb_dist/yottadb -run reuse^ydb1268'
echo "#   expect both OPENs to read [to-stderr] from the stderr device they name"
$ydb_dist/yottadb -run reuse^ydb1268
echo

echo '# Stage 5 : OPEN with noreadonly and stderr="perr6"'
echo '# Command : $ydb_dist/yottadb -run nord^ydb1268'
echo "#   expect the stderr device to give [to-stderr] and a WRITE to it to be refused with"
echo "#   DEVICEREADONLY. Without the fix, noreadonly clears the read_only that iopi_open.c set, so"
echo "#   the WRITE reaches the OS and fails with a bare ENO9 instead."
$ydb_dist/yottadb -run nord^ydb1268
echo

echo "# Done"
