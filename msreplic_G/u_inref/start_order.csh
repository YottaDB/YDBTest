#!/usr/local/bin/tcsh -f
# =================================================================================================
$MULTISITE_REPLIC_PREPARE 5
$gtm_tst/com/dbcreate.csh mumps 1
$MSR START INST1 INST2 RP
$MSR RUN INST1 '$gtm_tst/com/simpleinstanceupdate.csh 1'
# we redirect the output from RF_START to .outx here because we know the error
# and RF_START just cats the START_{time_msr}.out to the logs which we can avoid here.
echo "==Executing MULTISITE_REPLIC START INST4 INST1 RP=="
setenv msr_dont_chk_stat
$MSR STARTRCV INST4 INST1 >&! START_INST4_1.outx
get_msrtime
if (0 == $test_replic_suppl_type) then
	echo "# --> Test PRIMARYISROOT when INST1 is already a Root Primary"
	$msr_err_chk START_$time_msr.out PRIMARYISROOT NORECVPOOL
	# port reservation file created by the starting up script should be cleaned up
	$MSR RUN INST1 'set msr_dont_trace ; setenv rem_port `cat portno` ; rm /tmp/test_${rem_port}.txt'
endif

##############
echo "# --> Test PRIMARYNOTROOT when INST2 is already a receiver"
setenv msr_dont_chk_stat
$MSR STARTSRC INST2 INST3 RP
get_msrtime
$MSR RUN INST2 "$msr_err_chk START_$time_msr.out PRIMARYNOTROOT REPLINSTSECNONE"
# port reservation file created by the starting up script should be cleaned up
$MSR RUN INST3 'set msr_dont_trace ; setenv rem_port `cat portno` ; rm /tmp/test_${rem_port}.txt'

$MSR START INST2 INST3 PP
$MSR RUN INST1 '$gtm_tst/com/simpleinstanceupdate.csh 2'
$MSR START INST4 INST5 PP

##############
echo "# --> Test RECVPOOLSETUP when INST3 already has a receiver running:"
$MSR RUN INST3 'set msr_dont_chk_stat;$MUPIP replic -receiver -start -listen=__SRC_PORTNO__ -log=__SRC_DIR__/START_{$gtm_test_replic_timestamp}.log -buff=$tst_buffsize >&! recvpoolsetup.out'

$MSR RUN INST3 "$msr_err_chk recvpoolsetup.out RECVPOOLSETUP"

$MSR START INST3 INST4 PP
$MSR RUN INST1 '$gtm_tst/com/simpleinstanceupdate.csh 3'
$MSR SYNC ALL_LINKS
$gtm_tst/com/dbcheck.csh -extract INST1 INST2 INST3 INST4 INST5
#
