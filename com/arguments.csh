#################################################################
#								#
# Copyright (c) 2013-2016 Fidelity National Information		#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
#								#
# Copyright (c) 2018 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
##HELP_SCREEN Simple Help on
##HELP_SCREEN  The arguments' meanings
##HELP_SCREEN  And the environment variable set with each argument
##HELP_SCREEN Quick guide: gtmtest.csh -t <test_name> -s <test source dir> -v <Version> -<bg/mm/GT.M/GT.CM/replic/reorg/encrypt.....> ....

##HELP_SCREEN

######
#Parse command line
#this might be arguments like gtm nomail
#
# or  environment variables set at command line
# like v V40001G
#
# or a file to be read can be specified (another rc file that is not .testrc)
# this file can have setenv's or test configurations
@ argc1 = 1  #show next argument
foreach arg  ($argv)
   #set arg_ignore_case = `echo $arg|awk '{print toupper($1)}'`
   @ argc1 = $argc1 + 1
   set tmp_arg = `echo $arg|cut -b 2-`
   if ($?skip) then
      unset skip
   else
switch($arg)
case "-report":
	    ##HELP_SCREEN -report on or -report off
	    ##HELP_SCREEN to set report sending (the final mail) on or off
	    ##HELP_SCREEN default is on for more than a single test
	    setenv test_send_report `echo $argv[$argc1] |  tr '[a-z]' '[A-Z]'`
	    set skip
breaksw
case "-debug":
	    ##HELP_SCREEN print environment into a file
	    ##HELP_SCREEN for debugging
	    setenv test_debug
	    #setenv tst_keep_output
breaksw
case "-L":
case "-E":
case "-light":
case "-full":
case "-extended":
	    ##HELP_SCREEN RUN the selected tests with their L/E versions ($LFE)
	    setenv LFE $tmp_arg
	    breaksw
case "-L_ALL":
case "-E_ALL":
case "-M_ALL":
case "-T_ALL":
	    ##HELP_SCREEN RUN THE L/E suites completely ($bucket)
	    setenv bucket "$tmp_arg"
	    #the first character of each element of $bucket is taken as bucket
	    #you still have to process the arguments for the options
breaksw
case "-suite":
	    ##HELP_SCREEN start all tests in the SUITE specified by the next argument.
	    setenv  bucket "$argv[$argc1]"
	    set skip
breaksw
case "-minorbucket":
case "-bucket":
	    ##HELP_SCREEN RUN L/E buckets of the selected tests ($minorbucket)
	    # run LE versions of all tests from command line and request file
	    # so LE of selected tests
	    #must parse arguments
	    setenv minorbucket
breaksw
case "-distributed":
	    ##HELP_SCREEN This test invocation is a part of distributed run. The file passed controls the distribution
	    set param = "$argv[$argc1]"
	    set file = `echo $param | cut -d : -f 1`
	    if ((-d /gtc/staff/$USER/logs) && (-w /gtc/staff/$USER/logs)) then
		    setenv test_distributed /gtc/staff/$USER/logs/$file
	    else
	    	    # This is intentionally ~/ just in case the entire /gtc/staff/$USER doesn't exist. (~ is not equivalent to /gtc/staff/$USER always)
		    setenv test_distributed ~/$file
	    endif
	    set srvr = `echo "${param}:" | cut -d : -f 2`
	    if ("" == "$srvr") then
	    	setenv test_distributed_srvr "$tst_tcsh -c"
	    else
	    	setenv test_distributed_srvr "$rsh $srvr"
	    endif
	    set skip
breaksw
case "-exclude_servers":
	    ##HELP_SCREEN comma separated list of servers to be excluded from running test (in this case as remote buddies)
	    if ($?exclude_servers) then
		    setenv  exclude_servers "${exclude_servers},$argv[$argc1]"
	    else
		    setenv  exclude_servers "$argv[$argc1]"
	    endif
	    set skip
breaksw
case "-MM":
case "-mm":
	    ##HELP_SCREEN Set access method MM ($acc_meth)
	    setenv acc_meth MM
breaksw
case "-BG":
case "-bg":
	    ##HELP_SCREEN Set access method BG ($acc_meth)
	    setenv acc_meth BG
