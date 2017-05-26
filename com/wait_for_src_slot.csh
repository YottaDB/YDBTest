#!/usr/local/bin/tcsh -f
# Usage:
# $gtm_tst/com/wait_for_src_slot.csh [-jnlpool|-file] [-instance instname] [-maxwait maxtime] -searchstring <string> -lt|-gt|-eq <value>
# Searches for the value of the source server slot entry to be equalto/gt/lt the provided value
# Looks either the replication instance file or the journal pool
#
#SLT # 6 : Secondary Instance Name                INSTANCE8
#SLT # 6 : Resync Sequence Number                         1 [0x0000000000000001]
#SLT # 6 : Connect Sequence Number                        1 [0x0000000000000001]
#
# Note:
# Replication instance file is the default
# 300 seconds is the default timeout
# Looks for INSTANCE2 slot by defult

set opt_array	   = ("\-jnlpool"  "\-file"  "\-instance"  "\-searchstring"  "\-maxwait"  "\-eq"  "\-lt"  "\-gt")
set opt_name_array = ("injnlpool"  "infile"  "instname"    "searchstring"    "maxwait"    "iseq"  "islt"  "isgt")
source $gtm_tst/com/getargs.csh $argv

# Set the defaults first
# replic instance file is the default
if !(($?injnlpool) || ($?infile)) then
	set infile
endif
# 300 seconds is the default maxwait time
if !($?maxwait) then
	set maxwait = 300
endif
set timeout = $maxwait
# INSTANCE2 (which is the test system naming convention) is the default instance
if !($?instname) then
	set instname = "INSTANCE2"
endif

# Check for mandatory qualifiers.
if !($?searchstring) then
	echo "WAITFORSRCSLOT-E-PARAMETERS. -searchstring is a mandatory qualifier. Cannot proceed"
	exit 1
endif
if !(($?iseq) || ($?islt) || ($?isgt)) then
	echo "WAITFORSRCSLOT-E-PARAMETERS. One of -eq/-lt/-gt is a mandatory qualifier. Cannot proceed"
	exit 1
endif
# Only one of -eq/-lt/-gt should be given. Exit if more than one is passed.
if ((($?iseq) && ($?islt)) || (($?iseq) && ($?isgt)) || (($?isgt) && ($?islt))) then
	echo "WAITFORSRCSLOT-E-PARAMETERS. Only one of -eq/-lt/-gt should be given. Cannot proceed"
	exit 1
endif
# Only one of instancefile or journalpool should be given
if (($?injnlpool) && ($?infile)) then
	echo "WAITFORSRCSLOT-E-PARAMETERS. Only one of -file -jnlpool should be given. Cannot proceed"
	exit 1
endif

# Set comparison env.variables to use
if ($?iseq) then
	set compare = "=="
	set tocheck = "$iseq"
endif
if ($?islt) then
	set compare = "<"
	set tocheck = "$islt"
endif
if ($?isgt) then
	set compare = ">"
	set tocheck = "$isgt"
endif

# Dump the replication instance file or journal pool
if ($?infile) then
	set outfile = "wait_for_src_slot_instfile_dump.out"
	set mupip_cmd = "$MUPIP replic -editinstance -show $gtm_repl_instance"
endif
if ($?injnlpool) then
	set outfile = "wait_for_src_slot_jnlpool_dump.out"
	set mupip_cmd = "$MUPIP replic -source -jnlpool -show"
endif

$mupip_cmd >&! $outfile

# Find the slot number corresponding to the secondary instance $instname
set slotnumber = `$tst_awk '/^SLT #.. : Secondary Instance Name.*'"$instname"'/ {gsub(":.*",":"); print }' $outfile`

# Use this slot number to grep for the searchsting
set value = `$tst_awk  '/^'"$slotnumber $searchstring"'/ {print $(NF-1)}' $outfile`
# The above command assumes that the only two search slot entries are the below and looks for the last-1 th field directly
#SLT # 6 : Resync Sequence Number                         1 [0x0000000000000001]
#SLT # 6 : Connect Sequence Number                        1 [0x0000000000000001]
# The logic should change if anything else is introduced and last-1 th field doesn't hold good.

set fromtime = `date`
# Wait until $searchstring has value lt/gt/eq to the given value
while ($timeout)
	if ("$value" $compare "$tocheck") then
		# Whatever the compare operation is, it is satisfied. So exit
		exit 0
	endif
	sleep 1
	@ timeout--
	$mupip_cmd >&! $outfile
	set value = `$tst_awk  '/^'"$slotnumber $searchstring"'/ {print $(NF-1)}' $outfile`
end
set totime = `date`

if (0 == $timeout) then
	# Timedout waiting for the given conditions to satisfy. Print error
	echo "WAITFORSRCSLOT-E-TIMEOUT waiting for $searchstring to be $compare $tocheck"
	echo "Waited from : $fromtime to : $totime"
	exit 1
endif
