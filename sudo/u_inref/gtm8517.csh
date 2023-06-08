#!/usr/local/bin/tcsh
#################################################################
#                                                               #
# Copyright (c) 2023 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.                                          #
#                                                               #
#       This source code contains the intellectual property     #
#       of its copyright holder(s), and is made available       #
#       under a license.  If you do not know the terms of       #
#       the license, please stop and do not read further.       #
#                                                               #
#################################################################
#
echo
echo '# GTM-8517: Tests that ydbinstall creates install_{permissions,sha256_checksum}.log files that are non-zero size'
echo
echo '# Setup for install of YottaDB'
#
# Setup of the image environment
mkdir install # the install destination
cd install
# We have to make this folder before hand otherwise the installer will throw out errors. This happens
# only when this script is invoked by the test system. It works fine without permission issues when
# run as root in an interactive terminal.
mkdir gtmsecshrdir
chmod -R 755 .
cp $gtm_tst/$tst/u_inref/gtm8517.sh  .
# We pass these things as variables to gtm8517.sh because it doesn't inherit the tcsh environment variables
source $gtm_tst/$tst/u_inref/setinstalloptions.csh      # Sets the variable "installoptions" (e.g. "--force-install" if needed)
echo
echo '# Installation of current version to verify creates permission and checksum logs of all files in distro'
# Note that we pipe this to a log file as the install output is not deterministic in the quantify or contents
# of messages. See the install.log file for output to compare installs from versions.
$sudostr sh ./gtm8517.sh $gtm_verno $tst_image `pwd` "$installoptions" >& install.log
$grep -E "YottaDB version r.* installed successfully at" install.log
set savestatus = $status
if (0 != $savestatus) then
    echo "Failure in version installation (rc = $savestatus) - see install.log"
endif
#
echo
echo '# Verify the log files were created'
ls -1 install_*.log
cp install*.log .. # Copy files to test directory (including install.log this time)
set fail = 0
foreach file (install_permissions.log install_sha256_checksum.log)
    if (! -e $file) then
	echo "FAIL - file $file was not found"
	set fail = 1
    else if (-z $file) then
	echo "FAIL - file $file has a 0 length"
	set fail = 1
	endif
    endif
end
if (0 == $fail) then
    echo 'PASS - Both installation log files are non-zero'
endif
#
echo
echo '# Remove installed version (cleanup)'
# Clean up the install directory since the files are owned by root
cd ..
sudo rm -rf install
