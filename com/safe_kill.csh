#!/usr/local/bin/tcsh -f
#################################################################
#								#
#	Copyright 2014 Fidelity Information Services, Inc	#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################

#
# Script that safely KILLs the target list of pids. The need for saftey is the
# handling of PIDs 0, -1 and all negative numbers. For instance on Linux -1
# will kill all processes. On SVR5 platforms 0 kills all processes within a
# process group, -1 kills all processes and a negative value will kill all
# process with process group id of the absolute value of the target
#

@ scriptstat = 0
set killed_pids = ()

# The script takes a signal and list of PIDs as parameters. Without any
# arguments, you get the help below. The primary purpose is to avoid killing
# invalid PIDs. If during the course of evaluation a PID is deemed invalid, the
# script exits with an error message.
#
# Since we often need to wait for processes to die, the script can be source'd
# for the list of PIDs, $killed_pids which is ALWAYS defined such that the
# caller need not validate it's existence.
if ( $#argv < 1 ) then
	echo "To kill all pids safely"
	echo "  $0 [-signal] pid1 pid2 ...."
	echo ""
	echo "To kill all pids and then wait on the list of killed pids"
	echo "  source $0 [-signal] pid1 pid2 ...."
	echo "  foreach pid ( \$killed_pids )"
	echo "    \$gtm_tst/com/wait_for_proc_to_die.csh \$pid"
	echo "  end"
	exit 1
endif

# kill defaults to SIGTERM aka -15
set signal = -15
# If argc == 1 the next argument is a PID. If argc > 1
if ( $#argv > 1 && "$1" =~ -* ) then
	set signal = $1
	shift
endif

# Remaining arguments are PIDs
foreach pid ( $* )
	# Match up to 10 digits, otherwise it's a string. Please see below for
	# more information about PID length.
	if ( "$pid" !~ [0-9]{,[0-9]{,[0-9]{,[0-9]{,[0-9]{,[0-9]{,[0-9]{,[0-9]{,[0-9]{,[0-9]}}}}}}}}} ) then
		echo "TEST-E-SAFEKILL pid is not a positive int: '$pid'"
		@ scriptstat++
		exit $scriptstat
	endif
	# Special PIDs 0 and 1
	if ( 2 > $pid) then
		echo "TEST-E-SAFEKILL pid has special meaning: '$pid'"
		@ scriptstat++
		exit $scriptstat
	endif
	# KILL is a shell built-in which kills (no pun intended) the script on
	# failure. So we use a subshell to protect the script from the built-in
	# kill. Using built-in kill is simply a fork() whereas using /bin/kill
	# is a fork() and exec().
	(kill $signal $pid)
	if ( $status ) then
		@ scriptstat++
	else
		set killed_pids = ($killed_pids $pid)
	endif
end

unset signal log

exit $scriptstat

#
# PID Length as of 2014.07.30
#
# Linux PIDs go up to 32768 (cat /proc/sys/kernel/pid_max), but the value can
# be raised to 4194304 (2^22) which is seven digits long. So we should be safe
# there.
#
# Solaris
# (http://docs.oracle.com/cd/E19957-01/806-4015/chapter2-107/index.html) can go
# upto 999999 six digits long.
#
# AIX, I know PIDs go up to eight digits long, but I can't seem to find
# anything in their documentation via searches. This command
# 	lsattr -E -l sys0 | grep -i maxuproc
# gives me the max processes per user. This link,
# http://www.unix.com/aix/84085-pid-number-creation-rules-aix.html (which
# references another supporting link), says the the max pid is 2^26, 67108864
# which is 8 digits long.
#
# HPUX (man process_id_max) PIDs are usually set to 30000, but can go up to a
# ridiculous ten digit length 1,073,741,823. Wow! And here I thought I was
# leaving myself room to grow!
#
# Mac OS X, PID_MAX is 999999 (see sys/proc_internal.h)
#
# Windows ... couldn't find an answer