breaksw
case "-s":
	    ##HELP_SCREEN Test Source Directory ($tst_src) is set to next argument
	    setenv tst_src $argv[$argc1]
	    set skip
breaksw
case "-noreo*":
case "-NOREO*":
case "-no[n|_]reo*":
case "NO[N|_]REO*":
case "-non_reo*":
case "NON_REO*":
	    ##HELP_SCREEN Test will be run with MUPIP REORG off ($test_reorg)
	    setenv test_reorg NON_REORG
breaksw
case "-noco*":
case "-NOCO*":
case "-no[n|_]co*":
case "NO[N|_]CO*":
case "-non_co*":
case "NON_co*":
	    ##HELP_SCREEN Test will be run with default collation value (0)
	    setenv test_collation NON_COLLATION
	    setenv test_collation_value "default"
breaksw
case "-reo*":
case "-REO*":
	    ##HELP_SCREEN  Test will be run with MUPIP REORG on ($test_reorg)
	    setenv test_reorg REORG
breaksw
case "-repl":
case "-replic":
	    ##HELP_SCREEN Test will be run with Replication ON ($test_repl=REPLIC)
	    setenv test_repl REPLIC
breaksw
case "-MULTI*SITE":
case "-multi*site":
	    ##HELP_SCREEN Test will be run with Replication ON on multiple machines
	    ##HELP_SCREEN Also note that when running with -multisite, you cannot specify different remote hosts or
	    ##HELP_SCREEN versions. They will be picked up automatically.
	    setenv test_repl REPLIC
	    # don't set test_replic_mh_type 1 if test_replic_mh_type is already set to 2 by this script
	    if (! $?arguments_xendian) then
		    setenv test_replic_mh_type 1
	    endif
breaksw
case "-XENDIAN":
case "-xendian":
	    ##HELP_SCREEN Test will be run with Replication ON on multiple machines of opposite endianness
	    ##HELP_SCREEN Also note that when running with -xendian, you cannot specify different remote hosts or
	    ##HELP_SCREEN versions. They will be picked up automatically.
	    set arguments_xendian = 1
	    setenv test_repl REPLIC
	    setenv test_replic_mh_type 2
