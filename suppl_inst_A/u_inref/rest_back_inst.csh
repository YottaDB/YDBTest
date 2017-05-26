#!/usr/local/bin/tcsh

# Test restart from a backup which includes an instance file
#

setenv gtm_test_mupip_set_version "disable"

# mumps.dat is moved from INST1 to INST2. a) encryption will cause issues b) set jnl on -reg "*" will issue FILEEXISTS
setenv test_encryption "NON_ENCRYPT"
setenv test_jnl_on_file 1

$MULTISITE_REPLIC_PREPARE 2
$gtm_tst/com/dbcreate.csh mumps -rec=1000

setenv needupdatersync 1
$MSR START INST1 INST2 RP
unsetenv needupdatersync
$gtm_tst/com/simplegblupd.csh -instance INST1 -count 10
$MSR SYNC INST1 INST2
#TODO : The -dstinstname qualifier implementation has been defered, so manually change the instance name in the instance file for now.
#$MSR RUN INST1 'mkdir bak1 ; $MUPIP backup -replinstance=bak1 -dstinstname=INSTANCE2 "*" bak1'
$MSR RUN INST1 'mkdir bak1 ; $MUPIP backup -replinstance=bak1 "*" bak1 ; $MUPIP replic -editinstance bak1/mumps.repl -change -offset=0x00000058 -size=1 -value=0x32'
$MSR RUN INST1 '$MUPIP replicate -editinstance -show bak1/mumps.repl |& $grep INSTANCE2'
$MSR STOP INST1 INST2
# restore from backup
$MSR RUN SRC=INST1 RCV=INST2 '$gtm_tst/com/cp_remote_file.csh __SRC_DIR__/bak1/* _REMOTEINFO___RCV_DIR__/'
$MSR RUN INST2 'mv mumps.mjl mumps.mjl.back'
$MSR START INST2 INST1 RP
$gtm_tst/com/simplegblupd.csh -instance INST2 -count 10

$MSR SYNC INST2 INST1
$MSR STOP INST2 INST1

$gtm_tst/com/dbcheck.csh -extract
