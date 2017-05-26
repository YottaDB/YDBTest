#!/usr/local/bin/tcsh
#################################################################
#								#
# Copyright (c) 2005-2016 Fidelity National Information		#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
#
# check GTM MUPIP DSE utils with versions provided by the caller.
#
##############################################################################################
# the script accepts three arguments. first argument specifies gld version , second argument #
# specifies the db version and third argument specifies the version to test.                 #
# if called with just one argument it will upgrade the db from v4 to v5			     #
##############################################################################################
#
if ( "upgrade" == $1 ) then
	# switch to v4 version to conduct dbcertify followed by upgrade procedures
	$sv4
	$DSE change -file -reserved_bytes=8
	# run dbcertify both phases & upgrade it to V5
	#scan phase
	$DBCERTIFY scan -outfile=dbcertify_scanreport.scan DEFAULT
	if ($status) then
        	echo "TEST-E-ERROR. scan phase failed for the chosen V4 version"
	endif
	#certify phase
	$DBCERTIFY certify dbcertify_scanreport.scan < yes.txt >>&! dbcertify_scanreport.out
	if ($status) then
        	echo "TEST-E-ERROR. certify phase failed for the chosen V4 version"
	else
		$grep "DBCDBCERTIFIED" dbcertify_scanreport.out
	endif
	$MUPIPV5 upgrade mumps.dat < yes.txt
	if ($status) then
		echo "TEST-E-ERROR. upgrade failed for the chosen V4 version"
	else
		echo "databse upgraded to V5 now"
	endif
else
# copy the respective version's gld & db
	\cp mumps_$1.gld mumps.gld
	\cp mumps_$2.dat mumps.dat
	#
	# switch to the version to test
	source $gtm_tst/com/switch_gtm_version.csh $3 $tst_image
	#
	setenv dbver $2
	echo ""
	echo "vermismatch test -- $1 GLD, $2 DB and $3 version being tested"
	echo ""
	# access the utilities GT.M, MUPIP, DSE.
	$GTM << gtm_eof
	write "global set attempted on a ",\$ztrnlnm("dbver")," database. should error out"
	write ^a=10
	halt
gtm_eof

	echo "mupip extract attempted on a $2 database. should error out"
	$MUPIP extract -nolog fi.glo
	if ( 0 == $status ) then
		echo "TEST-E-ERROR. extarct expected to fail, but didn't"
	else
		rm -f fi.glo
	endif
	echo "dse dump attempted on a $2 database. should error out"
	$DSE dump -fileheader
	if ( 0 == $status ) then
		echo "TEST-E-ERROR. dse dump expected to fail, but didn't"
	endif
	# If check_util.csh is being invoked with a V5 gld and current version (not $v4ver) then we we would have
	# gotten a BADDBVER error above. In that case, do rundown to clean up the ftok semaphore left around.
	if (($1 == "v5") && ($3 == "$tst_ver")) then
		echo "Clean up ftok semaphore which will be left around from the BADDBVER errors above to avoid MUSTANDALONE errors later"
		$MUPIP rundown -reg DEFAULT
	endif
endif
#

