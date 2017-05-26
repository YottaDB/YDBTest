#!/usr/local/bin/tcsh -f
#################################################################
#								#
#	Copyright 2013 Fidelity Information Services, Inc	#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################

# use `pwd` instead of $PWD as $PWD does not take into account softlinks of /testarea1, which is reqired to flip
set curdir = `pwd`

# tstdir has only until /testarea1/nars/V998/tst_V998_dbg_01_120716_232431
# restdir multisite_replic_65/start_order (or multisite_replic_65/start_order/instance2)
set tstdir = `echo $curdir | sed 's|\(.*\)\/\(tst_[^/]*\)/.*|\1/\2|'`
set restdir = `echo $curdir | sed 's|\(.*\)\/\(tst_[^/]*\)/\(.*\)|\3|'`
set restdir = `echo $restdir | sed 's/\// /g'`

# testdirs is present in both primary and secondary side. Won't work for multi-host tests.
if (-e $tstdir/testdirs) source $tstdir/testdirs

set goto = $curdir # Just in case noting matches, don't go anywhere
if !($?remote_dir) then
	# This is not a replication test. Don't go anywhere
	exit
endif
# IF this is a remote directory, go to primary directory
echo $curdir | grep $remote_dir >&! /dev/null # BYPASSOK grep
if !($status) then
	set goto = $local_dir
else
	# If this is local directory, goto remote directory
	echo $curdir | grep $local_dir >&! /dev/null # BYPASSOK grep
	if !($status) then
		set goto = $remote_dir
	endif
endif

# Go in as far as possible (if instance2 is in remote path, go upto one directory level above it)
@ i = 1
while ($i <= $#restdir)
	if ( -d $goto/$restdir[$i]) then
		set goto = $goto/$restdir[$i]
	else
		break;
	endif
	@ i = $i + 1
end

# If a parameter is passed, check if instance$1 exists and if so go there
# It is only a convinence and hence no check is made to see if the passed argument is a number or if pwd is local side and we need to go to remote side etc
if ("" != "$1") then
	if ( -d $goto/instance$1) then
		set goto = $goto/instance$1
	endif
endif

if ("echo" == "$1") then
	echo $goto
else
	cd $goto
endif
