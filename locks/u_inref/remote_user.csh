#! /usr/local/bin/tcsh -f
#################################################################
#								#
#	Copyright 2002, 2014 Fidelity Information Services, Inc	#
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
if ( $?gtm_chset ) then
	echo $gtm_chset
else
	echo "gtm_chset is undefined"
endif

locale
version $1 $2
echo $gtm_exe
setenv GTM "$gtm_exe/mumps -direct"
cd $3
setenv gtmgbldir "mumps.gld"

# Generate script (encr_env_remote_user.csh) to be sourced so as to setup encryption environment for
# remote user (gtmtest1)
$gtm_tst/com/set_gtmtest1_encr_settings.csh	\
	encr_env_remote_user.csh		\
	$tst_working_dir/mumps.dat		\
	$tst_working_dir/mumps_remote_dat_key	\
	$tst_working_dir/remote_gtmcrypt.cfg	\
	$tst_working_dir/db_remote_mapping_file

echo "########"
cat << CAT_EOF > lkeinput.csh
#!/usr/local/bin/tcsh -f
source $gtm_tst/com/remote_getenv.csh $3
source $tst_working_dir/encr_env_remote_user.csh
$gtm_dist/lke show -all >&! lke.out
cat lke.out
CAT_EOF

chmod +x lkeinput.csh

source $tst_working_dir/encr_env_remote_user.csh
$GTM << \USER2 >&! gtm_output.out
do ^user2
kill ^child
halt
\USER2
cat gtm_output.out
echo "End of user2 job!"
