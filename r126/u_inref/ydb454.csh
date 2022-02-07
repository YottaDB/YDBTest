#!/usr/local/bin/tcsh
#################################################################
#								#
# Copyright (c) 2019-2022 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
# test of default value of ydb_routines if not set on yottadb/mumps process startup

echo '# test of default value of ydb_routines if not set on yottadb/mumps process startup'

mkdir install # the install destination
cd install

# copy the ydb files to the working directory
# NOTE: this will give out a few errors for files non-root users cannot read
# however those files are not used in this test
cp -r $ydb_dist/* . >& /dev/null

echo -n '\n$zroutines after source ydb_env_set'
echo 'write $zroutines' | ./mumps -direct

echo -n '\n$zroutines after unset of $ydb_routines and $gtmroutines'
source $gtm_tst/com/unset_ydb_env_var.csh ydb_routines gtmroutines
echo 'write $zroutines' | ./mumps -direct

echo -n '\n$zroutines after $ydb_routines and $gtmroutines are set to ""'
source $gtm_tst/com/set_ydb_env_var_random.csh ydb_routines gtmroutines ""
echo 'write $zroutines' | ./mumps -direct

echo -n '\n$zroutines when $ydb_routines and $gtmroutines are unset, and $ydb_dist/libyottadbutil.so does not exist'
chmod +w libyottadbutil.so
mv libyottadbutil.so libyottadbutil.so.changed
if ( -d ./utf8 ) then
	chmod -R +w ./utf8
	mv ./utf8/libyottadbutil.so utf8/libyottadbutil.so.changed
endif
echo 'write $zroutines' | ./mumps -direct

# clean up the isntall directory since the files are owned by root
cd ..
chmod -R +w install #need to give all the files write accesss to remove them
rm -rf install
