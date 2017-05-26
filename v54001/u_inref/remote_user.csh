#!/usr/local/bin/tcsh -f
#################################################################
#								#
#	Copyright 2010, 2014 Fidelity Information Services, Inc	#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################

echo "User Name          : " `whoami`
echo "Version            : " $1
echo "Image              : " $2

source $gtm_com/gtm_cshrc.csh
setenv gtm_tst $4
source $gtm_tst/com/remote_getenv.csh $3

version $1 $2
echo $gtm_exe
setenv MUPIP $gtm_exe/mupip
cd $3
setenv gtmgbldir "mumps.gld"

$gtm_tst/com/set_gtmtest1_encr_settings.csh	\
	encr_env_remote_user.csh		\
	$tst_working_dir/mumps.dat		\
	$tst_working_dir/mumps_remote_dat_key	\
	$tst_working_dir/remote_gtmcrypt.cfg	\
	$tst_working_dir/db_remote_mapping_file

source $tst_working_dir/encr_env_remote_user.csh

mkdir ss_tmp
chmod 744 ss_tmp
setenv gtm_snaptmpdir $3/ss_tmp

# The following INTEG are expected to error out with REGSSFAIL error. This means that GT.M will NOT write the before images
# in the snapshot files and hence INTEG could see post-update copies and assert fail in some cases. Set whitebox test case
# to prevent assert
setenv gtm_white_box_test_case_enable 1
setenv gtm_white_box_test_case_number 33
set cntr = 1
# It is possible that a single ONLINE INTEG might come out clean without errors (due to timing). So, run 5 iterations of
# ONLINE INTEG with a hope that at least one of them results in a REGSSFAIL error
while ($cntr <= 10)
	echo "#### Iteration : $cntr ####"
	$DSE all -dump -all >>&! fileheaders.outx
	date
	$MUPIP integ -reg "*" -dbg >&! integ.outx
	$DSE all -dump -all >>&! fileheaders.outx
	cat integ.outx
	sleep 2
	@ cntr = $cntr + 1
end

chmod -R 777 ss_tmp	# Switch back the permissions so that the test framework can access the directory for 'core' file search
			# and move around the directory in case of failure
