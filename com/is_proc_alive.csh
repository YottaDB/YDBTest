#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2003-2015 Fidelity National Information 	#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
#								#
# Copyright (c) 2020 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
#
# $1 - process-id
# $2 - filename to log details [Optional - defalts to isprocalive.out]
#
# Exits with normal status   (i.e. 0) if process $1 is alive
# Exits with abnormal status (i.e. 1) if process $1 is not alive
#
set pidtowait=`\echo $1 | $tst_awk '/^[0-9]*$/'`
if ("$pidtowait" == "") then
	echo "TEST-E-IS_PROC_ALIVE null is passed as parameter"
	exit 2
endif

if ("" != "$2") then
	set logfile = "$2"
else
	set logfile = isprocalive.out
endif

# If it is not used by a test, do not log the output. Logging the output is only for debugging purpose.
# Non-test usages might create the output file at odd places like /usr/library or if created in $HOME will create unison issues
if !($?tst) then
	set logfile = "/dev/null"
endif

# NOTE : Since this is a more generic tool (can be used even by $cms_tools etc), check before using test system specific env.variables
if !($?gtm_test_osname) then
	set os_name = `echo $HOSTOS | sed 's/\///g' | tr '[A-Z]' '[a-z]'`
	if ($os_name =~ "cygwin*") then
		set os_name = "cygwin"
	endif
	set gtm_test_osname  = "$os_name"
endif


echo "checking $pidtowait at `date`" >>&! $logfile
if ( "os390" == $gtm_test_osname ) then
	# In zOS, a process could be shown by ps as alive even though it is actually dead (in a "canceled" state)
	# see sr_unix/is_proc_alive.c for comment on this. Thankfully, "kill -0 $pid" seems to return 0 if the pid (BYPASSOK kill)
	# exists and non-zero if it does not. Surprisingly, this seems to work even if the pid is owned by a different
	# userid so is a more general solution than is currently implemented in sr_unix/is_proc_alive.c
	kill -0 $pidtowait >>& $logfile # BYPASSOK kill
	set stat = $status
else if ("cygwin" != "$gtm_test_osname") then
	# We need the distribution name to properly determine method as Alpine Linux does not have all the
	# extra amenities that glibc provides.
	if (("linux" == "$gtm_test_osname") && ("alpine" == "$gtm_test_linux_distrib")) then
		kill -0 $pidtowait >>& $logfile # BYPASSOK kill
		set stat = $status
	else
		ps -fp $pidtowait >>& $logfile # BYPASSOK ps
		set stat = $status
	endif
else
	ps -p $pidtowait |& $tst_awk '{ print $1 }' |& grep $pidtowait >>& $logfile # BYPASSOK ps
	set stat = $status
endif

if ( (0 == $stat) && ("hp-ux" == "$gtm_test_osname") ) then
	# If the process is alive and if the os is hp-ux or aix,
	# ignore <defunct> processes and treat them as dead since they are dead as far as the test system is concerned
	# The only reason they are alive is for the init process to do a waitpid() which is an OS thing, nothing related to GT.M.
	# check <defunct_process_with_ppid_of_1_in_ps_listing>
	# check <defunct_process_causes_WAITPROCALIVE_E_WAITTOOLONG/v5> for why this should not be done on AIX
	set iszombie = `ps -lp $pidtowait | $tst_awk '{if ($2=="Z") print $2}'`	# BYPASSOK ps
	if ("Z" == "$iszombie") then
		exit 1
	else
		exit 0
	endif
else
	exit $stat
endif
