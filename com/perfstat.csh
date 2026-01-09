#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2026 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################

# This is a centralized test framework wrapper around "perf stat" calls in the test system.
# It is to handle different output from "perf stat" in case of x86_64 systems with Hybrid CPUs (P-core and E-core).
#
# In a non-hybrid x86_64 CPU system, "perf stat" output looks like the following.
#
#	$ perf stat --log-fd 1 "-x " -e instructions $gtm_exe/mumps -run %XCMD 'halt'
#	4745495  instructions:u 4137087 100.00
#
# In a hybrid x86_64 CPU system, "perf stat" output looks like any one of the following.
#
#	$ perf stat --log-fd 1 "-x " -e instructions $gtm_exe/mumps -run %XCMD 'halt'
#	5056191  cpu_atom/instructions/u 6508228 93.00
#	5819018  cpu_core/instructions/u 443941 6.00
#
#	$ perf stat --log-fd 1 "-x " -e instructions $gtm_exe/mumps -run %XCMD 'halt'
#	5103325  cpu_atom/instructions/u 2175844 100.00
#	<not counted>  cpu_core/instructions/u 0 0.00
#
# There are 2 lines. 1 for "cpu_core" and 1 for "cpu_atom".
# The "cpu_core" lines correspond to P-cores (High Performance cores).
# And the "cpu_atom" lines correspond to E-cores (High Efficiency cores).
# It is possible for either of those lines to say "<not counted>" or "0".
#
# Since E-cores are energy efficient, they disturb the purpose of the caller test which is to check
# the instructions on the high-performance P-cores. Therefore, in this case, we should run something like
# the following to bind the command to only P-cores in order to get results that are repeatable and can be compared.
#
# Towards that, we check "/sys/devices/cpu_core/cpus". If that file exists, this system has Hybrid x86_64 CPUs.
# And the contents of that file correspond to P-cores. In this case let us say CPUs 0 to 15 are those.
# Assuming that, below would be the equivalent command on a hybrid core system to get the needed "perf stat" output.
#
#	$ taskset -c 0-15 perf stat --log-fd 1 "-x " -e cpu_core/instructions/ $gtm_exe/mumps -run %XCMD 'halt'
#	5107145  cpu_core/instructions/u 4927329 100.00
#
# And since "perf stat" is used in the test system in lots of tests, it is better to do this logic in a centralized
# place (to avoid duplication in all callers) and hence this script.

set perfcmd = perf_$$.cmd
if (-e /sys/devices/cpu_core/cpus) then
	# This system contains Hybrid x86_64 cores. Use fancy "perf stat" command with "taskset" to make sure the
	# perf stat is run only on P-cores (cpu_core) and not on E-cores (cpu_atom).
	echo "taskset -c `cat /sys/devices/cpu_core/cpus` perf stat --log-fd 1 "'"-x "'" -e cpu_core/instructions/ $*" > $perfcmd
else
	# This system does not contain Hybrid x86_64 cores. Use simple "perf stat" command.
	echo "perf stat --log-fd 1 "'"-x "'" -e instructions $*" > $perfcmd
endif

source $perfcmd
