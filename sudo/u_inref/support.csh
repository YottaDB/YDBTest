#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2024 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
echo "# This tests that ydb_support.sh successfully gathers the correct support information without issues"
echo "# It tests -h|--help, -o|--outdir, -p|--pid, -n|--no-logs, -l|--logs-since, -u|--logs-until, and uses -f|--force"
$echoline

# Setup of the image environment
mkdir install
cd install

# Make this folder before hand otherwise the installer will throw out errors.
# This happens only when this script is invoked by the test system, as it works
# fine without permission issues when run as root in an interactive terminal.
mkdir gtmsecshrdir
chmod -R 755 .

# We use plugins.sh to install the ydb_support.sh script we are testing
cp $gtm_tst/$tst/u_inref/plugins.sh .

# Pass these as variables to plugins.sh because it doesn't inherit the tcsh
# environment variables. The below sets the variable "installoptions."
#   e.g. "--force-install" if needed
source $gtm_tst/$tst/u_inref/setinstalloptions.csh
echo "# Installing ydb_support.sh with ydbinstall --support"
$sudostr sh ./plugins.sh $gtm_verno $tst_image `pwd` "$installoptions" "--support" "no"
$echoline

cd ..

echo "# Creating database"
$gtm_tst/com/dbcreate.csh mumps
$echoline

# Possible options used in the test
set options = ("-h|--help" "-o|--outdir" "-p|--pid" "-n|--no-logs" "-l|--logs-since" "-u|--logs-until")
# In a container, don't test journalctl
if ($?ydb_test_inside_docker) then
	if (1 == $ydb_test_inside_docker) set options = ("-h|--help" "-o|--outdir" "-p|--pid" "-n|--no-logs")
endif

