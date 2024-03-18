#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2024 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
#
cat << CAT_EOF | sed 's/^/# /;'
********************************************************************************************
GTM-DE201825 - Test the following release note
********************************************************************************************

Release note (from http://tinco.pair.com/bhaskar/gtm/doc/articles/GTM_V7.0-002_Release_Notes.html#GTM-DE197637999/)

The configure script checks for and removes semstat2, ftok, and geteuid files while installing GT.M in an existing directory
where a GT.M installation already exists. Note that GT.M versions starting from V6.3-014 no longer require these files.
Previously, the configure script did not remove these obsolete executable files.(GTM-DE201825)

CAT_EOF
echo ''

# setup of the image environment
mkdir install # the install destination
cd install
# we have to make this folder before hand otherwise the installer will throw out errors
# this happens only when this script is invoked by the test system
# it works fine without permission issues when run as root in an interactive terminal
mkdir gtmsecshrdir
chmod -R 755 .

cp $gtm_tst/$tst/u_inref/configure_rmfile-gtmde201825.sh  .
source $gtm_tst/$tst/u_inref/setinstalloptions.csh      # sets the variable "installoptions" (e.g. "--force-install" if needed)
# we pass these things as variables to onfigure_rmfile-gtmde201825.sh because it doesn't inherit the tcsh environment variables
$sudostr sh ./configure_rmfile-gtmde201825.sh $gtm_verno $tst_image `pwd` "$installoptions"
# clean up the install directory since the files are owned by root
cd ..
sudo rm -rf install
