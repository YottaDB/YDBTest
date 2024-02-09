#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2023-2024 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################

# prepare directories for testing home directories
chmod -fR a+rwX $PWD/ydb88_home
rm -rf $PWD/ydb88_home
mkdir -p $PWD/ydb88_home
echo -n > $PWD/ydb88_home/.ydb_YottaDB_history
mkdir $PWD/ydb88_home/home1
echo -n > $PWD/ydb88_home/home1/.ydb_YottaDB_history
mkdir $PWD/ydb88_home/home2
echo -n > $PWD/ydb88_home/home2/.ydb_YottaDB_history
mkdir $PWD/ydb88_home/home_pneumonoultramicroscopicsilicovolcanoconiosis
echo -n > $PWD/ydb88_home/home_pneumonoultramicroscopicsilicovolcanoconiosis/.ydb_YottaDB_history
mkdir "$PWD/ydb88_home/home dirname with spaces"
echo -n > "$PWD/ydb88_home/home dirname with spaces/.ydb_YottaDB_history"
mkdir -p $PWD/ydb88_home/readonly
echo -n > "$PWD/ydb88_home/readonly/.ydb_YottaDB_history"
chmod a-w $PWD/ydb88_home/readonly

# set filter
set PATTERN='^\#'
if ($2 == "grep") then
    set PATTERN = "$3"
endif

# avoid breaking long lines
setenv TERM ascii

set basename = $1:r:t

# run expect script
(expect -d $gtm_tst/$tst/u_inref/$basename.exp > expect_exec.out) >& expect.dbg
if ($status) then
	echo "EXPECT-E-FAIL : [expect -d $gtm_tst/$tst/u_inref/$basename.exp] returned non-zero exit status : [$status]"
	echo "See expect_exec.out and expect.dbg"
	exit -1
endif

perl $gtm_tst/com/expectsanitize.pl expect_exec.out > expect_sanitized.out

# - change "ZSYSTEM yottadb" to pathless (sed)
# - remove empty lines (sed)
# - preserve full output (tee)
# - filter for lines beginning with '#' (or custom, grep)
# - gently cut filename from ZSYSTEM (sed)
# - drastically cut rest of line with filenames (sed)
# - add line numbers (cat -n)
sed -e 's/^\s*//' -e '/^$/d' expect_sanitized.out \
    | tee expect.full \
    | grep "$PATTERN" \
    | sed '/ZSYSTEM.*yottadb /s/.*/ZSYSTEM \"yottadb -direct\"/g' \
    | sed -E 's/(\ \/).*($)/ \2/' \
    | cat -n

chmod a+w $PWD/ydb88_home/readonly
