#################################################################
#                                                               #
# Copyright (c) 2018, 2019 YottaDB LLC and/or its subsidiaries. #
# All rights reserved.                                          #
#                                                               #
# Copyright (c) 2021-2022 YottaDB LLC and/or its subsidiaries.	#
#								#
#       This source code contains the intellectual property     #
#       of its copyright holder(s), and is made available       #
#       under a license.  If you do not know the terms of       #
#       the license, please stop and do not read further.       #
#                                                               #
#################################################################
#
echo "---------------------------------------------------------------------------------------------------------------------------"
echo '# Test that ydb_env_set changes ydb_routines/gtmroutines/ydb_gbldir/gtmgbldir values appropriately whether preset or unset.'
echo "---------------------------------------------------------------------------------------------------------------------------"
# Set file for expected env variables for grep
cat << EOF > envsearch.txt
ydb_dir
ydb_dist
ydb_etrap
ydb_gbldir
ydb_log
ydb_rel
ydb_repl_instance
ydb_retention
ydb_routines
ydb_tmp
gtmdir
gtm_dist
gtm_etrap
gtmgbldir
gtm_log
gtmver
gtm_repl_instance
gtm_retention
gtmroutines
gtm_tmp
EOF
#
echo "# First set ydb_routines/gtmroutines/gtmgbldir to arbitrary values and ydb_gbldir to mumps.gld."
#
export ydb_routines="a" ; export gtmroutines="b" ; export ydb_gbldir="mumps.gld" ; export gtmgbldir="d"
echo "ydb_routines: $ydb_routines" ; echo "gtmroutines: $gtmroutines" ; echo "ydb_gbldir: $ydb_gbldir" ; echo "gtmgbldir: $gtmgbldir"
#
echo "----------------------------------------------------"
#
echo '# Run ydb_env_set'
. $ydb_dist/ydb_env_set
#
echo '# Now test to see that ydb_routines/gtmroutines are original values with some additions at the end'
echo "ydb_routines: $ydb_routines" ; echo "gtmroutines: $gtmroutines"
echo '# Also test to see that gtmgbldir is set to same value as ydb_gbldir'
echo "ydb_gbldir: $ydb_gbldir" ; echo "gtmgbldir: $gtmgbldir"
#
echo "----------------------------------------------------"
echo '# Unset ydb_routines and ydb_gbldir; Set gtmroutines and gtmgbldir'

unset ydb_routines ; unset gtmroutines ; unset ydb_gbldir ; unset gtmgbldir
export gtmroutines="b" ; export gtmgbldir="mumps.gld"
echo '# Run ydb_env_set'
. $ydb_dist/ydb_env_set
echo '# Test that ydb_routines is set to be same as gtmroutines and ydb_gbldir is set to be same as gtmgbldir'
echo "ydb_routines: $ydb_routines" ; echo "gtmroutines: $gtmroutines" ; echo "ydb_gbldir: $ydb_gbldir" ; echo "gtmgbldir: $gtmgbldir"
#
echo "----------------------------------------------------"
echo '# Unset gtmroutines and gtmgbldir; Set ydb_routines and ydb_gbldir'
unset ydb_routines ; unset gtmroutines ; unset ydb_gbldir ; unset gtmgbldir
export ydb_routines="a" ; export ydb_gbldir="mumps.gld"
echo '# Run ydb_env_set'
. $ydb_dist/ydb_env_set
echo '# Test that gtmroutines is set to be same as ydb_routines and gtmgbldir is set to be same as ydb_gbldir'
echo "ydb_routines: $ydb_routines" ; echo "gtmroutines: $gtmroutines" ; echo "ydb_gbldir: $ydb_gbldir" ; echo "gtmgbldir: $gtmgbldir"
#
echo "----------------------------------------------------"
#
unset ydb_routines ; unset gtmroutines ; unset ydb_gbldir ; unset gtmgbldir
#
echo '# Now test to see if unsetting both ydb_* and gtm* and sourcing ydb_env_set sets ydb_* and gtm* to the default values'
. $ydb_dist/ydb_env_set
echo "ydb_routines: $ydb_routines" ; echo "gtmroutines: $gtmroutines" ; echo "ydb_gbldir: $ydb_gbldir" ; echo "gtmgbldir: $gtmgbldir"
#
echo "----------------------------------------------------"
echo '# Environment variables set after sourcing ydb_env_set.'
echo "----------------------------------------------------"
# Note: The test framework sets "LC_COLLATE" to C (see "com/set_locale.csh") but it is possible that "ydb_env_set" sets
# "LC_ALL" to a UTF-8 locale (if it finds that LC_CTYPE or LC_ALL is not set to a UTF-8 locale at shell startup which
# can vary depending on how the current server was set up). In that case, the "LC_COLLATE" setting would get overridden
# to the UTF-8 locale which would cause a different sort order below than what is expected in the reference file so undo
# the LC_ALL env var override and set LC_COLLATE to "C" (just in case) for the "sort" command below.
env | grep -f envsearch.txt -w | env LC_ALL="" LC_COLLATE="C" sort
