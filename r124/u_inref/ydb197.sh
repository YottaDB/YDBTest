#################################################################
#                                                               #
# Copyright (c) 2018 YottaDB LLC. and/or its subsidiaries.      #
# All rights reserved.                                          #
#                                                               #
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
echo "# First set ydb_routines/gtmroutines/ydb_gbldir/gtmgbldir to arbitrary values."
#
export ydb_routines="a" ; export gtmroutines="b" ; export ydb_gbldir="c" ; export gtmgbldir="d"
echo "ydb_routines: $ydb_routines" ; echo "gtmroutines: $gtmroutines" ; echo "ydb_gbldir: $ydb_gbldir" ; echo "gtmgbldir: $gtmgbldir"
#
echo "----------------------------------------------------"
echo '# Now test to see if sourcing ydb_env_set changes the gtm* values to the ydb_* values'
#
. $ydb_dist/ydb_env_set
#
echo "ydb_routines: $ydb_routines" ; echo "gtmroutines: $gtmroutines" ; echo "ydb_gbldir: $ydb_gbldir" ; echo "gtmgbldir: $gtmgbldir"
#
echo "----------------------------------------------------"
echo '# Now test to see if unsetting ydb_*, setting gtm*, and sourcing ydb_env_set, sets ydb_* to the gtm* value'
#
unset ydb_routines ; unset gtmroutines ; unset ydb_gbldir ; unset gtmgbldir
export gtmroutines="b" ; export gtmgbldir="d"
. $ydb_dist/ydb_env_set
echo "ydb_routines: $ydb_routines" ; echo "gtmroutines: $gtmroutines" ; echo "ydb_gbldir: $ydb_gbldir" ; echo "gtmgbldir: $gtmgbldir"
#
echo "----------------------------------------------------"
echo '# Now test to see if unsetting gtm*, setting ydb_*, and sourcing ydb_env_set, sets gtm* to the ydb_* value'
#
unset ydb_routines ; unset gtmroutines ; unset ydb_gbldir ; unset gtmgbldir
export ydb_routines="a" ; export ydb_gbldir="c"
. $ydb_dist/ydb_env_set
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
env | grep -f envsearch.txt -w | sort
