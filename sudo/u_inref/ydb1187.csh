#!/usr/local/bin/tcsh
#################################################################
#                                                               #
# Copyright (c) 2022 YottaDB LLC and/or its subsidiaries.       #
# All rights reserved.                                          #
#                                                               #
#       This source code contains the intellectual property     #
#       of its copyright holder(s), and is made available       #
#       under a license.  If you do not know the terms of       #
#       the license, please stop and do not read further.       #
#                                                               #
#################################################################

echo "# Tests that ydbinstall/ydbinstall.sh does not create or update /usr/share/pkgconfig/yottadb.pc"
echo "# with the --nopkg-config command line option."

# setup of the image environment
mkdir install # the install destination
cd install
# we have to make this folder before hand otherwise the installer will throw out errors
# this happens only when this script is invoked by the test system
# it works fine without permission issues when run as root in an interactive terminal
mkdir gtmsecshrdir
chmod -R 755 .

cp $gtm_tst/$tst/u_inref/ydb1187.sh  .
# we pass these things as variables to ydb306.sh because it doesn't inherit the tcsh environment variables
source $gtm_tst/$tst/u_inref/setinstalloptions.csh      # sets the variable "installoptions" (e.g. "--force-install" if needed)
$sudostr sh ./ydb1187.sh $gtm_verno $tst_image `pwd` "$installoptions"

# run a few yottadb commands to test the install works
cat >> ../yottadbTest.txt << xx
write \$zyrel
write \$zreldate
set a="Hello,"
set a(1)="World!"
zwrite a
h
xx
`pwd`/yottadb -direct < ../yottadbTest.txt

# clean up the install directory since the files are owned by root
cd ..
sudo rm -rf install

