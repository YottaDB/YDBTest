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

# Randomly puts database and/or journal files in a folder which has limited capacity. Ensures that the instance freeze stops processes when space is exhausted.
# The processes should continue execution once more space made available and freeze is lifted.

set folder_size=2048 # Temporary file system size (KB)
set tmpfs = "small_fs"
set rel_tmpfs = $PWD/../testfiles/$tmpfs

# Enable freeze on ENOSPC
setenv	gtm_test_freeze_on_error 1
setenv	gtm_custom_errors $gtm_tools/custom_errors_sample.txt
# Disable fake ENOSPC because it can throw false positives by simulating disk space availability (DSKSPCAVAILABLE)
setenv	gtm_test_fake_enospc 0
# Disable spanning regions because each region must use no more than $folder_size of space. With spanning regions, we can't guarantee the limit.
setenv gtm_test_spanreg 0
# Pick up the same journal/database mappings if already given
if ($?gtm_random_dattosmall) then
    set random_dattosmall = ($gtm_random_dattosmall)
else
    set random_dattosmall = `$gtm_tst/com/genrandnumbers.csh 6 0 1`
    echo 'setenv gtm_random_dattosmall "'$random_dattosmall'"' >> settings.csh
endif
if ($?gtm_random_jnltosmall) then
    set random_jnltosmall = ($gtm_random_jnltosmall)
else
    # genrandnumbers.csh generates new numbers every second because of awk. This sleep is here to advance a second so that we dont get the exact same number for
    # both random_dattosmall and random_jnltosmall
    sleep 1
    set random_jnltosmall = `$gtm_tst/com/genrandnumbers.csh 6 0 1`
    echo 'setenv gtm_random_jnltosmall "'$random_jnltosmall'"' >> settings.csh
endif

echo "# Preparing gde file"
# GDE settings for all regions and DEFAULT
cat > xgde.gde <<EOF
template -region -key=255 -rec=1024
change -segment DEFAULT -file=mumps.dat
change -region DEFAULT -key=255 -rec=1024
EOF

echo "# Mapping .dat files to directories (check xgde.gde to see)"
foreach region (a b c d e f)
    \mkdir ${rel_tmpfs}_${region}
    echo "# Mounting ${rel_tmpfs}_${region}"
    $gtm_com/IGS MOUNT ${rel_tmpfs}_${region} $folder_size
    if ($status) then
	echo "Mounting ${rel_tmpfs}_${region} failed. Exiting test now"
	exit 1
    endif
    echo "$gtm_com/IGS UMOUNT ${rel_tmpfs}_${region}" >>& ../cleanup.csh
    cat >> xgde.gde <<EOF
add -name ${region}* -region=${region}reg
add -region ${region}reg -dyn=${region}seg
EOF
    # Randomly decide if .dat file goes to small file system
    @ i++
    set dattosmall = $random_dattosmall[$i]
    if (1 == $dattosmall) then
	# Database file goes to the small file system
	set fsused # Flag to show that small file system is used
	set segstr = "${rel_tmpfs}_${region}/${region}"
    else
	# Database file does not go to the small file system
	set segstr = "${region}"
    endif
    echo "add -segment ${region}seg -file=$segstr" >> xgde.gde
end

echo "# Creating database"
setenv test_specific_gde $PWD/xgde.gde
$gtm_tst/com/dbcreate_base.csh mumps >&! dbcreate_base.out

echo "# Mapping journal files to directories (check journalcfg.out to see)"
set i = 0
foreach region (a b c d e f)
    # Randomly decide if regions' journal file goes in the small file system
    @ i++
    set jnltosmall = $random_jnltosmall[$i]
    if ("f" == $region && !($?fsused)) then
	# If small file system is NEVER used by database or journal files so far, map the f's
	# Journal file to small file system so that this test does not fail
	set jnltosmall = 1
    endif
    if (1 == $jnltosmall) then
	set fsused
	set jnlpath=${rel_tmpfs}_${region}/$region
    else
	set jnlpath=$PWD/$region
    endif
    set upreg=`echo $region | tr "[a-z]" "[A-Z]"`
    # Specify journal path
    $MUPIP set -region ${upreg}REG -journal=enable,off,before,filename=$jnlpath >>&! journalcfg.out
end

# Activate instance freeze and journaling
$MUPIP set -region "*" -journal=on,before -replic=on -inst >>&! journalcfg.out
setenv gtm_repl_instance "mumps.repl"
echo "# Starting passive server"
$gtm_tst/com/passive_start_upd_enable.csh >&! passive_start_`date +%H_%M_%S`.out

echo "# Putting garbage in small file systems"
 # Put some garbage to the FS
foreach region (a b c d e f)
    dd if=/dev/zero of=${rel_tmpfs}_${region}/garbage count=$folder_size bs=1024 >&! ddout_${region}
end

set syslog_before1 = `date +"%b %e %H:%M:%S"`
echo "# Launching filler processes"
($gtm_exe/mumps -run fill > bgout.txtx &) # Launch 4 processes that updates all regions with uniq values
# Updates should cause freeze because the database is filled
$gtm_tst/com/getoper.csh "$syslog_before1" "" syslog1.txt "" "REPLINSTFROZEN"
if ($status) exit 1
$gtm_tst/com/getoper.csh "$syslog_before1" "" syslog2.txt "" "DSKNOSPCAVAIL"
if ($status) exit 1
# Remove the garbage and see if freeze is lifted
set syslog_before1 = `date +"%b %e %H:%M:%S"`
echo "# Removing garbages"
# The small file system is large enough to accommodate both journal and database files once the garbage is removed so the normal execution
# should continue ince the garbage is removed
rm ${rel_tmpfs}*/garbage
$gtm_tst/com/getoper.csh "$syslog_before1" "" syslog3.txt "" "DSKSPCAVAILABLE"
if ($status) exit 1
$gtm_tst/com/getoper.csh "$syslog_before1" "" syslog4.txt "" "REPLINSTUNFROZEN"
if ($status) exit 1
if (`$tst_awk 'END{print NR}' bgout.txtx` != 1) then
    # If there is more than just the pid in the bgout.txtx, it means we have timed out or some error happened
    echo "TEST-E-FAIL Check bgout.txt. Very likely the one of the children did not exit. Unfreezing so that we can terminate this test..."
    $MUPIP replicate -source -freeze=off
    echo "# Waiting for child processes to exit..."
    foreach file (start_fill.mjo*)
	set $pid=`sed 's/\([0-9]*\) DONE/\1/' $file`
	echo # "Waiting for $pid to quit."
	$gtm_tst/com/wait_for_proc_to_die.csh $pid 300
    end
else
    $gtm_tst/com/wait_for_proc_to_die.csh `cat bgout.txtx` 300
endif
$MUPIP replicate -source -shutdown -timeout=0
$gtm_tst/com/dbcheck.csh
set replog=`ls SRC_*.log`
mv $replog{,x}

# Unmount temporary file systems mounted by super user
foreach region (a b c d e f)
    cp -r ${rel_tmpfs}_${region} .
    echo "# Unmounting ${rel_tmpfs}_${region}"
    $gtm_com/IGS UMOUNT ${rel_tmpfs}_${region}
    if !($status) then
	$grep -v "UMOUNT ${rel_tmpfs}_${region}"  ../cleanup.csh > cleanup.bak
	\mv cleanup.bak ../cleanup.csh
    else
	echo "Unmount failed for ${rel_tmpfs}_${region}. Exiting now"
	exit 1
    endif
end

