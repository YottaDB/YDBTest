#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2020 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################

echo "------------------------------------------------------------------------------------------------------"
echo "Test that ydb_dist is expanded in zroutines if ydb_routines and gtmroutines are not set"
echo "------------------------------------------------------------------------------------------------------"
source $gtm_tst/com/unset_ydb_env_var.csh ydb_routines gtmroutines
echo " -> unsetenv ydb_routines gtmroutines"
echo -n ' -> $zroutines output follows'
echo 'write $zroutines' | $ydb_dist/yottadb -direct

echo "------------------------------------------------------------------------------------------------------"
echo "Test that an error is issued if environment variables don't point to a valid directory"
echo "------------------------------------------------------------------------------------------------------"
setenv ydb_routines '$abcd $efgh'
echo " -> setenv ydb_routines '$ydb_routines'"
echo -n ' -> $zroutines output follows'
echo 'write $zroutines' | $ydb_dist/yottadb -direct

echo "------------------------------------------------------------------------------------------------------"
echo "Test that environment variables in ydb_routines are expanded when zroutines is initialized"
echo "------------------------------------------------------------------------------------------------------"
cd /tmp
echo " -> cd /tmp"
echo " -> PWD is $PWD"
setenv ydb_routines '$PWD'
echo " -> setenv ydb_routines $ydb_routines"
echo -n ' -> $zroutines output follows'
echo 'write $zroutines' | $ydb_dist/yottadb -direct

echo "------------------------------------------------------------------------------------------------------"
echo "Test that multiple env vars corresponding to valid directories in ydb_routines shows up expanded in zroutines"
echo "------------------------------------------------------------------------------------------------------"
setenv abcd "/usr/lib"
echo " -> setenv abcd $abcd"
setenv efgh "/usr/bin"
echo " -> setenv efgh $efgh"
setenv ydb_routines '$abcd $efgh'
echo " -> setenv ydb_routines $ydb_routines"
echo -n ' -> $zroutines output follows'
echo 'write $zroutines' | $ydb_dist/yottadb -direct

echo "------------------------------------------------------------------------------------------------------"
echo 'Test that . does not get expanded but $envvar does'
echo "------------------------------------------------------------------------------------------------------"
setenv ydb_routines '.($ydb_dist)'
echo " -> setenv ydb_routines $ydb_routines"
echo -n ' -> $zroutines output follows'
echo 'write $zroutines' | $ydb_dist/yottadb -direct

echo "------------------------------------------------------------------------------------------------------"
echo 'Test that * at end of directory in ydb_routines does show up in $zroutines'
echo "------------------------------------------------------------------------------------------------------"
setenv ydb_routines '.(.) .*($ydb_dist)'
echo " -> setenv ydb_routines $ydb_routines"
echo -n ' -> $zroutines output follows'
echo 'write $zroutines' | $ydb_dist/yottadb -direct

echo "------------------------------------------------------------------------------------------------------"
echo 'Test that a long ydb_routines does expand properly into $zroutines; Include shared library too'
echo "------------------------------------------------------------------------------------------------------"
setenv ydb_routines '$ydb_dist*($ydb_dist $ydb_dist $ydb_dist $ydb_dist $ydb_dist $ydb_dist .) $ydb_dist*($ydb_dist $ydb_dist $ydb_dist $ydb_dist $ydb_dist . $ydb_dist) $ydb_dist/libyottadbutil.so $ydb_dist*($ydb_dist $ydb_dist $ydb_dist $ydb_dist . $ydb_dist $ydb_dist) $ydb_dist*($ydb_dist $ydb_dist $ydb_dist . $ydb_dist $ydb_dist $ydb_dist) $ydb_dist*($ydb_dist $ydb_dist . $ydb_dist $ydb_dist $ydb_dist $ydb_dist) $ydb_dist*($ydb_dist . $ydb_dist $ydb_dist $ydb_dist $ydb_dist $ydb_dist)'
echo " -> setenv ydb_routines $ydb_routines"
echo -n ' -> $zroutines output follows'
echo 'write $zroutines' | $ydb_dist/yottadb -direct

