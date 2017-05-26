#!/usr/local/bin/tcsh -f
#################################################################
#								#
#	Copyright 2012, 2014 Fidelity Information Services, Inc	#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
# This test ensures that if a process opens a region for the first time but had other regions opened before this and had encountered
# an online rollback in the interim, issues a DBROLLEDBACK appropriately. The test cases in nontp.m has more details

setenv gtm_test_repl_norepl 1	# Causes HREG's journaling and replication to be disabled
setenv  gtm_test_sprgde_exclude_reglist HREG	# Since HREG's journaling is disabled, seqno count assumptions in the rest of the test won't be accurate

$MULTISITE_REPLIC_PREPARE 4
$gtm_tst/com/dbcreate.csh mumps 9 255 5000 1024

# Create another global directory with [aA]* and [bB]* mapped to ABREG and everything else going to DEFAULT
setenv gtmgbldir mumps2.gld
cat << EOF > mumps2.gde
add -name a* -region=ABREG
add -name A* -region=ABREG
add -name b* -region=ABREG
add -name B* -region=ABREG
add -region ABREG -dyn=ABSEG
add -segment ABSEG -file=ab.dat
EOF
$GDE @mumps2.gde >&! mumps2gld.out
$MUPIP create -region=ABREG >&! dbcreate4mumps2.out

# Restore original global directory
setenv gtmgbldir mumps.gld

# We need to be able to read from a different replicating instance but don't want to replicate it. So, in this test, INST1 -> INST2
# and INST3 -> INST4. There is no connection between INST1 and INST3.
$MSR STARTSRC INST3 INST4 RP	# This is needed for test cases 6 and 7

setenv inst3dir	$PRI_SIDE	# To be used later in test cases 6 and 7
if ("ENCRYPT" == $test_encryption) then
	# Encryption enabled
	# Note down INST3's encryption key mappings in the current configuration file.
	foreach db (mumps a b c d e f g h)
		$gtm_tst/com/modconfig.csh $gtmcrypt_config append-keypair $inst3dir/${db}.dat $inst3dir/${db}_dat_key
	end
endif
# Set fully qualified database file names for all the regions on INST3 as in tests 6 and 7 we access data from INST3's
# gld and we don't want GT.M to be confused with relative path names.
# Note: Since $PRI_SIDE reflects the most recent $MSR STARTSRC command that was run, in the above case PRI_SIDE points to INST3's
# directory and not INST1's.
foreach seg (a b c d e f g h)
	echo "change -segment ${seg}seg -file=$PRI_SIDE/${seg}.dat" >> changeseg.gde
end
echo "change -segment default -file=$PRI_SIDE/mumps.dat" >> changeseg.gde
$MSR RUN SRC=INST1 RCV=INST3 '$gtm_tst/com/cp_remote_file.csh __SRC_DIR__/changeseg.gde _REMOTEINFO___RCV_DIR__/' >&! cpchangeseginst3.out
$MSR RUN INST3 "$GDE @changeseg.gde"	>&! inst3changeseg.out

$MSR STARTSRC INST1 INST2 RP

# Set a basic test bed on INST1 and INST3
$MSR RUN INST1 "set msr_dont_trace; $gtm_exe/mumps -run init^nontp INST1"
$MSR RUN INST3 "set msr_dont_trace; $gtm_exe/mumps -run init^nontp INST3"

echo "# Test 1 #"
$gtm_exe/mumps -run test1^nontp

echo "# Test 2 #"
$gtm_exe/mumps -run test2^nontp

echo "# Test 3 #"
$gtm_exe/mumps -run test3^nontp

echo "# Test 4 #"
$gtm_exe/mumps -run test4^nontp

echo "# Test 5 #"
$gtm_exe/mumps -run test5^nontp

echo "# Test 6 #"
$gtm_exe/mumps -run test6^nontp

echo "# Test 7 #"
$gtm_exe/mumps -run test7^nontp

echo "# Test 8 #"
$gtm_exe/mumps -run test8^nontp

$gtm_tst/com/check_error_exist.csh "orlbk*.out" NOTALLREPLON		# Due to HREG being non-journaled.
$gtm_tst/com/check_error_exist.csh "$inst3dir/orlbk7.out" NOTALLREPLON	# Due to HREG being non-journaled.

# Sync everything
$MSR SYNC ALL_LINKS

# Since we did not start the receivers, don't bother with -extract
# Also, INST2 and INST4 receiver server was never "officially" started in the test. So, there isn't any mumps.repl file
# available in INST2 and INST4. If $gtm_custom_errors is set, then the INTEG on INST2 and INST4 will error out with
# FTOKERR/ENO2. To avoid this, unsetenv gtm_custom_errors.
unsetenv gtm_custom_errors
$gtm_tst/com/dbcheck.csh
