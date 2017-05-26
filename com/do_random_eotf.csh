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

# This is a helper script that randomly enables encryption on the fly for a few select tests

# $gtm_test_do_eotf	- determines whether the background reorg -encrypt job has to be started by dbcreate.csh
# $gtm_test_eotf_keys	- determines the number of database-key pairs needs to be generated per db by create_key_file.csh

if ($?gtm_test_eotf_keys) then
	set keycount = $gtm_test_eotf_keys
else
	set keycount = 3 # Should this be random?
endif

if ($?gtm_test_do_eotf) then
	# gtm_test_do_eotf already set.
	if (! $?gtm_test_eotf_keys) then
		# If gtm_test_do_eotf is set but gtm_test_eotf_keys is not, set it.
		setenv gtm_test_eotf_keys $keycount
	endif
	exit
endif
if (! $?gtm_test_eotf_keys) then
	setenv gtm_test_eotf_keys 0
endif
setenv gtm_test_do_eotf 0

if (! $?test_encryption) then
	# encryption not set, cannot set encryption on the fly
	exit
endif

if ("NON_ENCRYPT" == "$test_encryption") then
	# cannot set encryption on the fly if non-encrypt is chosen
	exit
endif


set eotf_always = ""
set eotf_random = " overflow mem_stress reorg "

set dorand = `date | $tst_awk '{srand() ; print (int(rand() * 100) + 1 )}'`

if ( "$eotf_always" =~ "* $tst *" ) then
	setenv gtm_test_eotf_keys $keycount
else if ( "$eotf_random" =~ "* $tst *" ) then
	if ( 50 < $dorand ) then
		setenv gtm_test_do_eotf 1
		setenv gtm_test_eotf_keys $keycount
	endif
endif
