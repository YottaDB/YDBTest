#!/usr/local/bin/tcsh -f
# =================================================================================================
$echoline
cat << EOF
       |--> INST2
       |
INST1 -|--> INST3
       |
       |--> INST4
EOF
$echoline
#
$MULTISITE_REPLIC_PREPARE 4
$gtm_tst/com/dbcreate.csh mumps 1
$MSR START INST1 INST2 RP
$MSR RUN INST1 '$gtm_tst/com/simpleinstanceupdate.csh 10'
# start background process
echo "Starting background GT.M process..."
$MSR RUN INST1 '$gtm_tst/com/simplebgupdate.csh 10 >>&! bg.out'
$MSR START INST1 INST3 RP
$MSR RUN INST1 '$gtm_tst/com/simpleinstanceupdate.csh 20'
$MSR START INST1 INST4 RP
$MSR RUN INST1 '$gtm_tst/com/simpleinstanceupdate.csh 10'
$MSR SYNC ALL_LINKS
$MSR STOP INST1 INST2
$MSR STOP INST1 INST3
# check whether the bg process is sticking around still
set bg_id=`cat bg.out|sed 's/.*\]//g'|sed 's/ *//g'`
$ps | grep -v grep | grep " $bg_id "  >& /dev/null
if ($status) then
	echo "TEST-E-ERROR. bg process expected to be alive at this point but it is not.Check bg_gtm.out"
	exit 1
endif
echo "Stopping background GT.M process."
# this touch ensures we now stop the backgroung simplebgupdate process
touch endbgupdate.txt
$gtm_tst/com/dbcheck.csh -extract INST1 INST2 INST3 INST4
#
