#################################################################
#								#
#	Copyright 2006, 2014 Fidelity Information Services, Inc	#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
# Do not try to add a tcsh header line for this script
# The reason is, this script is source'd, so that line never gets executed, so we actually did not have the -x output.
# A set echo is added for the effect of -x."
##########################################################################################################
# This script creates the working directories - database,journal,backups - for a given number of instances
# You can specify two number of instances.  The first argument is the number of non-supplementary
# instances, the second argument is optional and is the number of supplementary instance.
# It sets up the necessary environment - variables and files for those instances
# The script creates a config.file where all related details of an instance goes in
##########################################################################################################
#
echo "######################## Begin multisite_prepare ################################"
set echo
# re-define test_repl variable here to be MULTISITE from NULL. This is crucial throughout the run
# as it determines the way in which the existing framewrok scripts behave for msr tests
if ($?test_replic) then
	if ("MULTISITE" != "$test_replic") then
		# If this test was not submitted with -multisite, then it was meant to run on a single host only
		unsetenv tst_remote_dir_ms_1
	endif
	setenv test_replic "MULTISITE"
else
	echo "TEST-E-MULTISITE-NO-REPLIC error. msr tests must be called with replic option.Pls. resubmit"
	unset echo;exit 1
endif
###################################################################################################################
# section to hold common aliases and env's to be used by msr tests
#
# set an env. to call multisite_replic.csh
setenv MSR "source $gtm_tst/com/multisite_replic.csh"
# set an env. to call multisite_replic_env.csh, this will be used by other tests as well if found necessary
setenv MULTISITE_REPLIC_ENV "source $gtm_tst/com/multisite_replic_env.csh"
# set an alias that will be used by msr scripts to know the timestamp of the last executed action
alias get_msrtime 'set time_msr=`$tst_awk -F":" '"'"'{print $2}'"'"' $msr_execute_last_out|$tail -n 1`;if ( "" == "$time_msr" ) echo "Error grabbing time from msr_action outfile"'
setenv msr_err_chk "$gtm_tst/com/check_error_exist.csh"
#
###################################################################################################################
set insno = $1
if (2 == $#argv) then
	set suppinsno = $2
else
	set suppinsno = 0
endif
set testcleanupcsh = "../cleanup.csh"
set generalcleanupcsh = "../../cleanup.csh"
if ((0 == $insno) && (0 == $suppinsno)) then
	# this was a dummy call to pick up environment variables, so exit
	unset echo;exit 0
endif
@ totalinsno = $insno + $suppinsno
if ($?gtm_test_base_inst_name) then
	set base_inst_name = $gtm_test_base_inst_name
else
	set base_inst_name = "INSTANCE"
endif
# config file holding multisite_replic informations
set file = $tst_working_dir/msr_instance_config.txt
echo "INSTANCE_COUNT:	$totalinsno" >&! $file
#
# First fill in the primary instance INST1 details.
echo "INST1	INSTNAME:	${base_inst_name}1" >>&! $file
echo "INST1	VERSION:	$tst_ver" >>&! $file
echo "INST1	IMAGE:		$tst_image" >>&! $file
echo "INST1	DBDIR:		$tst_working_dir" >>&! $file
echo "INST1	JNLDIR:		$test_jnldir" >>&! $file
echo "INST1	BAKDIR:		$test_bakdir" >>&! $file
echo "INST1	HOST:		HOST1" >>&! $file
echo "INST1	HOSTNAME:	${tst_org_host:r:r:r}" >>&! $file
echo "INST1	PORTNO:	UNINITIALIZED" >>&! $file
if (0 == $insno) then
	echo "INST1	SUPP:	TRUE"	>>&! $file
else
	echo "INST1	SUPP:	FALSE"	>>&! $file
endif
# fill in the HOST1 details
echo "HOST1	NAME:	$tst_org_host" >>&! $file
echo "HOST1	SHELL:	$pri_shell" >>&! $file
set detailedhost = 1
# we keep getenv.csh always because sometimes HOST1 runs on different version and remote_ver will be set accordingly before
# fetching this detail
echo 'HOST1	GETENV:	source $gtm_tst/com/pri_getenv.csh $pri_ver $pri_image' >>&! $file

# The loop runs under the framework structure assumption that ROOT instance will be on the host side
# and all other instances (propagating,secondary,tertiary etc.) are on the remote side.
set loopcnt=2
if ($?tst_remote_dir_ms_1) then	# if there is at least one different remote host
	set roundcnt = 0	# init
	set totalrmtdircnt = `setenv | $grep "tst_remote_dir_ms_" | wc -l`
	if (totalrmtdircnt == 0) then
		set totalrmtdircnt = `setenv | $grep "tst_remote_dir_" | wc -l`
	endif
endif
while ($loopcnt <= $totalinsno)
	echo "--------------------------"
	#Determine remote location (host and directory)
	set tst_remote_dir_rmtcnt = tst_remote
	if ($?roundcnt) then	#i.e. multiple remote hosts involved
		# loop around as many remote hosts as you have in a round-robin fashion
		@ roundcnt = $roundcnt + 1
		if ($roundcnt > $totalrmtdircnt) then
			set roundcnt = 1	#next round
			set roundcomplete
		endif
		eval 'set tst_remote_dir_base = $tst_remote_dir_ms_'$roundcnt
		eval 'set tst_remote_host_loopcnt = $tst_remote_host_ms_'$roundcnt
		@ hostcnt = $roundcnt + 1	#HOST1 is local
	else
		set tst_remote_dir_base = $tst_remote_dir
		set tst_remote_host_loopcnt = $tst_remote_host
		set hostcnt = 2
	endif
	if ($tst_org_host != $tst_remote_host_loopcnt) then
		set logon = "$rsh $tst_remote_host_loopcnt "
		set logon_nouser = "$rsh $tst_remote_host_loopcnt"
	else
		set logon = ""
		set logon_nouser = ""
	endif
	# create directories to house the remote instances
	# define the directories
	set dbdirx = $tst_remote_dir_base/$gtm_tst_out/$testname/$test_subtest_name/instance$loopcnt
	# create DBDIR
	$logon mkdir -p $dbdirx
	if ( $status ) then
		echo "TEST-E-REMOTEDIR, could not create DBDIR on the remote side"
	endif
	if ($?roundcnt) then    #i.e. multiple remote hosts involved
		# if running on multiple servers, don't worry about jnldir or bakdir, use defaults
		set jnldirx = $dbdirx
		set bakdirx = $dbdirx/bak
	else
		# running on a single machine, the user might define other dirs
		set jnldirx = $test_remote_jnldir/instance$loopcnt
		set bakdirx = $test_remote_bakdir/instance$loopcnt
		# create JNLDIR
		$logon mkdir -p $jnldirx
		if ( $status ) then
			echo "TEST-E-REMOTEDIR, could not create JNLDIR on the remote side"
		endif
	endif
	# create BAKDIR
	$logon mkdir -p $bakdirx
	if ( $status ) then
		echo "TEST-E-REMOTEDIR, could not create BAKDIR on the remote side"
	endif
	if ($detailedhost < $hostcnt) then	#if we have not detailed this host yet
		echo "HOST$hostcnt	NAME:	$tst_remote_host_loopcnt" >>&! $file
		if ( $tst_org_host != $tst_remote_host_loopcnt ) then
			echo "HOST$hostcnt	GETENV:	source $gtm_tst/com/remote_getenv.csh CUR_DIR" >>&! $file
			echo "HOST$hostcnt	SHELL:	$rsh $tst_remote_host_loopcnt" >>&! $file
			#we need to send the environment in that case
			set do_send_env
		else
			echo "HOST$hostcnt	GETENV:	source $gtm_tst/com/getenv.csh" >>&! $file
			echo "HOST$hostcnt	SHELL:	$pri_shell" >>&! $file
		endif
		# write an entry into cleanup.csh files for the directory on the hosts involved:
		set cleanupdirx = $tst_remote_dir_base/$gtm_tst_out
		$grep -E "${logon_nouser}.*$cleanupdirx/$testname" $testcleanupcsh >& /dev/null
		if ($status) echo "#1#${logon_nouser} 'rm -rf $cleanupdirx/$testname' >& /dev/null" >>! $testcleanupcsh
		$grep -E "${logon_nouser}.*$cleanupdirx/.*__$testname" $testcleanupcsh >& /dev/null
		if ($status) echo "#2#${logon_nouser} 'rm -rf $cleanupdirx/*__$testname' >& /dev/null" >>! $testcleanupcsh
		$grep -E "${logon_nouser}.*$cleanupdirx" $generalcleanupcsh >& /dev/null
		if ($status) echo "#3#${logon_nouser} 'rm -rf $cleanupdirx' >& /dev/null" >>! $generalcleanupcsh
		set detailedhost = $hostcnt	#detailedhost goes up, once you detail one host, no need to detail it again
	endif
	echo "INST$loopcnt	INSTNAME:	${base_inst_name}$loopcnt" >>&! $file
	if (($remote_ver != $tst_ver) || (! $?gtm_test_msr_smallenvironment)) then
		echo "INST$loopcnt	VERSION:	$remote_ver" >>&! $file
	endif
	if (($remote_image != $tst_image) || (! $?gtm_test_msr_smallenvironment)) then
		echo "INST$loopcnt	IMAGE:		$remote_image" >>&! $file
	endif
	echo "INST$loopcnt	DBDIR:		$dbdirx" >>&! $file
	if  (($jnldirx != $dbdirx) || (! $?gtm_test_msr_smallenvironment)) then
		echo "INST$loopcnt	JNLDIR:		$jnldirx" >>&! $file
	endif
	echo "INST$loopcnt	BAKDIR:		$bakdirx" >>&! $file
	echo "INST$loopcnt	HOST:		HOST$hostcnt" >>&! $file
	echo "INST$loopcnt	HOSTNAME:	${tst_remote_host_loopcnt:r:r:r}"	>>&! $file
	# portno will be substituted on the fly later
	echo "INST$loopcnt	PORTNO:	UNINITIALIZED" >>&! $file
	if ($loopcnt > $insno) then
		echo "INST$loopcnt	SUPP:	TRUE"	>>&! $file
	else
		echo "INST$loopcnt	SUPP:	FALSE"	>>&! $file
	endif
	# should we create primary_dir testdirs file like for a normal remote dir? I don't think it helps here but should clarify!
	@ loopcnt = $loopcnt + 1
end

# to set env. variables for each of the attribute prepared by this script for every instance
$MULTISITE_REPLIC_ENV

if ($?do_send_env) then
	# call send_env, but call it thorough $MSR so that the correct values are defined for each host
	foreach instx (`echo $gtm_test_msr_all_instances|sed 's/INST1 //g'`)
		$MSR RUN SRC=INST1 RCV=$instx 'setenv INSTXNAME __RCV_INSTNAME__; $gtm_tst/com/send_env.csh'
	end
endif
#
################################
# now that everything is setup, we can use $MSR to do other tasks

# let's note down the directories involved on all locations
# the following might not be the most efficient way, but since it is in the same style as
# multisite_replic.awk, it is easier to maintain.
$tst_awk '	/^HOST.*NAME:/ {hostinfo_name[$1]=$3}				\
		/^HOST.*GETENV:/ {hostinfo_dir[$1]=$NF}				\
		/^INST.*HOST:/ {instinfo_host[$1]=$3}				\
		/^INST.*INSTNAME:/ {instinfo_instname[$1]=$3}			\
		/^INST.*DBDIR:/ {instinfo_dbdir[$1]=$3}				\
	    END { for (i in instinfo_dbdir)					\
		  {	hname = hostinfo_name[instinfo_host[i]];                \
			print hname ": " instinfo_dbdir[i];			\
		  }								\
		}' msr_instance_config.txt >! testdirs.txt
foreach instx (`echo $gtm_test_msr_all_instances|sed 's/INST1 //g'`)
	$MSR RUN SRC=INST1 RCV=$instx '$gtm_tst/com/cp_remote_file.csh __SRC_DIR__/testdirs.txt _REMOTEINFO___RCV_DIR__/../..'
end

# let's check remote versions:
if ($?tst_remote_dir_1) then	# if there is at least one different remote host
	foreach instx (`echo $gtm_test_msr_all_instances|sed 's/INST1 //g'`)
		echo "Checking ${instx}:" >>&! remote_gtm_exe_check.out
		$MSR RUN $instx 'set msr_dont_trace; file $gtm_exe' >>& remote_gtm_exe_check.out
	end
	$MSR RUN INST1 'set msr_dont_trace; echo' # to set all PRI* environment variables straight again
	$grep "No such file" remote_gtm_exe_check.out >& /dev/null
	if (! $status) then
		echo "MSR-E-REMOTE_GTM_EXE, one (or more) of remote versions not available. Check remote_gtm_exe_check.out"
		unset echo;exit 1
	endif
endif
echo "#################### End of multisite_prepare ####################################"
unset echo
#
