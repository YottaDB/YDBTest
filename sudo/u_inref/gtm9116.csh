#!/usr/local/bin/tcsh
#################################################################
#								#
# Copyright (c) 2020 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################

echo "# Tests that ydbinstall will install libyottadbutil.so with 755 permissions regardless of what"
echo "# the umask is set to."
# setup of the image environment
mkdir install # the install destination
cd install
# we have to make this folder before hand otherwise the installer will throw out errors
# this happens only when this script is invoked by the test system
# it works fine without permission issues when run as root in an interactive terminal
mkdir gtmsecshrdir
chmod -R 755 .

cp $gtm_tst/$tst/u_inref/gtm9116.sh ..

# Pass "--force-install" to ydbinstall.sh if this is a platform that is not currently offically supported for YottaDB.
source $gtm_tst/$tst/u_inref/setinstalloptions.csh	# sets the variable "installoptions" (e.g. "--force-install" if needed)
sudo sh ../gtm9116.sh $gtm_verno $tst_image `pwd` "$installoptions"

# Verify that libyottadb.so has 755 permissions
#ls -l | grep libyottadbutil.so
$gtm_tst/com/lsminusl.csh libyottadbutil.so | $tst_awk '{print $1,$2,$3,$4,$9,$10,$11}'

# clean up the install directory since the files are owned by root
cd ..
sudo rm -rf install
