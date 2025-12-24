#!/bin/sh
#################################################################
#								#
# Copyright (c) 2022-2025 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################

mkdir ydb_build
echo "# Building YottaDB with Default Compiler"
echo '# Running [/Distrib/YottaDB/$1/$2/yottadb_r*/ydbinstall --installdir $3 --from-source --source-build-dir $PWD/ydb_build --overwrite-existing --utf8 --user $USER $4 > ydbinstall_fromsource.txt 2>&1]'
/Distrib/YottaDB/$1/$2/yottadb_r*/ydbinstall --installdir $3 --from-source --source-build-dir $PWD/ydb_build --overwrite-existing --utf8 --user $USER $4 > ydbinstall_fromsource.txt 2>&1

status=$?
if [ 0 != $status ]; then
	echo "ydbinstall returned a non-zero status: $status"
	exit $status
fi

head -1 ydbinstall_fromsource.txt
echo ""
echo "# YottaDB installed with Default Compiler"
tail -2 ydbinstall_fromsource.txt

echo "# Building YottaDB with Clang"
echo '# Running [/Distrib/YottaDB/$1/$2/yottadb_r*/ydbinstall --installdir $3 --from-source --compiler clang --source-build-dir $PWD/ydb_build --overwrite-existing --utf8 --user $USER $4 > ydbinstall_fromsource2.txt 2>&1]'
/Distrib/YottaDB/$1/$2/yottadb_r*/ydbinstall --installdir $3 --from-source --compiler clang --source-build-dir $PWD/ydb_build --overwrite-existing --utf8 --user $USER $4 > ydbinstall_fromsource2.txt 2>&1

status=$?
if [ 0 != $status ]; then
	echo "ydbinstall returned a non-zero status: $status"
	exit $status
fi

head -1 ydbinstall_fromsource2.txt
echo ""
echo "# YottaDB installed with Clang"
tail -2 ydbinstall_fromsource2.txt

echo "# Installing Octo"
echo '# Running [/Distrib/YottaDB/$1/$2/yottadb_r*/ydbinstall --installdir $3 --plugins-only --octo --overwrite-existing --user $USER $4 > ydbinstall_fromsource3.txt 2>&1]'
/Distrib/YottaDB/$1/$2/yottadb_r*/ydbinstall --installdir $3 --plugins-only --octo --overwrite-existing --user $USER $4 > ydbinstall_fromsource3.txt 2>&1
status=$?
if [ 0 != $status ]; then
	echo "ydbinstall returned a non-zero status: $status"
	exit $status
fi

cat ydbinstall_fromsource3.txt

echo "# Checking that Clang was used to compile YottaDB, Posix Plug-in, and Octo"
echo -n "YottaDB: "
readelf -p .comment $3/libyottadb.so | grep clang
echo -n "Posix Plug-in: "
readelf -p .comment $3/plugin/libydbposix.so | grep clang
echo -n "Octo: "
readelf -p .comment $3/plugin/bin/octo | grep clang
