#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2007-2016 Fidelity National Information		#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
#
# C9F06-002736 Test case for REPLOFFJNLON error from GT.M
#
# Since we are playing with mupltiple GLDs, unsetenv gtm_custom_errors to avoid REPLINSTMISMTCH errors.
unsetenv gtm_custom_errors
# Because we do multiple dbcreates without balancing dbchecks (due to deleting database files)
# it is not straightforward to enable sprgde file generation. Since it is exercised in various other
# tests and this test purpose is for REPLINSTMISMTCH error and is very simply written, disable this flag.
setenv gtm_test_spanreg 0
echo "# Create two-region gld and associated .dat files"
setenv tst_jnl_str "-journal=enable,on,nobefore"
setenv gtmgbldir mumps.gld
$gtm_tst/com/dbcreate.csh mumps 2	# will create mumps.dat and a.dat and a two-region gld
cp mumps.gld tworeg.gld

echo "# Remove mumps.dat and recreate it using a single-region gld"
rm -f mumps.dat
mv a.dat bak				# move a.dat to bak so that the next dbcreate doesn't move it to a.dat_<timestamp>
$gtm_tst/com/dbcreate.csh mumps 1	# will recreate mumps.dat and a single-region gld
cp mumps.gld onereg.gld
mv bak a.dat
echo "# Make gtmgbldir point to single-region gld"
setenv gtmgbldir onereg.gld
setenv gtm_repl_instance mumps.repl
echo "# Create replication instance file and set replic on"
$MUPIP replicate -instance -name=INSTA $gtm_test_qdbrundown_parms
$MUPIP set -replication=on -reg "*" >&! mupip_replic_on.out
$grep -E "GTM-I-JNLSTATE|GTM-I-REPLSTATE" mupip_replic_on.out
echo "# Start the passive source server"
$MUPIP replic -source -start -passive -log=source.log -buf=1 -instsecondary=INSTB -rootprimary

echo "# Now switch to a two-region gld file (AREG and DEFAULT) and turn journaling ON (but not replication) on AREG"
setenv gtmgbldir tworeg.gld
$MUPIP set $tst_jnl_str -reg AREG >&! mupip_set_jnlon.out
$grep "GTM-I-JNLSTATE" mupip_set_jnlon.out
echo "# Run c002736 and expect GTM-E-REPLOFFJNLON"
$gtm_exe/mumps -run c002736
echo "# Shutdown the passive source server"
$MUPIP replic -source -shut -time=0
echo "# dbcheck"
$gtm_tst/com/dbcheck.csh
