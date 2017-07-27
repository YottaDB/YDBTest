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
##########################################################################
## Test mupip: if both database and journal or, either one is read_only ##
##########################################################################
# If spanning regions is chosen, pick a static spanning regions gde configuration since
# the test reference file relies on the actual layout of the global nodes
if ((1 == $gtm_test_spanreg) || (3 == $gtm_test_spanreg)) then
	set colno = 0
	if ($?test_collation_no) then
		set colno = $test_collation_no
	endif
	setenv test_specific_gde $gtm_tst/$tst/inref/multireg_col${colno}.gde
endif
setenv gtm_test_spanreg 0	# We have already pointed test_specific_gde for spanning regions cases
cp $gtm_tst/$tst/u_inref/load.go* $tst_working_dir
if ($?gtm_chset) then
	if ($gtm_chset == "UTF-8") then
		pushd $tst_working_dir >& /dev/null
		foreach file (load.go*)
			mv $file $file.tmp
			sed 's/GT.M MUPIP EXTRACT/& UTF-8/g' $file.tmp > $file
		end
		popd >& /dev/null
	endif
endif
cp $gtm_tst/$tst/u_inref/ipcmanage $tst_working_dir
cp $gtm_tst/$tst/u_inref/mipcmanage $tst_working_dir
cp $gtm_tst/$tst/u_inref/lsmumps $tst_working_dir
cp $gtm_tst/$tst/u_inref/res $tst_working_dir
cp $gtm_tst/$tst/u_inref/chmod.csh $tst_working_dir
$gtm_tst/$tst/u_inref/tstmbaknj.csh 4
$gtm_tst/$tst/u_inref/tstmbakwj.csh 4
$gtm_tst/$tst/u_inref/tstmexte.csh 4
$gtm_tst/$tst/u_inref/tstmextrnj.csh 4
$gtm_tst/$tst/u_inref/tstmextrnjwfr.csh 4
$gtm_tst/$tst/u_inref/tstmextrwj.csh 4
$gtm_tst/$tst/u_inref/tstmextrwjwfr.csh 4
$gtm_tst/$tst/u_inref/tstmfrez.csh 4
$gtm_tst/$tst/u_inref/tstmintegr.csh 4
$gtm_tst/$tst/u_inref/tstmintegtn.csh 4
$gtm_tst/$tst/u_inref/tstmload.csh 4
$gtm_tst/$tst/u_inref/tstmreorgnj.csh 4
$gtm_tst/$tst/u_inref/tstmreorg.csh 4
$gtm_tst/$tst/u_inref/tstmrestore.csh 4
$gtm_tst/$tst/u_inref/tstmrundown.csh 4
$gtm_tst/$tst/u_inref/tstmsetr.csh 4
#$gtm_tst/$tst/u_inref/tstmsetf.csh 4
$gtm_tst/$tst/u_inref/tstmjlex.csh 4
$gtm_tst/$tst/u_inref/tstmjlrec.csh 4
$gtm_tst/$tst/u_inref/tstmjlsh.csh 4
$gtm_tst/$tst/u_inref/tstmjlveri.csh 4

if (-e leftover_ipc_cleanup_if_needed.out) then
	# This test creates read-only databases which could cause a DBRDONLY error from mupip rundown in case it got executed
	# through the leftover_ipc_cleanup_if_needed.csh script. So filter those out as expected.
	$gtm_tst/com/knownerror.csh leftover_ipc_cleanup_if_needed.out "GTM-E-DBRDONLY|GTM-W-MUNOTALLSEC"
endif

##########################################################################
## End ##
##########################################################################

