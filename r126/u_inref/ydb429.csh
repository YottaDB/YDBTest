#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2019-2023 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
#
# Prevent use of V6 DB mode by utilizing a random V6 version to create DBs as we are creating a template
# with -LOCK_CRIT_SEPARATE which older versions of GDE do not know about.
setenv gtm_test_use_V6_DBs 0
#

echo '# Test of all ydb_env_set/unset functions'
echo '# Environment variables are set correctly'
echo '# Environment variables are restored correctly after unset'
echo '# Will create a working database at $HOME/.yottadb if $ydb_dir is not set'
echo '# Will create new regions if the .gld has changed'
echo '# Will create a UTF-8 database if $ydb_chset is set to UtF-8'
echo '# Will create a working database at $ydb_dir if none exists there'
echo '# Will recover a database with before journaling after a crash and will error on nobefore/disable journaling'
echo '# A database with nobefore/disable journaling will start up normally after ydb_env_set'


setenv HOME `pwd` # change $HOME to the test dir so we can test things that default to $HOME
setenv ydbDistTmp $ydb_dist
setenv gtmgbldir yottadb.gld
unsetenv gtm_test_fake_enospc # unset this because it can cause test hangs (due to a frozen instance) because of mupip stop of mumps followed right away by a dbcheck

cp $gtm_tst/$tst/inref/ydb429.sh .

# The below touch/mkdir commands create files and directories which begin with an underscore in their names.
# This is to test a buggy state of the ydb_env_set older-generation-journal-file-deletion-logic
# where it used to generate DEVOPENFAIL/GTMEISDIR errors.
# See https://gitlab.com/YottaDB/DB/YDB/-/merge_requests/950#note_545937207 for details.
touch _dummy1
mkdir _dummy2

foreach i (A B C D E F G H I J K)
	echo "\n"
	sh `pwd`/ydb429.sh test$i
	if ( $status == 1 ) then
		echo "ydb429.sh test$i : dbcreate failed exiting"
		exit 1
	else if ( $status == 2 ) then
		echo "ydb429.sh test$i : dbcheck failed exiting"
		exit 2
	endif
end
