#!/usr/local/bin/tcsh -f
#################################################################
#								#
#	Copyright 2006, 2013 Fidelity Information Services, Inc	#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
# =================================================================================================
$echoline
cat << EOF
      |--> INST2 --> INST4
INST1-|
      |--> INST3 --> INST5
EOF
$echoline
$MULTISITE_REPLIC_PREPARE 5
$tst_awk '{ if($1"	"$2":" ~ /INST5	INSTNAME:/) print $1"	"$2"	INSTANCE1";else print $0}' $tst_working_dir/msr_instance_config.txt >&! /tmp/msr_instance_config_{$$}.txt
mv /tmp/msr_instance_config_{$$}.txt $tst_working_dir/msr_instance_config.txt
$MULTISITE_REPLIC_ENV
# This test plays with the instance names and does various explicit source server startup commands making it difficult to enable
# SSL/TLS for the replication stream. So, disable SSL/TLS for this test.
setenv gtm_test_tls "FALSE"
$gtm_tst/com/dbcreate.csh mumps 1
set echoline = "echo #####################################################################################"
# the below set of error checks happens both at source and receiver side - so let's run loop
foreach side (RCV SRC)
	# but we need to ensure we cover the naming conventions so we have some little temp sets
	if ("SRC" == $side) then
		set qual="RP"
		set loopfile="START"
		set tmp_name=$gtm_test_msr_INSTNAME2
	else
		set qual=""
		set loopfile=$gtm_test_msr_DBDIR2"/START"
		set tmp_name=$gtm_test_msr_INSTNAME1
	endif
	setenv gtm_test_instsecondary
	setenv msr_dont_chk_stat
	$MSR START$side INST1 INST2 $qual
	get_msrtime
	$msr_err_chk "$loopfile"_$time_msr.out REPLINSTSECUNDF MUPCLIERR NOJNLPOOL
	# port reservation file created by the rcvr starting up scripts should be cleaned up.(startup failed-shutdown isn't called)
	if ("RCV" == "$side") then
		$MSR RUN INST2 'set msr_dont_trace ; setenv rem_port `cat portno` ; rm /tmp/test_${rem_port}.txt'
	endif
	setenv gtm_test_instsecondary ""
	setenv gtm_repl_instsecondary "SOMEREALLYLONGINVALIDNAME"
	setenv msr_dont_chk_stat
	$MSR START$side INST1 INST2 $qual
	get_msrtime
	$msr_err_chk "$loopfile"_$time_msr.out REPLINSTSECLEN MUPCLIERR
	if ("RCV" == "$side") then
		$MSR RUN INST2 'set msr_dont_trace ; setenv rem_port `cat portno` ; rm /tmp/test_${rem_port}.txt'
	endif
	setenv gtm_test_instsecondary ""
	setenv gtm_repl_instsecondary ""
	setenv msr_dont_chk_stat
	$MSR START$side INST1 INST2 $qual
	get_msrtime
	$msr_err_chk "$loopfile"_$time_msr.out REPLINSTSECLEN MUPCLIERR
	if ("RCV" == "$side") then
		$MSR RUN INST2 'set msr_dont_trace ; setenv rem_port `cat portno` ; rm /tmp/test_${rem_port}.txt'
	endif
	setenv gtm_test_instsecondary "-instsecondary=$tmp_name"
	setenv gtm_repl_instsecondary "SOMEREALLYLONGINVALIDNAMEBUTSHOULDNOTBEUSED"
	$MSR START$side INST1 INST2 $qual
	unsetenv gtm_repl_instsecondary
end
setenv gtm_repl_instsecondary "$gtm_test_msr_INSTNAME3"
$MSR START INST1 INST3 RP
unsetenv gtm_repl_instsecondary
#
echo ""
$MSR RUN INST5 '$MUPIP replic -instance_create -name=__SRC_INSTNAME__'	# note instance name will be INSTANCE1

# start INST3-INST5 link. Use RUN option here as normal MSR action START will return success
# and so link history will be updated too.
# get a dummy portno
setenv tmp_portno `$MSR RUN INST5 'set msr_dont_trace;source $gtm_tst/com/portno_acquire.csh'`
#
echo ""
echo "TEST-I-error SRCSRVEXISTS expected here on starting INST3-INST5"
$MSR RUN SRC=INST3 RCV=INST5 'set msr_dont_chk_stat;$MUPIP replic -source -start -secondary=__RCV_HOST__:'$tmp_portno' -buff=$tst_buffsize -log=src.log -instsecondary=__RCV_INSTNAME__'
$msr_err_chk $msr_execute_last_out SRCSRVEXISTS
# release the dummy portno
$MSR RUN INST5 'rm /tmp/test_$tmp_portno.txt'
$MSR START INST2 INST4 PP
$MSR RUN INST1 '$gtm_tst/com/simpleinstanceupdate.csh 20'
$MSR SYNC ALL_LINKS
#
$echoline
echo "TEST-I-ERROREXPECT, REPLINSTSECUNDF expected for the section below"
echo ""
$gtm_tst/$tst/u_inref/replic_source_commands.csh RCV=INST2 "" "REPLINSTSECUNDF MUPCLIERR" "checkhealth,showbacklog"
#
$echoline
echo "TEST-I-ALLPASS, all commands expected to PASS for the section below"
echo ""
setenv gtm_repl_instsecondary "$gtm_test_msr_INSTNAME2"
$gtm_tst/$tst/u_inref/replic_source_commands.csh RCV=INST2
#
$echoline
echo "TEST-I-ALLPASS, all commands expected to PASS for the section below"
echo ""
setenv gtm_repl_instsecondary "BADINSTANCENAME" # just a bait and no significance otherwise
$gtm_tst/$tst/u_inref/replic_source_commands.csh RCV=INST2 "-instsecondary=$gtm_test_msr_INSTNAME2"
#
$echoline
echo "TEST-I-ERROREXPECT, REPLINSTSECLEN expected for the section below"
echo ""
setenv gtm_repl_instsecondary "SOMEREALLYLONGINVALIDNAME"
$gtm_tst/$tst/u_inref/replic_source_commands.csh RCV=INST2 "" "REPLINSTSECLEN MUPCLIERR"
#
$echoline
echo "TEST-I-ERROREXPECT, REPLINSTSECLEN expected for the section below"
echo ""
setenv gtm_repl_instsecondary ""
$gtm_tst/$tst/u_inref/replic_source_commands.csh RCV=INST2 "" "REPLINSTSECLEN MUPCLIERR"
#
$echoline
echo "TEST-I-ERROREXPECT, REPLINSTNMSAME expected for the section below"
echo ""
setenv gtm_repl_instsecondary "$gtm_test_msr_INSTNAME1"
$gtm_tst/$tst/u_inref/replic_source_commands.csh RCV=INST2 "" "REPLINSTNMSAME"
#
unsetenv gtm_repl_instsecondary
$gtm_tst/com/dbcheck.csh
#
