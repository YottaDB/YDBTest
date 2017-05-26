#!/usr/local/bin/tcsh -f

# INST1 --> INST2 --> INST3 --> INST4

$MULTISITE_REPLIC_PREPARE 4
$gtm_tst/com/dbcreate.csh mumps
$MSR START INST3 INST4 PP
$MSR START INST1 INST2 RP
$MSR RUN INST1 '$gtm_tst/com/simpleinstanceupdate.csh 50'
$MSR START INST2 INST3 PP
$MSR RUN INST1 '$gtm_tst/com/simpleinstanceupdate.csh 100'
$gtm_tst/com/dbcheck.csh -extract INST1 INST2 INST3 INST4
