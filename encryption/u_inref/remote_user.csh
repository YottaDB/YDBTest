#! /usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2015 Fidelity National Information		#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################

echo "User name          : " `whoami`
echo "Version            : " $1
echo "Image              : " $2
echo "Directory	         : " $3
echo "Test version	 : " $4
echo "GNUPGHOME	         : " $5

source $gtm_com/gtm_cshrc.csh
setenv gtm_tst $4
source $gtm_tst/com/remote_getenv.csh $3
setenv GNUPGHOME $5

version $1 $2
echo $gtm_exe
setenv GTM "$gtm_exe/mumps -direct"
cd $3
setenv gtmgbldir "mumps.gld"

# Now that we have a basic second user setup, set the gtm_passwd to the appropriate value
setenv gtm_passwd `echo $gtmtest1 | $gtm_exe/plugin/gtmcrypt/maskpass | cut -f3 -d" "`

# Now try accessing a global in the current database. This should issue an error
# %GTM-E-CRYPTKEYFETCHFAILED - No read permissions on $GNUPGHOME
$GTM << xyz >&! gtm_output.outx
w ^a(100)
h
xyz

$gtm_tst/com/reset_gpg_agent.csh

cat gtm_output.outx
