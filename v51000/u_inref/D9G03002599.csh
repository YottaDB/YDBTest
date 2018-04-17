#!/usr/local/bin/tcsh
#################################################################
#								#
# Copyright (c) 2006-2016 Fidelity National Information		#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
#								#
# Copyright (c) 2018 YottaDB LLC. and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
#
# D9G03-002599 GTM does not detect (and stop) external reference to second replicated instance
#
# Create two sets of gld, databases and instance file
#	mumps.gld : mumpsrepl.dat and mumpsnonrepl.dat : mumps.repl
#	other.gld : otherrepl.dat and othernonrepl.dat : other.repl
#
# Out of the 4 databases above,
#	mumpsrepl.dat and otherrepl.dat will be replicated.
#	mumpsnonrepl.dat and othernonrepl.dat will not be replicated.
#
# Source servers will be started for both the replication instances without going through the framework scripts.
# Note that this test is run without the -replic option but it does use replication.
#
# A GT.M process that starts up with mumps.repl as the replication instance should get an error when it tries to
#	update otherrepl.dat but should not get an error when it tries to update othernonrepl.dat
#

setenv gtm_test_spanreg 0	# because this test does not do subscripted updates, no point generating/using sprgde files.
setenv gtm_test_jnl NON_SETJNL	# because replication is enabled for only one database

##################### Create MUMPS and OTHER environments ######################
foreach value (mumps other)
	setenv gtmgbldir ${value}.gld
	source $gtm_tst/com/set_ydb_env_var_random.csh ydb_repl_instance gtm_repl_instance ${value}.repl
	cat > ${value}.gde << CAT_EOF
	add -name nonrepl -region=nonreplreg
	add -region nonreplreg -dyn=nonreplseg
	add -segment nonreplseg -file=${value}nonrepl.dat
	add -name repl -region=replreg
	add -region replreg -dyn=replseg
	add -segment replseg -file=${value}repl.dat
	delete -segment DEFAULT
	add -segment DEFAULT -file=${value}default.dat
	exit
CAT_EOF

	setenv test_specific_gde $tst_working_dir/${value}.gde
	$gtm_tst/com/dbcreate.csh $value
	$gtm_tst/com/backup_dbjnl.csh bak_${value} '*.dat *.gld' mv nozip # To prevent the next dbcreate from renaming *.dat and *.gld
end

foreach value (mumps other)
	setenv gtmgbldir ${value}.gld
	source $gtm_tst/com/set_ydb_env_var_random.csh ydb_repl_instance gtm_repl_instance ${value}.repl
	mv bak_${value}/* .
	# Since ${value}.repl is not yet created, the below replic=on command issues FTOKERR/ENO2 error if $gtm_custom_errors is
	# defined. So, temporarily undefine $gtm_custom_errors.
	if ($?gtm_custom_errors) then
		setenv restore_gtm_custom_errors $gtm_custom_errors
		unsetenv gtm_custom_errors
	endif
	$MUPIP set -replic=on -file ${value}repl.dat >&! ${value}_set_replic_on.out
	if ($?restore_gtm_custom_errors) then
		setenv gtm_custom_errors $restore_gtm_custom_errors
		unsetenv restore_gtm_custom_errors
	endif

	# Create instance file for ${value}.repl
	$MUPIP replicate -instance_create -name=$value $gtm_test_qdbrundown_parms

	# Start active source server for ${value}.repl
	source $gtm_tst/com/portno_acquire.csh >>& portno_${value}.out
	set sechost = "${value}_secondary"
	$MUPIP replic -source -start -secondary="$HOST":"$portno" -log=${value}_source.log -buffsize=1 -instsecondary="$sechost"
end

##################### Start GT.M process to perform updates to MUMPS and OTHER environment ######################
source $gtm_tst/com/set_ydb_env_var_random.csh ydb_repl_instance gtm_repl_instance mumps.repl
$GTM << EOF
	do mumpsfirst^d002599
	quit
EOF
$GTM << EOF
	do otherfirst^d002599
	quit
EOF

source $gtm_tst/com/set_ydb_env_var_random.csh ydb_repl_instance gtm_repl_instance other.repl
$GTM << EOF
	do mumpsfirst^d002599
	quit
EOF
$GTM << EOF
	do otherfirst^d002599
	quit
EOF

foreach value (mumps other)
	# Print journal seqno of the replication instance through the showbacklog command
	echo ""
	echo "Checking $value environment"
	source $gtm_tst/com/set_ydb_env_var_random.csh ydb_repl_instance gtm_repl_instance ${value}.repl
	$MUPIP replic -source -showbacklog >& ${value}_showbacklog.log
	echo '$grep last transaction written to journal pool'" ${value}_showbacklog.log"
	$grep "last transaction written to journal pool" ${value}_showbacklog.log
	$MUPIP replic -source -shut -time=0 >& ${value}_shut.log

	# Print the journal seqno and the <key,value> in the journal files. This should match the seqno from the showbacklog.
	$MUPIP journal -extract -forward -noverify -fences=none ${value}repl.mjl >& ${value}_extract.out
	echo '$grep repl '"${value}repl.mjf"
	$grep repl ${value}repl.mjf | $tst_awk -F\\ '{printf "%s\\\\%s\n", $6,$NF;}'

	setenv gtmgbldir $value.gld
	$gtm_tst/com/dbcheck.csh
	# Remove the port reservation files (since there are 2, using variable interpolation type of logic)
	mv portno_${value}.out portno.out
	$gtm_tst/com/portno_release.csh
end
