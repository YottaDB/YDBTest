#!/usr/local/bin/tcsh -f
#################################################################
#								#
#	Copyright 2005, 2014 Fidelity Information Services, Inc	#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
# sets the current transaction number for all regions
# unless instructed not to (by the environment variable gtm_test_disable_randomdbtn)
# need to transfer the random tn to the secondary as well.

#if it is a GT.CM test, we will disable mupip set version
if ("GT.CM" == $test_gtm_gtcm) exit

# if this script has been run before, the value picked here will be written in settings.csh, so
# let's use that (if it exists)
if (-e settings.csh) then
	# Get only the value of gtm_test_dbcreate_initial_tn from settings.csh. If present tmp.csh will have the setenv command
	# else the file will be null. So no need to check the presence of gtm_test_dbcreate_initial_tn explicitly
	$grep gtm_test_dbcreate_initial_tn settings.csh >&! tmp.csh
	source tmp.csh
	\rm tmp.csh
endif


if ($?gtm_test_disable_randomdbtn) exit

if (! $?gtm_test_dbcreate_initial_tn) then
	if (! $?gtm_test_db_format) then
		#then gtm_test_db_format must have been disabled, i.e. it will be V6
		set max = 64
	else
		if ("V4" == $gtm_test_db_format) then
			set max = 32
		else
			set max = 64
		endif
	endif

	# pick randomly [0,max-1]
	\rm -f rand.o	# In case prior version is being used and rand.o already existed
	set rand = `$gtm_exe/mumps -run rand $max`
	setenv gtm_test_dbcreate_initial_tn $rand
	echo "# gtm_test_dbcreate_initial_tn defined in change_current_tn.csh" 		>>! settings.csh
	echo "setenv gtm_test_dbcreate_initial_tn  $gtm_test_dbcreate_initial_tn" 	>>! settings.csh
	echo ""									 	>>! settings.csh
endif


# now that the current_tn is determined, set it:
set timestamp = `date +%y%m%d_%H%M%S`
set timenow = `date +%H_%M_%S`
set renamecount = 0
# If this script is not called by dbcreate, $rename will not be set. Set it to $timenow then
if !($?rename) set rename = "$timenow"
while ( -e chcurtn.out_$rename)
	@ renamecount++
	set rename = "${timenow}_$renamecount"
end
if (0 == $gtm_test_dbcreate_initial_tn) exit #no need to do anything
# determine list of regions
source $gtm_tst/com/create_reg_list.csh
# need reg_list used here for debugging if problem
if ( -e reg_list.txt )	cp -p reg_list.txt reg_list_$rename
if ( -e chcurtn.out )	cp -p chcurtn.out chcurtn.out_$rename
if ( -e chcurtnc.out )	cp -p chcurtnc.out chcurtnc.out_$rename
if ( -e ddf.out)	cp -p ddf.out ddf.out_$rename
if ( -e chcurtn_c.csh)	cp -p chcurtn_c.csh chcurtn_c.csh_$rename
if ( -e chcurtn_d.csh)	cp -p chcurtn_d.csh chcurtn_d.csh_$rename

$gtm_dist/mumps -run changecurtn >&! chcurtn.out
$tst_tcsh chcurtn_c.csh >& chcurtnc.out
set cstat = $status
if ($cstat) then
	echo "CHANGE_CURRENT_TN-E-ERROR, please check chcurtnc_${timestamp}.out"
	cp chcurtnc.out chcurtnc_${timestamp}.out
endif
$tst_tcsh chcurtn_d.csh >& ddf.out
$tst_awk '/Current transaction/{ctn[$3]++}END{for (i in ctn)x++;if(x!=1)exit 1;}' ddf.out
if ($status) then
	echo "CHANGE_CURRENT_TN-E-MULTIPLE_TNS, it does not look like the transaction numbers were set correctly"
	echo "check chcurtn_${timestamp}.out and ddf_${timestamp}.out"
	cp chcurtn.out chcurtn_${timestamp}.out ; cp ddf.out ddf_${timestamp}.out
	exit 1
endif
