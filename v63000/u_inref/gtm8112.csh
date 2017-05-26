#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2015-2016 Fidelity National Information		#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################

# GT.M uses the following non-GT.M Env Vars
#  SHELL        - had an overflow tested below in zsystem
#                 iopi_open uses it without copying it into a local buffer
#                 util_spawn uses it without copying it into a local buffer
#  HOME         - is properly protected in gtmcrypt_pk_ref.c
#  EDITOR       - geteditor malloc()s space for it before copying
#                 op_zedit.c uses it without copying it into a local buffer
#  GNUPGHOME    - had an overflow in gtmcrypt_pk_ref.c tested below
#  PATH         - use in iopi_open is properly guarded
#  TERM         - use in getcaps.c is properly guarded
#                 used without copying it into a local buffer in iott_open.c
# 
# These are GT.M env vars but are different from the usually tested ones
#  GTMXC        - java test group validates this, but callin test group
#  does not
#  GTCM_*       - gvcmy_open, from GT.CM client interface, had an overflow
#                 tested below
# 
#  Generic:
#  op_fnztrnlnm and trans_log_name handle any env var correctly


$gtm_tst/com/dbcreate.csh mumps 1	>&! dbcreate_$$.log

# This caused prior versions to core dump
setenv gtm_etrap 'write:$zstatus["INVSTRLEN" "PASS INVSTRLEN in zsystem",\! zhalt +$zstatus'
$gtm_dist/mumps -run %XCMD 'set x=$&gtmposix.setenv("SHELL",$justify($ztrnlnm("SHELL"),5000),1,.errno) zsystem "echo should not get here"'
# This fits inside the buffer, so it works " -c 'echo PASS SHELL'" is 21 bytes
$gtm_dist/mumps -run %XCMD 'set x=$&gtmposix.setenv("SHELL",$justify($ztrnlnm("SHELL"),4075),1,.errno) zsystem "echo PASS SHELL"'

# This causes prior versions to core dump in the child
setenv gtm_etrap 'write:$zstatus["ZGBLDIR" "PASS GTMGBLDIR in JOB",\! zhalt +$zstatus'
$gtm_dist/mumps -run %XCMD 'write "setenv gtmgbldir """,$tr($justify($zgbldir,256)," ","/"),"""",!' 	>& 2longgld.csh
(source 2longgld.csh ; $gtm_dist/mumps -run %XCMD 'job ^%XCMD:(cmdline="zwr $zgbldir zwr ^a":output="zgbldir":error="zgbldir")')
$gtm_tst/com/wait_for_log.csh -log zgbldir -message "PASS" -duration 30 -grep
# This shows that $zgbldir is sent across and not $gtmgbldir - GTM-8512
(source 2longgld.csh ; $gtm_dist/mumps -run %XCMD 'set $zgbldir="mumps.gld" job ^%XCMD:(cmdline="set ^a=$job write ""PASS ZGBLDIR in JOB"",!":output="zgbldir":error="zgbldir")')
$gtm_tst/com/wait_for_log.csh -log zgbldir -message "PASS" -duration 30 -grep
set pid = `$gtm_dist/mumps -run %XCMD 'write ^a'`
$gtm_tst/com/wait_for_proc_to_die.csh $pid 300

if ("ENCRYPT" == "$test_encryption") then
	# This causes prior versions to core dump during encryption initialization
	setenv gtm_etrap 'write:$zstatus["CRYPTINIT" "PASS GNUPGHOME",\! zhalt +$zstatus'
	$gtm_dist/mumps -run %XCMD 'set x=$&gtmposix.setenv("GNUPGHOME",$justify($ztrnlnm("GNUPGHOME"),5000),1,.errno) kill ^a write "how did we get here? Shoulda errored out",!'
endif
$gtm_tst/com/dbcheck.csh		>&! dbcheck_$$.log

# This caused prior versions to core dump
cp mumps.gld{,.save}
$GDE change -segment DEFAULT -file=SOMEFAKENAME:$PWD/mumps.gld										>& fakegtcm.out
$gtm_dist/mumps -run %XCMD 'write "setenv GTCM_SOMEFAKENAME """,$justify("[fdfb:26dc:b4f1:300:00:00:af3:81cd]:65536",258),"""",!'	>& somefake.csh
setenv gtm_etrap 'write:$zstatus["LOGTOOLONG" "PASS LOGTOOLONG in GT.CM",\! zhalt +$zstatus'
(source somefake.csh ; $gtm_dist/mumps -run %XCMD 'set ^a=1')

