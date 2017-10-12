#################################################################
#								#
# Copyright (c) 2002-2016 Fidelity National Information		#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
#################################################################
#								#
# Copyright (c) 2017 YottaDB LLC. and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
#!/user/local/bin/tcsh -f

# disable random 4-byte collation header in DT leaf block since this test output is sensitive to DT leaf block layout
setenv gtm_dirtree_collhdr_always 1
#
##########################################################################
## Test mupip: if both database and journal or, either one is read_only ##
##########################################################################
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
cp $gtm_tst/$tst/u_inref/chmod.csh $tst_working_dir
$gtm_tst/$tst/u_inref/tstcreate.csh
$gtm_tst/$tst/u_inref/tstbaknj.csh
$gtm_tst/$tst/u_inref/tstbakwj.csh
$gtm_tst/$tst/u_inref/tstexte.csh
$gtm_tst/$tst/u_inref/tstextrnj.csh
$gtm_tst/$tst/u_inref/tstextrnjwfr.csh
$gtm_tst/$tst/u_inref/tstextrwj.csh
$gtm_tst/$tst/u_inref/tstextrwjwfr.csh
$gtm_tst/$tst/u_inref/tstfrez.csh
$gtm_tst/$tst/u_inref/tstintegf.csh
$gtm_tst/$tst/u_inref/tstintegr.csh
$gtm_tst/$tst/u_inref/tstintegtn.csh
$gtm_tst/$tst/u_inref/tstload.csh
$gtm_tst/$tst/u_inref/tstreorgnj.csh
$gtm_tst/$tst/u_inref/tstreorg.csh
$gtm_tst/$tst/u_inref/tstrestore.csh
$gtm_tst/$tst/u_inref/tstrundown.csh
$gtm_tst/$tst/u_inref/tstsetf.csh
$gtm_tst/$tst/u_inref/tstsetr.csh
$gtm_tst/$tst/u_inref/tstjlex.csh
$gtm_tst/$tst/u_inref/tstjlrec.csh
$gtm_tst/$tst/u_inref/tstjlsh.csh
$gtm_tst/$tst/u_inref/tstjlveri.csh

if (-e leftover_ipc_cleanup_if_needed.out) then
	# This test creates read-only databases which could cause a DBRDONLY error from mupip rundown in case it got executed
	# through the leftover_ipc_cleanup_if_needed.csh script. So filter those out as expected.
	$gtm_tst/com/knownerror.csh leftover_ipc_cleanup_if_needed.out "GTM-E-DBRDONLY|GTM-W-MUNOTALLSEC"
endif

##########################################################################
## End ##
##########################################################################