set cnt = 0
foreach option ($options)
	# Convert to array of one option and its possible forms
	set option = (`echo $option | tr "|" " "`)
	# Of these, pick random ones
	set version = `shuf -i 1-$#option -n 1`
	set name = "$option[$version]"
	set sudo_num = `shuf -i 0-1 -n 1`
	# Set defaults for other options
	set sudo = ""
	set arg = ""
	set log = "ydb_support"
	set pid = ""
	set log_until = ""

	# Pick whether to test with root via sudo or not
	if (1 == $sudo_num) set sudo = "sudo -E"
	# Turn sudo off in a container
	if ($?ydb_test_inside_docker) then
		if (1 == $ydb_test_inside_docker) set sudo = ""
	endif

	switch ("$option")
	case "-o --outdir":
		set log = "support_dir"
		set arg = " $log"
		breaksw
	case "-p --pid":
		# Hang for 30 secs, will stop later
		($gtm_dist/mumps -run %XCMD 'hang 30' & ; echo $! >&! pid.txt) >& m_job_control_output.txt
		set pid = `cat pid.txt`
		# Test with core or with process number?
		set pid_runningP_or_core = `shuf -i 0-1 -n 1`
		if (1 == $pid_runningP_or_core) then
			set arg = " $pid"
		else
			gcore $pid >& ydb_core_file_creation_output.txt
			set arg = " core.$pid"
		endif
	case "-n --no-logs":
		set name = "--force $name"
		breaksw
	case "-l --logs-since":
		set name = "-f $name"
		# Whether to test with hours or minutes
		set types = `shuf -e 2 60 -n 1`
		# Set random hour or minutes to test (1 or 2 hours, and 1 to 60 minutes)
		# The defaults when you don't pass -l or -u is -l '2 hours ago' and -u now
		set since = `shuf -i 1-$types -n 1`
		set since_arg = "$since minutes ago"
		if (2 == $types) set since_arg = "$since hours ago"
		breaksw
	case "-u --logs-until":
		set name = "-f $name"
		set types = `shuf -e 0 2 60 -n 1`
		set until = "now"
		if (0 != $types) set until = `shuf -i 1-$types -n 1`
		set until_arg = "$until"
		if (2 == $types) then
			set until_arg = "$until hours ago"
		else if (60 == $types) then
			set until_arg = "$until minutes ago"
		endif
		breaksw
	default:
		breaksw
	endsw

	# Need to pass the full YottaDB environment to ydb_support.sh for it to do its thing
	if ($?since) then
		echo "Running ydb_support.sh with $name "$since_arg" option"
		$sudo install/plugin/ydb_support.sh $name "$since_arg" >>& ydb_support-$cnt.log
		unset since since_arg
	else if ($?until) then
		echo "Running ydb_support.sh with $name "$until_arg" option"
		$sudo install/plugin/ydb_support.sh $name "$until_arg" >>& ydb_support-$cnt.log
		unset until until_arg
	else
		echo "Running ydb_support.sh with $name$arg option"
		$sudo install/plugin/ydb_support.sh $name$arg >> ydb_support-$cnt.log
	endif

	if ("-p --pid" == "$option") then
		# Stop the YottaDB process that was used to gather information with gdb
		$MUPIP stop $pid
		$gtm_tst/com/wait_for_proc_to_die.csh $pid 10
		# Tell test system to ignore core file
		if (-f "core.$pid") mv core.$pid ignoreme.$pid
	endif

	if ($status) then
		echo "ydb_support.sh returned a non-zero status: $status" >> ydb_support-$cnt.log
	endif

	if ("-h --help" == "$option") then
		set test = "Usage: ./ydb_support.sh [-f|--force] [-o|--outdir OUTPUT DIRECTORY]"
		set test = "$test sudo -E ./ydb_support.sh [-f|--force] [-o|--outdir OUTPUT DIRECTORY]"
		set output = `sed -n "1,3p" ydb_support-$cnt.log`

		if ("$test" != "$output") then
			echo "# Test failed (ydb_support.sh $name). Check ydb_support-$cnt.log"
		endif

		$echoline
		@ cnt++
		continue
	else if ("-n --no-logs" == "$option") then
		set test = "## Done getting information, packing tarball ## Done! Please review the files"
		set test = "$test in ydb_support to make sure that they only contain metadata ## that can be sent."
		set test = "$test If not, please edit them as needed, and run the command"
		set output = `sed -n "1,3p" ydb_support-$cnt.log`

		if ("$test" != "$output") then
			echo "# Test failed (ydb_support.sh $name$arg). Check ydb_support-$cnt.log"
		endif

		# Change ownership to avoid issues with cleanup
		sudo chown -R ${USER}:`id -gn` $log

		$echoline
		@ cnt++
		continue
	endif

	set test = "## Gathering system information ## Gathering environment variables,"
	set test = "$test omitting keys, passphrases, and passwords ## Gathering system logs"
	set output = `sed -n "1,3p" ydb_support-$cnt.log`

	if ("$test" != "$output") then
		echo "# Test failed (ydb_support.sh $name$arg). Check ydb_support-$cnt.log"
	endif

	foreach file (`ls $log`)
		if (0 == `stat --format="%s" $log/$file`) then
			echo "# Test failed (ydb_support.sh $name$arg). File $file was empty"
		endif
	end

	# ydb_support.sh creates a tar file (maybe root owned if invoked with sudo).
	# We don't want it preventing subsequent non-root invocations using the same file name.
	if (-f ${log}.tar.gz) $sudo mv ${log}.tar.gz{,.$cnt}
	# For some reason, the test system adds the contents of `journalctl.log` to the output file and I can't find out where.
	# So we rename file.
	if (-f ${log}/journalctl.log) $sudo mv ${log}/journalctl.log{,.$cnt}

	# Change ownership to avoid issues with cleanup
	sudo chown -R ${USER}:`id -gn` $log
	$echoline
	@ cnt++
end

# The container cannot run the -l or -u options, so we fake some output to
# keep the outref/support.txt file matching outside of a container
if ($?ydb_test_inside_docker) then
	if (1 == $ydb_test_inside_docker) then
		# Provide output for the support.txt file for the -l option
		echo "This option doesn't work in a container"
		$echoline
		# Provide output for the support.txt file for the -u option
		echo "This option doesn't work in a container"
		$echoline
	endif
endif

# Clean up the install directory since the files are owned by root
sudo rm -rf install

echo "# Checking database"
$gtm_tst/com/dbcheck.csh
$echoline

# The -h|--help test doesn't run the script, so won't show up in num_pass
@ cnt--
set num_pass = `cat ydb_support-*.log | grep -c '## Done getting information, packing tarball'`
echo "# Test that $num_pass of $cnt tests succeeded"
grep -q --exclude=ydb_support-1.log "non-zero status" ydb_support-*.log

if ((! $status) || ($num_pass != $cnt)) then
	echo "# Test failed. Check ydb_support-*.log"
else
	echo "# Test succeeded."
endif
