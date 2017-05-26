#!/usr/local/bin/tcsh -f
#########################################################################################
# This script sets an env for each of the attributes for every instance prepared by
# multisite_replic_prepare.csh
# The script has to be sourced and use the alias MULTISITE_REPLIC_ENV for the same
#########################################################################################
# The msr_instance_config.txt has the following layout
# INSTANCE_COUNT: 3
# INST1   INSTNAME:       INSTANCE1
# INST1   VERSION:        V997
# INST1   IMAGE:          dbg
# INST1   DBDIR:          /testarea1/karthikk/V997/tst_V997_dbg_15_110325_111945/dual_fail_multisite_67/tmp
# INST1   JNLDIR:         /testarea1/karthikk/V997/tst_V997_dbg_15_110325_111945/dual_fail_multisite_67/tmp
# INST1   BAKDIR:         /testarea1/karthikk/V997/tst_V997_dbg_15_110325_111945/dual_fail_multisite_67/tmp/bak
# INST1   HOST:           HOST1
# INST1   PORTNO: UNINITIALIZED
# HOST1   NAME:   scylla
# .
# .
# INST2   INSTNAME:        INSTANCE2
# .
# .
# HOST2   NAME:   charybdis
#
# The following commands creates a list of environment variables of the type -
# gtm_test_msr_INSTNAME1 = INSTANCE1
# gtm_test_msr_VERSION1 = V997
# gtm_test_msr_DBDIR1 = /testarea1/karthikk/V997/tst_V997_dbg_15_110325_111945/dual_fail_multisite_67/tmp
# .
# .
# gtm_test_msr_NAME1 = scylla
# .
# .
# gtm_test_msr_NAME2 = charybdis
#
# This way, the caller can source this script (via MULTISITE_REPLIC_ENV) and get access to the remote hosts, their directories and
# other information easily from environment variables
#
set file = $tst_working_dir/msr_instance_config.txt
set tmpfile = /tmp/msr_env_{$$}_${USER}.csh
if (! -e $file) then
	echo "TEST-E-INSTANCEFILE not found, is this test really MULTISITE?"
	exit 1
endif
setenv gtm_test_msr_all_instances `$grep INSTNAME $file | $tst_awk '{print $1}'`
$tst_awk '/INST[0-9]/ {gsub("INST","",$1);gsub(":","",$2);print "setenv gtm_test_msr_"$2$1" "$3}' $file >! $tmpfile
$tst_awk '/HOST[0-9]/ {gsub("HOST","",$1);gsub(":","",$2);print "setenv gtm_test_msr_"$2$1" "$3}' $file >>! $tmpfile
# We will need to have an environment to show a minimum set of instances to identify all hosts involved:
setenv gtm_test_msr_oneinstperhost `$grep "HOST:" $file | $tst_awk '{instforhost[$3] = $1} END {for (i in instforhost) print  instforhost[i]}'`
source $tmpfile
\rm -f $tmpfile
#
