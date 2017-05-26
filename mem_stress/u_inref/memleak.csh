#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2002-2016 Fidelity National Information		#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
if ("1" == "$gtm_test_trigger") then
		setenv test_specific_trig_file "$gtm_tst/$tst/u_inref/mem_stress.trg"
	endif
endif

setenv memstrss_rtn memstrss
if ($?gtm_chset) then
	if ("UTF-8" == $gtm_chset) then
		setenv gtm_badchar "no"
		setenv memstrss_rtn umemstrss
	endif
endif

if (($?test_replic) && (! $?gtm_test_replay)) then
	if ($gtm_platform_size == 32) then
		set hardcap = 12	# Use a lower cap on 32-bit machines
	else
		set hardcap = 15	# Use at most 2**32 bytes for each buffer
	endif
	set cap = $hardcap
	# Where possible, base the cap on current free memory levels.
	if (-f /proc/meminfo) then
		# The meminfo lines of interest are:
		#	MemFree:          ###### kB
		#	SwapFree:         ###### kB
		# The test creates three buffers: two journal pools and a receive pool.
		# So divide free memory into four pieces, allowing a piece for the rest of the test, and base the cap on that.
		# awk log() is base e, so divide by log(2) to get base 2.
		# Subtract 18 so we can add $random(18) back below.
		set cap = `$tst_awk 'BEGIN {mf=0;sf=0} ($1 == "MemFree:") {mf=$2} ($1 == "SwapFree:") {sf=$2} END { print int(log((mf+sf)*1024/4)/log(2)-18) }' /proc/meminfo`
	else if (-X svmon) then
		# This is for AIX, where the svmon output looks like:
		#	               size       inuse        free         pin     virtual  available   mmode
		#	memory      7929856     4599144     3330712     2195384     2969212    3848788     Ded
		# See above section for a description of the math.
		set cap = `svmon -G -O unit=KB | $tst_awk '($1 == "memory") {print int(log((int($7))*1024/4)/log(2)-18) }'`
	else if (-x /usr/local/bin/top) then
		# Currently this covers Solaris, but may be used elsewhere as long as the top format looks like:
		# 	Memory: ####M phys mem, ####M free mem, ####M total swap, ####M free swap
		# See above section for a description of the math.
		set cap = `/usr/local/bin/top | $tst_awk '($1 == "Memory:") {print int(log((int($5)+int($11))*1048576/4)/log(2)-18) }'`
	endif
	if ($cap > $hardcap) then
		set cap = $hardcap
	endif
	set buffsize = `$gtm_dist/mumps -run %XCMD 'write (2**($random(18)+'$cap'))'`	# 2**19 to 2**32 inclusive
	setenv tst_buffsize $buffsize
endif
echo "# tst_buffsize defined in memleak.csh" 	>> settings.csh
echo "setenv tst_buffsize $tst_buffsize"	>> settings.csh

source $gtm_tst/com/dbcreate.csh mumps 4 255 16360 16384

$gtm_exe/mumps -run $memstrss_rtn
$gtm_tst/com/dbcheck.csh -extract
