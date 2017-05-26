#!/usr/local/bin/tcsh -f
#  Takes some arguments:
#  -primary=INSTx
#  -secondary=INSTy,INSTz,...	- can be 1 or more.	($secondary_instances)
#  for example:
#  deadlock_check_preparedb.csh -primary=INST1 -secondary=INST2,INST3,INST4

set opt_array      = ("\-primary" "\-secondary"        )
set opt_name_array = ("rp"            "secondary_instances")
source $gtm_tst/com/getargs.csh $argv

set INSTx = $rp
$echoline
echo "# Running deadlock_check_preparedb on $INSTx to $secondary_instances"
pwd

#  The script will then do (say INSTx is the primary, and INSTy, INSTz, and INSTt are secondaries):
#  - Step 1:
foreach INSTi ($secondary_instances)
	$MSR START $INSTx $INSTi	# i.e. msr_decide, replication is already on
end
echo "lots of simple, but large updates..."
set updcount = 700
if ("L" == $LFE) set updcount = 70	## for debugging only
$MSR RUN $INSTx '$gtm_tst/com/simpleinstanceupdate.csh '$updcount' LARGE'

#  - Step 2:
$MSR SYNC ALL_LINKS
foreach INSTi ($secondary_instances)
	$MSR STOP $INSTx $INSTi RESERVEPORT # i.e. msr_decide, replication will be left on, and portno will be reserved
end
