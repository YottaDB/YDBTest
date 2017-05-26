#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2006-2015 Fidelity National Information 	#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
# Usage:
# $MSR RUN SRC=INST1 RCV=$cur_ins '$gtm_tst/com/cp_remote_file.csh _REMOTEINFO___RCV_DIR__/'$cur_ins'_${extract_time}.glo __SRC_DIR__/'
# $gtm_tst/com/cp_remote_file.csh _REMOTEINFO_$SEC_SIDE/restore_sec.log .
# $cprcp mumps.repl $sec_SIDE/mumps.repl.primary
#
# _REMOTEINFO_ will be replaced with the actual host: information

if ($?inside_multisite_replic) then
	echo "TEST-E-ERROR unnecessary/incorrect call to cp_remote_file, please check usage at multisite_replic.csh"
	exit 1
endif
if ( $tst_now_primary != $tst_now_secondary ) then
	setenv cpremote "$rcp"
	setenv remoteinfo "${tst_now_secondary:r:r:r:r}:"
else
	setenv cpremote cp
	setenv remoteinfo ""
endif

#$MSR RUN SRC=INST1 RCV=$cur_ins "set msr_dont_trace;$cpremote ${remoteinfo}__RCV_DIR__/$cur_ins_${extract_time}.glo __SRC_DIR__/"
if ( "$argv" !~ "*_REMOTEINFO_*" ) then
	# If _REMOTEINFO_ is not passed, assume the destination to be the remote side
	set arguments = `echo $argv | sed 's|'$argv[$#argv]'|'$remoteinfo''$argv[$#argv]'|'`
else
	set arguments = `echo $argv | sed 's|_REMOTEINFO_|'$remoteinfo'|g'`
endif

$cpremote $arguments
