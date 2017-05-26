#!/usr/local/bin/tcsh -f
#################################################################
#								#
#	Copyright 2006, 2013 Fidelity Information Services, Inc	#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################


# Basic preparation for the test
source $gtm_tst/$tst/u_inref/endiancvt_prepare.csh
cat << EOF

## Foreach tn (0, 4G-128M, 4G, 4G+128M)
##   Create a V5 database
##   DSE change -file -curr=<tn>
##   Populate the database
##   mupip endiancvt mumps.dat
##   copy mumps.dat to the other endian machine
##   In the remote machine
##    MUPIP INTEG REG *
##    Repeat the same updates on the converted database
##    MUPIP INTEG REG *
##    dbcheck
## end

EOF

# 4G  = FFFFFFFF
# 128M = 7FFFFFF
# 4G-128M = F8000000
# 4G+128M = 108000000
foreach tn ( 1 F8000000 FFFFFFFF 108000000)
	echo "# Transaction Number : $tn"
	source $gtm_tst/com/bakrestore_test_replic.csh
	$gtm_tst/com/dbcreate.csh mumps $coll_arg
	source $gtm_tst/com/bakrestore_test_replic.csh
	$sec_shell "$sec_getenv; cd $SEC_SIDE;source coll_env.csh 1; source $gtm_tst/com/bakrestore_test_replic.csh; $gtm_tst/com/dbcreate_base.csh mumps $coll_arg ; source $gtm_tst/com/bakrestore_test_replic.csh"
	echo "# Set the transaction number to $tn"
	$DSE change -fileheader -current_tn=$tn
	echo "# Populate the databse"
	$gtm_exe/mumps -run populate
	source $gtm_tst/com/bakrestore_test_replic.csh
	$gtm_tst/com/dbcheck.csh
	source $gtm_tst/com/bakrestore_test_replic.csh
	echo "# Endian convert the database"
	$MUPIP endiancvt mumps.dat < yes.txt
	echo "# Copy the converted database to the remote machine, do the same updates and do an integ/application check"
	$rcp mumps.dat "$tst_remote_host":$SEC_SIDE/mumps.dat
	$sec_shell "$sec_getenv; cd $SEC_SIDE;source coll_env.csh 1; $gtm_tst/$tst/u_inref/cvt_integchk.csh"
	mkdir bak_$tn ; mv mumps.* bak_$tn
	$sec_shell "$sec_getenv; cd $SEC_SIDE; mkdir bak_$tn ; mv mumps.* bak_$tn"
	echo ""
	echo "#######################################################################"
	echo ""
end
