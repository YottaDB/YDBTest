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
#
###     db_extract <extract_file_name> <0|1>
# Arg1 : Name of the extract file (and the root name of trigger extract file if done)
# Arg2 : Should trigger extract be done
#
if ($1 == "") then
	echo "TEST-E-DB_EXTRACT, MUPIP extract destination file not defined"
	exit 1
endif

# Different ICU versions can have different printout because different codepoint may
# be considered valid or not by each ICU versions.  To ensure database extract for the
# same data will be printed the same on multi-machine tests, use M mode for that task.
if ($?test_replic) then
	if ("MULTISITE" == $test_replic) then
		setenv gtm_chset "M"
	endif
endif
# This second if is for those test manually setting up multisite.
if (($?tst_org_host) && ($?tst_remote_host)) then
	if ($tst_org_host != $tst_remote_host) then
		setenv gtm_chset "M"
	endif
endif
\rm -f rf_extr.tmp rf_extr.out

if ("1" == "$2") then
	# Extract trigger
	set trigextr = ${1:r}.trg
	$MUPIP trigger -select ${trigextr}.tmp
	sed 's/ cycle: [0-9]*/ cycle: X/' ${trigextr}.tmp >&! $trigextr
	\rm -f ${trigextr}.tmp
endif

$GTM << \emptytest >>&! emptyfiletest.log
s a=$order(^%)
i $l(a)=0  s f="rf_extr.tmp"  o f  u f  w !,"EMPTY DATABASE(S)",!  c f
h
\emptytest

if (-f rf_extr.tmp) then
	mv rf_extr.tmp $1
	exit 0
endif
if ($gtm_test_repl_norepl >= 1) then
	source $gtm_tst/com/leftover_ipc_cleanup_if_needed.csh $0 h.dat # do rundown if needed before renaming h.dat
	set cur_time = `date +%H_%M_%S`
	\mv h.dat h_${cur_time}.dat
	# If gtm_test_repl_norepl is set, then HREG is not replicated (see SRC.csh and RCVR.csh). This means,
	# any updates happening on HREG on the primary side will not be replicated across to the secondary.
	# This would cause the primary and secondary to be out-of-sync. To avoid RF_EXTR.csh from failing
	# because of this out-of-sync issue, create an EMPTY HREG database (after moving the orignal h.dat)
	# on both primary and secondary so that database extract will PASS.
	$MUPIP create -reg=HREG
endif

$MUPIP extract -nolog rf_extr.tmp >>& rf_extr.out
if ($status) then
	echo "TEST-E-DB_EXTRACT, MUPIP extract failed"
	cat rf_extr.out
	exit 1
endif
if (-f rf_extr.tmp) then
	$tail -n +3  rf_extr.tmp >! $1
	exit 0
else
	echo "TEST-E-DB_EXTRACT, No extracts"
	exit 1
endif