breaksw
case "-CO*":
case "-co*":
	    ##HELP_SCREEN Test will be run with collation on
	    ##HELP_SCREEN This argument might have a qualifier for the collation number and collation routines file
	    ##HELP_SCREEN the qualifier must be comma seperated (e.g. -coll 3,~/mycollation.c)
	    ##HELP_SCREEN polish collation (1) is the default if the collation value is not specified
	    # -collation 1,/usr/library/sfdfddfss.c
	    setenv test_collation COLLATION
	    # Check if it has a qualifier
	    # first check if this is the last argument
	    if ($argc1 > $# ) breaksw
	    # then check if the next argument is another argument on its own (i.e. "-*")
	    if ( "$argv[$argc1]" =~ -*) breaksw
	    # then check if it is actually a number
	    setenv test_collation_value $argv[$argc1]
	    setenv test_collation_submit_dir `pwd`
	    set skip
breaksw
case "-norep*":
case "-NOREP*":
case "-no[n|_]rep*":
case "-NO[N|_]REP*":
case "-non_rep*":
case "-NON_REP*":
	    ##HELP_SCREEN Test will be run with Replication OFF ($test_repl=NON_REPLIC)
	    setenv test_repl NON_REPLIC
breaksw
case "-noni*":
case "-NONI*":
case "-no[n|_]ni*":
case "-NO[N|_]NI*":
case "-non_ni*":
case "-NON_NI*":
case "-unni*":
	   ##HELP_SCREEN Test will not be run with nice ($test_nice=UNNICE)
	   setenv test_nice UNNICE
breaksw
case "-nomail":
case "-no_m*":
case "-nm":
	    ##HELP_SCREEN No mail will be sent ($tst_dont_send_mail)
	    #set up mail routine so that mail won't be sent
	    setenv tst_dont_send_mail
breaksw
case "-failmail":
	    ##HELP_SCREEN Mail will be sent only if test fails (no mail sent if test passes)
	    ##HELP_SCREEN optionally followed by the maximum number of test failures to be sent
	    ##HELP_SCREEN no mail will be sent for the failed tests beyond that number
            setenv gtm_test_fail_mail 9999
	    # Check if it has a qualifier
	    # first check if this is the last argument
	    if ($argc1 > $# ) breaksw
	    # then check if the next argument is another argument on its own (i.e. "-*")
	    if !( "$argv[$argc1]" =~ -*) then
	    	#if ("-" != `echo $argv[$argc1] | cut -b 1`) then
	        setenv gtm_test_fail_mail $argv[$argc1]
		set skip
	    endif
breaksw
case "-failsubtestmail":
	    ##HELP_SCREEN The failmail will automatically send diff of the subtests too
	    ##HELP_SCREEN This is present here only for backward compatibility
	    # Check if it has a qualifier (but ignore it)
	    # first check if this is the last argument
	    if ($argc1 > $# ) breaksw
	    # then check if the next argument is another argument on its own (i.e. "-*")
	    if !( "$argv[$argc1]" =~ -*) then
		set skip
	    endif
breaksw
case "-procstuckmail":
	    ##HELP_SCREEN Mail alerts from gtmprocstuck_get_stack_trace.csh for 30 second hangs will be sent
	    ##HELP_SCREEN By default, only for a 5 minute hang, mail alert will be sent
	    setenv gtm_procstuck_mail
breaksw
case "-k*":
	    ##HELP_SCREEN The output will not be removed even if test is successful ($tst_keep_output)
	    setenv tst_keep_output
breaksw
case "-v*":
	    ##HELP_SCREEN Version tested is set to next argument ($tst_ver)
	    setenv tst_ver `echo $argv[$argc1] |  tr '[a-z]' '[A-Z]'`
	    set skip
breaksw
case "-ml":
case "-mail*":
	    ##HELP_SCREEN Mail will be sent to the mailing list in the next argument ($mailing_list)
	    #setup mailing list
	    setenv  mailing_list  $argv[$argc1]
	    set skip
breaksw
case "-o*":
	    ##HELP_SCREEN Output directory will be set to the next argument ($tst_dir)
	    if ( -w $argv[$argc1] ) then
		    setenv tst_dir $argv[$argc1]
	    else
		    mkdir -p  $argv[$argc1] >& /dev/null
		    if ($status) then
			    echo "cannot write to $argv[$argc1], $tst_dir is output directory"
		    else
			   setenv tst_dir $argv[$argc1]
		    endif
	    endif
	    set skip
breaksw
case "-no_o*":
case "-noo*":
	    ##HELP_SCREEN No output will remain when test is finished ($tst_no_output)
	    setenv tst_dir /tmp #/$USER
	    if (!(-d $tst_dir)) then
	    \mkdir $tst_dir
	    endif
	    setenv tst_no_output
breaksw
case "-stdout":
	    ##HELP_SCREEN Output directly to stdout, config file, output file, and diff file (if it exists)
	    setenv tst_stdout 1
breaksw
case "-fg":
	    ##HELP_SCREEN Run the test(s) in the foreground
	    ##HELP_SCREEN Tests are run in the background by default
	    setenv test_no_background
breaksw
case "-ru":
case "-remote_u*":
case "-remoteu*":
	    ##HELP_SCREEN Remote User ($tst_remote_user) is set to next argument
	    setenv tst_remote_user $argv[$argc1]
	    set skip
breaksw
case "-rv":
case "-remote_v*":
case "-remotev*":
	    ##HELP_SCREEN Remote Version ($remote_ver) is set to next argument
	    setenv remote_ver $argv[$argc1]
	    set skip
breaksw
case "-rv*gtcm":
case "-remote_v*gtcm":
case "-remotev*gtcm":
	    ##HELP_SCREEN GT.CM Remote Version ($remote_ver_gtcm) is set to next argument
	    ##HELP_SCREEN It should be a comma separated list (refer to the explanation of rh_gtcm)
	    setenv remote_ver_gtcm $argv[$argc1]
	    set skip
breaksw
case "-ri":
case "-remote_i*":
case "-remotei*":
	    ##HELP_SCREEN Remote Image ($remote_image) is set to next argument
	    setenv remote_image $argv[$argc1]
	    set skip
breaksw
case "-ri*gtcm":
case "-remote_i*gtcm":
case "-remotei*gtcm":
	    ##HELP_SCREEN GT.CM Remote Image ($remote_image_gtcm) is set to next argument
	    ##HELP_SCREEN It should be a comma separated list (refer to the explanation of rh_gtcm)
	    setenv remote_image_gtcm $argv[$argc1]
	    set skip
breaksw
case "-rh*gtcm":
case "-remote_h*gtcm":
case "-remoteh*gtcm":
	    ##HELP_SCREEN GT.CM Remote Host ($tst_gtcm_remote_host) is set to next argument
	    ##HELP_SCREEN It should be a comma separated list of hosts, such as host1,host2,host3
	    ##HELP_SCREEN The order of $tst_remote_dir should match the order of the host list
	    setenv tst_gtcm_remote_host $argv[$argc1]
	    set skip
breaksw
case "-rh":
case "-remote_h*":
case "-remoteh*":
	    ##HELP_SCREEN Remote Host ($tst_remote_host) is set to next argument
	    setenv tst_remote_host $argv[$argc1]
	    set skip
breaksw
case "-rd*gtcm":
case "-ro*gtcm":
case "-remote_d*gtcm":
case "-remoted*gtcm":
	    ##HELP_SCREEN Remote Output Directory ($tst_gtcm_remote_dir) is set to next argument
	    ##HELP_SCREEN It should be a comma separated list of directories,
	    ##HELP_SCREEN matching the order of the host list
	    setenv tst_gtcm_remote_dir $argv[$argc1]
	    set skip
breaksw
case "-rd":
case "-ro":
case "-remote_d*":
case "-remoted*":
	    ##HELP_SCREEN Remote Output Directory ($tst_remote_dir) is set to next argument
	    setenv tst_remote_dir $argv[$argc1]
	    set skip
breaksw
case "-buff_size":
	    ##HELP_SCREEN Global buffer Size ($tst_buffsize) is set to next argument
	    setenv tst_buffsize $argv[$argc1]
	    set skip
breaksw
case "-alignsize":
case "-align":
	    ##HELP_SCREEN Journaling alignment ($test_align) is set to next argument
	    setenv test_align $argv[$argc1]
	    set skip
breaksw
case "-journal":
case "-jnl":
	    ##HELP_SCREEN Journaling ($tst_jnl_str = before/nobefore) is set to next argument
	    setenv tst_jnl_str "-journal=enable,on,$argv[$argc1]"
	    if ("nobefore" == "$argv[$argc1]") then
	    	setenv gtm_test_jnl_nobefore 1
	    else
	    	setenv gtm_test_jnl_nobefore 0
	    endif
	    set skip
breaksw
case "-setjnl":
case "-setjournal":
case "-set_jnl":
case "-set_journal":
	##HELP_SCREEN Journalling will be turned on while testing ($gtm_test_jnl)
	setenv gtm_test_jnl "SETJNL"
breaksw
case "-jnldir":
case "-tst_jnldir":
	##HELP_SCREEN Journaling of primary side will start in the directory pointed by the next argument ($tst_jnldir)
	##HELP_SCREEN The test scripts will derive $test_jnldir from this
	setenv tst_jnldir $argv[$argc1]
	set skip
breaksw
case "-remote_jnldir":
case "-tst_remote_jnldir":
	##HELP_SCREEN Journaling of secondary side will start in the directory pointed by the next argument ($tst_remote_jnldir)
	##HELP_SCREEN The test scripts will derive $test_remote_jnldir from this
	setenv tst_remote_jnldir $argv[$argc1]
	set skip
breaksw
case "-bakdir":
case "-tst_bakdir":
case "-backup_dir":
	##HELP_SCREEN Backup directory for the primary side will be the directory pointed by the next argument ($tst_bakdir)
	##HELP_SCREEN The test scripts will derive $test_bakdir from this
	setenv tst_bakdir $argv[$argc1]
	set skip
breaksw
case "-remote_bakdir":
case "-tst_remote_bakdir":
case "-remote_backup_dir":
	##HELP_SCREEN  Backup directory for the secondary side will be the directory pointed by the next argument ($tst_remote_bakdir)
	##HELP_SCREEN The test scripts will derive $test_remote_bakdir from this
	setenv tst_remote_bakdir $argv[$argc1]
	set skip
breaksw
case "-noline*":
case "-NOLINE*":
	    ##HELP_SCREEN Run the M code with NOLINE_ENTRY
	    ##HELP_SCREEN Note that the default is no NOLINE_ENTRY
	    setenv gtm_test_nolineentry NOLINE
breaksw
case "-num_runs":
	    ##HELP_SCREEN Number of Runs ($test_num_runs) is set to next argument
	    setenv test_num_runs $argv[$argc1]
	    set skip
breaksw
case "-GT.M":
case "-gt.m":
case "-GTM":
case "-gtm":
	    ##HELP_SCREEN Test GT.M ($test_gtm_gtcm)
	    setenv test_gtm_gtcm "GT.M"
breaksw
case "-gtcm":
case "-gt.cm":
case "-GTCM":
case "-GT.CM":
	    ##HELP_SCREEN Test GT.CM ($test_gtm_gtcm)
	    setenv test_gtm_gtcm "GT.CM"
breaksw
case "-TP":
case "-tp":
	    ##HELP_SCREEN  TP ($gtm_test_tp)
	    setenv gtm_test_tp "TP"
breaksw
case "-notp":
case "-NOTP":
case "-no[n|_]tp":
case "-NO[N|_]TP":
case "-non_tp":
case "-NON_TP":
	    ##HELP_SCREEN NON_TP  ($gtm_test_tp)
	    setenv gtm_test_tp "NON_TP"
breaksw
case "-testtiminglog":
	    ##HELP_SCREEN log results into timing.info
	    setenv testtiming_log
breaksw
case "-testresultslog":
	    ##HELP_SCREEN log results into testresults.csv
	    setenv testresults_log
breaksw
case "-nozip":
case "-no_zip":
case "-dontzip":
	    ##HELP_SCREEN Do not zip the tmp directory  (or sub-test directory) contents
	    setenv test_dont_zip
	    breaksw
case "-nodbxcstack":
case "-nodbx*":
	    ##HELP_SCREEN Disable the use of the debugger.
	    ##HELP_SCREEN Use this option when the debugger bogs down the system like on
	    ##HELP_SCREEN z/OS.  You need this option for an L_ALL or E_ALL
	    setenv tst_disable_dbx
	    breaksw
case "-f":
	    ##HELP_SCREEN The next argument specifies the test request file
	    ##HELP_SCREEN which might have ordinary shell commands
	    ##HELP_SCREEN or requests in the form
	    ##HELP_SCREEN <request/exclude> <test_name_1> <conf_1>
	    ##HELP_SCREEN where <request/exclude> is either -t or -x
	    \cat $argv[$argc1] >>! $test_list
	    set skip
breaksw
case "-t":
	    ##HELP_SCREEN The next argument is the name of the test requested
	    #test given at command line
	    # setenv tst_suite "$tst_suite _1_$argv[$argc1]"
	    #check if next argument is a valid test name, maybe
	    echo "-t" $argv[$argc1] >>! $test_list
	    set skip
breaksw
case "-st":
case "-subtest":
	    ##HELP_SCREEN The next argument is the name of the subtests requested (comma seperated)
	    ##HELP_SCREEN Only those subtests requested will be run
	    ##HELP_SCREEN No logs will be kept of this run (forced -nolog)
	    setenv gtm_test_st_list $argv[$argc1]
	    set skip
breaksw
case "-x":
	    ##HELP_SCREEN Exclude following test or option
	    ##HELP_SCREEN Is case sensitive, i.e. -x mm will exclude mm test and -x MM will exclude MM option, since options are writtenin uppercase
	    ##HELP_SCREEN if the following parameter is a file, it assumes the file contains a list of -x <test> entries
	    ##HELP_SCREEN Pattern matching is not done, so -x replic will not exclude replication tests. The options recognized can be seen by submitting with -- option, or from submitted_tests file in the test output directory
	    #exclude test given at command line
	    if (-f $argv[$argc1] ) then
	    	# If the next argument is a file, it would contain a list of tests to exclude
		cat $argv[$argc1] >>&! $test_list
	    else
		echo "-x" $argv[$argc1] >>! $test_list
	    endif
	    set skip
breaksw
case "-dry*":
case "-dryrun":
	##HELP_SCREEN Will not actually submit the tests
	##HELP_SCREEN May be used in reference file creation/checking
	##HELP_SCREEN Note that a warning line will be printed in outstream.log. Remove it when creating the reference file.
	setenv gtm_test_dryrun
breaksw

   #     case "impossible_sample_argument": #to take next arg into a variable
   #	 setenv impossible_sample_case_variable $argv[$argc1]
   #	 set skip #so next argument shall not be parsed
   #	 breaksw
case "-env":
	    ##HELP_SCREEN To set arbitrary environment variables "-env env_var=value"
	    ##HELP_SCREEN Ex: gtmtest.csh -env gtm_test_nomultihost=1 <other options>
	    ##HELP_SCREEN The above will set the env.variable gtm_test_nomultihost to 1
	    ##HELP_SCREEN Setting the above env.variable will disable all multi-host tests like
	    ##HELP_SCREEN GT.CM tests, multi_machine, dualfail_ms and MULTISITE option of multisite_replic test
	    set temp = `echo $argv[$argc1]|cut -f 1 -d "="`
	    set value = `echo $argv[$argc1]|cut -f 2 -d "="`
	    setenv $temp  $value
	    set skip
breaksw
case "-h":
case "-help":
	   ##HELP_SCREEN Print help and exit
           $tst_awk -f $gtm_test_com_individual/help_screen.awk $gtm_test_com_individual/arguments.csh |more
	   exit 5
breaksw
case "-dbglvl":
	##HELP_SCREEN $gtmdbglvl is set to next argument
	setenv gtmdbglvl $argv[$argc1]
	set skip
breaksw
case "-dynlit*":
	    ##HELP_SCREEN Selects standard literal compilation
	    setenv gtm_test_dynamic_literals	"DYNAMIC_LITERALS"
breaksw
case "-nodynlit*":
	    ##HELP_SCREEN Selects space-saving dynamic literal compilation
	    setenv gtm_test_dynamic_literals	"NODYNAMIC_LITERALS"
breaksw
case "-list":
	    ##HELP_SCREEN Print list of tests (and their applicabilities)
	    setenv test_list_only
breaksw
case "--":
	    ##HELP_SCREEN print out submitted tests and exit
	    ##HELP_SCREEN for debugging
	    setenv test_debug_print_only
breaksw
case "-buildcycle":
	    ##HELP_SCREEN not intended for use by individual users. Intended for build cycle to log directory information.
	    setenv gtm_test_buildcycle
breaksw
case "-ipcs*":
	    ##HELP_SCREEN Differences in ipcs list causes test to fail
	    setenv tst_ipcs_diff_causes_fail
breaksw
case "-at":
	    ##HELP_SCREEN at functionality, the next argument is taken as the argument to the at command.
	    setenv gtm_test_run_time $argv[$argc1]
	    set skip
breaksw
case "-unicode":
	    ##HELP_SCREEN defines $gtm_chset=UTF-8 and gtm_test_dbdata=UTF-8
	    setenv gtm_test_unicode
breaksw
case "-nounicode":
	    ##HELP_SCREEN defines $gtm_chset=M and gtm_test_dbdata=M
	    setenv gtm_test_nounicode
breaksw
case "-encrypt":
	##HELP_SCREEN -encrypt defines test_encryption=ENCRYPT
	    setenv test_encryption ENCRYPT
	    setenv acc_meth BG # encryption requires BG access method - do not leave acc_meth setting to randomization
breaksw
case "-noencrypt":
        ##HELP_SCREEN -noencrypt defines test_encryption=NON_ENCRYPT
            setenv test_encryption NON_ENCRYPT
breaksw
case "-freeze*":
	    ##HELP_SCREEN Allows mumps processes to freeze on failures defined in custom_errors_sample.txt
	    setenv gtm_test_freeze_on_error	1
breaksw
case "-nofreeze*":
	    ##HELP_SCREEN Disallows mumps processes to freeze on failures
	    setenv gtm_test_freeze_on_error	0
breaksw
case "-qdbr*":
	    ##HELP_SCREEN Allows mumps processes to bypass in gds_rundown
	    setenv gtm_test_qdbrundown	1
breaksw
case "-noqdbr*":
	    ##HELP_SCREEN Disallows mumps processes to bypass in gds_rundown
	    setenv gtm_test_qdbrundown	0
breaksw
case "-side*":
	    ##HELP_SCREEN Selects standard side effect compilation
	    setenv gtm_side_effects	1
breaksw
case "-noside*":
	    ##HELP_SCREEN Selects original GT.M side effect compilation
	    setenv gtm_side_effects	0
breaksw
case "-spannode":
	    ##HELP_SCREEN Forces spanning node testing in all tests
	    setenv gtm_test_spannode	1
breaksw
case "-nospannode":
	    ##HELP_SCREEN Disables spanning node testing in all tests but spanning_nodes
	    setenv gtm_test_spannode	0
breaksw
case "-spanreg":
	    ##HELP_SCREEN Forces spanning node testing in all tests
	    setenv gtm_test_spanreg	1
breaksw
case "-nospanreg":
	    ##HELP_SCREEN Forces spanning node testing in all tests
	    setenv gtm_test_spanreg	0
breaksw
case "-trig*":
	    ##HELP_SCREEN Forces trigger testing in all tests
	    setenv gtm_test_trigger	1
breaksw
case "-notrig*":
	    ##HELP_SCREEN Disables trigger testing in all tests but the triggers test
	    setenv gtm_test_trigger	0
breaksw
case "-defer_allocate":
	    ##HELP_SCREEN The database space is not fully allocated at the database creation and extentions
	    setenv gtm_test_defer_allocate	1
breaksw
case "-nodefer_allocate":
	    ##HELP_SCREEN The database space is fully allocated at the database creation and extentions
	    setenv gtm_test_defer_allocate	0
breaksw
case "-norandomsettings":
	##HELP_SCREEN -norandomsettings disables sourcing of do_random_settings.csh.
	## Thereby avoiding random test-environment settings
	setenv	test_norandomsettings "NON_RANDOM"
breaksw
case "-replay":
	##HELP_SCREEN do_random_settings.csh would source the replay file and not randomize anything
	setenv gtm_test_replay $argv[$argc1]
	set skip
breaksw
case "-tslog":
	##HELP_SCREEN -tslog creates a copy of test and subtest logs with timestamps on each line.
	setenv	gtm_test_tslog	1
breaksw
case "-b*":
	    #image, since bg is caught above, it will not come here
	    ##HELP_SCREEN Image ($tst_image)
	    setenv tst_image bta
breaksw
case "-d*":
	    ##HELP_SCREEN Image ($tst_image)
	    setenv tst_image dbg
breaksw
case "-p*":
	    ##HELP_SCREEN Image ($tst_image)
	    setenv tst_image pro
breaksw
default:
	    echo "Unrecognized option $arg"
	    echo Try \"gtmtest.csh\" for help "(no arguments)"
	    exit 5
endsw
endif
end
if ("$remote_ver" == "default") setenv remote_ver $tst_ver
if ("$remote_image" == "default") setenv remote_image $tst_image

##HELP_SCREEN_PROLOGUE
##HELP_SCREEN
##HELP_SCREEN Exit values of the testsuite
##HELP_SCREEN 0 tests submitted were run and (all) passed
##HELP_SCREEN 1 tests submitted were run and (at least one) failed
##HELP_SCREEN 2 no tests were submitted
##HELP_SCREEN 3 all submitted tests were canceled
##HELP_SCREEN 4 for some reason the tests could not be submitted
##HELP_SCREEN 40 $gtm_dist is not found and environment variables could not be set
##HELP_SCREEN 41 root or library submitted the tests
##HELP_SCREEN 42 gtmtest tried to run the test without specifying another recipient for the mail
##HELP_SCREEN 5 help is output
##HELP_SCREEN 6 Output directory nonexistent, or not writable, or /gtc/... or /usr/...
##HELP_SCREEN 61 Output directory on remote machine could not be created
##HELP_SCREEN 62 the test directory was not found
##HELP_SCREEN 63 Output directory on one of the GT.CM Server hosts could not be created
##HELP_SCREEN
##HELP_SCREEN Important:
##HELP_SCREEN If $gtm_tools is not defined, the version/image options will not be effective
##HELP_SCREEN The environment variables will be extracted from $gtm_dist, or
##HELP_SCREEN can be set in com/gtm_env_missing_csh
