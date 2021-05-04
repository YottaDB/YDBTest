#!/usr/local/bin/tcsh
#################################################################
#                                                               #
# Copyright (c) 2020-2021 YottaDB LLC and/or its subsidiaries.       #
# All rights reserved.                                          #
#                                                               #
#       This source code contains the intellectual property     #
#       of its copyright holder(s), and is made available       #
#       under a license.  If you do not know the terms of       #
#       the license, please stop and do not read further.       #
#                                                               #
#################################################################
#Tests that ydbinstall will not give an error when run with --zlib and --utf8 default

# setup of the image environment
mkdir install # the install destination
cd install
# we have to make this folder before hand otherwise the installer will throw out errors
# this happens only when this script is invoked by the test system
# it works fine without permission issues when run as root in an interactive terminal
mkdir gtmsecshrdir
chmod -R 755 .

cp $gtm_tst/$tst/u_inref/ydb306.sh  .
# we pass these things as variables to ydb306.sh because it doesn't inherit the tcsh environment variables
source $gtm_tst/$tst/u_inref/setinstalloptions.csh      # sets the variable "installoptions" (e.g. "--force-install" if needed)
sudo sh ./ydb306.sh $gtm_verno $tst_image `pwd` "$installoptions"

# Set chset to UTF-8 to verify that UTF-8 install done in the previous step works fine.
# "$switch_chset" requires us to be in the test output directory so cd back from "install" subdirectory for this step.
cd ..
$switch_chset "UTF-8"
# Switch back to "install" subdirectory now that "$switch_chset" is done.
cd install

# run a few yottadb commands to test the install works and UTF-8 is being used
cat >> ../yottadbTest.txt << xx
write \$zyrel
write \$zreldate
set a="Hello,"
set a(1)="World!"
zwrite a
write \$zchset
h
xx
`pwd`/yottadb -direct < ../yottadbTest.txt

# clean up the install directory since the files are owned by root
cd ..
sudo rm -rf install

